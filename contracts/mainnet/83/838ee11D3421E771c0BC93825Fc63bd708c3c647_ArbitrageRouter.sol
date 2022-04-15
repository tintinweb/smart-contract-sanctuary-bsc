//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakePair {
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

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IBakeryPair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external;
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract ArbitrageRouter {
    
    uint256 constant MAX_UINT = type(uint256).max;
    address public immutable WETH;
    address payable owner;

    constructor(address _WETH) {
        owner = payable(msg.sender);
        WETH = _WETH;
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "PancakeRouter: EXPIRED");
        _;
    }

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "ArbitrageRouter: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "ArbitrageRouter: ZERO_ADDRESS");
    }

    function approve(address router, address tokenAddress) public {
        IERC20 token = IERC20(tokenAddress);
        if (token.allowance(address(this), address(router)) < 1) {
            require(
                token.approve(address(router), MAX_UINT),
                "FAIL TO APPROVE"
            );
        }
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 fee
    ) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "ArbitrageRouter: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "ArbitrageRouter: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn * (10000 - fee);
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 10000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path,
        address pairAdd,
        uint256 fee
    ) public view returns (uint256[] memory amounts) {
        amounts = new uint256[](2);
        amounts[0] = amountIn;
        (address input, address output) = (path[0], path[1]);
        (address token0, ) = sortTokens(input, output);
        IPancakePair pair = IPancakePair(pairAdd);
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        (uint256 reserveIn, uint256 reserveOut) = input == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        amounts[1] = getAmountOut(amountIn, reserveIn, reserveOut, fee);
    }

    function _swapTokens(
        address pairAdd,
        address[] memory path,
        address _to,
        uint256 fee
    ) public virtual {
        (address input, address output) = (path[0], path[1]);
        (address token0, ) = sortTokens(input, output);
        IPancakePair pair = IPancakePair(pairAdd);
        uint256 amountInput;
        uint256 amountOutput;
        {
            // scope to avoid stack too deep errors
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
            (uint256 reserveInput, uint256 reserveOutput) = input == token0
                ? (reserve0, reserve1)
                : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
            amountOutput = getAmountOut(
                amountInput,
                reserveInput,
                reserveOutput,
                fee
            );
        }
        (uint256 amount0Out, uint256 amount1Out) = input == token0
            ? (uint256(0), amountOutput)
            : (amountOutput, uint256(0));
        try pair.swap(amount0Out, amount1Out, _to, new bytes(0)) {} catch {
            IBakeryPair(pairAdd).swap(amount0Out, amount1Out, _to);
        }
    }

    function swapTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address pair,
        address to,
        uint256 fee
    ) external virtual ensure(block.timestamp + 60) {
        safeTransferFrom(path[0], msg.sender, pair, amountIn);
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapTokens(pair, path, to, fee);
        require(
            (IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore) >=
                amountOutMin,
            "ArbitrageRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapETHForTokens(
        uint256 amountOutMin,
        address[] calldata path, // [wbnb, token]
        address pair,
        address to,
        uint256 fee
    ) external payable virtual ensure(block.timestamp + 60) {
        uint256 amountIn = msg.value;
        IWETH(path[0]).deposit{value: amountIn}();
        assert(IWETH(path[0]).transfer(pair, amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapTokens(pair, path, to, fee);
        require(
            (IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore) >=
                amountOutMin,
            "PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path, // [token, wbnb]
        address pair,
        address to,
        uint256 fee
    ) external virtual ensure(block.timestamp + 60) {
        safeTransferFrom(path[0], msg.sender, pair, amountIn);
        _swapTokens(pair, path, address(this), fee);
        uint256 amountOut = IERC20(path[path.length - 1]).balanceOf(
            address(this)
        );
        require(
            amountOut >= amountOutMin,
            "PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(path[path.length - 1]).withdraw(amountOut);
        safeTransferETH(to, amountOut);
    }

    function withdraw() external {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }

    function withdrawToken(address tokenAddress, address to) external {
        require(msg.sender == owner);
        IERC20 token = IERC20(tokenAddress);
        token.transfer(to, token.balanceOf(address(this)));
    }

    receive() external payable {}
}