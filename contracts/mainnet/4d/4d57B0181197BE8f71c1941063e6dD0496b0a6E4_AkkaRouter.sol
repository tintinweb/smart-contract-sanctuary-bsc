/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// Sources flattened with hardhat v2.12.6 https://hardhat.org

// File @uniswap/lib/contracts/libraries/[email protected]

// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.4;

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


// File contracts/interfaces/IAkka1Pair.sol


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


// File contracts/interfaces/IAkkaPair.sol


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


// File contracts/interfaces/IAkkaRouter.sol


interface IAkkaRouter {
    struct PathDescription {
        address srcToken;
        address dstToken;
        address pairAddr;
        uint fee;
        uint256 srcAmount;
        uint256 dstMinAmount;
        uint feeSrc;
        uint feeDst;
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
        uint256 dstSrcAmount;
        uint256 dstReturnAmount;
        uint256 bridgeFee;
        uint16 bridgeId;
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
    ) external view returns (uint256, uint256);
}


// File contracts/interfaces/IBridgeAnyswap.sol


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


// File contracts/interfaces/IERC20.sol


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


// File contracts/interfaces/IIceBridge.sol


interface IIceBridge {
    function deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable;
}


// File contracts/interfaces/IStargateRouter.sol


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


// File contracts/interfaces/IUnderlying.sol


interface IUnderlying {
    function underlying() external view returns (address);
}


// File contracts/interfaces/IWETH.sol


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}


// File contracts/libraries/SafeMath.sol


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


// File contracts/libraries/AkkaLibrary.sol

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
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut, uint256 fee, uint256 feeSrc, uint256 feeDst) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint256 amountInWithFeeSrc = amountIn.mul(feeSrc) / 10000;
        uint256 amountInWithFee = amountInWithFeeSrc.mul(fee);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
        amountOut = amountOut.mul(feeDst) / 10000;
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
    function getAmountsOut(uint256 amountIn, address[][] memory path, uint256[][] memory fees) internal view returns (uint256[] memory amounts) {
        // require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint256[](path.length+1);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(path[i][0], path[i][1], path[i][2]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, fees[i][0], fees[i][1], fees[i][2]);
        }
    }
    
}


// File contracts/AkkaRouter.sol

contract AkkaRouter is IAkkaRouter {
    address private _WETH;
    address private receiverContract;

    uint16 immutable STARGATE_ID = 1;
    uint16 immutable MULTICHAIN_V6_ID = 2;
    uint16 immutable MULTICHAIN_V7_ID = 3;
    uint16 immutable ICE_BRIDGE_ID = 4;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "AkkaRouter: EXPIRED");
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
            IAkkaPair(path[i][0]).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function _stargateBridgeToken(
        BridgeDescription memory bridge,
        uint256 amount,
        address receiver,
        SplitedPathDescription[] memory dstData
    ) internal virtual {
        IERC20(bridge.srcToken).approve(address(bridge.routerAddr), amount * 2);

        bytes memory data = abi.encode(
            dstData,
            bridge.dstSrcAmount,
            bridge.dstReturnAmount,
            msg.sender,
            receiver
        );

        IStargateRouter(bridge.routerAddr).swap{value: bridge.fee}(
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

    function _iceBridgeToken(
        BridgeDescription memory bridge,
        uint256 amount,
        address to
    ) internal virtual {
        IERC20(bridge.srcToken).approve(address(bridge.iceHandler), amount);

        bytes memory data = encodeIceBridgeData(amount, to);

        IIceBridge(bridge.routerAddr).deposit{value: msg.value}(
            bridge.domainId,
            bridge.resourceId,
            data
        );
    }

    function _multichainV6BridgeToken(
        BridgeDescription memory bridge,
        uint256 amount,
        address receiver
    ) internal virtual {
        IERC20(bridge.srcToken).approve(bridge.routerAddr, amount * 2);

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

    function _bridge(
        BridgeDescription memory bridge,
        uint256 amount,
        address receiver,
        SplitedPathDescription[] memory dstData
    ) internal virtual {
        if (bridge.bridgeId == STARGATE_ID) {
            _stargateBridgeToken(bridge, amount, receiver, dstData);
        }

        if (bridge.bridgeId == MULTICHAIN_V6_ID) {
            _multichainV6BridgeToken(bridge, amount, receiver);
        }

        if (bridge.bridgeId == ICE_BRIDGE_ID) {
            _iceBridgeToken(bridge, amount, bridge.destinationAddr);
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
        uint256[][] memory fees = new uint256[][](data.paths.length);

        for (uint i; i < data.paths.length; i++) {
            path[i] = new address[](3);
            fees[i] = new uint256[](3);
            path[i][0] = data.paths[i].pairAddr;
            path[i][1] = data.paths[i].srcToken;
            path[i][2] = data.paths[i].dstToken;
            fees[i][0] = data.paths[i].fee;
            fees[i][1] = data.paths[i].feeSrc;
            fees[i][2] = data.paths[i].feeDst;
        }
        // data[0].paths[paths.length-1][]
        uint256[] memory amounts = AkkaLibrary.getAmountsOut(
            data.srcAmount,
            path,
            fees
        );
        fAmountOut = amounts[amounts.length - 1];
        // require(
        //     amounts[amounts.length - 1] >= data.dstMinAmount,
        //     "AkkaRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        // );
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
        require(f >= amountOutMin, "AkkaRouter: price impact");

        if (bridge.length > 0) {
            if (data.length == 0) {
                TransferHelper.safeTransferFrom(
                    bridge[0].srcToken,
                    msg.sender,
                    address(this),
                    amountIn
                );
            }
            _bridge(bridge[0], f > 0 ? f : amountIn, to, dstData);
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
        require(f >= amountOutMin, "AkkaRouter: price impact");
    }

    function getBridgeFee(
        uint256 amountIn,
        BridgeDescription[] calldata bridge,
        SplitedPathDescription[] calldata dstData,
        address to
    ) external view virtual override returns (uint256, uint256) {
        bytes memory data1;
        if (dstData.length != 0) {
            data1 = abi.encode(
                dstData,
                amountIn,
                dstData[dstData.length - 1].dstMinAmount,
                to
            );
        } else {
            data1 = abi.encode("");
        }
        BridgeDescription memory bridgeData = bridge[0];
        return
            IStargateRouter(bridgeData.routerAddr).quoteLayerZeroFee(
                bridgeData.dstChain,
                1,
                abi.encode(to),
                data1,
                IStargateRouter.lzTxObj(bridgeData.bridgeFee, 0, "0x")
            );
    }

    function encodeIceBridgeData(
        uint256 amount,
        address to
    ) public pure returns (bytes memory data) {
        data = abi.encodePacked(amount, uint(20), to);
    }
}