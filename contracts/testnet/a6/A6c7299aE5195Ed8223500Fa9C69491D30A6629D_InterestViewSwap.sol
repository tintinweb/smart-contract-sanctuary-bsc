// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./interfaces/IERC20.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IPair.sol";

import "./DataTypes.sol";

interface InterestViewBalancesInterface {
    function getUserBalances(address account, address[] calldata tokens)
        external
        view
        returns (uint256 nativeBalance, uint256[] memory balances);

    function getUserBalanceAndAllowance(
        address user,
        address spender,
        address token
    ) external view returns (uint256 allowance, uint256 balance);

    function getUserBalancesAndAllowances(
        address user,
        address spender,
        address[] calldata tokens
    )
        external
        view
        returns (uint256[] memory allowances, uint256[] memory balances);
}

struct ERC20Metadata {
    string name;
    string symbol;
    uint256 decimals;
}

struct PairMetadata {
    ERC20Metadata token0Metadata;
    ERC20Metadata token1Metadata;
    address token0;
    address token1;
    bool isStable;
    uint256 reserve0;
    uint256 reserve1;
}

contract InterestViewSwap {
    IFactory private immutable factory;
    IRouter private immutable router;
    InterestViewBalancesInterface private immutable viewBalances;

    constructor(IRouter _router, InterestViewBalancesInterface _viewBalances) {
        router = _router;
        factory = IFactory(_router.factory());
        viewBalances = _viewBalances;
    }

    function getERC20Metadata(IERC20 token)
        public
        view
        returns (ERC20Metadata memory)
    {
        string memory name = token.name();
        string memory symbol = token.symbol();
        uint256 decimals = token.decimals();

        return ERC20Metadata(name, symbol, decimals);
    }

    function getPairData(IPair pair, address account)
        external
        view
        returns (
            PairMetadata memory pairMetadata,
            uint256[] memory allowances,
            uint256[] memory balances
        )
    {
        if (factory.isPair(address(pair))) {
            (
                address t0,
                address t1,
                bool isStable,
                ,
                uint256 r0,
                uint256 r1,
                ,

            ) = pair.metadata();

            pairMetadata = PairMetadata(
                getERC20Metadata(IERC20(t0)),
                getERC20Metadata(IERC20(t1)),
                t0,
                t1,
                isStable,
                r0,
                r1
            );

            address[] memory tokens = new address[](3);
            tokens[0] = address(pair);
            tokens[1] = t0;
            tokens[2] = t1;

            (allowances, balances) = viewBalances.getUserBalancesAndAllowances(
                account,
                address(router),
                tokens
            );
        }
    }

    function getAmountsOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address[] calldata bases
    ) external view returns (address base, uint256 amountOut) {
        Amount memory amountStruct = router.getAmountOut(
            amountIn,
            tokenIn,
            tokenOut
        );

        amountOut = amountStruct.amount;

        for (uint256 i; i < bases.length; i++) {
            address _base = bases[i];

            Route[] memory route = new Route[](2);

            route[0] = Route({from: tokenIn, to: _base});
            route[1] = Route({from: _base, to: tokenOut});

            Amount[] memory amounts = router.getAmountsOut(amountIn, route);
            if (amounts.length < 3) continue;
            uint256 _amount = amounts[amounts.length - 1].amount;

            if (_amount > amountOut) {
                amountOut = _amount;
                base = _base;
            }
        }
    }

    function getAmountsIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address[] calldata bases
    ) external view returns (address base, uint256 amountOut) {
        (address volatilePair, address stablePair) = router.getPairs(
            tokenIn,
            tokenOut
        );
        Amount memory amountStruct = _getWorstAmount(
            tokenIn,
            amountIn,
            stablePair,
            volatilePair
        );

        amountOut = amountStruct.amount;

        for (uint256 i; i < bases.length; i++) {
            address _base = bases[i];

            Route[] memory route = new Route[](2);

            route[0] = Route({from: tokenIn, to: _base});
            route[1] = Route({from: _base, to: tokenOut});

            Amount[] memory amounts = _getAmountsIn(amountIn, route);
            if (amounts.length < 3) continue;
            uint256 _amount = amounts[amounts.length - 1].amount;

            if (_amount > amountOut) {
                amountOut = _amount;
                base = _base;
            }
        }
    }

    function _getAmountsIn(uint256 amount, Route[] memory routes)
        private
        view
        returns (Amount[] memory amounts)
    {
        unchecked {
            amounts = new Amount[](routes.length + 1);

            amounts[0] = Amount(amount, false);

            for (uint256 i; i < routes.length; i++) {
                (address volatilePair, address stablePair) = router.getPairs(
                    routes[i].from,
                    routes[i].to
                );

                if (
                    IFactory(factory).isPair(volatilePair) ||
                    IFactory(factory).isPair(stablePair)
                ) {
                    amounts[i + 1] = _getWorstAmount(
                        routes[i].from,
                        amounts[i].amount,
                        stablePair,
                        volatilePair
                    );
                }
            }
        }
    }

    function _getWorstAmount(
        address tokenIn,
        uint256 amountIn,
        address stablePair,
        address volatilePair
    ) private view returns (Amount memory) {
        uint256 amountStable;
        uint256 amountVolatile;

        if (IFactory(factory).isPair(stablePair)) {
            (bool success, bytes memory data) = stablePair.staticcall(
                abi.encodeWithSelector(
                    IPair.getAmountOut.selector,
                    tokenIn,
                    amountIn
                )
            );

            if (success && data.length == 32)
                amountStable = abi.decode(data, (uint256));
        }

        if (IFactory(factory).isPair(volatilePair)) {
            (bool success, bytes memory data) = volatilePair.staticcall(
                abi.encodeWithSelector(
                    IPair.getAmountOut.selector,
                    tokenIn,
                    amountIn
                )
            );

            if (success && data.length == 32)
                amountVolatile = abi.decode(data, (uint256));
        }

        return
            amountStable < amountVolatile
                ? Amount(amountStable, true)
                : Amount(amountVolatile, false);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        bool stable,
        address pair,
        uint256
    );

    event NewTreasury(address indexed oldTreasury, address indexed newTreasury);

    event NewGovernor(address indexed oldGovernor, address indexed newGovernor);

    function feeTo() external view returns (address);

    function governor() external view returns (address);

    function allPairs(uint256) external view returns (address);

    function isPair(address pair) external view returns (bool);

    function getPair(
        address tokenA,
        address token,
        bool stable
    ) external view returns (address);

    function allPairsLength() external view returns (uint256);

    function pairCodeHash() external pure returns (bytes32);

    function getInitializable()
        external
        view
        returns (
            address,
            address,
            bool
        );

    function createPair(
        address tokenA,
        address tokenB,
        bool stable
    ) external returns (address pair);

    function setFeeTo(address _feeTo) external;

    function setGovernor(address _governor) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import {Amount, Route} from "../DataTypes.sol";

