// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.6.12;

import "./libraries/ArdMoneyLibrary.sol";
import "./libraries/ArdMoneySafeMath.sol";
import "./libraries/ArdMoneyTransferHelper.sol";

import "./interfaces/IArdMoneyRouter02.sol";
import "./interfaces/IArdMoneyPair.sol";
import "./interfaces/IArdMoneyFactory.sol";
import "./interfaces/IArdMoneyERC20.sol";
import "./interfaces/IArdMoneyWETH.sol";

contract ArdMoneyRouter is IArdMoneyRouter02 {
    using ArdMoneySafeMath for uint256;

    address public immutable override factory;
    address public immutable override WETH;
    address admin;
    uint swapFee;
    uint mintFee;
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "ArdMoneyRouter: EXPIRED");
        _;
    }

    constructor(address _factory, address _WETH, address _admin, uint _swapFee, uint _mintFee) public {
        factory = _factory;
        WETH = _WETH;
        admin = _admin;
        swapFee = _swapFee;
        mintFee = _mintFee;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (IArdMoneyFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IArdMoneyFactory(factory).createPair(tokenA, tokenB, swapFee, mintFee, admin);
        }
        (uint256 reserveA, uint256 reserveB) = ArdMoneyLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = ArdMoneyLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "ArdMoneyRouter: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = ArdMoneyLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "ArdMoneyRouter: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

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
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = ArdMoneyLibrary.pairFor(factory, tokenA, tokenB);
        ArdMoneyTransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        ArdMoneyTransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IArdMoneyPair(pair).mint(to);
    }

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
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = ArdMoneyLibrary.pairFor(factory, token, WETH);
        ArdMoneyTransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IArdMoneyWETH(WETH).deposit{value: amountETH}();
        assert(IArdMoneyWETH(WETH).transfer(pair, amountETH));
        liquidity = IArdMoneyPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH)
            ArdMoneyTransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = ArdMoneyLibrary.pairFor(factory, tokenA, tokenB);
        IArdMoneyPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IArdMoneyPair(pair).burn(to);
        (address token0, ) = ArdMoneyLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(
            amountA >= amountAMin,
            "ArdMoneyRouter: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "ArdMoneyRouter: INSUFFICIENT_B_AMOUNT"
        );
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountETH)
    {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        ArdMoneyTransferHelper.safeTransfer(token, to, amountToken);
        IArdMoneyWETH(WETH).withdraw(amountETH);
        ArdMoneyTransferHelper.safeTransferETH(to, amountETH);
    }

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
    ) external virtual override returns (uint256 amountA, uint256 amountB) {
        address pair = ArdMoneyLibrary.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IArdMoneyPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

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
    )
        external
        virtual
        override
        returns (uint256 amountToken, uint256 amountETH)
    {
        address pair = ArdMoneyLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IArdMoneyPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        ArdMoneyTransferHelper.safeTransfer(
            token,
            to,
            IArdMoneyERC20(token).balanceOf(address(this))
        );
        IArdMoneyWETH(WETH).withdraw(amountETH);
        ArdMoneyTransferHelper.safeTransferETH(to, amountETH);
    }

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
    ) external virtual override returns (uint256 amountETH) {
        address pair = ArdMoneyLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IArdMoneyPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = ArdMoneyLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2
                ? ArdMoneyLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IArdMoneyPair(ArdMoneyLibrary.pairFor(factory, input, output))
                .swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    /// @param amountIn Amount Of TokenA Willing To Swap For
    /// @param amountOutMin Minimum amount out TokenB willing to take
    /// @param path array of pair address , Ex: TokenA swap for TokenC route would be [TokenA/TokenB Pair Address,TokenB/TokenC Pair Address]
    /// @param to user address
    /// @param deadline epoch timestamp deadline - https://www.epochconverter.com/
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        amounts = ArdMoneyLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "ArdMoneyRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        ArdMoneyTransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    /// @param amountOut Amount Of TokenB To Expect
    /// @param amountInMax Max Of Amount Of TokenA Willing To Trade For
    /// @param path array of pair address , Ex: TokenA swap for TokenC route would be [TokenA/TokenB Pair Address,TokenB/TokenC Pair Address]
    /// @param to user address
    /// @param deadline epoch timestamp deadline - https://www.epochconverter.com/
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        amounts = ArdMoneyLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "ArdMoneyRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        ArdMoneyTransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    /// @dev Payable function henceforth sending ether for TokenA
    /// @param amountOutMin Minimum Amount Of TokenA Willing To Take
    /// @param path array of pair address , Ex: TokenA swap for TokenC route would be [TokenA/TokenB Pair Address,TokenB/TokenC Pair Address]
    /// @param to user address
    /// @param deadline epoch timestamp deadline - https://www.epochconverter.com/
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "ArdMoneyRouter: INVALID_PATH");
        amounts = ArdMoneyLibrary.getAmountsOut(factory, msg.value, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "ArdMoneyRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IArdMoneyWETH(WETH).deposit{value: amounts[0]}();
        assert(
            IArdMoneyWETH(WETH).transfer(
                ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
    }

    /// @dev Give Token and Take Ether
    /// @param amountOut Amount Of Ether Willing To Take
    /// @param amountInMax ???
    /// @param path array of pair address , Ex: TokenA swap for TokenC route would be [TokenA/TokenB Pair Address,TokenB/TokenC Pair Address]
    /// @param to user address
    /// @param deadline epoch timestamp deadline - https://www.epochconverter.com/
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WETH, "ArdMoneyRouter: INVALID_PATH");
        amounts = ArdMoneyLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "ArdMoneyRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        ArdMoneyTransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IArdMoneyWETH(WETH).withdraw(amounts[amounts.length - 1]);
        ArdMoneyTransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    /// @dev Give Token and Take Ether
    /// @param amountIn Amount of token willing to swap for
    /// @param amountOutMin Minimum amount of ether willing to take
    /// @param path array of pair address , Ex: TokenA swap for TokenC route would be [TokenA/TokenB Pair Address,TokenB/TokenC Pair Address]
    /// @param to user address
    /// @param deadline epoch timestamp deadline - https://www.epochconverter.com/
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WETH, "ArdMoneyRouter: INVALID_PATH");
        amounts = ArdMoneyLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "ArdMoneyRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        ArdMoneyTransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IArdMoneyWETH(WETH).withdraw(amounts[amounts.length - 1]);
        ArdMoneyTransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    /// @dev Give Ether and Take Token - Henceforth function payable
    /// @param amountOut Amount Of Token wanting to take
    /// @param path array of pair address , Ex: TokenA swap for TokenC route would be [TokenA/TokenB Pair Address,TokenB/TokenC Pair Address]
    /// @param to user address
    /// @param deadline epoch timestamp deadline - https://www.epochconverter.com/
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "ArdMoneyRouter: INVALID_PATH");
        amounts = ArdMoneyLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= msg.value,
            "ArdMoneyRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        IArdMoneyWETH(WETH).deposit{value: amounts[0]}();
        assert(
            IArdMoneyWETH(WETH).transfer(
                ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0])
            ArdMoneyTransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = ArdMoneyLibrary.sortTokens(input, output);
            IArdMoneyPair pair = IArdMoneyPair(
                ArdMoneyLibrary.pairFor(factory, input, output)
            );
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IArdMoneyERC20(input).balanceOf(address(pair)).sub(
                        reserveInput
                    );
                uint256 swapFee =  IArdMoneyPair(ArdMoneyLibrary.pairFor(factory, input, output)).getSwapFee();
                amountOutput = ArdMoneyLibrary.getAmountOut(
                    amountInput,
                    reserveInput,
                    reserveOutput,
                    swapFee
                );
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2
                ? ArdMoneyLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        ArdMoneyTransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint256 balanceBefore = IArdMoneyERC20(path[path.length - 1]).balanceOf(
            to
        );
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IArdMoneyERC20(path[path.length - 1]).balanceOf(to).sub(
                balanceBefore
            ) >= amountOutMin,
            "ArdMoneyRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        require(path[0] == WETH, "ArdMoneyRouter: INVALID_PATH");
        uint256 amountIn = msg.value;
        IArdMoneyWETH(WETH).deposit{value: amountIn}();
        assert( IArdMoneyWETH(WETH).transfer( ArdMoneyLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IArdMoneyERC20(path[path.length - 1]).balanceOf( to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IArdMoneyERC20(path[path.length - 1]).balanceOf(to).sub(
                balanceBefore
            ) >= amountOutMin,
            "ArdMoneyRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WETH, "ArdMoneyRouter: INVALID_PATH");
        ArdMoneyTransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ArdMoneyLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IArdMoneyERC20(WETH).balanceOf(address(this));
        require(
            amountOut >= amountOutMin,
            "ArdMoneyRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IArdMoneyWETH(WETH).withdraw(amountOut);
        ArdMoneyTransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return ArdMoneyLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 swapFee
    ) public pure virtual override returns (uint256 amountOut) {
        return ArdMoneyLibrary.getAmountOut(amountIn, reserveIn, reserveOut, swapFee);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 swapFee
    ) public pure virtual override returns (uint256 amountIn) {
        return ArdMoneyLibrary.getAmountIn(amountOut, reserveIn, reserveOut, swapFee);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return ArdMoneyLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return ArdMoneyLibrary.getAmountsIn(factory, amountOut, path);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

import "../interfaces/IArdMoneyPair.sol";
import "../interfaces/IArdMoneyFactory.sol";

import "./ArdMoneySafeMath.sol";

library ArdMoneyLibrary {
    using ArdMoneySafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "ArdMoney: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "ArdMoney: ZERO_ADDRESS");
    }

    // Fix - https://forum.openzeppelin.com/t/uniswap-fork-testing-hardhat/14472
    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
      pair = IArdMoneyFactory(factory).getPair(tokenA,tokenB);
    }
    // function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
    //     (address token0, address token1) = sortTokens(tokenA, tokenB);
    //     pair = address(uint(keccak256(abi.encodePacked(
    //             hex'ff',
    //             factory,
    //             keccak256(abi.encodePacked(token0, token1)),
    //             hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
    //         ))));
    // }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IArdMoneyPair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "ArdMoney: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "ArdMoney: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    // Хэрэглэгч бидэнд өгөх гэж буй хэмжээгээ бичихэд fee-гээ бодсоны дараа pool-нээс авч болох max token-ы хэмжээг буцаана
    function getAmountOut(
        uint256 amountIn, //100
        uint256 reserveIn, //1000
        uint256 reserveOut, //100
        uint256 swapFee
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "ArdMoney: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "ArdMoney: INSUFFICIENT_LIQUIDITY"
        );
        uint256 hundredPercent = 1000;
        uint256 amountInWithFee = amountIn.mul(hundredPercent.sub(swapFee)); // 99700 =  100 * 997
        uint256 numerator = amountInWithFee.mul(reserveOut); // 9970000 = 99700 * 100
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee); // 1000997 = 1000 * 1000 + 997
        amountOut = numerator / denominator; // 9.96 = 9970000 / 1000997
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    // Хэрэглэгч биднээс авах гэж буй хэмжээгээ бичихэд fee-гээ бодсоны дараа pool-д өгөх хамгиййн бага token-ы хэмжээг буцаана
    function getAmountIn(
        uint256 amountOut, //10
        uint256 reserveIn, //1000
        uint256 reserveOut, //100
        uint256 swapFee
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "ArdMoney: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "ArdMoney: INSUFFICIENT_LIQUIDITY"
        );
        uint256 hundredPercent = 1000;
        uint256 numerator = reserveIn.mul(amountOut).mul(1000); // 10000000 = 1000 * 10 * 1000
        uint256 denominator = reserveOut.sub(amountOut).mul(hundredPercent.sub(swapFee)); // 89730 = (100 - 10) * 997
        amountIn = (numerator / denominator).add(1); // 112.44 = (10000000 / 89730) + 1
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "ArdMoney: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            uint256 swapFee =  IArdMoneyPair(pairFor(factory, path[i], path[i + 1])).getSwapFee();
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, swapFee);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "ArdMoney: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            uint256 swapFee =  IArdMoneyPair(pairFor(factory, path[i - 1], path[i])).getSwapFee();
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, swapFee);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library ArdMoneySafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

// SPDX-License-Identifier: GPL-3.0

import "../interfaces/IArdMoneyERC20.sol";

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library ArdMoneyTransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ArdMoneyTransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ArdMoneyTransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
      bool success = IArdMoneyERC20(token).transferFrom(from,to,value);
      require(success == true,'ArdMoneyTransferHelper::transferFrom: transferFrom failed');

      // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
      // (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872de, from, to, value));
      // require(
      //     success && (data.length == 0 || abi.decode(data, (bool))),
      //     'TransferHelper::transferFrom: transferFrom failed'
      // );
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'ArdMoneyTransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.2;

import "./IArdMoneyRouter01.sol";

interface IArdMoneyRouter02 is IArdMoneyRouter01 {
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IArdMoneyPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function getAdmin() external pure returns (address);
    function setAdmin(address _admin) external;
    function getSwapFee() external pure returns (uint256);
    function setSwapFee(uint256 _swapFee) external;
    function getMintFee() external pure returns (uint256);
    function setMintFee(uint256 _mintFee) external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IArdMoneyFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function migrator() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB, uint swapFee, uint mintFee, address admin) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setMigrator(address) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IArdMoneyERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IArdMoneyWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.2;

interface IArdMoneyRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint swapFee) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint swapFee) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}