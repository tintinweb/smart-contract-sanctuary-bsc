/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

// Safemath Library
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

// interface IERC20
interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

}

// DEXLibrary Library
interface IDEXPair {
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
library DEXLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'DEXLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'DEXLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(bytes32 initHash, address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                initHash // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(bytes32 initHash, address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(initHash, factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IDEXPair(pairFor(initHash, factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'DEXLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'DEXLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'DEXLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'DEXLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(fee);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'DEXLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'DEXLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(fee);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(bytes32 initHash, address factory, uint amountIn, address[] memory path, uint fee) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'DEXLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(initHash, factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, fee);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(bytes32 initHash, address factory, uint amountOut, address[] memory path, uint fee) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'DEXLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(initHash, factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, fee);
        }
    }
}
interface IDEXFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract AnjiUtils {

    struct PairReserveInfo {
        address pair_addr;
        address token0;
        address token1;
        uint256 token_decimals;
        uint256 reserve_decimals;
        uint256 reserve0;
        uint256 reserve1;
        uint256 token_reserve;
        address token_pair;
        address factory;
    }

    function getDexPairInfo(address tokenAddr, address[] memory possiblePairs, address dexFactory) public view virtual returns (PairReserveInfo memory) {
        PairReserveInfo memory pairedReserveInfo;
        
        for (uint256 index = 0; index < possiblePairs.length; index++) {
            // Do not check token matching to itself
            if (possiblePairs[index] == tokenAddr) { continue; }
            // Check if factory has pair
            address pair_addr = IDEXFactory(dexFactory).getPair(tokenAddr, possiblePairs[index]);
            if (pair_addr == address(0)) { continue; }

            PairReserveInfo memory reserveInfo = getTokenPairReserveInfo(tokenAddr, pair_addr, dexFactory);

            if (reserveInfo.token_reserve > pairedReserveInfo.token_reserve) {
                pairedReserveInfo = reserveInfo;
            }
        }

        return pairedReserveInfo;
    }

    function getDexBestPairInfo(address tokenAddr, address[] memory possiblePairs, address[] memory dexFactories) public view virtual returns (PairReserveInfo[] memory) {
        PairReserveInfo[] memory pairs = new PairReserveInfo[](dexFactories.length);

        for (uint256 index = 0; index < dexFactories.length; index++) {
            pairs[index] = getDexPairInfo(tokenAddr, possiblePairs, dexFactories[index]);
        }

        return pairs;
    }

    function getLargestPairingCrossDexs(address tokenAddr, address[] memory possiblePairs, address[] memory dexFactories) public view virtual returns (PairReserveInfo memory) {
        PairReserveInfo memory pairedReserveInfo;
        PairReserveInfo[] memory dexPairs = getDexBestPairInfo(tokenAddr, possiblePairs, dexFactories);

        for (uint256 index = 0; index < dexPairs.length; index++) {
            if (dexPairs[index].pair_addr == address(0)) { continue; }

            if (dexPairs[index].token_reserve > pairedReserveInfo.token_reserve) {
                pairedReserveInfo = dexPairs[index];
            }
        }

        return pairedReserveInfo;
    }

    function getWalletBalances(address wallet, address[] memory token_addresses) public view virtual returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](token_addresses.length);

        for (uint256 index = 0; index < token_addresses.length; index++) {
            try IERC20(token_addresses[index]).balanceOf(wallet) returns (uint v) {
                balances[index] = v;
            } catch (bytes memory /*lowLevelData*/) {
                balances[index] = 0;
            }
        }

        return balances;
    }

    function getTokenPairReservesInfo(address[] memory token_addresses, address[] memory token_pair_addresses, address[] memory factories) public view virtual returns (PairReserveInfo[] memory) {
        require(token_addresses.length == token_pair_addresses.length, 'There must be the same amount of pair addresses to token addresses');

        PairReserveInfo[] memory reserveInfo = new PairReserveInfo[](token_addresses.length);

        for (uint256 index = 0; index < token_pair_addresses.length; index++) {
            reserveInfo[index] = getTokenPairReserveInfo(token_addresses[index], token_pair_addresses[index], factories[index]);
        }

        return reserveInfo;
    }

    function getTokenPairReserveInfo(address tokenAddress, address tokenPairAddress, address factory) public view virtual returns (PairReserveInfo memory) {
        address paired_token = tokenAddress == IDEXPair(tokenPairAddress).token0() ? IDEXPair(tokenPairAddress).token1() : IDEXPair(tokenPairAddress).token0();

        (uint256 reserve0, uint256 reserve1, ) = IDEXPair(tokenPairAddress).getReserves();
        (address token0, address token1) = DEXLibrary.sortTokens(tokenAddress, paired_token);
        (uint256 token_decimals, uint256 reserve_decimals) = (IERC20(tokenAddress).decimals(), IERC20(paired_token).decimals());

        return PairReserveInfo({
            pair_addr: tokenPairAddress,
            reserve0: reserve0,
            reserve1: reserve1,
            token_decimals: token_decimals,
            reserve_decimals: reserve_decimals,
            token0: token0,
            token1: token1,
            token_reserve: token0 == tokenAddress ? reserve0 : reserve1,
            token_pair: paired_token,
            factory: factory
        });
    }
}