import "./IWNT.sol";

interface IRouter {
    function factory() external view returns (address);

    //solhint-disable-next-line func-name-mixedcase
    function WNT() external view returns (IWNT);

    function sortTokens(address tokenA, address tokenB)
        external
        pure
        returns (address token0, address token1);

    function pairFor(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (address pair);

    function getPairs(address tokenA, address tokenB)
        external
        view
        returns (address volatilePair, address stablePair);

    function getAmountsOut(uint256 amount, Route[] memory routes)
        external
        view
        returns (Amount[] memory amounts);

    function getReserves(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (uint256 reserveA, uint256 reserveB);

    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (Amount memory amount);

    function isPair(address pair) external view returns (bool);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired
    )
        external
        view
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity
    ) external view returns (uint256 amountA, uint256 amountB);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
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

    function addLiquidityNativeToken(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountNativeTokenMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountNativeToken,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityNativeToken(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountNativeTokenMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountNativeToken);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        bool stable,
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

    function removeLiquidityNativeTokenWithPermit(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountNativeTokenMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountNativeToken);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (Amount[] memory amounts);

    function swapExactNativeTokenForTokens(
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external payable returns (Amount[] memory amounts);

    function swapExactTokensForNativeToken(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (Amount[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import {Observation} from "../DataTypes.sol";

import "./IERC20.sol";

interface IPair is IERC20 {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    event Sync(uint256 reserve0, uint256 reserve1);

    function stable() external view returns (bool);

    function nonces(address) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function observations(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function reserve0() external view returns (uint256);

    function reserve1() external view returns (uint256);

    function blockTimestampLast() external view returns (uint256);

    function reserve0CumulativeLast() external view returns (uint256);

    function reserve1CumulativeLast() external view returns (uint256);

    function observationLength() external view returns (uint256);

    function getFirstObservationInWindow()
        external
        view
        returns (Observation memory);

    function observationIndexOf(uint256 timestamp)
        external
        pure
        returns (uint256 index);

    function metadata()
        external
        view
        returns (
            address t0,
            address t1,
            bool st,
            uint256 fee,
            uint256 r0,
            uint256 r1,
            uint256 dec0,
            uint256 dec1
        );

    function tokens() external view returns (address, address);

    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getTokenPrice(address tokenIn, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function currentCumulativeReserves()
        external
        view
        returns (
            uint256 reserve0Cumulative,
            uint256 reserve1Cumulative,
            uint256 blockTimestamp
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function getAmountOut(address, uint256) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

struct Observation {
    uint256 timestamp;
    uint256 reserve0Cumulative;
    uint256 reserve1Cumulative;
}

struct Route {
    address from;
    address to;
}

struct Amount {
    uint256 amount;
    bool stable;
}

struct InitData {
    address token0;
    address token1;
    bool stable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./IERC20.sol";

/// @notice IWNT stands for Wrapped Native Token Interface
interface IWNT is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}