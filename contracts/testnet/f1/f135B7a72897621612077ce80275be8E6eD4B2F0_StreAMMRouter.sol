// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './interfaces/directImports/IStreAMMFactory.sol';
import './interfaces/directImports/IStreAMMPair.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './interfaces/IStreAMMRouter.sol';
import './interfaces/IWBNB.sol';
import './libraries/StreAMMLibrary.sol';
import './libraries/TransferHelper.sol';

contract StreAMMRouter is IStreAMMRouter {
    address public immutable override factory;
    address public immutable override WBNB;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, 'StreAMMRouter: EXPIRED');
        _;
    }

    constructor(address _factory, address _WBNB) {
        require(_factory != address(0) && _WBNB != address(0), 'StreAMMRouter: Zero Address');
        factory = _factory;
        WBNB = _WBNB;
    }

    receive() external payable {
        assert(msg.sender == WBNB); // only accept BNB via fallback from the WBNB contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal view virtual returns (uint256 amountA, uint256 amountB) {
        (uint256 reserveA, uint256 reserveB) = StreAMMLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = StreAMMLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'StreAMMRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = StreAMMLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'StreAMMRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    // Add liquidity for two ERC20 Tokens
    function _addLiquidityTokens(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        address pair
    ) internal virtual {
        (uint256 amountA, uint256 amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        pair = StreAMMLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        IStreAMMPair(pair).mint(to);
    }

    // add liquidity to a pool with liquidity
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        address pair = IStreAMMFactory(factory).getPair(tokenA, tokenB);
        require(pair != address(0), 'StreAMMRouter: Pair not created yet.');
        require(IStreAMMPair(pair).countryCode() != type(uint16).max, 'StreAMMRouter: Pair not initilized');
        _addLiquidityTokens(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, pair);
    }

    // add the first time liquidity to a ERC20 pool
    // creates a pair and initilzes it with country code
    function addLiquidityInitial(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        uint16 countryCode,
        address newOwner
    ) external payable virtual override ensure(deadline) {
        require(IStreAMMFactory(factory).isCountryCodeValid(countryCode), 'StreAMMRouter: CountryCode not valid');
        address pair = IStreAMMFactory(factory).getPair(tokenA, tokenB);

        // create pair if not exists
        if (pair == address(0)) {
            address[] memory owner = new address[](1);
            owner[0] = newOwner;
            pair = IStreAMMFactory(factory).createPair{value: msg.value}(tokenA, tokenB, owner);
        } else {
            require(IStreAMMPair(pair).countryCode() == type(uint16).max, 'StreAMMRouter: Pair already initilized');
        }

        _addLiquidityTokens(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, pair);
        IStreAMMPair(pair).setCountryCode(countryCode);
    }

    function _addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountBNBDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        address pair
    ) internal {
        (uint256 amountToken, uint256 amountBNB) = _addLiquidity(
            token,
            WBNB,
            amountTokenDesired,
            amountBNBDesired,
            amountTokenMin,
            amountBNBMin
        );
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWBNB(WBNB).deposit{value: amountBNB}();
        assert(IWBNB(WBNB).transfer(pair, amountBNB));
        IStreAMMPair(pair).mint(to);
        // refund dust bnb, if any
        if (amountBNBDesired > amountBNB) TransferHelper.safeTransferBNB(msg.sender, amountBNBDesired - amountBNB);
    }

    function addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        address pair = IStreAMMFactory(factory).getPair(token, WBNB);
        require(pair != address(0), 'StreAMMRouter: Pair not created yet.');
        require(IStreAMMPair(pair).countryCode() != type(uint16).max, 'StreAMMRouter: Pair not initilized');
        _addLiquidityBNB(token, amountTokenDesired, msg.value, amountTokenMin, amountBNBMin, to, pair);
    }

    function addLiquidityBNBInitial(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        uint16 countryCode,
        address newOwner
    ) external payable virtual override ensure(deadline) {
        require(IStreAMMFactory(factory).isCountryCodeValid(countryCode), 'StreAMMRouter: CountryCode not valid');

        // check if pair is already initilized with country code
        address pair = IStreAMMFactory(factory).getPair(token, WBNB);
        // create pair if not exists
        uint256 feePaid;
        if (pair == address(0)) {
            uint256 creationFee = IStreAMMFactory(factory).getPairCreationFee();
            address[] memory owner = new address[](1);
            owner[0] = newOwner;
            pair = IStreAMMFactory(factory).createPair{value: creationFee}(token, WBNB, owner);
            feePaid = creationFee;
        } else {
            require(IStreAMMPair(pair).countryCode() == type(uint16).max, 'StreAMMRouter: Pair already initilized');
        }

        _addLiquidityBNB(token, amountTokenDesired, msg.value - feePaid, amountTokenMin, amountBNBMin, to, pair);
        IStreAMMPair(pair).setCountryCode(countryCode);
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
    ) public virtual override ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        address pair = StreAMMLibrary.pairFor(factory, tokenA, tokenB);
        IStreAMMPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IStreAMMPair(pair).burn(to);
        (address token0, ) = StreAMMLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'StreAMMRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'StreAMMRouter: INSUFFICIENT_B_AMOUNT');
    }

    function removeLiquidityBNB(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountToken, uint256 amountBNB) {
        (amountToken, amountBNB) = removeLiquidity(
            token,
            WBNB,
            liquidity,
            amountTokenMin,
            amountBNBMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWBNB(WBNB).withdraw(amountBNB);
        TransferHelper.safeTransferBNB(to, amountBNB);
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
        address pair = StreAMMLibrary.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IStreAMMPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityBNBWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountToken, uint256 amountBNB) {
        address pair = StreAMMLibrary.pairFor(factory, token, WBNB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IStreAMMPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountBNB) = removeLiquidityBNB(token, liquidity, amountTokenMin, amountBNBMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountBNB) {
        (, amountBNB) = removeLiquidity(token, WBNB, liquidity, amountTokenMin, amountBNBMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWBNB(WBNB).withdraw(amountBNB);
        TransferHelper.safeTransferBNB(to, amountBNB);
    }

    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountBNB) {
        address pair = StreAMMLibrary.pairFor(factory, token, WBNB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IStreAMMPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountBNB = removeLiquidityBNBSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountBNBMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to,
        bool discounted
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = StreAMMLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? StreAMMLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IStreAMMPair(StreAMMLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                discounted,
                msg.sender
            );
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        amounts = getAmountsOut(amountIn, path, discounted);
        require(amounts[amounts.length - 1] >= amountOutMin, 'StreAMMRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            StreAMMLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to, discounted);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        amounts = getAmountsIn(amountOut, path, discounted);
        require(amounts[0] <= amountInMax, 'StreAMMRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            StreAMMLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to, discounted);
    }

    function swapExactBNBForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external payable virtual override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[0] == WBNB, 'StreAMMRouter: INVALID_PATH');
        amounts = getAmountsOut(msg.value, path, discounted);
        require(amounts[amounts.length - 1] >= amountOutMin, 'StreAMMRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWBNB(WBNB).deposit{value: amounts[0]}();
        assert(IWBNB(WBNB).transfer(StreAMMLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to, discounted);
    }

    function swapTokensForExactBNB(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WBNB, 'StreAMMRouter: INVALID_PATH');
        amounts = getAmountsIn(amountOut, path, discounted);
        require(amounts[0] <= amountInMax, 'StreAMMRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            StreAMMLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this), discounted);
        IWBNB(WBNB).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferBNB(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WBNB, 'StreAMMRouter: INVALID_PATH');
        amounts = getAmountsOut(amountIn, path, discounted);
        require(amounts[amounts.length - 1] >= amountOutMin, 'StreAMMRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            StreAMMLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this), discounted);
        IWBNB(WBNB).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferBNB(to, amounts[amounts.length - 1]);
    }

    function swapBNBForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external payable virtual override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[0] == WBNB, 'StreAMMRouter: INVALID_PATH');
        amounts = getAmountsIn(amountOut, path, discounted);
        require(amounts[0] <= msg.value, 'StreAMMRouter: EXCESSIVE_INPUT_AMOUNT');
        IWBNB(WBNB).deposit{value: amounts[0]}();
        assert(IWBNB(WBNB).transfer(StreAMMLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to, discounted);
        // refund dust bnb, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferBNB(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,
        address _to,
        bool discounted
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address token0, ) = StreAMMLibrary.sortTokens(path[i], path[i + 1]);
            IStreAMMPair pair = IStreAMMPair(StreAMMLibrary.pairFor(factory, path[i], path[i + 1]));
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = path[i] == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IERC20(path[i]).balanceOf(address(pair)) - reserveInput;
                amountOutput = getAmountOut(path[i], path[i + 1], amountInput, reserveInput, reserveOutput, discounted);
            }
            (uint256 amount0Out, uint256 amount1Out) = path[i] == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? StreAMMLibrary.pairFor(factory, path[i + 1], path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, discounted, msg.sender);
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            StreAMMLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to, discounted);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'StreAMMRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external payable virtual override ensure(deadline) {
        require(path[0] == WBNB, 'StreAMMRouter: INVALID_PATH');
        uint256 amountIn = msg.value;
        IWBNB(WBNB).deposit{value: amountIn}();
        assert(IWBNB(WBNB).transfer(StreAMMLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to, discounted);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'StreAMMRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WBNB, 'StreAMMRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            StreAMMLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this), discounted);
        uint256 amountOut = IERC20(WBNB).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'StreAMMRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWBNB(WBNB).withdraw(amountOut);
        TransferHelper.safeTransferBNB(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return StreAMMLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        bool discounted
    ) public view virtual override returns (uint256 amountOut) {
        IStreAMMPair pair = IStreAMMPair(StreAMMLibrary.pairFor(factory, tokenIn, tokenOut));
        uint256 swapFee = pair.getTotalFee(discounted);
        return StreAMMLibrary.getAmountOut(amountIn, reserveIn, reserveOut, swapFee);
    }

    function getAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        bool discounted
    ) public view virtual override returns (uint256 amountIn) {
        IStreAMMPair pair = IStreAMMPair(StreAMMLibrary.pairFor(factory, tokenIn, tokenOut));
        uint256 swapFee = pair.getTotalFee(discounted);
        return StreAMMLibrary.getAmountIn(amountOut, reserveIn, reserveOut, swapFee);
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path,
        bool discounted
    ) public view virtual override returns (uint256[] memory amounts) {
        return StreAMMLibrary.getAmountsOut(factory, amountIn, path, discounted);
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] memory path,
        bool discounted
    ) public view virtual override returns (uint256[] memory amounts) {
        return StreAMMLibrary.getAmountsIn(factory, amountOut, path, discounted);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// original resource @uniswap/lib/contracts/libraries/TransferHelper.sol

pragma solidity 0.8.0;

// helper methods for interacting with ERC20 tokens and sending BNB that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferBNB: BNB transfer failed');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '../interfaces/directImports/IStreAMMPair.sol';

library StreAMMLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'StreAMMLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'StreAMMLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex'6322f992ff252e9ae5921b53fb0adbaedd24b0b0684ebc51cde5a30cf2ae25f9' // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IStreAMMPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, 'StreAMMLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'StreAMMLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = (amountA * reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 fee
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, 'StreAMMLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'StreAMMLibrary: INSUFFICIENT_LIQUIDITY');
        uint256 amountInWithFee = amountIn * (10000 - fee);
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 10000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 fee
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, 'StreAMMLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'StreAMMLibrary: INSUFFICIENT_LIQUIDITY');
        uint256 numerator = reserveIn * amountOut * 10000;
        uint256 denominator = (reserveOut - amountOut) * (10000 - fee);
        amountIn = numerator / denominator + 1;
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path,
        bool discounted
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, 'StreAMMLibrary: INVALID_PATH');
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            IStreAMMPair pair = IStreAMMPair(pairFor(factory, path[i], path[i + 1]));
            uint256 swapFee = pair.getTotalFee(discounted);
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, swapFee);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path,
        bool discounted
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, 'StreAMMLibrary: INVALID_PATH');
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            IStreAMMPair pair = IStreAMMPair(pairFor(factory, path[i], path[i - 1]));
            uint256 swapFee = pair.getTotalFee(discounted);
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, swapFee);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMProtocolFee contract
 */
