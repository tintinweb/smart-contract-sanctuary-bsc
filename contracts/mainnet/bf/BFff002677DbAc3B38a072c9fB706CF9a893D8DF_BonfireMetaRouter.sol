// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import "../strategies/IBonfireStrategyAccumulator.sol";
import "../swap/IBonfireMetaRouter.sol";
import "../swap/IBonfirePair.sol";
import "../swap/IBonfireRouter.sol";
import "../swap/IBonfireRouterPaths.sol";
import "../token/IBonfireProxyTokenVisibleReflection.sol";
import "../token/IBonfireTokenWrapper.sol";
import "../token/IBonfireTokenTracker.sol";
import "../token/IMultichainToken.sol";
import "../utils/BonfireTokenHelper.sol";
import "../utils/ITransferLogbook.sol";

contract BonfireMetaRouter is IBonfireMetaRouter, Ownable {
    using SafeERC20 for IERC20;

    address public constant override WETH =
        address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public constant override tracker =
        address(0xBFac04803249F4C14f5d96427DA22a814063A5E1);
    address public constant override logbook =
        address(0xBFba947785e8fd9251585806b50301b17F12D095);
    address public constant override wrapper =
        address(0xBFeb131436219d69c3DC6FAf325c4E4330D9A7b0);
    address public constant defaultToken =
        address(0x5e90253fbae4Dab78aa351f4E6fed08A64AB5590);

    event AccumulatorUpdate(
        address _accumulator,
        uint256 _defaultWETHThreshold,
        uint256 _maxAccumulationCount
    );
    event PathsUpdate(address _path);

    address public override paths;
    address public accumulator;
    uint256 public defaultWETHThreshold;
    uint256 public maxAccumulationCount;

    constructor(
        address admin
    ) Ownable() {
        transferOwnership(admin);
    }

    function setPathsContract(address pathsContract) external onlyOwner {
        paths = pathsContract;
        emit PathsUpdate(paths);
    }

    function transferToken(
        address from,
        address to,
        address token,
        uint256 amount,
        address bonusTo,
        uint256 bonusThreshold,
        uint256 bonusMaxCount
    ) external {
        IERC20(token).transferFrom(from, to, amount);
        accumulate(bonusTo, token, bonusThreshold, bonusMaxCount);
    }

    function transferTokenLogged(
        address from,
        address to,
        address token,
        uint256 amount,
        address bonusTo,
        uint256 bonusThreshold,
        uint256 bonusMaxCount,
        string calldata message
    ) external {
        require(from != to, "BonfireMetaRouter: weird logged transfer");
        uint256 gains = IERC20(token).balanceOf(to);
        IERC20(token).transferFrom(from, to, amount);
        gains = IERC20(token).balanceOf(to) - gains;
        accumulate(bonusTo, token, bonusThreshold, bonusMaxCount);
        ITransferLogbook(logbook).commissionedTransfer(
            msg.sender,
            to,
            token,
            amount,
            gains,
            message
        );
    }

    /**
     * This function is designed such that it computes the maximal amountIn to
     * ensure that with the given path any single pool in the path has a max
     * price increase of
     *           X = (Q/(Q-P))^2
     *
     * In addition the parameter permilleIncrease returns the estimated overall
     * price increase of the input given. In comparison, the suggestedAmountIn
     * should have a maximal price increase of
     *           P = X ^ poolPath.length
     *
     * In other words if the user opts for the paths as given but the
     * suggestedAmountIn instead of the amountIn input for any pool along the
     * path we have a maximum output of
     *        bOut = reserveB * P / Q
     * and a maximum input of
     *         aIn = reserveA * P / (Q - P)
     *
     */
    function querySwapAmount(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 maxChangeFactorP,
        uint256 maxChangeFactorQ
    )
        external
        view
        override
        returns (uint256 suggestedAmountIn, uint256 permilleIncrease)
    {
        require(
            maxChangeFactorP < maxChangeFactorQ && maxChangeFactorP > 0,
            "BonfireMetaRouter: bad maxChangeFactors"
        );
        uint256 amount;
        bool first = true;
        for (uint256 i = poolPath.length; i > 0; ) {
            i--;
            if (poolPath[i] == wrapper) {
                address target = i > 0 ? poolPath[i - 1] : msg.sender;
                amount = IBonfireRouterPaths(paths).wrapperQuote(
                    tokenPath[i + 1],
                    tokenPath[i],
                    amount,
                    target
                );
            } else {
                (uint256 rA, uint256 rB, ) = IBonfirePair(poolPath[i])
                    .getReserves();
                (rA, rB) = IBonfirePair(poolPath[i]).token0() == tokenPath[i]
                    ? (rA, rB)
                    : (rB, rA);
                amount = first ||
                    amount > (rB * maxChangeFactorP) / maxChangeFactorQ
                    ? ((rA * maxChangeFactorP) /
                        (maxChangeFactorQ - maxChangeFactorP))
                    : (rA * amount) / (rB - amount);
                first = false;
            }
        }
        suggestedAmountIn = amount < amountIn ? amount : amountIn;
        amount = amountIn;
        permilleIncrease = 1000;
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (poolPath[i] != wrapper) {
                (uint256 rA, uint256 rB, ) = IBonfirePair(poolPath[i])
                    .getReserves();
                (rA, rB) = IBonfirePair(poolPath[i]).token0() == tokenPath[i]
                    ? (rA, rB)
                    : (rB, rA);
                uint256 amountB = (rB * amount) / (rA + amount);
                uint256 increase = (1000 * ((rA * rB) + (amount * rB))) /
                    ((rA * rB) - (rA * amountB));
                permilleIncrease = (permilleIncrease * increase) / 1000;
                amount = amountB;
            } else {
                address target = i < poolPath.length - 1
                    ? poolPath[i + 1]
                    : msg.sender;
                amount = BonfireMetaRouter(this).quote(
                    poolPath[i:i],
                    tokenPath[i:i + 1],
                    amount,
                    target,
                    true
                );
            }
        }
    }

    function setAccumulator(
        address _accumulator,
        uint256 _defaultWETHThreshold,
        uint256 _count
    ) external onlyOwner {
        accumulator = _accumulator;
        defaultWETHThreshold = _defaultWETHThreshold;
        maxAccumulationCount = _count;
        emit AccumulatorUpdate(
            accumulator,
            defaultWETHThreshold,
            maxAccumulationCount
        );
    }

    function simpleQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    )
        external
        view
        override
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            string[] memory poolDescriptions,
            address bonusToken,
            uint256 bonusAmount
        )
    {
        (
            amountOut,
            poolPath,
            tokenPath,
            poolDescriptions
        ) = IBonfireRouterPaths(paths).getBestPathAugmented(
            tokenIn,
            tokenOut,
            amountIn,
            to
        );
        if (accumulator != address(0)) {
            for (uint256 i = tokenPath.length; i > 0; ) {
                i--;
                if (
                    IBonfireStrategyAccumulator(accumulator).tokenRegistered(
                        tokenPath[i]
                    )
                ) {
                    bonusToken = tokenPath[i];
                    break;
                }
            }
            if (bonusToken == address(0)) bonusToken = defaultToken;
            (bonusAmount, ) = IBonfireStrategyAccumulator(accumulator).quote(
                bonusToken,
                tokenThreshold(bonusToken),
                maxAccumulationCount
            );
        }
    }

    function tokenThreshold(address token)
        internal
        view
        returns (uint256 threshold)
    {
        threshold = IBonfireRouterPaths(paths).getWETHEquivalent(
            token,
            defaultWETHThreshold
        );
    }

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to,
        bool optimized
    ) external view override returns (uint256 amountOut) {
        return
            IBonfireRouterPaths(paths).quote(
                poolPath,
                tokenPath,
                amount,
                to,
                optimized
            );
    }

    receive() external payable {
        assert(msg.sender == WETH);
    }

    function isWrapper(address pool) internal pure returns (bool) {
        return pool == wrapper;
    }

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "BonfireMetaRouter: expired");
        _;
    }

    function _pairSwap(
        address pool,
        address tokenA,
        address tokenB,
        address target,
        uint256 amount,
        bool optimized
    ) internal returns (uint256) {
        (uint256 reserveA, uint256 reserveB, ) = IBonfirePair(pool)
            .getReserves();
        (reserveA, reserveB) = IBonfirePair(pool).token0() == tokenA
            ? (reserveA, reserveB)
            : (reserveB, reserveA);
        if (
            !optimized || IBonfireTokenTracker(tracker).getTotalTaxP(tokenA) > 0
        ) {
            amount = IERC20(tokenA).balanceOf(pool) - reserveA;
        }
        //compute amountOut
        uint256 projectedBalanceB;
        (amount, , projectedBalanceB) = IBonfireRouterPaths(paths)
            .getAmountOutFromPool(amount, tokenB, pool);
        if (
            optimized &&
            IBonfireTokenTracker(tracker).getReflectionTaxP(tokenB) > 0
        ) {
            //reflection adjustment
            amount = IBonfireRouterPaths(paths).reflectionAdjustment(
                tokenB,
                pool,
                amount,
                projectedBalanceB
            );
        }
        if (IBonfirePair(pool).token0() == tokenA) {
            IBonfirePair(pool).swap(uint256(0), amount, target, new bytes(0));
        } else {
            IBonfirePair(pool).swap(amount, uint256(0), target, new bytes(0));
        }
        return amount;
    }

    function _regularSwap(
        address pool,
        address target,
        address[] calldata tokenPath,
        uint256 amount,
        bool optimized
    ) internal returns (uint256) {
        if (isWrapper(pool)) {
            require(
                target != pool,
                "BonfireMetaRouter: wrapper should not occur twice in succession in path"
            );
            address t0 = BonfireTokenHelper.getSourceToken(tokenPath[0]);
            address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
            if (t0 == tokenPath[1]) {
                //unwrap it
                (amount, ) = IBonfireTokenWrapper(pool).withdrawShares(
                    tokenPath[0],
                    target,
                    IBonfireProxyToken(tokenPath[0]).tokenToShares(amount)
                );
            } else if (t1 == tokenPath[0]) {
                //wrap it
                (amount, ) = IBonfireTokenWrapper(pool).executeDeposit(
                    tokenPath[1],
                    target
                );
            } else if (t0 != address(0) && t0 == t1) {
                //convert it
                (amount, ) = IBonfireTokenWrapper(pool).moveShares(
                    tokenPath[0],
                    tokenPath[1],
                    IBonfireProxyToken(tokenPath[0]).tokenToShares(amount),
                    address(this),
                    target
                );
            } else {
                revert("BonfireMetaRouter: wrapper is not a swap");
            }
        } else {
            if (isWrapper(target) && tokenPath.length > 2) {
                //the else to this is swapping into wrapper without control (could be used for custom two-step deposit though
                address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
                address t2 = BonfireTokenHelper.getSourceToken(tokenPath[2]);
                if (t1 == tokenPath[2] || (t1 != address(0) && t1 == t2)) {
                    //prepare unwrapping or converting
                    target = address(this);
                } else if (t2 == tokenPath[1]) {
                    //prepare wrapping
                    IBonfireTokenWrapper(target).announceDeposit(t2);
                } else {
                    revert("BonfireMetaRouter: wrapper is not a swap");
                }
            }
            //and swap
            amount = _pairSwap(
                pool,
                tokenPath[0],
                tokenPath[1],
                target,
                amount,
                optimized
            );
        }
        return amount;
    }

    function _firstSwap(
        address pool,
        address target,
        address[] calldata tokenPath,
        uint256 amount,
        bool optimized
    ) internal returns (uint256 amountOut) {
        if (isWrapper(pool)) {
            require(
                target != pool,
                "BonfireMetaRouter: wrapper should not occur twice in succession in path"
            );
            address t0 = BonfireTokenHelper.getSourceToken(tokenPath[0]);
            address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
            if (t0 == tokenPath[1]) {
                //unwrap it
                (amount, ) = IBonfireTokenWrapper(pool).withdrawSharesFrom(
                    tokenPath[0],
                    msg.sender,
                    target,
                    IBonfireProxyToken(tokenPath[0]).tokenToShares(amount)
                );
            } else if (t1 == tokenPath[0]) {
                //wrap it
                IBonfireTokenWrapper(pool).announceDeposit(tokenPath[0]);
                if (amount > 0)
                    IERC20(tokenPath[0]).safeTransferFrom(
                        msg.sender,
                        pool,
                        amount
                    );
                (amount, ) = IBonfireTokenWrapper(pool).executeDeposit(
                    tokenPath[1],
                    target
                );
            } else if (t0 != address(0) && t0 == t1) {
                //convert it
                (amount, ) = IBonfireTokenWrapper(pool).moveShares(
                    tokenPath[0],
                    tokenPath[1],
                    IBonfireProxyToken(tokenPath[0]).tokenToShares(amount),
                    msg.sender,
                    target
                );
            } else {
                revert("BonfireMetaRouter: wrapper is not a swap");
            }
        } else {
            if (isWrapper(target) && tokenPath.length > 2) {
                //the else to this is swapping into wrapper without control (could be used for custom two-step deposit though
                address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
                address t2 = BonfireTokenHelper.getSourceToken(tokenPath[2]);
                if (t1 == tokenPath[2] || (t1 != address(0) && t1 == t2)) {
                    //prepare unwrapping or converting
                    target = address(this);
                } else if (t2 == tokenPath[1]) {
                    //prepare wrapping
                    IBonfireTokenWrapper(target).announceDeposit(t2);
                } else {
                    revert("BonfireMetaRouter: wrapper is not a swap");
                }
            }
            //and swap
            if (amount > 0)
                IERC20(tokenPath[0]).safeTransferFrom(msg.sender, pool, amount);
            amount = _pairSwap(
                pool,
                tokenPath[0],
                tokenPath[1],
                target,
                amount,
                optimized
            );
        }
        return amount;
    }

    function _swapTokenCore(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        uint256 beforeBalance,
        uint256 minAmountOut,
        address to,
        bool optimized
    ) internal returns (uint256) {
        if (poolPath.length > 0) {
            for (uint256 i = 0; i < poolPath.length; i++) {
                (address pool0, address pool1) = i < poolPath.length - 1
                    ? (poolPath[i], poolPath[i + 1])
                    : (poolPath[i], to);
                amount = _regularSwap(
                    pool0,
                    pool1,
                    tokenPath[i:],
                    amount,
                    optimized
                );
            }
        }
        amount =
            IERC20(tokenPath[tokenPath.length - 1]).balanceOf(to) -
            beforeBalance;
        require(
            amount >= minAmountOut,
            "BonfireMetaRouter: amount out too small"
        );
        return amount;
    }

    function accumulate(
        address to,
        address bonusToken,
        uint256 threshold,
        uint256 maxCount
    ) public {
        if (bonusToken != address(0) && accumulator != address(0)) {
            address token = bonusToken;
            address target = address(this);
            if (IBonfireTokenTracker(tracker).getTotalTaxP(bonusToken) > 0) {
                token = IBonfireRouterPaths(paths).getDefaultProxy(bonusToken);
                target = wrapper;
                IBonfireTokenWrapper(wrapper).announceDeposit(bonusToken);
            }
            uint256 gains = IERC20(token).balanceOf(address(this));
            (uint256 aGains, ) = IBonfireStrategyAccumulator(accumulator)
                .execute(
                    bonusToken,
                    threshold,
                    block.timestamp,
                    target,
                    maxCount
                );
            if (
                aGains > 0 &&
                IBonfireTokenTracker(tracker).getTotalTaxP(bonusToken) > 0
            ) {
                IBonfireTokenWrapper(wrapper).executeDeposit(
                    token,
                    address(this)
                );
            }
            gains = IERC20(token).balanceOf(address(this)) - gains;
            gains = (gains * 95) / 100;
            IERC20(token).transfer(to, gains);
        }
    }

    function swapToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _swapToken(
            poolPath,
            tokenPath,
            amountIn,
            minAmountOut,
            to,
            optimized
        );
        accumulate(
            to,
            bonusToken,
            tokenThreshold(bonusToken),
            maxAccumulationCount
        );
    }

    function swapTokenLogged(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken,
        string calldata message
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _swapToken(
            poolPath,
            tokenPath,
            amountIn,
            minAmountOut,
            to,
            optimized
        );
        logSwap(tokenPath[0], tokenPath[1], amountIn, amountOut, to, message);
        accumulate(
            to,
            bonusToken,
            tokenThreshold(bonusToken),
            maxAccumulationCount
        );
    }

    function _swapToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        uint256 minAmountOut,
        address to,
        bool optimized
    ) internal returns (uint256 amountB) {
        uint256 beforeBalance = IERC20(tokenPath[tokenPath.length - 1])
            .balanceOf(to);
        address target = poolPath.length > 1 ? poolPath[1] : to;
        amount = _firstSwap(poolPath[0], target, tokenPath, amount, optimized);
        amountB = _swapTokenCore(
            poolPath[1:],
            tokenPath[1:],
            amount,
            beforeBalance,
            minAmountOut,
            to,
            optimized
        );
        emit Swap(poolPath, tokenPath, amountB, to);
    }

    function logSwap(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        address to,
        string calldata message
    ) internal {
        ITransferLogbook(logbook).commissionedSwap(
            msg.sender,
            to,
            tokenA,
            tokenB,
            amountA,
            amountB,
            message
        );
    }

    function buyToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256 amountOut)
    {
        amountOut = _buyToken(poolPath, tokenPath, minAmountOut, to, optimized);
        accumulate(
            to,
            bonusToken,
            tokenThreshold(bonusToken),
            maxAccumulationCount
        );
    }

    function buyTokenLogged(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken,
        string calldata message
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256 amountOut)
    {
        uint256 amountIn = msg.value;
        amountOut = _buyToken(poolPath, tokenPath, minAmountOut, to, optimized);
        logSwap(tokenPath[0], tokenPath[1], amountIn, amountOut, to, message);
        accumulate(
            to,
            bonusToken,
            tokenThreshold(bonusToken),
            maxAccumulationCount
        );
    }

    function _buyToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        address to,
        bool optimized
    ) internal returns (uint256 amountB) {
        uint256 beforeBalance = IERC20(tokenPath[tokenPath.length - 1])
            .balanceOf(to);
        uint256 amount = msg.value;
        IWETH(WETH).deposit{value: amount}();
        address target = poolPath.length > 1 ? poolPath[1] : to;
        if (isWrapper(poolPath[0])) {
            require(
                target != poolPath[0],
                "BonfireMetaRouter: wrapper should not occur twice in succession in path"
            );
            //only case: wrap wbnb
            address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
            require(
                t1 == WETH,
                "BonfireMetaRouter: proxy token needs to have source wbnb"
            );
            IBonfireTokenWrapper(poolPath[0]).announceDeposit(WETH);
            if (amount > 0)
                IERC20(tokenPath[0]).safeTransfer(poolPath[0], amount);
            (amount, ) = IBonfireTokenWrapper(poolPath[0]).executeDeposit(
                tokenPath[1],
                target
            );
        } else {
            if (isWrapper(target) && tokenPath.length > 2) {
                //the else to this is swapping into wrapper without control (could be used for custom two-step deposit though
                address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
                address t2 = BonfireTokenHelper.getSourceToken(tokenPath[2]);
                if (t1 == tokenPath[2] || (t1 != address(0) && t1 == t2)) {
                    //prepare unwrapping or converting
                    target = address(this);
                } else if (t2 == tokenPath[1]) {
                    //prepare wrapping
                    IBonfireTokenWrapper(target).announceDeposit(t2);
                } else {
                    revert("BonfireMetaRouter: wrapper is not a swap");
                }
            }
            //and swap
            if (amount > 0)
                IERC20(tokenPath[0]).safeTransfer(poolPath[0], amount);
            amount = _pairSwap(
                poolPath[0],
                tokenPath[0],
                tokenPath[1],
                target,
                amount,
                optimized
            );
        }
        amountB = _swapTokenCore(
            poolPath[1:],
            tokenPath[1:],
            amount,
            beforeBalance,
            minAmountOut,
            to,
            optimized
        );
        emit Swap(poolPath, tokenPath, amountB, to);
    }

    function sellToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _sellToken(
            poolPath,
            tokenPath,
            amountIn,
            minAmountOut,
            to,
            optimized
        );
        accumulate(
            to,
            bonusToken,
            tokenThreshold(bonusToken),
            maxAccumulationCount
        );
    }

    function sellTokenLogged(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken,
        string calldata message
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _sellToken(
            poolPath,
            tokenPath,
            amountIn,
            minAmountOut,
            to,
            optimized
        );
        logSwap(tokenPath[0], tokenPath[1], amountIn, amountOut, to, message);
        accumulate(
            to,
            bonusToken,
            tokenThreshold(bonusToken),
            maxAccumulationCount
        );
    }

    function _sellToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        uint256 minAmountOut,
        address to,
        bool optimized
    ) internal returns (uint256 amountB) {
        uint256 beforeBalance = IERC20(tokenPath[tokenPath.length - 1])
            .balanceOf(address(this));
        require(
            tokenPath[tokenPath.length - 1] == WETH,
            "BonfireMetaRouter: last token in sell must be weth"
        );
        address target = poolPath.length > 1 ? poolPath[1] : address(this);
        amount = _firstSwap(
            poolPath[0],
            target,
            tokenPath[0:],
            amount,
            optimized
        );
        amountB = _swapTokenCore(
            poolPath[1:],
            tokenPath[1:],
            amount,
            beforeBalance,
            minAmountOut,
            address(this),
            optimized
        );
        IWETH(WETH).withdraw(amountB);
        if (amountB > 0) TransferHelper.safeTransferETH(to, amountB);
        emit Swap(poolPath, tokenPath, amountB, to);
    }

    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (amount == 0) amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, amount);
    }

    function withdrawETH(address payable to, uint256 amount)
        external
        onlyOwner
    {
        if (amount == 0) amount = address(this).balance;
        to.transfer(amount);
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
        IERC20Permit token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireStrategyAccumulator {
    function tokenRegistered(address token)
        external
        view
        returns (bool registered);

    function quote(
        address token,
        uint256 threshold,
        uint256 maxCount
    ) external view returns (uint256 expectedGains, uint256 expectedCount);

    function execute(
        address token,
        uint256 threshold,
        uint256 deadline,
        address to,
        uint256 maxCount
    ) external returns (uint256 gains, uint256 count);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireMetaRouter {
    event Swap(
        address[] poolPath,
        address[] tokenPath,
        uint256 amountOut,
        address to
    );

    function WETH() external returns (address);

    function tracker() external returns (address);

    function logbook() external returns (address);

    function wrapper() external returns (address);

    function paths() external returns (address);

    function swapTokenLogged(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken,
        string memory message
    ) external returns (uint256 amountB);

    function swapToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken
    ) external returns (uint256 amountB);

    function buyTokenLogged(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken,
        string memory message
    ) external payable returns (uint256 amountB);

    function buyToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken
    ) external payable returns (uint256 amountB);

    function sellTokenLogged(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken,
        string memory message
    ) external returns (uint256 amountB);

    function sellToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        bool optimized,
        address bonusToken
    ) external returns (uint256 amountB);

    function querySwapAmount(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 maxChangeFactorP,
        uint256 maxChangeFactorQ
    )
        external
        view
        returns (uint256 suggestedAmountIn, uint256 permilleIncrease);

    function simpleQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            string[] memory poolDescriptions,
            address bonusToken,
            uint256 bonusAmount
        );

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to,
        bool optimized
    ) external view returns (uint256 amountOut);
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

