/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
 *Submitted for verification at polygonscan.com on 2021-08-18
*/

/**
 *Submitted for verification at polygonscan.com on 2021-08-17
*/

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}


pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.6;

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

/*
Join us at PolyCrystal.Finance!
█▀▀█ █▀▀█ █░░ █░░█ █▀▀ █▀▀█ █░░█ █▀▀ ▀▀█▀▀ █▀▀█ █░░ 
█░░█ █░░█ █░░ █▄▄█ █░░ █▄▄▀ █▄▄█ ▀▀█ ░░█░░ █▄▄█ █░░ 
█▀▀▀ ▀▀▀▀ ▀▀▀ ▄▄▄█ ▀▀▀ ▀░▀▀ ▄▄▄█ ▀▀▀ ░░▀░░ ▀░░▀ ▀▀▀
*/

pragma solidity ^0.8.6;

/*
This library provides an initial framework for optimized routing and 
functions to manage data specific to UniswapV2-compatible AMMs. The pure
functions inline to constants at compile time, so we can deploy
strategies involving AMMs other than ApeSwap with minimal need to refactor.

Tested with AMMs that implement the standard UniswapV2 swap logic. Not tested with fee on 
transfer tokens. Not likely to work with Firebird, Curve, or DMM without extension.
*/


enum AmmData { STEP, PANCAKE, NULL }

/*
To retrieve stats, use for example:

    using UniV2AMMData for AmmData; 

    function exampleFunc() public {
        AmmData _amm = AmmData.STEP;
        _amm.factory();
        _amm.pairCodeHash();
        _amm.fee();
    }
*/

library AMMData {
    
    uint constant public NUM_AMMS = 2;
    
    address constant public STEP_FACTORY = 0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6; // using APESWAP factory
    address constant public PANCAKE_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    
    //used for internally locating a pair without an external call to the factory
    bytes32 constant public STEP_PAIRCODEHASH = hex'f4ccce374816856d11f00e4069e7cada164065686fbef53c6167a63ec2fd8c5b';
    bytes32 constant public PANCAKE_PAIRCODEHASH = hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5';
    
    // Fees are in increments of 1 basis point (0.01%)
    uint constant public STEP_FEE = 30; 
    uint constant public PANCAKE_FEE = 30;

    function factoryToAmm(address _factory) public pure returns(AmmData amm) {
        if (_factory == STEP_FACTORY) return AmmData.STEP;
        if (_factory == PANCAKE_FACTORY) return AmmData.PANCAKE;
        revert("");
    }

    function factory(AmmData _amm) public pure returns(address) {
        if (_amm == AmmData.STEP) return STEP_FACTORY;
        if (_amm == AmmData.PANCAKE) return PANCAKE_FACTORY; 
        revert(); //should never happen
    }

    function pairCodeHash(AmmData _amm) public pure returns(bytes32) {
        if (_amm == AmmData.STEP) return STEP_PAIRCODEHASH;
        if (_amm == AmmData.PANCAKE) return PANCAKE_PAIRCODEHASH;  
        revert();
    }
    
    function fee(AmmData _amm) public pure returns (uint) {
        if (_amm == AmmData.STEP) return STEP_FEE;
        if (_amm == AmmData.PANCAKE) return PANCAKE_FEE;   
        revert();
    }
    
}
// SPDX-License-Identifier: GPL
pragma solidity ^0.8.6;

// This library provides simple price calculations for ApeSwap tokens, accounting
// for commonly used pairings. Will break if BUSD, BUSD, or DAI goes far off peg.
// Should NOT be used as the sole oracle for sensitive calculations such as 
// liquidation, as it is vulnerable to manipulation by flash loans, etc. BETA
// SOFTWARE, PROVIDED AS IS WITH NO WARRANTIES WHATSOEVER.

// Polygon mainnet version
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

