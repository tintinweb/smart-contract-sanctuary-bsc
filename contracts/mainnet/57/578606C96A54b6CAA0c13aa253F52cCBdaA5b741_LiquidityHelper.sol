// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import '../interfaces/IApeFactory.sol';
import '../interfaces/IApePair.sol';
import '../interfaces/IERC20.sol';

contract LiquidityHelper {
    IApeFactory public factory;

    struct PairInfo {
        uint256 totalLpSupply;
        IERC20 token0;
        string token0Symbol;
        uint256 token0Balance;
        IERC20 token1;
        string token1Symbol;
        uint256 token1Balance;
    }

    struct LiquidityOutInfo {
        uint256 totalLpSupply;
        IERC20 token0;
        string token0Symbol;
        uint256 token0Out;
        IERC20 token1;
        string token1Symbol;
        uint256 token1Out;
    }

    constructor(address factoryAddress) {
        factory = IApeFactory(factoryAddress);
    }

    /// @notice Provide two tokens and this will find the pair address related and return useful values
    /// @param tokenA Address of token0
    /// @param tokenB Address of token1
    /// @return pairInfo PairInfo struct based on provided inputs
    function getPairBalances(address tokenA, address tokenB)
        public
        view
        returns (PairInfo memory pairInfo)
    {
        address pair = factory.getPair(tokenA, tokenB);
        pairInfo = getPairBalances(pair);
    }

    /// @notice Provide a pair address and this will find the pair address related and return useful values
    /// @param pairAddress Address of the pair contract
    /// @return pairInfo PairInfo struct based on provided inputs
    function getPairBalances(address pairAddress)
        public
        view
        returns (PairInfo memory pairInfo)
    {
        IApePair apePair = IApePair(pairAddress);
        pairInfo.token0 = IERC20(apePair.token0());
        pairInfo.token0Symbol = pairInfo.token0.symbol();
        pairInfo.token1 = IERC20(apePair.token1());
        pairInfo.token1Symbol = pairInfo.token1.symbol();

        pairInfo.totalLpSupply = apePair.totalSupply();
        pairInfo.token0Balance = pairInfo.token0.balanceOf(pairAddress);
        pairInfo.token1Balance = pairInfo.token1.balanceOf(pairAddress);
    }

    /// @notice Find the token outputs for unwrapping LP tokens
    /// @param tokenA Address of the token0 contract
    /// @param tokenB Address of the token1 contract
    /// @param lpBalance Amount of LP tokens to unwrap
    /// @return liquidityOutInfo LiquidityOutInfo based on input data
    function getLiquidityAmountsOut(
        address tokenA,
        address tokenB,
        uint256 lpBalance
    )
        public
        view
        returns (LiquidityOutInfo memory liquidityOutInfo)
    {
        address pair = factory.getPair(tokenA, tokenB);
        liquidityOutInfo = getLiquidityAmountsOut(pair, lpBalance);
    }

    /// @notice Find the token outputs for unwrapping LP tokens
    /// @param pairAddress Address of the pair contract
    /// @param lpBalance Amount of LP tokens to unwrap
    /// @return liquidityOutInfo LiquidityOutInfo based on input data
    function getLiquidityAmountsOut(address pairAddress, uint256 lpBalance)
        public
        view
        returns (LiquidityOutInfo memory liquidityOutInfo)
    {
        PairInfo memory pairInfo = getPairBalances(pairAddress);

        uint256 token0Out = lpBalance * (pairInfo.token0Balance) / (pairInfo.totalLpSupply);
        uint256 token1Out = lpBalance * (pairInfo.token1Balance) / (pairInfo.totalLpSupply);

        liquidityOutInfo = LiquidityOutInfo(
            pairInfo.totalLpSupply,
            pairInfo.token0,
            pairInfo.token0Symbol,
            token0Out,
            pairInfo.token1,
            pairInfo.token1Symbol,
            token1Out
        );
    }
}

pragma solidity 0.8.13;

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

pragma solidity 0.8.13;

interface IApePair {
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

pragma solidity 0.8.13;

interface IApeFactory {
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