interface IBonfireRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireRouterPaths {
    event ChangeFactory(
        address indexed uniswapFactory,
        uint256 fee,
        uint256 denominator,
        string description,
        bool enabled
    );

    event ChangeIntermediateToken(
        address indexed intermediateToken,
        bool enabled
    );

    function wrapper() external returns (address);

    function tracker() external returns (address);

    function WETH() external returns (address);

    function getBestPathAugmented(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            string[] memory poolDescriptions
        );

    function wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amount,
        address to
    ) external view returns (uint256 amountOut);

    function getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath
        );

    function factoryFee(address factory) external view returns (uint256 p);

    function factoryRemainder(address factory)
        external
        view
        returns (uint256 p);

    function factoryDenominator(address factory)
        external
        view
        returns (uint256 p);

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to,
        bool optimized
    ) external view returns (uint256 amountOut);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveA,
        uint256 reserveB,
        uint256 remainderP,
        uint256 remainderQ
    ) external pure returns (uint256 amountOut);

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
        );

    function reflectionAdjustment(
        address token,
        address pool,
        uint256 amount,
        uint256 reserve
    ) external view returns (uint256);

    function getUniswapFactories()
        external
        returns (address[] memory factories);

    function getIntermediateTokens() external returns (address[] memory tokens);

    function defaultProxy(address) external returns (address);

    function getDefaultProxy(address) external returns (address);

    function getAlternateProxy(address) external returns (address);

    function tokenFactory() external returns (address);

    function getWETHEquivalent(address token, uint256 wethAmount)
        external
        view
        returns (uint256 tokenAmount);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "../token/IBonfireProxyToken.sol";

interface IBonfireProxyTokenVisibleReflection is IBonfireProxyToken {}

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
import "../token/IBonfireProxyTokenInvisibleReflection.sol";

interface IMultichainToken is IBonfireProxyTokenInvisibleReflection {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface ITransferLogbook {
    event LoggedSwap(
        address indexed sender,
        uint256 indexed index,
        address recipient,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        string message
    );

    event LoggedTransfer(
        address indexed sender,
        uint256 indexed index,
        address recipient,
        address token,
        uint256 amountOut,
        uint256 amountIn,
        string message
    );

    function commissionedSwap(
        address sender,
        address recipient,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        string calldata message
    ) external returns (uint256 index);

    function commissionedTransfer(
        address sender,
        address recipient,
        address token,
        uint256 amountOut,
        uint256 amountIn,
        string memory message
    ) external returns (uint256 index);
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
interface IERC20Permit {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "../token/IBonfireProxyToken.sol";

interface IBonfireProxyTokenInvisibleReflection is IBonfireProxyToken {}