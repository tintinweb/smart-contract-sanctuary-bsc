/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// File: contracts/vdex/interfaces/IWETH.sol



pragma solidity >=0.5.0;



interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


// File: contracts/vdex/interfaces/IERC20Permit.sol



pragma solidity ^0.8.0;



interface IERC20Permit {

    function permit(

        address owner,

        address spender,

        uint256 value,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external;



    function nonces(address owner) external view returns (uint256);



    function DOMAIN_SEPARATOR() external view returns (bytes32);

}


// File: contracts/vdex/interfaces/IERC20.sol



pragma solidity ^0.8.0;



interface IERC20 {

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

    event Transfer(address indexed from, address indexed to, uint256 value);



    function name() external view returns (string memory);



    function symbol() external view returns (string memory);



    function decimals() external view returns (uint8);



    function totalSupply() external view returns (uint256);



    function balanceOf(address owner) external view returns (uint256);



    function allowance(address owner, address spender)

        external

        view

        returns (uint256);



    function approve(address spender, uint256 value) external returns (bool);



    function transfer(address to, uint256 value) external returns (bool);



    function transferFrom(

        address from,

        address to,

        uint256 value

    ) external returns (bool);

}


// File: contracts/vdex/interfaces/IVFactory.sol



pragma solidity ^0.8.0;



interface IVFactory {

    event PairCreated(

        address indexed token0,

        address indexed token1,

        address pair,

        uint256

    );



    function feeTo() external view returns (address);



    function admin() external view returns (address);



    function getPair(address tokenA, address tokenB)

        external

        view

        returns (address pair);



    function allPairs(uint256) external view returns (address pair);



    function allPairsLength() external view returns (uint256);



    function createPair(address tokenA, address tokenB)

        external

        returns (address pair);



    function setFeeTo(address) external;



    function setAdmin(address) external;

}


// File: contracts/vdex/interfaces/IVRouter.sol



pragma solidity ^0.8.0;



interface IVRouter {

    function factory() external view returns (address);



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



    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint256 liquidity,

        uint256 amountAMin,

        uint256 amountBMin,

        address to,

        uint256 deadline

    ) external returns (uint256 amountA, uint256 amountB);



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

}


// File: contracts/vdex/libraries/TransferHelper.sol



pragma solidity ^0.8.0;



// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false

library TransferHelper {

    function safeApprove(

        address token,

        address to,

        uint256 value

    ) internal {

        // bytes4(keccak256(bytes('approve(address,uint256)')));

        (bool success, bytes memory data) = token.call(

            abi.encodeWithSelector(0x095ea7b3, to, value)

        );

        require(

            success && (data.length == 0 || abi.decode(data, (bool))),

            "TransferHelper: APPROVE_FAILED"

        );

    }



    function safeTransfer(

        address token,

        address to,

        uint256 value

    ) internal {

        // bytes4(keccak256(bytes('transfer(address,uint256)')));

        (bool success, bytes memory data) = token.call(

            abi.encodeWithSelector(0xa9059cbb, to, value)

        );

        require(

            success && (data.length == 0 || abi.decode(data, (bool))),

            "TransferHelper: TRANSFER_FAILED"

        );

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



    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));

        require(success, "TransferHelper: ETH_TRANSFER_FAILED");

    }

}


// File: contracts/vdex/libraries/SafeMath.sol



pragma solidity ^0.8.0;



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");

    }



    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");

    }



    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");

    }

}


// File: contracts/vdex/interfaces/IVPair.sol



pragma solidity ^0.8.0;



interface IVPair {

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

    event Transfer(address indexed from, address indexed to, uint256 value);



    function name() external pure returns (string memory);



    function symbol() external pure returns (string memory);



    function decimals() external pure returns (uint8);



    function totalSupply() external view returns (uint256);



    function balanceOf(address owner) external view returns (uint256);



    function allowance(address owner, address spender)

        external

        view

        returns (uint256);



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

    event Sync(uint112 reserve0, uint112 reserve1);

    event AmountsUpdate(

        uint112 amount0Min,

        uint112 amount0Max,

        uint112 amount1Min,

        uint112 amount1Max

    );