interface IStreAMMProtocolFee {
    /**
     * @dev get the default stream fee applied to a new created pair
     */
    function defaultLiquidityLockerFee() external view returns (uint256);

    /**
     * @dev get the default LP fee applied to a new created pair
     */
    function defaultLPFee() external view returns (uint256);

    /**
     * @dev get the StreAMM fee applied all pairs
     */
    function streAMMFee() external view returns (uint256);

    /**
     * @dev get the address of the StreAMM and creation fee receiving account
     */
    function feeTo() external view returns (address payable);

    /**
     * @dev get the absolute pair creation fee in native token charged on every new pair
     * creation
     */
    function pairCreationFee() external view returns (uint256);

    /**
     * @dev get the relative fee for discounted trades
     */
    function discountedFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './IStreAMMProtocolFee.sol';

/**
 * @dev Interface of the StreAMMPairFee contract
 */
interface IStreAMMPairFee {
    /**
     * @dev Returns the address of the StreAMMFactory.
     */
    function factory() external view returns (address);

    /**
     * @dev Returns the stream protocol fee interface
     */
    function streAMMProtocolFee() external view returns (IStreAMMProtocolFee);

    /**
     * @dev Returns the relative value for the liquidity provider fee in parts per 10,000.
     * The liquidity provider fee is kept in the pool to let the shares of the liquidity
     * providers grow.
     */
    function liquidityProviderFee() external view returns (uint256);

