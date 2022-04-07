// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import '../interfaces/IApeFactory.sol';
import '../interfaces/IApePair.sol';
import '../interfaces/IERC20.sol';
import '../libraries/SafeMath.sol';

contract LiquidityHelper {
    using SafeMath for uint256;
    IApeFactory public factory;

    constructor(address factoryAddress) public {
        factory = IApeFactory(factoryAddress);
    }

    /// @notice Provide two tokens and this will find the pair address related and return useful values
    /// @param token0 Address of token0
    /// @param token1 Address of token1
    /// @return totalLpSupply The total supply of LP tokens minted for the pair
    /// @return token0 token0 as registered on the pair contract
    /// @return token0Balance The total balance of token0 in the pair
    /// @return token1 token1 as registered on the pair contract
    /// @return token1Balance The total balance of token1 in the pair
    function getPairBalances(address _tokenA, address _tokenB)
        public
        view
        returns (
            uint256 totalLpSupply,
            IERC20 token0, 
            uint256 token0Balance, 
            IERC20 token1, 
            uint256 token1Balance
        )
    {
        address pair = factory.getPair(_tokenA, _tokenB);
        return getPairBalances(pair);
    }

    /// @notice Provide a pair address and this will find the pair address related and return useful values
    /// @param pairAddress Address of the pair contract
    /// @return totalLpSupply The total supply of LP tokens minted for the pair
    /// @return token0 token0 as registered on the pair contract
    /// @return token0Balance The total balance of token0 in the pair
    /// @return token1 token1 as registered on the pair contract
    /// @return token1Balance The total balance of token1 in the pair
    function getPairBalances(address pairAddress)
        public
        view
        returns (
            uint256 totalLpSupply,
            IERC20 token0, 
            uint256 token0Balance, 
            IERC20 token1, 
            uint256 token1Balance
        )
    {
        IApePair apePair = IApePair(pairAddress);
        token0 = IERC20(apePair.token0());
        token1 = IERC20(apePair.token1());

        totalLpSupply = apePair.totalSupply();
        token0Balance = token0.balanceOf(pairAddress);
        token1Balance = token1.balanceOf(pairAddress);
    }

    /// @notice Find the token outputs for unwrapping LP tokens
    /// @param tokenA Address of the token0 contract
    /// @param tokenB Address of the token1 contract
    /// @param lpBalance Amount of LP tokens to unwrap
    /// @return totalLpSupply Total supply of LP tokens for the pair
    /// @return token0 token0 as registered on the pair contract
    /// @return token0Out The output amount of token0
    /// @return token1 token1 as registered on the pair contract
    /// @return token1Out The output amount of token1
    function getLiquidityAmountsOut(address tokenA, address tokenB, uint256 lpBalance)
        public
        view
        returns (
            uint256 totalLpSupply,
            IERC20 token0,
            uint256 token0Out,
            IERC20 token1,
            uint256 token1Out
        )
    {
        address pair = factory.getPair(tokenA, tokenB);
        return getLiquidityAmountsOut(pair, lpBalance);
    }

    /// @notice Find the token outputs for unwrapping LP tokens
    /// @param pairAddress Address of the pair contract
    /// @param lpBalance Amount of LP tokens to unwrap
    /// @return totalLpSupply Total supply of LP tokens for the pair
    /// @return token0 token0 as registered on the pair contract
    /// @return token0Out The output amount of token0
    /// @return token1 token1 as registered on the pair contract
    /// @return token1Out The output amount of token1
    function getLiquidityAmountsOut(address pairAddress, uint256 lpBalance)
        public
        view
        returns (
            uint256 totalLpSupply,
            IERC20 token0,
            uint256 token0Out,
            IERC20 token1,
            uint256 token1Out
        )
    {
        (
            uint256 totalLpSupply_, 
            IERC20 token0_,
            uint256 token0Balance, 
            IERC20 token1_,
            uint256 token1Balance
        ) = getPairBalances(pairAddress);

        totalLpSupply = totalLpSupply_;
        token0 = token0_;
        token1 = token1_;
        token0Out = lpBalance.mul(token0Balance) / (totalLpSupply_);
        token1Out = lpBalance.mul(token1Balance) / (totalLpSupply_);
    }
}

pragma solidity =0.6.6;

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

pragma solidity >=0.5.0;

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

pragma solidity >=0.6.6;

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

pragma solidity >=0.6.6;

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