    function MINIMUM_LIQUIDITY() external pure returns (uint256);



    function factory() external view returns (address);



    function token0() external view returns (address);



    function token1() external view returns (address);



    function setAmounts(

        uint112 amount0Min,

        uint112 amount0Max,

        uint112 amount1Min,

        uint112 amount1Max

    ) external;



    function getReserves()

        external

        view

        returns (

            uint112 reserve0,

            uint112 reserve1,

            uint32 blockTimestampLast

        );



    function getAmounts()

        external

        view

        returns (

            uint112 amount0Min,

            uint112 amount0Max,

            uint112 amount1Min,

            uint112 amount1Max

        );



    function price0CumulativeLast() external view returns (uint256);



    function price1CumulativeLast() external view returns (uint256);



    function kLast() external view returns (uint256);



    function mint(address to) external returns (uint256 liquidity);



    function burn(address to)

        external

        returns (uint256 amount0, uint256 amount1);



    function swap(

        uint256 amount0Out,

        uint256 amount1Out,

        address to

    ) external;



    function skim(address to) external;



    function sync() external;



    function initialize(address, address) external;

}


// File: contracts/vdex/libraries/VLibrary.sol



pragma solidity ^0.8.0;





library VLibrary {

    using SafeMath for uint256;



    // calculates the CREATE2 address for a pair without making any external calls

    function pairFor(

        address factory,

        address tokenA,

        address tokenB

    ) internal pure returns (address pair) {

        pair = address(

            uint160(

                uint256(

                    keccak256(

                        abi.encodePacked(

                            hex"ff",

                            factory,

                            keccak256(abi.encodePacked(tokenA, tokenB)),

                            hex"5ed5df8cd82dc987e9074c46d7b62c505ef15fac9531b79055a3141f8db656ec" // init code hash

                        )

                    )

                )

            )

        );

    }



    // fetches the reserves for a pair

    function getReserves(

        address tokenA,

        address tokenB,

        address pair

    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        require(tokenA != tokenB, "VLibrary: IDENTICAL_ADDRESSES");

        address token0 = IVPair(pair).token0();

        require(tokenA != address(0) && tokenB != address(0), "VLibrary: ZERO_ADDRESS");

        (uint256 reserve0, uint256 reserve1,) = IVPair(pair).getReserves();

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

        require(amountA > 0, "VLibrary: INSUFFICIENT_AMOUNT");

        require(

            reserveA > 0 && reserveB > 0,

            "VLibrary: INSUFFICIENT_LIQUIDITY"

        );

        amountB = amountA.mul(reserveB) / reserveA;

    }



    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset

    function getAmountOut(

        uint256 amountIn,

        uint256 reserveIn,

        uint256 reserveOut

    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, "VLibrary: INSUFFICIENT_INPUT_AMOUNT");

        require(

            reserveIn > 0 && reserveOut > 0,

            "VLibrary: INSUFFICIENT_LIQUIDITY"

        );

        uint256 amountInWithFee = amountIn.mul(997);

        uint256 numerator = amountInWithFee.mul(reserveOut);

        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);

        amountOut = numerator / denominator;

    }



    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset

    function getAmountIn(

        uint256 amountOut,

        uint256 reserveIn,

        uint256 reserveOut

    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, "VLibrary: INSUFFICIENT_OUTPUT_AMOUNT");

        require(

            reserveIn > 0 && reserveOut > 0,

            "VLibrary: INSUFFICIENT_LIQUIDITY"

        );

        uint256 numerator = reserveIn.mul(amountOut).mul(1000);

        uint256 denominator = reserveOut.sub(amountOut).mul(997);

        amountIn = (numerator / denominator).add(1);

    }



    function getAmountsOut(

        uint256 amountIn,

        address[] memory path,

        address pair

    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "VLibrary: INVALID_PATH");

        amounts = new uint256[](path.length);

        amounts[0] = amountIn;

        for (uint256 i; i < path.length - 1; i++) {

            (uint256 reserveIn, uint256 reserveOut) = getReserves(

                path[i],

                path[i + 1],

                pair

            );

            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);

        }

    }



    function getAmountsIn(

        uint256 amountOut,

        address[] memory path,

        address pair

    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "VLibrary: INVALID_PATH");

        amounts = new uint256[](path.length);

        amounts[amounts.length - 1] = amountOut;

        for (uint256 i = path.length - 1; i > 0; i--) {

            (uint256 reserveIn, uint256 reserveOut) = getReserves(

                path[i - 1],

                path[i],

                pair

            );

            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);

        }

    }

}