    /**
     * @dev Returns the relative value for the stream fee in parts per 10,000. The stream fee
     * is calculated for whitelisted tokens (USDT, USDC, DAI, ...) and will be sent to the
     * liquidity top lockers of the swapped token registered in LiquidityTopLockers contract.
     * If the paired tokens are not whitelisted, the stream fee will be burned.
     */
    function liquidityLockerFee() external view returns (uint256);

    /**
     * @dev Returns the relative value for the total swapping fee in parts per 10,000.
     * The total fee is equal to the liquidity locker fee plus StreAMM fee plus liquidity
     * provider fee. For a discounted trade, the total fee is equal to the discounted fee.
     */
    function getTotalFee(bool discounted) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './IStreAMMERC20.sol';
import './IStreAMMPairFee.sol';

/**
 * @dev Interface of StreAMMPair contract
 */
interface IStreAMMPair is IStreAMMERC20, IStreAMMPairFee {
    // define events
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

    /**
     * @dev Returns the minimum liquidity of a pair. The minimum liquidity is burned on initial token minting.
     */
    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    /**
     * @dev Returns the address of the pair's token0
     */
    function token0() external view returns (address);

    /**
     * @dev Returns the address of the pair's token1
     */
    function token1() external view returns (address);

    /**
     * @dev Returns the pair's country code. The country code is set by the router on the initial
     * liquidity adding.
     */
    function countryCode() external view returns (uint16);

