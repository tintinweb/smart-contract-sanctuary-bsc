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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.7.0;

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.6.6;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import "./library/BarterLibrary.sol";
import "./interface/IBarterRouter.sol";
import "./interface/IBarterFactory.sol";
import "../tokenization/interface/IERC20.sol";
import "../tokenization/interface/IWETH.sol";
import { IAddressProviderRouter } from "./interface/IAddressProviderRouter.sol";

contract BarterRouter is IBarterRouter {
  address public immutable override factory;
  address public immutable override WETH;

  IAddressProviderRouter public ADDRESSES_PROVIDER;

  event liquidityAdded(address by, address pair, uint256 amount0, uint256 amount1, uint256 lpAmount, uint256 r0, uint256 r1, uint256 totalSupply);
  event swapPath(address token0, address token1);

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "BarterRouter: EXPIRED");
    _;
  }

  constructor(address _factory, address _WETH, IAddressProviderRouter provider) public {
    factory = _factory;
    WETH = _WETH;
    ADDRESSES_PROVIDER = provider;
  }

  modifier onlyPrimeAndZap() {
    _onlyPrimeAndZap();
    _;
  }

  function _onlyPrimeAndZap() internal view {
    require(ADDRESSES_PROVIDER.getPrimeContract() == msg.sender || ADDRESSES_PROVIDER.getZapContract() == msg.sender, "CALLER_NOT_PRIME_OR_ZAP_CONTRACT");
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
  ) private returns (uint256 amountA, uint256 amountB) {
    // create the pair if it doesn't exist yet
    if (IBarterFactory(factory).getPair(tokenA, tokenB) == address(0)) {
      IBarterFactory(factory).createPair(tokenA, tokenB);
    }
    (uint256 reserveA, uint256 reserveB) = BarterLibrary.getReserves(factory, tokenA, tokenB);
    if (reserveA == 0 && reserveB == 0) {
      (amountA, amountB) = (amountADesired, amountBDesired);
    } else {
      uint256 amountBOptimal = BarterLibrary.quote(amountADesired, reserveA, reserveB);
      if (amountBOptimal <= amountBDesired) {
        require(amountBOptimal >= amountBMin, "BarterRouter: INSUFFICIENT_B_AMOUNT");
        (amountA, amountB) = (amountADesired, amountBOptimal);
      } else {
        uint256 amountAOptimal = BarterLibrary.quote(amountBDesired, reserveB, reserveA);
        assert(amountAOptimal <= amountADesired);
        require(amountAOptimal >= amountAMin, "BarterRouter: INSUFFICIENT_A_AMOUNT");
        (amountA, amountB) = (amountAOptimal, amountBDesired);
      }
    }
  }

  // **** ONLY MASTER CONTRACT****
  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external override onlyPrimeAndZap ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
    (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
    address pair = BarterLibrary.pairFor(factory, tokenA, tokenB);
    TransferHelper.safeTransferFrom(tokenA, to, pair, amountA);
    TransferHelper.safeTransferFrom(tokenB, to, pair, amountB);
    liquidity = IBarterPair(pair).mint(to);
    (uint256 r0, uint256 r1, ) = IBarterPair(pair).getReserves();
    uint256 totalSupply = IBarterPair(pair).totalSupply();
    emit liquidityAdded(to, pair, amountA, amountB, liquidity, r0, r1, totalSupply);
  }

  // **** REMOVE LIQUIDITY ****
  // **** ONLY MASTER CONTRACT****
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) public override onlyPrimeAndZap ensure(deadline) returns (uint256 amountA, uint256 amountB) {
    address pair = BarterLibrary.pairFor(factory, tokenA, tokenB);
    IBarterPair(pair).transferFrom(to, pair, liquidity); // send liquidity to pair
    (uint256 amount0, uint256 amount1) = IBarterPair(pair).burn(to);
    (address token0, ) = BarterLibrary.sortTokens(tokenA, tokenB);
    (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
    require(amountA >= amountAMin, "BarterRouter: INSUFFICIENT_A_AMOUNT");
    require(amountB >= amountBMin, "BarterRouter: INSUFFICIENT_B_AMOUNT");
  }

  // **** SWAP ****
  // requires the initial amount to have already been sent to the first pair
  function _swap(uint256[] memory amounts, address[] memory path, address _to) private {
    for (uint256 i; i < path.length - 1; i++) {
      (address input, address output) = (path[i], path[i + 1]);
      (address token0, ) = BarterLibrary.sortTokens(input, output);
      uint256 amountOut = amounts[i + 1];
      (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
      address to = i < path.length - 2 ? BarterLibrary.pairFor(factory, output, path[i + 2]) : _to;
      IBarterPair(BarterLibrary.pairFor(factory, input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
      emit swapPath(path[0], path[1]);
    }
  }

  // **** ONLY MASTER CONTRACT****
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override onlyPrimeAndZap ensure(deadline) returns (uint256[] memory amounts) {
    amounts = BarterLibrary.getAmountsOut(factory, amountIn, path);
    require(amounts[amounts.length - 1] >= amountOutMin, "BarterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    TransferHelper.safeTransferFrom(path[0], to, BarterLibrary.pairFor(factory, path[0], path[1]), amounts[0]);
    _swap(amounts, path, to);
  }

  // **** ONLY MASTER CONTRACT****
  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override onlyPrimeAndZap ensure(deadline) returns (uint256[] memory amounts) {
    amounts = BarterLibrary.getAmountsIn(factory, amountOut, path);
    require(amounts[0] <= amountInMax, "BarterRouter: EXCESSIVE_INPUT_AMOUNT");
    TransferHelper.safeTransferFrom(path[0], to, BarterLibrary.pairFor(factory, path[0], path[1]), amounts[0]);
    _swap(amounts, path, to);
  }

  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) public pure override returns (uint256 amountB) {
    return BarterLibrary.quote(amountA, reserveA, reserveB);
  }

  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure override returns (uint256 amountOut) {
    return BarterLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
  }

  function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) public pure override returns (uint256 amountIn) {
    return BarterLibrary.getAmountOut(amountOut, reserveIn, reserveOut);
  }

  function getAmountsOut(uint256 amountIn, address[] memory path) public view override returns (uint256[] memory amounts) {
    return BarterLibrary.getAmountsOut(factory, amountIn, path);
  }

  function getAmountsIn(uint256 amountOut, address[] memory path) public view override returns (uint256[] memory amounts) {
    return BarterLibrary.getAmountsIn(factory, amountOut, path);
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.6.6;

interface IAddressProviderRouter {
  function getBarterFactory() external view returns (address);

  function getBarterRouter() external view returns (address);

  function getPrimeContract() external view returns (address);

  function getManagerContract() external view returns (address);

  function getZapContract() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IBarterFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;

  function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IBarterPair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IBarterRouter {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);

  function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;
import "../../../common/libraries/helpers/SafeMath.sol";
import "../interface/IBarterFactory.sol";
import "../interface/IBarterPair.sol";

library BarterLibrary {
  using SafeMath for uint256;

  // returns sorted token addresses, used to handle return values from pairs sorted in this order
  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
    require(tokenA != tokenB, "BarterLibrary: IDENTICAL_ADDRESSES");
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "BarterLibrary: ZERO_ADDRESS");
  }

  // calculates the CREATE2 address for a pair without making any external calls
  function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
    (address token0, address token1) = sortTokens(tokenA, tokenB);
    pair = IBarterFactory(factory).getPair(token0, token1);
    // pair = address(
    //   uint256(
    //     keccak256(
    //       abi.encodePacked(
    //         hex"ff",
    //         factory,
    //         keccak256(abi.encodePacked(token0, token1)),
    //         hex"e629780d1cc07bce8b7d9c08d089bce29808ab8cdc759e9621e1bac771547abd" // init code hash
    //       )
    //     )
    //   )
    // );
  }

  // fetches and sorts the reserves for a pair
  function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
    (address token0, ) = sortTokens(tokenA, tokenB);
    pairFor(factory, tokenA, tokenB);
    (uint256 reserve0, uint256 reserve1, ) = IBarterPair(pairFor(factory, tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
    require(amountA > 0, "BarterLibrary: INSUFFICIENT_AMOUNT");
    require(reserveA > 0 && reserveB > 0, "BarterLibrary: INSUFFICIENT_LIQUIDITY");
    amountB = amountA.mul(reserveB) / reserveA;
  }

  // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, "BarterLibrary: INSUFFICIENT_INPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "BarterLibrary: INSUFFICIENT_LIQUIDITY");
    uint256 amountInWithFee = amountIn.mul(9975);
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
    amountOut = numerator / denominator;
  }

  // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
  function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountIn) {
    require(amountOut > 0, "BarterLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "BarterLibrary: INSUFFICIENT_LIQUIDITY");
    uint256 numerator = reserveIn.mul(amountOut).mul(10000);
    uint256 denominator = reserveOut.sub(amountOut).mul(9975);
    amountIn = (numerator / denominator).add(1);
  }

  // performs chained getAmountOut calculations on any number of pairs
  function getAmountsOut(address factory, uint256 amountIn, address[] memory path) internal view returns (uint256[] memory amounts) {
    require(path.length >= 2, "BarterLibrary: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[0] = amountIn;
    for (uint256 i; i < path.length - 1; i++) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
      amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
    }
  }

  // performs chained getAmountIn calculations on any number of pairs
  function getAmountsIn(address factory, uint256 amountOut, address[] memory path) internal view returns (uint256[] memory amounts) {
    require(path.length >= 2, "BarterLibrary: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint256 i = path.length - 1; i > 0; i--) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
      amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
    }
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IWETH {
  function deposit() external payable;

  function transfer(address to, uint256 value) external returns (bool);

  function withdraw(uint256) external;
}