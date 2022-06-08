// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol';

contract PriceFeed {

    using SafeMath for uint256;
    using FixedPoint for *;

    address owner;
    address public marketPairAddressBUSD = address(0xdd52bd6CcE78f3114ba83B04F006aec03f432779); // CHANGE THIS!!! 
    address public marketPairAddressBNB = address(0xD9f0D34f142E4C855D879A84195CaEeA4fcf6E4B); // CHANGE THIS!!! 
    address public marketPairAddressBNB_BUSD = address(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16); // CHANGE THIS!!! 

    IERC20 public pistonToken = IERC20(address(0xBfACD29427fF376FF3BC22dfFB29866277cA5Fb4)); // CHANGE THIS!!! 
    IERC20 public busdtoken = IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56)); // MAINNET BUSD 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56  TESTNET BUSD 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    IERC20 public bnbtoken = IERC20(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)); // MAINNET WBNB 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  TESTNET BUSD 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd

    uint256 public PERIOD = 2 minutes;
    uint32 public blockTimestampLast;

    uint256 public PSTN_BUSD_price0CumulativeLast;
    uint256 public PSTN_BUSD_price1CumulativeLast;

    uint256 public PSTN_BNB_price0CumulativeLast;
    uint256 public PSTN_BNB_price1CumulativeLast;

    uint256 public BNB_BUSD_price0CumulativeLast;
    uint256 public BNB_BUSD_price1CumulativeLast;

    FixedPoint.uq112x112 public PSTN_BUSD_price0Average;
    FixedPoint.uq112x112 public PSTN_BUSD_price1Average;

    FixedPoint.uq112x112 public PSTN_BNB_price0Average;
    FixedPoint.uq112x112 public PSTN_BNB_price1Average;

    FixedPoint.uq112x112 public BNB_BUSD_price0Average;
    FixedPoint.uq112x112 public BNB_BUSD_price1Average;

    constructor() {
        owner = msg.sender;

        // PISTON/BUSD
        PSTN_BUSD_price0CumulativeLast = IUniswapV2Pair(marketPairAddressBUSD).price0CumulativeLast();
        PSTN_BUSD_price1CumulativeLast = IUniswapV2Pair(marketPairAddressBUSD).price1CumulativeLast();

        // PISTON/BNB
        PSTN_BNB_price0CumulativeLast = IUniswapV2Pair(marketPairAddressBNB).price0CumulativeLast();
        PSTN_BNB_price1CumulativeLast = IUniswapV2Pair(marketPairAddressBNB).price1CumulativeLast();

        // BNB/BUSD
        BNB_BUSD_price0CumulativeLast = IUniswapV2Pair(marketPairAddressBNB_BUSD).price0CumulativeLast();
        BNB_BUSD_price1CumulativeLast = IUniswapV2Pair(marketPairAddressBNB_BUSD).price1CumulativeLast();

        (, , blockTimestampLast) = IUniswapV2Pair(marketPairAddressBUSD).getReserves();
    }

    function setup(address piston_token, address busd_token, address bnb_token, address aam_pstn_busd, address aam_pstn_bnb, address aam_bnb_busd) external {
        require(msg.sender == owner, "owner only");
        require(piston_token != address(0) && 
            busd_token != address(0) && 
            bnb_token != address(0) && 
            aam_pstn_busd != address(0) && 
            aam_pstn_bnb != address(0) && 
            aam_bnb_busd != address(0)
        );

        marketPairAddressBUSD = aam_pstn_busd;
        marketPairAddressBNB = aam_pstn_bnb;
        marketPairAddressBNB_BUSD = aam_bnb_busd;

        pistonToken = IERC20(piston_token); 
        busdtoken = IERC20(busd_token); 
        bnbtoken = IERC20(bnb_token); 
    }
    
    function setOwner(address value) external {
        require(msg.sender == owner, "owner only");
        require(value != address(0));
        owner = value;
    }

    //  Market Data 
    //
    function getPrice(uint amount) external view returns(uint) {
        return getPriceTWAP(amount.mul(1 ether));
    }

    // price BUSD only calculated by TWAP (Time Weighted Average Price)
    // use this if you need to store the price
    // flash loan safe
    function getPriceTWAP(uint amountIn) public view returns (uint amountOut) {
        amountOut = getPriceAverage().mul(amountIn);
    }

    /*
    // live price by Pair reserves (DONT STORE THIS!)
    function getPriceByReserves(uint amount) external view returns(uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(marketPairAddressBUSD);
        IERC20 token0 = IERC20(pair.token0());
        (uint Res0, uint Res1,) = pair.getReserves();

        // decimals
        uint _Res1 = Res1*(10**token0.decimals());
        uint _Res0 = Res0;
        
        return ((amount*_Res1)/_Res0);
    }

    // live price BUSD pair (DONT STORE THIS!)
    function getPriceByBalancesBUSD() public view returns(uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(marketPairAddressBUSD);      

        // decimals
        uint _Res0 = pistonToken.balanceOf(address(pair));
        uint _Res1 = busdtoken.balanceOf(address(pair));        
        
        return ((_Res1*10**18)/_Res0);
    }

    //live price BNB pair (DONT STORE THIS!)
    function getPriceByBalancesBNB() public view returns(uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(marketPairAddressBNB); 

        // decimals
        uint _Res0 = pistonToken.balanceOf(address(pair));
        uint _Res1 = bnbtoken.balanceOf(address(pair));        
        
        return ((_Res1*10**18)/_Res0);
    }

    // live price BNB token (DONT STORE THIS!)
    function getBNBPrice() public view returns(uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(marketPairAddressBNB_BUSD); 

        // decimals
        uint _Res0 = busdtoken.balanceOf(address(pair));
        uint _Res1 = bnbtoken.balanceOf(address(pair));        
        
        return ((_Res0*10**18)/_Res1);
    }*/

    // live avg price PISTON/BUSD and PISTON/BNB (DONT STORE THIS!)
    function getPriceAverage() internal view returns(uint) {

        uint256 pistonBalanceAtBUSDPAIR = pistonToken.balanceOf(address(marketPairAddressBUSD));
        uint256 pistonBalanceAtBNBPAIR = pistonToken.balanceOf(address(marketPairAddressBNB));

        uint256 PSTNPriceAtBUSDPair = PSTN_BUSD_price0Average.mul(1 ether).decode144();
        uint256 PSTNPriceAtBNBPair = PSTN_BNB_price0Average.mul(1 ether).decode144();
        uint256 BNBPriceAtBUSDPair = BNB_BUSD_price0Average.mul(1 ether).decode144();

        return pistonBalanceAtBUSDPAIR.mul(PSTNPriceAtBUSDPair).add(
                pistonBalanceAtBNBPAIR.mul(PSTNPriceAtBNBPair).mul(BNBPriceAtBUSDPair.div(1 ether))            
            ).div(pistonBalanceAtBUSDPAIR.add(pistonBalanceAtBNBPAIR)
        );
    }

    // update TWAP price. this is called several times from oether contracts to have actual values.
    function updateTWAP() external {

        //  PISTON/BUSD
        //------------------------------------------------------------
        (uint PSTN_BUSD_price0Cumulative, uint PSTN_BUSD_price1Cumulative, uint32 PSTN_BUSD_blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(marketPairAddressBUSD));
        uint32 timeElapsed = PSTN_BUSD_blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= PERIOD, 'PistonPriceFeed: PERIOD_NOT_ELAPSED');

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        PSTN_BUSD_price0Average = FixedPoint.uq112x112(uint224((PSTN_BUSD_price0Cumulative - PSTN_BUSD_price0CumulativeLast) / timeElapsed));
        PSTN_BUSD_price1Average = FixedPoint.uq112x112(uint224((PSTN_BUSD_price1Cumulative - PSTN_BUSD_price1CumulativeLast) / timeElapsed));

        PSTN_BUSD_price0CumulativeLast = PSTN_BUSD_price0Cumulative;
        PSTN_BUSD_price1CumulativeLast = PSTN_BUSD_price1Cumulative;

        //  BNB/BUSD
        //------------------------------------------------------------
        (uint BNB_BUSD_price0Cumulative, uint BNB_BUSD_price1Cumulative, uint32 BNB_BUSD_blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(marketPairAddressBNB_BUSD));
        timeElapsed = BNB_BUSD_blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= PERIOD, 'PistonPriceFeed: PERIOD_NOT_ELAPSED');

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        BNB_BUSD_price0Average = FixedPoint.uq112x112(uint224((BNB_BUSD_price0Cumulative - BNB_BUSD_price0CumulativeLast) / timeElapsed));
        BNB_BUSD_price1Average = FixedPoint.uq112x112(uint224((BNB_BUSD_price1Cumulative - BNB_BUSD_price1CumulativeLast) / timeElapsed));

        BNB_BUSD_price0CumulativeLast = BNB_BUSD_price0Cumulative;
        BNB_BUSD_price1CumulativeLast = BNB_BUSD_price1Cumulative;


        //  PISTON/BNB
        //------------------------------------------------------------
        (uint PSTN_BNB_price0Cumulative, uint PSTN_BNB_price1Cumulative, uint32 PSTN_BNB_blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(marketPairAddressBNB));
        timeElapsed = PSTN_BNB_blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= PERIOD, 'PistonPriceFeed: PERIOD_NOT_ELAPSED');

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        PSTN_BNB_price0Average = FixedPoint.uq112x112(uint224((PSTN_BNB_price0Cumulative - PSTN_BNB_price0CumulativeLast) / timeElapsed));
        PSTN_BNB_price1Average = FixedPoint.uq112x112(uint224((PSTN_BNB_price1Cumulative - PSTN_BNB_price1CumulativeLast) / timeElapsed));

        PSTN_BNB_price0CumulativeLast = PSTN_BNB_price0Cumulative;
        PSTN_BNB_price1CumulativeLast = PSTN_BNB_price1Cumulative;

        blockTimestampLast = PSTN_BNB_blockTimestamp;
    }

    function needsUpdateTWAP() external view returns (bool){
        (, , uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(marketPairAddressBUSD));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        return timeElapsed >= PERIOD;
    }

    function update_PERIOD(uint256 value) external {
        require(msg.sender == owner, "only owner");

        PERIOD = value;
    }
}
    

    /**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
   */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
     * @dev Adds two numbers, throws on overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

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

    function decimals() external view returns (uint8);

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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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

pragma solidity >=0.4.0;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

pragma solidity >=0.5.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}