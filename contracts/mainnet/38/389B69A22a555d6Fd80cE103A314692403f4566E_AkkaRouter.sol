// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma abicoder v2;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import {IAkkaRouter} from "./interfaces/IAkkaRouter.sol";
import {IAkkaPair} from "./interfaces/IAkkaPair.sol";
import {IAkka1Pair} from "./interfaces/IAkka1Pair.sol";
import {IStargateRouter} from "./interfaces/IStargateRouter.sol";
import {IBridgeAnyswap} from "./interfaces/IBridgeAnyswap.sol";
import {IUnderlying} from "./interfaces/IUnderlying.sol";
import {AkkaLibrary} from "./libraries/AkkaLibrary.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {IDepositExecute} from "./interfaces/IDepositExecute.sol";

contract AkkaRouter is IAkkaRouter {
    // address public immutable override factory;
    // address public WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // address public WETH = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    address private _WETH;
    address private receiverContract;
    uint16 immutable STARGATE_ID = 1;
    uint16 immutable MULTICHAIN_V6_ID = 2;
    uint16 immutable MULTICHAIN_V7_ID = 3;
    uint16 immutable ICE_BRIDGE_ID = 4;
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "PancakeRouter: EXPIRED");
        _;
    }

    constructor(address WETH_) {
        _WETH = WETH_;
    }

    receive() external payable {
        assert(msg.sender == _WETH); // only accept ETH via fallback from the WETH contract
    }

    function _swap(
        uint256[] memory amounts,
        address[][] memory path,
        address _to
    ) internal virtual {
        for (uint i; i < path.length; i++) {
            (address output, address input) = (path[i][2], path[i][1]);
            (address token0, ) = AkkaLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 1 ? path[i + 1][0] : _to;
            address factory = IAkkaPair(path[i][0]).factory();
            if (factory == 0x01bF7C66c6BD861915CdaaE475042d3c4BaE16A7) {
                IAkka1Pair(path[i][0]).swap(amount0Out, amount1Out, to);
            } else {
                IAkkaPair(path[i][0]).swap(
                    amount0Out,
                    amount1Out,
                    to,
                    new bytes(0)
                );
            }
        }
    }

    function _stargteBridgeToken(
        BridgeDescription memory bridge,
        uint256 amount,
        address receiver,
        SplitedPathDescription[] memory dstData
    ) internal virtual {
        IERC20(bridge.srcToken).approve(address(bridge.routerAddr), amount * 2);

        bytes memory data = abi.encode(
            dstData,
            amount,
            1000000000000,
            msg.sender,
            receiver
        );

        IStargateRouter(bridge.routerAddr).swap{value: msg.value}(
            bridge.dstChain,
            bridge.srcPool,
            bridge.dstPool,
            payable(receiver),
            amount,
            bridge.dstMinAmount,
            IStargateRouter.lzTxObj(bridge.bridgeFee, 0, "0x"),
            abi.encodePacked(bridge.destinationAddr),
            data
        );
    }

    function _multichainV6BridgeToken(
        BridgeDescription memory bridge,
        uint256 amount,
        address receiver,
        SplitedPathDescription[] memory dstData
    ) internal virtual {
        IERC20(bridge.srcToken).approve(bridge.routerAddr, amount * 2); //Why amount * 2?

        if (IUnderlying(bridge.srcAnyToken).underlying() != address(0)) {
            IBridgeAnyswap(bridge.routerAddr).anySwapOutUnderlying(
                bridge.srcAnyToken,
                receiver,
                amount,
                bridge.dstChain
            );
        } else {
            IBridgeAnyswap(bridge.routerAddr).anySwapOut(
                bridge.srcAnyToken,
                receiver,
                amount,
                bridge.dstChain
            );
        }
    }

    function _multichainV7BridgeTokenAndCall(
        BridgeDescription memory bridge,
        uint256 amount,
        address receiver,
        SplitedPathDescription[] memory dstData
    ) internal virtual {}

    function _iceBridgeToken(
        BridgeDescription memory bridge,
        uint256 amount
    ) internal virtual {
        IERC20(bridge.srcToken).approve(address(bridge.iceHandler), amount);

        IDepositExecute(bridge.routerAddr).deposit{value: msg.value}(
            bridge.domainId,
            bridge.resourceId,
            bridge.iceData
        );
    }

    function _bridge(
        BridgeDescription memory bridge,
        uint256 amount,
        address receiver,
        SplitedPathDescription[] memory dstData
    ) internal virtual {
        if (bridge.bridgeId == STARGATE_ID) {
            _stargteBridgeToken(bridge, amount, receiver, dstData);
        }
        if (bridge.bridgeId == MULTICHAIN_V6_ID) {
            _multichainV6BridgeToken(bridge, amount, receiver, dstData);
        }
        if (bridge.bridgeId == ICE_BRIDGE_ID) {
            _iceBridgeToken(bridge, amount);
        }
    }

    function singlePathSwap(
        SplitedPathDescription memory data,
        bool bridge,
        address to,
        address from,
        uint256 totalIn
    ) internal virtual returns (uint256 fAmountOut) {
        address[][] memory path = new address[][](data.paths.length);
        uint256[] memory fees = new uint[](data.paths.length);

        for (uint i; i < data.paths.length; i++) {
            path[i] = new address[](3);
            path[i][0] = data.paths[i].pairAddr;
            path[i][1] = data.paths[i].srcToken;
            path[i][2] = data.paths[i].dstToken;
            fees[i] = data.paths[i].fee;
        }

        uint256[] memory amounts = AkkaLibrary.getAmountsOut(
            data.srcAmount,
            path,
            fees
        );
        fAmountOut = amounts[amounts.length - 1];
        require(
            amounts[2] >= data.dstMinAmount,
            "AkkaRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        if (data.isFromNative == 1) {
            IWETH(_WETH).deposit{value: amounts[0]}();
            assert(IWETH(_WETH).transfer(path[0][0], amounts[0]));
        } else {
            IERC20(path[0][1]).approve(from, amounts[0] * 2);
            TransferHelper.safeTransferFrom(
                path[0][1],
                from,
                path[0][0],
                amounts[0]
            );
        }

        if (bridge || data.isToNative == 1) {
            _swap(amounts, path, address(this));
        } else {
            _swap(amounts, path, to);
        }

        if (data.isToNative == 1) {
            IWETH(_WETH).withdraw(amounts[amounts.length - 1]);
            TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        }
    }

    function multiPathSwap(
        uint256 amountIn,
        uint256 amountOutMin,
        SplitedPathDescription[] calldata data,
        BridgeDescription[] calldata bridge,
        SplitedPathDescription[] calldata dstData,
        address to
    ) external payable virtual override {
        uint256 f = 0;

        for (uint i; i < data.length; i++) {
            f += singlePathSwap(
                data[i],
                bridge.length > 0,
                to,
                msg.sender,
                amountIn
            );
        }

        if (bridge.length > 0) {
            _bridge(bridge[0], f, to, dstData);
        }
    }

    function multiPathSwapAfterBridge(
        uint256 amountIn,
        uint256 amountOutMin,
        address from,
        address to,
        address token,
        SplitedPathDescription[] calldata data
    ) external payable virtual override {
        IERC20(token).transferFrom(from, address(this), amountIn);

        uint256 f = 0;

        for (uint i; i < data.length; i++) {
            f += singlePathSwap(data[i], false, to, address(this), amountIn);
        }
    }

    function getBridgeFee(
        uint256 amountIn,
        BridgeDescription[] calldata bridge,
        SplitedPathDescription[] calldata dstData,
        address to
    ) external virtual override returns (uint256, uint256) {
        bytes memory data1 = abi.encode(dstData, amountIn, 1000000000000, to);
        return
            IStargateRouter(bridge[0].routerAddr).quoteLayerZeroFee(
                bridge[0].dstChain,
                1,
                abi.encode(to),
                data1,
                IStargateRouter.lzTxObj(bridge[0].bridgeFee, 0, "0x")
            );
    }
}