    /**
     * @dev Returns the current reserves of the pair's two tokens and the timestamp of the last update.
     * The reserves are the total value of each token hold by the pair. They define the proportion of
     * tokens in this pool.
     */
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

    /**
     * @dev Mints new StreAMMPair tokens to the given address and returns the minted liquidity.
     */
    function mint(address to) external returns (uint256 liquidity);

    /**
     * @dev Burns the sent pair tokens amount and sends back the equivalent amount of token0
     * and token1 to the given address. It returns the received amounts of each token.
     */
    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    /**
     * @dev Swaps token0 for token1 or reverse. Swap funds of a token(token0 or token1) has to be sent to
     * the pair contract and the desired output amount is transferred to the given address. This function
     * optimistcally transfers the output amount, calculates the input amount and checks, if the balances
     * are matching with the swapping fees set in StreAMMPairFee contract. It collects all fees defined in StreAMMPairFee
     * contract. A trader can swap with discounted fees, if he has discounted trading balance in
     * StreAMMDiscountedTrading contract.
     */
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bool discounted,
        address sender
    ) external;

    /**
     * @dev Force balances to match reserves. Remaining tokens are sent to the given address.
     */
    function skim(address to) external;

    /**
     * @dev Forces reserves to match balances.
     */
    function sync() external;