// File: contracts/vdex/VRouter.sol



pragma solidity ^0.8.0;











contract VRouter is IVRouter {

    using SafeMath for uint256;

    address public immutable override factory;

    address public immutable WETH;



    modifier ensure(uint256 deadline) {

        require(deadline >= block.timestamp, "VRouter: EXPIRED");

        _;

    }



    constructor(address _factory, address _WETH) {

        factory = _factory;

        WETH = _WETH;

    }



    receive() external payable {

        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract

    }



    function _liquidityFromReserves(

        uint256 reserveA,

        uint256 reserveB,

        uint256 amountADesired,

        uint256 amountBDesired,

        uint256 amountAMin,

        uint256 amountBMin) private pure returns (uint256 amountA, uint256 amountB) {

        if (reserveA == 0 && reserveB == 0) {

            (amountA, amountB) = (amountADesired, amountBDesired);

        } else {

            uint256 amountBOptimal = VLibrary.quote(

                amountADesired,

                reserveA,

                reserveB

            );

            if (amountBOptimal <= amountBDesired) {

                require(

                    amountBOptimal >= amountBMin,

                    "VRouter: INSUFFICIENT_B_AMOUNT"

                );

                (amountA, amountB) = (amountADesired, amountBOptimal);

            } else {

                uint256 amountAOptimal = VLibrary.quote(

                    amountBDesired,

                    reserveB,

                    reserveA

                );

                assert(amountAOptimal <= amountADesired);

                require(

                    amountAOptimal >= amountAMin,

                    "VRouter: INSUFFICIENT_A_AMOUNT"

                );

                (amountA, amountB) = (amountAOptimal, amountBDesired);

            }

        }

    }



    function _addLiquidity(

        address tokenA,

        address tokenB,

        uint256 amountADesired,

        uint256 amountBDesired,

        uint256 amountAMin,

        uint256 amountBMin,

        address pair

    ) internal virtual returns (uint256 amountA, uint256 amountB) {

        require(pair != address(0), "VDEX: PAIR_NOT_EXISTS"); // single check is sufficient



        (uint256 reserveA, uint256 reserveB) = VLibrary.getReserves(

            tokenA,

            tokenB,

            pair

        );

        (amountA, amountB) = _liquidityFromReserves(reserveA, reserveB, amountADesired, amountBDesired, amountAMin, amountBMin);

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

        address pair = IVFactory(factory).getPair(tokenA, tokenB);

        (amountA, amountB) = _addLiquidity(

            tokenA,

            tokenB,

            amountADesired,

            amountBDesired,

            amountAMin,

            amountBMin,

            pair

        );

        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);

        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);

        liquidity = IVPair(pair).mint(to);

    }



    function _addLiquidityWithPermit(

        address vndt,

        address tokenB,

        uint256 amountVNDTDesired,

        uint256 amountBDesired,

        uint256 amountVNDTMin,

        uint256 amountBMin,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s,

        address pair

    ) internal returns (uint256 amountA, uint256 amountB) {

        {

            (uint256 reserveA, uint256 reserveB) = VLibrary.getReserves(vndt, tokenB, pair);

            (amountA, amountB) = _liquidityFromReserves(reserveA, reserveB, amountVNDTDesired, amountBDesired,

                amountVNDTMin, amountBMin);

        }

        IERC20Permit(vndt).permit(

            msg.sender,

            address(this),

            amountVNDTDesired,

            deadline,

            v,

            r,

            s

        );

    }



    function addLiquidityWithPermit(

        address vndt,

        address tokenB,

        uint256 amountVNDTDesired,

        uint256 amountBDesired,

        uint256 amountVNDTMin,

        uint256 amountBMin,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s,

        address pair

    ) external ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity) {

        (amountA, amountB) = _addLiquidityWithPermit(

            vndt,

            tokenB,

            amountVNDTDesired,

            amountBDesired,

            amountVNDTMin,

            amountBMin,

            deadline,

            v,

            r,

            s,

            pair

        );

        TransferHelper.safeTransferFrom(vndt, msg.sender, pair, amountA);

        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);

        liquidity = IVPair(pair).mint(msg.sender);

    }



    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external virtual payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {

        address pair = IVFactory(factory).getPair(token, WETH);

        (amountToken, amountETH) = _addLiquidity(

            token,

            WETH,

            amountTokenDesired,

            msg.value,

            amountTokenMin,

            amountETHMin,

            pair

        );

        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);

        IWETH(WETH).deposit{value: amountETH}();

        assert(IWETH(WETH).transfer(pair, amountETH));

        liquidity = IVPair(pair).mint(to);

        // refund dust eth, if any

        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);

    }



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

        address pair = IVFactory(factory).getPair(tokenA, tokenB);

        IVPair(pair).transferFrom(msg.sender, pair, liquidity);

        (uint256 amount0, uint256 amount1) = IVPair(pair).burn(to);

        address token0 = IVPair(pair).token0();

        (amountA, amountB) = tokenA == token0

            ? (amount0, amount1)

            : (amount1, amount0);

        require(amountA >= amountAMin, "VRouter: INSUFFICIENT_A_AMOUNT");

        require(amountB >= amountBMin, "VRouter: INSUFFICIENT_B_AMOUNT");

    }



    function removeLiquidityETH(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) public virtual ensure(deadline) returns (uint amountToken, uint amountETH) {

        (amountToken, amountETH) = removeLiquidity(

            token,

            WETH,

            liquidity,

            amountTokenMin,

            amountETHMin,

            address(this),

            deadline

        );



        TransferHelper.safeTransfer(token, to, amountToken);

        IWETH(WETH).withdraw(amountETH);

        TransferHelper.safeTransferETH(to, amountETH);

    }



    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint256 liquidity,

        uint256 amountAMin,

        uint256 amountBMin,

        address to,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) public returns (uint256 amountA, uint256 amountB) {

        address pair = IVFactory(factory).getPair(tokenA, tokenB);

        IVPair(pair).permit(

            msg.sender,

            address(this),

            liquidity,

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



    function _swap(

        uint256[] memory amounts,

        address[] memory path,

        address _to,

        address pair

    ) internal virtual {

        for (uint256 i; i < path.length - 1; i++) {

            (address input, address output) = (path[i], path[i + 1]);

            require(input != output, "VLibrary: IDENTICAL_ADDRESSES");

            require(input != address(0) && output != address(0), "VLibrary: ZERO_ADDRESS");

            address token0 = IVPair(pair).token0();

            uint256 amountOut = amounts[i + 1];

            (uint256 amount0Out, uint256 amount1Out) = input == token0

                ? (uint256(0), amountOut)

                : (amountOut, uint256(0));

            IVPair(pair).swap(

                amount0Out,

                amount1Out,

                _to

            );

        }

    }



    function swapExactTokensForTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline,

        address pair

    )

    external

    virtual

    ensure(deadline)

    returns (uint256[] memory amounts)

    {

        amounts = VLibrary.getAmountsOut(amountIn, path, pair);

        require(

            amounts[amounts.length - 1] >= amountOutMin,

            "VRouter: INSUFFICIENT_OUTPUT_AMOUNT"

        );

        TransferHelper.safeTransferFrom(

            path[0],

            msg.sender,

            pair,

            amounts[0]

        );

        _swap(amounts, path, to, pair);

    }



    function swapExactTokensForTokensWithPermit(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s,

        address pair

    )

    external

    virtual

    ensure(deadline)

    returns (uint256[] memory amounts)

    {

        amounts = VLibrary.getAmountsOut(amountIn, path, pair);

        require(

            amounts[amounts.length - 1] >= amountOutMin,

            "VRouter: INSUFFICIENT_OUTPUT_AMOUNT"

        );

        IERC20Permit(path[0]).permit(

            msg.sender,

            address(this),

            amounts[0],

            deadline,

            v,

            r,

            s

        );

        TransferHelper.safeTransferFrom(path[0], msg.sender, pair, amounts[0]);

        _swap(amounts, path, to, pair);

    }



    function swapTokensForExactTokens(

        uint256 amountOut,

        uint256 amountInMax,

        address[] calldata path,

        address to,

        uint256 deadline,

        address pair

    )

    external

    virtual

    ensure(deadline)

    returns (uint256[] memory amounts)

    {

        amounts = VLibrary.getAmountsIn(amountOut, path, pair);

        require(amounts[0] <= amountInMax, "VRouter: EXCESSIVE_INPUT_AMOUNT");

        TransferHelper.safeTransferFrom(

            path[0],

            msg.sender,

            pair,

            amounts[0]

        );

        _swap(amounts, path, to, pair);

    }



    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline, address pair)

    external

    virtual

    payable

    ensure(deadline)

    returns (uint[] memory amounts)

    {

        require(path[0] == WETH, 'VRouter: INVALID_PATH');

        amounts = VLibrary.getAmountsOut(msg.value, path, pair);

        require(amounts[amounts.length - 1] >= amountOutMin, 'VRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        IWETH(WETH).deposit{value: amounts[0]}();

        assert(IWETH(WETH).transfer(pair, amounts[0]));

        _swap(amounts, path, to, pair);

    }

    function swapTokensForExactETH(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline,

        address pair)

    external

    virtual

    ensure(deadline)

    returns (uint[] memory amounts)

    {

        require(path[path.length - 1] == WETH, 'VRouter: INVALID_PATH');

        amounts = VLibrary.getAmountsIn(amountOut, path, pair);

        require(amounts[0] <= amountInMax, 'VRouter: EXCESSIVE_INPUT_AMOUNT');

        TransferHelper.safeTransferFrom(path[0], msg.sender, pair, amounts[0]);

        _swap(amounts, path, address(this), pair);

        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

    }

    function swapExactTokensForETH(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline,

        address pair)

    external

    virtual

    ensure(deadline)

    returns (uint[] memory amounts)

    {

        require(path[path.length - 1] == WETH, 'VRouter: INVALID_PATH');

        amounts = VLibrary.getAmountsOut(amountIn, path, pair);

        require(amounts[amounts.length - 1] >= amountOutMin, 'VRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        TransferHelper.safeTransferFrom(path[0], msg.sender, pair, amounts[0]);

        _swap(amounts, path, address(this), pair);

        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline, address pair)

    external

    virtual

    payable

    ensure(deadline)

    returns (uint[] memory amounts)

    {

        require(path[0] == WETH, 'VRouter: INVALID_PATH');

        amounts = VLibrary.getAmountsIn(amountOut, path, pair);

        require(amounts[0] <= msg.value, 'VRouter: EXCESSIVE_INPUT_AMOUNT');

        IWETH(WETH).deposit{value : amounts[0]}();

        assert(IWETH(WETH).transfer(pair, amounts[0]));

        _swap(amounts, path, to, pair);

        // refund dust eth, if any

        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);

    }



    function quote(

        uint256 amountA,

        uint256 reserveA,

        uint256 reserveB

    ) public pure virtual override returns (uint256 amountB) {

        return VLibrary.quote(amountA, reserveA, reserveB);

    }



    function getAmountOut(

        uint256 amountIn,

        uint256 reserveIn,

        uint256 reserveOut

    ) public pure virtual override returns (uint256 amountOut) {

        return VLibrary.getAmountOut(amountIn, reserveIn, reserveOut);

    }



    function getAmountIn(

        uint256 amountOut,

        uint256 reserveIn,

        uint256 reserveOut

    ) public pure virtual override returns (uint256 amountIn) {

        return VLibrary.getAmountIn(amountOut, reserveIn, reserveOut);

    }



    function getAmountsOut(uint256 amountIn, address[] memory path, address pair)

        public

        view

        virtual

        returns (uint256[] memory amounts)

    {

        return VLibrary.getAmountsOut(amountIn, path, pair);

    }



    function getAmountsIn(uint256 amountOut, address[] memory path, address pair)

        public

        view

        virtual

        returns (uint256[] memory amounts)

    {

        return VLibrary.getAmountsIn(amountOut, path, pair);

    }

}