pragma solidity 0.8.4;
pragma abicoder v2;

interface IAkkaRouter {
    struct PathDescription {
        address srcToken;
        address dstToken;
        address pairAddr;
        uint fee;
        uint256 srcAmount;
        uint256 dstMinAmount;
    }

    struct SplitedPathDescription {
        uint256 srcAmount;
        uint256 dstMinAmount;
        uint isFromNative;
        uint isToNative;
        PathDescription[] paths;
    }

    struct BridgeDescription {
        address srcToken;
        address srcAnyToken; //for multichain
        uint16 srcPool;
        uint16 dstPool;
        uint16 dstChain;
        address routerAddr;
        address destinationAddr;
        uint fee;
        uint256 srcAmount;
        uint256 dstMinAmount;
        uint256 bridgeFee;
        uint256 bridgeId;
        uint8 domainId;
        bytes32 resourceId;
        address iceHandler;
        bytes iceData;
    }

    function multiPathSwap(
        uint256 amountIn,
        uint256 amountOutMin,
        SplitedPathDescription[] calldata data,
        BridgeDescription[] calldata bridge,
        SplitedPathDescription[] calldata dstData,
        address to
    ) external payable;

    function multiPathSwapAfterBridge(
        uint256 amountIn,
        uint256 amountOutMin,
        address from,
        address to,
        address token,
        SplitedPathDescription[] calldata data
    ) external payable;

    function getBridgeFee(
        uint256 amountIn,
        BridgeDescription[] calldata bridge,
        SplitedPathDescription[] calldata dstData,
        address to
    ) external returns (uint256, uint256);
}

pragma solidity 0.8.4;

interface IAkka1Pair {
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
    function swap(uint amount0Out, uint amount1Out, address to) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity 0.8.4;

interface IAkkaPair {
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

    function initialize(address, address) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;
pragma abicoder v2;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

interface IBridgeAnyswap {
    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to`
    function anySwapOut(
        address token,
        address to,
        uint amount,
        uint toChainID
    ) external;

    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to` by minting with `underlying`
    function anySwapOutUnderlying(
        address token,
        address to,
        uint amount,
        uint toChainID
    ) external;
}

pragma solidity 0.8.4;

import "../interfaces/IAkkaPair.sol";

import "./SafeMath.sol";

library AkkaLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address pairAddr, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IAkkaPair(pairAddr).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut, uint256 fee) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint256 amountInWithFee = amountIn.mul(fee);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(fee);
        amountIn = (numerator / denominator).add(1);
    }


    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(uint256 amountIn, address[][] memory path, uint256[] memory fees) internal view returns (uint256[] memory amounts) {
        // require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint256[](path.length+1);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(path[i][0], path[i][1], path[i][2]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, fees[i]);
        }
    }
    
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

interface IUnderlying {
    function underlying() external view returns (address);
}

pragma solidity 0.8.4;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity 0.8.4;

interface IERC20 {
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

pragma solidity 0.8.4;
pragma abicoder v2;

interface IDepositExecute {
    function deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

pragma solidity 0.8.4;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
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