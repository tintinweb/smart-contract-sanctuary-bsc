/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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

// File: contracts/1_Storage.sol



pragma solidity 0.8.7;


contract Storage {

    // GLOBAL DATA UINT256
    function EX_BusdToCoinPrice(address busdBnbPairAddress, address tokenBnbPairAddress) external view returns (uint256 aowBnbPrice_, uint256 aowBusdPrice_) {
        uint256 requestedValue = 10 ** 18;
        // Busd Amount -> Converts to Bnb Amount -> Converts to Aow Amount
        (uint256 aowBnbPrice ,uint256 aowBusdPrice) = getBusdToBnbToTokenPrice(tokenBnbPairAddress, busdBnbPairAddress, requestedValue);
        return (aowBnbPrice, aowBusdPrice);
    }
    function EX_CoinToBusdPrice(address busdBnbPairAddress, address tokenBnbPairAddress) external view returns (uint256 aowBnbPrice_, uint256 aowBusdPrice_) {
        uint256 requestedValue = 10 ** 18;
        // Busd Amount -> Converts to Bnb Amount -> Converts to Aow Amount
        (uint256 aowBnbPrice ,uint256 aowBusdPrice) = getBusdToBnbToTokenPrice(busdBnbPairAddress, tokenBnbPairAddress, requestedValue);
        return (aowBnbPrice, aowBusdPrice);
    }
    function getBusdToBnbToTokenPrice(address tokenBnbPairAddress, address busdBnbPairAddress, uint amount) 
        private view returns (uint256 bnbPrice_, uint256 tokenPrice_) {
        uint busdPriceAsBnb = getTokenPriceAsAow(busdBnbPairAddress, amount);
        uint tokenPriceAsToken = getTokenPriceAsAow(tokenBnbPairAddress, busdPriceAsBnb);
        return (busdPriceAsBnb, tokenPriceAsToken);
    }
    function getTokenPriceAsAow(address pairAddress, uint amount) private view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        return((amount*Res1)/Res0); // Returns amount of token1 needed to buy token0 (returns bnb)
    }
}