library PriceGetter {
    using AMMData for AmmData;
    
    //Returned prices calculated with this precision (18 decimals)
    uint public constant DECIMALS = 18;
    uint public constant PRECISION = 1e18; //1e18 == $1
    
    //Token addresses
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // address constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    // address constant DAI = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
    address constant BUSD = 0x55d398326f99059fF775485246999027B3197955;

    address constant BNBUSDDataFeed = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;

    //Normalized to specified number of decimals based on token's decimals and
    //specified number of decimals
    function getPrice(address token, uint _decimals) external view returns (uint) {
        return normalize(getRawPrice(token), token, _decimals);
    }

    function getLPPrice(address token, uint _decimals) external view returns (uint) {
        return normalize(getRawLPPrice(token), token, _decimals);
    }
    function getPrices(address[] calldata tokens, uint _decimals) external view returns (uint[] memory prices) {
        prices = getRawPrices(tokens);
        
        for (uint i; i < prices.length; i++) {
            prices[i] = normalize(prices[i], tokens[i], _decimals);
        }
    }
    function getLPPrices(address[] calldata tokens, uint _decimals) external view returns (uint[] memory prices) {
        prices = getRawLPPrices(tokens);
        
        for (uint i; i < prices.length; i++) {
            prices[i] = normalize(prices[i], tokens[i], _decimals);
        }
    }
    
    //returns the price of any token in USD based on common pairings; zero on failure
    function getRawPrice(address token) public view returns (uint) {
        uint pegPrice = pegTokenPrice(token);
        if (pegPrice != 0) return pegPrice;
        return getRawPrice(token, getBNBPrice());
    }
    
    //returns the prices of multiple tokens, zero on failure
    function getRawPrices(address[] calldata tokens) public view returns (uint[] memory prices) {
        prices = new uint[](tokens.length);
        uint bnbPrice = getBNBPrice();
        
        for (uint i; i < prices.length; i++) {
            address token = tokens[i];
            
            uint pegPrice = pegTokenPrice(token, bnbPrice);
            if (pegPrice != 0) prices[i] = pegPrice;
            else prices[i] = getRawPrice(token, bnbPrice);
        }
    }
    
    //returns the value of a LP token if it is one, or the regular price if it isn't LP
    function getRawLPPrice(address token) public view returns (uint) {
        uint pegPrice = pegTokenPrice(token);
        if (pegPrice != 0) return pegPrice;
        
        return getRawLPPrice(token, getBNBPrice());
    }
    //returns the prices of multiple tokens which may or may not be LPs
    function getRawLPPrices(address[] calldata tokens) public view returns (uint[] memory prices) {
        prices = new uint[](tokens.length);
        uint bnbPrice = getBNBPrice();
        
        for (uint i; i < prices.length; i++) {
            address token = tokens[i];
            
            uint pegPrice = pegTokenPrice(token, bnbPrice);
            if (pegPrice != 0) prices[i] = pegPrice;
            else prices[i] = getRawLPPrice(token, bnbPrice);
        }
    }
    
    //Calculate LP token value in USD. Generally compatible with any UniswapV2 pair but will always price underlying
    //tokens using ape prices. If the provided token is not a LP, it will attempt to price the token as a
    //standard token. This is useful for MasterChef farms which stake both single tokens and pairs
    function getRawLPPrice(address lp, uint bnbPrice) public view returns (uint) {
        
        //if not a LP, handle as a standard token
        try IApePair(lp).getReserves() returns (uint112 reserve0, uint112 reserve1, uint32) {
            
            address token0 = IApePair(lp).token0();
            address token1 = IApePair(lp).token1();
            uint totalSupply = IApePair(lp).totalSupply();
            
            //price0*reserve0+price1*reserve1
            uint totalValue = getRawPrice(token0, bnbPrice) * reserve0 
                + getRawPrice(token1, bnbPrice) * reserve1;
            
            return totalValue / totalSupply;
            
        } catch {
            return getRawPrice(lp, bnbPrice);
        }
    }

    // checks for primary tokens and returns the correct predetermined price if possible, otherwise calculates price
    function getRawPrice(address token, uint bnbPrice) public view returns (uint rawPrice) {
        uint pegPrice = pegTokenPrice(token, bnbPrice);
        if (pegPrice != 0) return pegPrice;

        uint numTokens;
        uint pairedValue;
        
        uint lpTokens;
        uint lpValue;
        
        (lpTokens, lpValue) = pairTokensAndValueMulti(token, WBNB);
        numTokens += lpTokens;
        pairedValue += lpValue;
        
        // (lpTokens, lpValue) = pairTokensAndValueMulti(token, USDC);
        // numTokens += lpTokens;
        // pairedValue += lpValue;
        
        // (lpTokens, lpValue) = pairTokensAndValueMulti(token, DAI);
        // numTokens += lpTokens;
        // pairedValue += lpValue;
        
        (lpTokens, lpValue) = pairTokensAndValueMulti(token, BUSD);
        numTokens += lpTokens;
        pairedValue += lpValue;
        
        if (numTokens > 0) return pairedValue / numTokens;
    }
    //if one of the peg tokens, returns that price, otherwise zero
    function pegTokenPrice(address token, uint bnbPrice) public pure returns (uint) {
        if (token == BUSD ) return PRECISION*1e12;
        if (token == WBNB) return bnbPrice;
        // if (token == USDC ) return PRECISION*1e12;
        // if (token == DAI) return PRECISION;
        return 0;
    }
    function pegTokenPrice(address token) public view returns (uint) {
        if (token == BUSD ) return PRECISION*1e12;
        if (token == WBNB) return getBNBPrice();
        // if (token == USDC ) return PRECISION*1e12;
        // if (token == DAI) return PRECISION;
        return 0;
    }

    //returns the number of tokens and the USD value within a single LP. peg is one of the listed primary, pegPrice is the predetermined USD value of this token
    function pairTokensAndValue(address token, address peg, address factory, bytes32 initcodehash) public view returns (uint tokenNum, uint pegValue) {

        address tokenPegPair = pairFor(token, peg, factory, initcodehash);
        
        // if the address has no contract deployed, the pair doesn't exist
        uint256 size;
        assembly { size := extcodesize(tokenPegPair) }
        if (size == 0) return (0,0);
        
        try IApePair(tokenPegPair).getReserves() returns (uint112 reserve0, uint112 reserve1, uint32) {
            uint reservePeg;
            (tokenNum, reservePeg) = token < peg ? (reserve0, reserve1) : (reserve1, reserve0);
            pegValue = reservePeg * pegTokenPrice(peg);
        } catch {
            return (0,0);
        }

    }
    
    function pairTokensAndValueMulti(address token, address peg) public view returns (uint tokenNum, uint pegValue) {
        
        //across all AMMs in AMMData library
        for (AmmData amm = AmmData.STEP; uint8(amm) < AMMData.NUM_AMMS; amm = AmmData(uint(amm) + 1)) {
            (uint tokenNumLocal, uint pegValueLocal) = pairTokensAndValue(token, peg, amm.factory(), amm.pairCodeHash());
            tokenNum += tokenNumLocal;
            pegValue += pegValueLocal;
        }
    }
    
    //normalize a token price to a specified number of decimals
    function normalize(uint price, address token, uint _decimals) public view returns (uint) {
        uint tokenDecimals;
        
        try IERC20Metadata(token).decimals() returns (uint8 dec) {
            tokenDecimals = dec;
        } catch {
            tokenDecimals = 18;
        }

        if (tokenDecimals + _decimals <= 2*DECIMALS) return price / 10**(2*DECIMALS - tokenDecimals - _decimals);
        else return price * 10**(_decimals + tokenDecimals - 2*DECIMALS);
    
    }
    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address tokenA, address tokenB, address factory, bytes32 initcodehash) public pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                initcodehash
        )))));
    }

    function getBNBPrice() public view returns (uint256) {
        AggregatorV3Interface  priceFeed = AggregatorV3Interface(BNBUSDDataFeed);
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        uint256 result = uint256(price) * (10 ** 10);
        return result;
    }
    
    
}