    /**
     * @dev Initializes the pair contract with all needed contract addresses. This function is called by
     * the factory on pair creation.
     */
    function initialize(
        address tokenA,
        address tokenB,
        address[] memory owners,
        address liquidityTopLockerContract,
        address protocolFeeContract
    ) external;

    /**
     * @dev Set the country code of a pair. This function can only be called by the router. It is called
     * on initial adding liquidity to the pair.
     */
    function setCountryCode(uint16 _countryCode) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMFactory contract
 */
interface IStreAMMFactory {
    /**
     * @dev Emitted when a new pair is created.
     */
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    /**
     * @dev Returns if a given country code is valid. The CountryList contract is used for checking
     * if a country code is valid.
     */
    function isCountryCodeValid(uint16) external view returns (bool);

    /**
     * @dev Returns if a given token address is whitelisted. The StreAMMTokenWhitelist contract is used
     * for checking if a token is whitelisted.
     */
    function isTokenWhitelisted(address _token) external view returns (bool isWhitelisted);

    /**
     * @dev Returns if a given address has discounted trades balance. The StreAMMDiscountedTrading contract
     * is used for checking if a trader has discounted trades left.
     */
    function hasDiscountedTrades(address _trader) external view returns (bool);

    /**
     * @dev Returns the address of the router. It is used to check if the router called the
     * setCountryCode function of the StreAMMPair.
     */
    function router() external view returns (address);

    /**
     * @dev Returns the address of the StreAMMPair for two given tokens.
     */
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    /**
     * @dev Returns the address of the StreAMMPair for the given index of the array with all pairs.
     */
    function allPairs(uint256) external view returns (address pair);

    /**
     * @dev Returns the number of all created StreAMMPairs.
     */
    function allPairsLength() external view returns (uint256);

    /**
     * @dev Creates a new StreAMMPair for the given two tokens and returns its address. The exact pair
     * creation fee has to be sent with the transaction call. Otherwise the creation will fail.
     */
    function createPair(
        address tokenA,
        address tokenB,
        address[] memory owners
    ) external payable returns (address pair);

    /**
     * @dev Returns the absolute value of the pair creation fee
     */
    function getPairCreationFee() external view returns (uint256 creationFee);

    /**
     * @dev Decreases the discounted trades balance of a given trader. The StreAMMDiscountedTrading contract is
     * used to decrease the balance of discounted trades.
     */
    function decreaseDiscountedTrades(address _trader) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
 * @dev Interface of the StreAMMERC20 contract
 */
interface IStreAMMERC20 is IERC20 {
    /**
     * @dev Returns the name of the ERC20 token
     */
    function name() external pure returns (string memory);

    /**
     * @dev Returns the symbol of the ERC20 token
     */
    function symbol() external pure returns (string memory);

    /**
     * @dev Returns the decimals of the ERC20 token
     */
    function decimals() external pure returns (uint8);

    /**
     * @dev Returns the domain separator of the ERC20 token
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /**
     * @dev Returns the domain separator of the ERC20 token
     */
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    /**
     * @dev Returns the users nonces of the ERC20 token
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Permits a token to be transfered. It uses a signature for verification and calls the approve function.
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
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IStreAMMRouter {
    function factory() external view returns (address);

    function WBNB() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityInitial(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        uint16 countryCode,
        address newOwner
    ) external payable;

    function addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external payable;

    function addLiquidityBNBInitial(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        uint16 countryCode,
        address newOwner
    ) external payable;

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityBNB(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountBNB);

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

    function removeLiquidityBNBWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountBNB);

    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountBNB);

    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountBNB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external returns (uint256[] memory amounts);

    function swapExactBNBForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactBNB(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external returns (uint256[] memory amounts);

    function swapBNBForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external;

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external payable;

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool discounted
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        bool discounted
    ) external view returns (uint256 amountOut);

    function getAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        bool discounted
    ) external view returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path,
        bool discounted
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path,
        bool discounted
    ) external view returns (uint256[] memory amounts);
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