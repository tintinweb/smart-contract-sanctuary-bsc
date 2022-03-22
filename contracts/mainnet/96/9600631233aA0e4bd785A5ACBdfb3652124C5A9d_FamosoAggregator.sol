// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IUniswapV2Exchange.sol";
import "./interfaces/IWBNB.sol";
import "./interfaces/IMooniswap.sol";

contract FamosoAggregator {
  using SafeMath for uint256;
  using UniswapV2ExchangeLib for IUniswapV2Exchange;
  address public owner;
  
  uint256 constant internal DEXES_COUNT = 3;
  int256 internal constant VERY_NEGATIVE_VALUE = -1e72;

  IWBNB constant internal wbnb = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
  IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
  IERC20 private constant BNB_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

  IPancakeFactory constant internal pancakeswap = IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  IUniswapV2Factory constant internal sushiswap = IUniswapV2Factory(0xc35DADB65012eC5796536bD9864eD8773aBc74C4);
  IMooniswapRegistry constant internal mooniswapRegistry = IMooniswapRegistry(0xD41B24bbA51fAc0E4827b6F94C0D6DDeB183cD64);

  struct Args {
    IERC20 fromToken;
    IERC20 destToken;
    uint256 amount;
    uint256 parts;
    uint256 destTokenEthPriceTimesGasPrice;
    uint256[] distribution;
    int256[][] matrix;
    uint256[DEXES_COUNT] gases;
    function(IERC20, IERC20, uint256, uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] reserves;
  }


  modifier admin() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  constructor() {
    owner = msg.sender;
  }
  function isBNB(IERC20 token) internal pure returns(bool) {
    return (address(token) == address(ZERO_ADDRESS) || address(token) == address(BNB_ADDRESS));
  }

  function _getAllReserves() internal pure returns(function(IERC20, IERC20, uint256, uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] memory) 
  {
    return [calculatePancakeswap, calculateSushiswap, calculateMooniswap];
  }

  function _linearInterpolation(
    uint256 value,
    uint256 parts
  ) internal pure returns(uint256[] memory rets) {
    rets = new uint256[](parts);
    for (uint i = 0; i < parts; i++) {
      rets[i] = value.mul(i + 1).div(parts);
    }
  }

  function calculateMooniswapMany(
    IERC20 fromToken,
    IERC20 destToken,
    uint256[] memory amounts
  ) internal view returns(uint256[] memory rets, uint256 gas) {
    rets = new uint256[](amounts.length);

    IMooniswap mooniswap = mooniswapRegistry.pools(
      isBNB(fromToken) ? ZERO_ADDRESS : fromToken,
      isBNB(destToken) ? ZERO_ADDRESS : destToken
    );
    if (mooniswap == IMooniswap(0x0000000000000000000000000000000000000000)) {
      return (rets, 0);
    }

    uint256 fee = mooniswap.fee();
    uint256 fromBalance = mooniswap.getBalanceForAddition(isBNB(fromToken) ? ZERO_ADDRESS : fromToken);
    uint256 destBalance = mooniswap.getBalanceForRemoval(isBNB(destToken) ? ZERO_ADDRESS : destToken);
    if (fromBalance == 0 || destBalance == 0) {
      return (rets, 0);
    }

    for (uint i = 0; i < amounts.length; i++) {
      uint256 amount = amounts[i].sub(amounts[i].mul(fee).div(1e18));
      rets[i] = amount.mul(destBalance).div(fromBalance.add(amount));
    }

    return (rets, (isBNB(fromToken) || isBNB(destToken)) ? 80_000: 110_000);
  }

  function calculateMooniswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 parts
  ) internal view returns(uint256[] memory rets, uint256 gas) {
    return calculateMooniswapMany(
      fromToken,
      destToken,
      _linearInterpolation(amount, parts)
    );
  }

  function calculateSushiswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 parts
  ) internal view returns(uint256[] memory rets, uint256 gas) {
    return _calculateSushiswap(
      fromToken, 
      destToken, 
      _linearInterpolation(amount, parts)
    );
  }

  function _calculateSushiswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256[] memory amounts
  ) internal view returns(uint256[] memory rets, uint256 gas) {
    rets = new uint256[](amounts.length);
    IERC20 fromTokenReal = isBNB(fromToken) ? wbnb: fromToken;
    IERC20 destTokenReal = isBNB(destToken) ? wbnb: destToken;
    IUniswapV2Exchange exchange = IUniswapV2Exchange(sushiswap.getPair(address(fromTokenReal), address(destTokenReal)));
    if (exchange != IUniswapV2Exchange(address(0x0))) {
      uint256 fromTokenBalance = fromTokenReal.balanceOf(address(exchange));
      uint256 destTokenBalance = destTokenReal.balanceOf(address(exchange));
      for (uint i = 0; i < amounts.length; i++) {
        rets[i] = _caculateUniswapFormula(fromTokenBalance, destTokenBalance, amounts[i]);
      }
      return (rets, 50_000);
    }
  }

  function universalApprove(IERC20 token, address to, uint256 amount) internal {
    if (!isBNB(token)) {
      if (amount == 0) {
        token.approve(to, 0);
        return;
      }

      uint256 allowance = token.allowance(address(this), to);
      if (allowance < amount) {
        if (allowance > 0) {
          token.approve(to, 0);
        }
        token.approve(to, amount);
      }
    }
  }
  
  function _swapOnMooniswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount
  ) internal {
    IMooniswap mooniswap = mooniswapRegistry.pools(
      isBNB(fromToken) ? ZERO_ADDRESS : fromToken,
      isBNB(destToken) ? ZERO_ADDRESS : destToken
    );
    universalApprove(fromToken, address(mooniswap), amount);
    if (isBNB(fromToken)) {
      payable(address(mooniswap)).transfer(amount);
    }
    mooniswap.swap(
      isBNB(fromToken) ? ZERO_ADDRESS : fromToken,
      isBNB(destToken) ? ZERO_ADDRESS : destToken,
      amount,
      0,
      0xc35DADB65012eC5796536bD9864eD8773aBc74C4
    );
  }

  function calculatePancakeswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 parts
  ) internal view returns(uint256[] memory rets, uint256 gas) {
    return _calculatePancakeswap(
      fromToken,
      destToken,
      _linearInterpolation(amount, parts)
    );
  }

  function _calculatePancakeswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256[] memory amounts
  ) internal view returns(uint256[] memory rets, uint256 gas) {
    rets = new uint256[](amounts.length);
    IERC20 fromTokenReal = isBNB(fromToken) ? wbnb: fromToken;
    IERC20 destTokenReal = isBNB(destToken) ? wbnb: destToken;
    IUniswapV2Exchange exchange = IUniswapV2Exchange(pancakeswap.getPair(address(fromTokenReal), address(destTokenReal)));
    if (exchange != IUniswapV2Exchange(address(0x0))) {
      uint256 fromTokenBalance = fromTokenReal.balanceOf(address(exchange));
      uint256 destTokenBalance = destTokenReal.balanceOf(address(exchange));
      for (uint i = 0; i < amounts.length; i++) {
        rets[i] = _caculateUniswapFormula(fromTokenBalance, destTokenBalance, amounts[i]);
      }
      return (rets, 50_000);
    }
  }
  function _caculateUniswapFormula(uint256 fromBalance, uint256 toBalance, uint256 amount) internal pure returns(uint256) {
    if (amount == 0) {
      return 0;
    }
    return amount.mul(toBalance).mul(997).div(fromBalance.mul(1000).add(amount.mul(997)));
  }

  function getExpectedReturnWithGas(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 parts,
    uint256 destTokenEthPriceTimesGasPrice
  ) public view returns (
    uint256 returnAmount, 
    uint256 estimateGasAmount, 
    uint256[] memory distribution
  ) {
    distribution = new uint256[](DEXES_COUNT);
    if (fromToken == destToken) {
      return (amount, 0, distribution);
    }
    function(IERC20, IERC20, uint256, uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] memory reserves = _getAllReserves();
    int256[][] memory matrix = new int256[][](DEXES_COUNT);
    uint256[DEXES_COUNT] memory gases;
    bool atLeastOnePositive = false;
    for (uint i = 0; i < DEXES_COUNT; i++) {
      uint256[] memory rets;
      (rets, gases[i]) = reserves[i](fromToken, destToken, amount, parts);

      int256 gas = int256(gases[i].mul(destTokenEthPriceTimesGasPrice).div(1e18));
      matrix[i] = new int256[](parts + 1);
      for (uint j = 0; j < rets.length; j++) {
        matrix[i][j + 1] = int256(rets[j]) - gas;
        atLeastOnePositive = atLeastOnePositive || (matrix[i][j + 1] > 0);
      }
    }

    if (!atLeastOnePositive) {
      for (uint i = 0; i < DEXES_COUNT; i++) {
        for (uint j = 1; j < parts + 1; j++) {
          if (matrix[i][j] == 0) {
            matrix[i][j] = VERY_NEGATIVE_VALUE;
          }
        }
      }
    }
    (, distribution) = _findBestDistribution(parts, matrix);
    (returnAmount, estimateGasAmount) = _getReturnAndGasByDistribution(
      Args({
        fromToken: fromToken,
        destToken: destToken,
        amount: amount,
        parts: parts,
        destTokenEthPriceTimesGasPrice: destTokenEthPriceTimesGasPrice,
        distribution: distribution,
        matrix: matrix,
        gases: gases,
        reserves: reserves
      })
    );
    return (
      returnAmount, 
      estimateGasAmount, 
      distribution
    );
  }

  function _findBestDistribution(
    uint256 s, 
    int256[][] memory amounts
  ) internal pure returns(
    int256 returnAmount, 
    uint256[] memory distribution
  ) {
    uint256 n = amounts.length;
    int256[][] memory answer = new int256[][](n);
    answer = new int256[][](n);
    uint256[][] memory parent = new uint256[][](n);

    for (uint i = 0; i < n; i++) {
      answer[i] = new int256[](s + 1);
      parent[i] = new uint256[](s + 1);
    }

    for (uint j = 0; j <= s; j++) {
      answer[0][j] = amounts[0][j];
      for (uint i = 1; i < n; i++) {
        answer[i][j] = -1e72;
      }
      parent[0][j] = 0;
    }

    for (uint i = 1; i < n; i++) {
      for (uint j = 0; j <= s; j++) {
        answer[i][j] = answer[i - 1][j];
        parent[i][j] = j;

        for (uint k = 1; k <= j; k++) {
          if (answer[i - 1][j - k] + amounts[i][k] > answer[i][j]) {
            answer[i][j] = answer[i - 1][j - k] + amounts[i][k];
            parent[i][j] = j - k;
          }
        }
      }
    }

    distribution = new uint256[](DEXES_COUNT);
    uint256 p = s;
    for (uint i = 0; i < DEXES_COUNT; i++) {
      distribution[DEXES_COUNT - i - 1] = p - parent[DEXES_COUNT - i - 1][p];
      p = parent[DEXES_COUNT - i - 1][p];
    }

    returnAmount = (answer[n - 1][s] == VERY_NEGATIVE_VALUE) ? int256(0) : answer[n - 1][s];
  }

  function _getReturnAndGasByDistribution(
    Args memory args
  ) internal pure returns(uint256 returnAmount, uint256 estimateGasAmount) {
    // bool[DEXES_COUNT] memory exact = [];
    for (uint i = 0; i < DEXES_COUNT; i++) {
      if (args.distribution[i] > 0) {
        estimateGasAmount = estimateGasAmount.add(args.gases[i]);
        int256 value = args.matrix[i][args.distribution[i]];
        returnAmount = returnAmount.add(
          uint256(
            (value == VERY_NEGATIVE_VALUE ? int256(0) : value) + int256(args.gases[i].mul(args.destTokenEthPriceTimesGasPrice).div(1e18))
          )
        );
        // if (args.distribution[i] == args.parts || exact[i]) {
        // } else {
        //   (uint256[] memory rets, uint256 gas) = args.reserves[i](args.fromToken , args.destToken, args.amount.mul(args.distribution[i]).div(args.parts), 1);
        //   estimateGasAmount = estimateGasAmount.add(gas);
        //   returnAmount = returnAmount.add(rets[0]);
        // }
      }
    }
  }

  function swap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 minReturn,
    uint256[] memory distribution
  ) public payable returns(uint256 returnAmount) {
    if (fromToken == destToken) {
      return amount;
    }

    function(IERC20, IERC20, uint256)[DEXES_COUNT] memory reserves = [
      _swapOnPancakeswap,
      _swapOnSushiswap,
      _swapOnMooniswap
    ];
    require(distribution.length <= reserves.length, "FamosoAggregator: Distribution array should not exceed reserves array size");
    
    uint256 parts = 0;
    uint256 lastNonZeroIndex = 0;
    for (uint i = 0; i < distribution.length; i++) {
      if (distribution[i] > 0) {
        parts = parts.add(distribution[i]);
        lastNonZeroIndex = i;
      }
    }

    if (parts == 0) {
      if (isBNB(fromToken)) {
        payable(msg.sender).transfer(msg.value);
        return msg.value;
      }
      return amount;
    }
    if (isBNB(fromToken)) {
      if (msg.value > amount) {
        payable(msg.sender).transfer(msg.value.sub(amount));
      }
    } else {
      fromToken.transferFrom(msg.sender, address(this), amount);
    }
    
    uint256 remainingAmount = isBNB(fromToken) ? address(this).balance : fromToken.balanceOf(address(this));

    for (uint i = 0; i < distribution.length; i++) {
      if (distribution[i] == 0) {
        continue;
      }

      uint256 swapAmount = amount.mul(distribution[i]).div(parts);
      if (i == lastNonZeroIndex) {
        swapAmount = remainingAmount;
      }
      remainingAmount -= swapAmount;
      reserves[i](fromToken, destToken, swapAmount);
    }

    returnAmount = isBNB(destToken) ? wbnb.balanceOf(address(this)) : destToken.balanceOf(address(this));
    // returnAmount = isBNB(destToken) ? address(this).balance : destToken.balanceOf(address(this));
    require(returnAmount >= minReturn, "FamosoAggregator: Return amount was not enough");
    if (isBNB(destToken)) {
      wbnb.withdraw(returnAmount);
      // wbnb.transfer(msg.sender, returnAmount);
      payable(msg.sender).transfer(returnAmount);
    } else {
      destToken.transfer(msg.sender, returnAmount);
    }
    if (isBNB(fromToken)) {
      payable(msg.sender).transfer(address(this).balance);
    } else {
      fromToken.transfer(msg.sender, fromToken.balanceOf(address(this)));
    }
  }

  function _swapOnPancakeswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount
  ) internal {
    _swapOnPancakeswapInternal(fromToken, destToken, amount);
  }

  function _swapOnPancakeswapInternal (
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount
  ) internal returns (uint256 returnAmount) {
    if (isBNB(fromToken)) {
      wbnb.deposit{value: amount}();
    }
    IERC20 fromTokenReal = isBNB(fromToken) ? wbnb : fromToken;
    IERC20 toTokenReal = isBNB(destToken) ? wbnb: destToken;
    IUniswapV2Exchange exchange = IUniswapV2Exchange(pancakeswap.getPair(address(fromTokenReal), address(toTokenReal)));
    bool needSync;
    bool needSkim;
    (returnAmount, needSync, needSkim) = exchange.getReturn(fromTokenReal, toTokenReal, amount);
    if (needSync) {
      exchange.sync();
    } else if (needSkim) {
      exchange.skim(owner);
    }

    fromTokenReal.transfer(address(exchange), amount);
    if (address(fromTokenReal) < address(toTokenReal)) {
      exchange.swap(0, returnAmount, address(this), "");
    } else {
      exchange.swap(returnAmount, 0, address(this), "");
    }

    // if (isBNB(destToken)) {
    //   wbnb.withdraw(wbnb.balanceOf(address(this)));
    // }
  }

  function _swapOnSushiswap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount
  ) internal {
    _swapOnSushiswapInternal(fromToken, destToken, amount);
  }

  function _swapOnSushiswapInternal (
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount
  ) internal returns (uint256 returnAmount) {
    if (isBNB(fromToken)) {
      wbnb.deposit{value: amount}();
    }
    IERC20 fromTokenReal = isBNB(fromToken) ? wbnb : fromToken;
    IERC20 toTokenReal = isBNB(destToken) ? wbnb: destToken;
    IUniswapV2Exchange exchange = IUniswapV2Exchange(sushiswap.getPair(address(fromTokenReal), address(toTokenReal)));
    bool needSync;
    bool needSkim;
    (returnAmount, needSync, needSkim) = exchange.getReturn(fromTokenReal, toTokenReal, amount);
    if (needSync) {
      exchange.sync();
    } else if (needSkim) {
      exchange.skim(owner);
    }

    fromTokenReal.transfer(address(exchange), amount);
    if (address(fromTokenReal) < address(toTokenReal)) {
      exchange.swap(0, returnAmount, address(this), "");
    } else {
      exchange.swap(returnAmount, 0, address(this), "");
    }

    // if (isBNB(destToken)) {
    //   wbnb.withdraw(wbnb.balanceOf(address(this)));
    // }
  }

  function test(uint256 amount) public {
    wbnb.transferFrom(msg.sender, address(this), amount);
    wbnb.withdraw(amount);
    payable(msg.sender).transfer(amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWBNB is IERC20 {
    function deposit() external payable;
    
    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);
  function migrator() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;
  function setFeeToSetter(address) external;
  function setMigrator(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Exchange {
    function getReserves() external view returns(uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

library UniswapV2ExchangeLib {
    using Math for uint256;
    using SafeMath for uint256;

    function getReturn(
        IUniswapV2Exchange exchange,
        IERC20 fromToken,
        IERC20 destToken,
        uint amountIn
    ) internal view returns (uint256 result, bool needSync, bool needSkim) {
        uint256 reserveIn = fromToken.balanceOf(address(exchange));
        uint256 reserveOut = destToken.balanceOf(address(exchange));
        (uint112 reserve0, uint112 reserve1, ) = exchange.getReserves();
        if (fromToken > destToken) {
            (reserve0, reserve1) = (reserve1, reserve0);
        }
        needSync = (reserveIn < reserve0 || reserveOut < reserve1);
        needSkim = !needSync && (reserveIn > reserve0 || reserveOut > reserve1);

        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(Math.min(reserveOut, reserve1));
        uint256 denominator = Math.min(reserveIn, reserve0).mul(1000).add(amountInWithFee);
        result = (denominator == 0) ? 0 : numerator.div(denominator);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;


interface IPancakeFactory {
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMooniswapRegistry {
    function pools(IERC20 token1, IERC20 token2) external view returns(IMooniswap);
    function isPool(address addr) external view returns(bool);
}

interface IMooniswap {
    function fee() external view returns (uint256);

    function tokens(uint256 i) external view returns (IERC20);
    function deposit(uint256[] calldata amounts, uint256[] calldata minAmounts) external payable returns(uint256 fairSupply);

    function withdraw(uint256 amount, uint256[] calldata minReturns) external;
    function getBalanceForAddition(IERC20 token) external view returns(uint256);
    function getBalanceForRemoval(IERC20 token) external view returns(uint256);

    function getReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) external view returns(uint256 returnAmount);

    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        address referral
    ) external payable returns(uint256 returnAmount);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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