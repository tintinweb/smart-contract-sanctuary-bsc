//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../interfaces/IPair.sol";
import "../interfaces/IVault.sol";
import "../interfaces/IController.sol";
import "../interfaces/IUSDOracle.sol";
import "../interfaces/IRouter02.sol";
import "../interfaces/IPancakeFactory.sol";
import "../interfaces/IDusdMinter.sol";

import "../interfaces/IDYToken.sol";
import "../interfaces/IFeeConf.sol";
import "../interfaces/IMintVault.sol";
import "../interfaces/IDepositVault.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../Constants.sol";

contract Reader is Constants {

  using SafeMath for uint;

  IFeeConf private feeConf;
  IController private controller;
  IPancakeFactory private factory;
  IRouter02 private router;
  
  address public minter;

  constructor(address _controller, address _feeConf, address _factory, address _router, address _minter) {
    controller = IController(_controller);
    feeConf = IFeeConf(_feeConf);
    factory = IPancakeFactory(_factory);
    router = IRouter02(_router);

    minter = _minter;
  }



  // underlyingAmount : such as lp amount;
  function getVaultPrice(address vault, uint underlyingAmount, bool _dp) external view returns(uint256 value) {
    // calc dytoken amount;
    address dytoken = IVault(vault).underlying();

    uint amount = IERC20(dytoken).totalSupply() * underlyingAmount / IDYToken(dytoken).underlyingTotal();
    value = IVault(vault).underlyingAmountValue(amount, _dp);
  } 
  
  function getAssetDiscount(address asset, bool lp) external view returns(uint16 dr){
    if (lp) {
      address token0 = IPair(asset).token0();
      address token1 = IPair(asset).token1();
      ( , uint16 dr0,  ,  , uint16 dr1, ) = controller.getValueConfs(token0, token1);
      dr = (dr0 + dr1) / 2;
    } else {
      ( , dr, ) = controller.getValueConf(asset);
    }
  }

  function getDTokenVaultPrice(address[] memory _vaults, address user, bool _dp)  external view returns(uint256[] memory amounts, 
    uint256[] memory prices,
    uint256[] memory values,
    uint256[] memory marketcaps) {
      uint len = _vaults.length;

      values = new uint[](len);
      amounts = new uint[](len);
      prices = new uint[](len);
      marketcaps = new uint[](len);

      for (uint256 i = 0; i < len; i++) {
          address dtoken = IVault(_vaults[i]).underlying();

          prices[i] = IVault(_vaults[i]).underlyingAmountValue(1e18, _dp);

          amounts[i] = IMintVault(_vaults[i]).borrows(user);
          values[i] = amounts[i] * prices[i] / 1e18;

          uint total = IERC20(dtoken).totalSupply();
          marketcaps[i] = total * prices[i] / 1e18;
      }
  }

  // 
  function depositVaultValues(address[] memory _vaults, bool _dp) external view returns (uint256[] memory amounts, uint256[] memory values) {
    uint len = _vaults.length;
    values = new uint[](len);
    amounts = new uint[](len);

    for (uint256 i = 0; i < len; i++) {
      address dytoken = IVault(_vaults[i]).underlying();
      require(dytoken != address(0), "no dytoken");

      uint amount = IERC20(dytoken).balanceOf(_vaults[i]);
      if (amount == 0) {
        amounts[i] = 0;
        values[i] = 0;
      } else {
        uint value =  IVault(_vaults[i]).underlyingAmountValue(amount, _dp);
        amounts[i] = amount;
        values[i] = value;
      }
    }
  }

  // 获取用户所有仓位价值:
  function userVaultValues(address _user, address[] memory  _vaults, bool _dp) external view returns (uint256[] memory values) {
    uint len = _vaults.length;
    values = new uint[](len);

    for (uint256 i = 0; i < len; i++) {
      values[i] = IVault(_vaults[i]).userValue(_user, _dp);
    }
  }

  // 获取用户所有仓位数量（dyToken 数量及底层币数量）
  function userVaultDepositAmounts(address _user, address[] memory _vaults) 
    external view returns (uint256[] memory amounts, uint256[] memory underAmounts) {
    uint len = _vaults.length;
    amounts = new uint[](len);
    underAmounts = new uint[](len);

    for (uint256 i = 0; i < len; i++) {
      amounts[i] = IDepositVault(_vaults[i]).deposits(_user);
      address underlying = IVault(_vaults[i]).underlying();
      if (amounts[i] == 0) {
        underAmounts[i] = 0;
      } else {
        underAmounts[i] = IDYToken(underlying).underlyingAmount(amounts[i]);
      }
    }
  }

    // 获取用户所有借款数量
  function userVaultBorrowAmounts(address _user, address[] memory _vaults) external view returns (uint256[] memory amounts) {
    uint len = _vaults.length;
    amounts = new uint[](len);

    for (uint256 i = 0; i < len; i++) {
      amounts[i] = IMintVault(_vaults[i]).borrows(_user);
    }
  }

// 根据输入，预估实际可借和费用
  function pendingBorrow(uint amount) external view returns(uint actualBorrow, uint fee) {
    (, uint borrowFee) = feeConf.getConfig("borrow_fee");

    fee = amount * borrowFee / PercentBase;
    actualBorrow = amount - fee;
  }

// 根据输入，预估实际转换和费用
  function pendingRepay(address borrower, address vault, uint amount) external view returns(uint actualRepay, uint fee) {
    uint256 borrowed = IMintVault(vault).borrows(borrower);
    if(borrowed == 0) {
      return (0, 0);
    }

    (address receiver, uint repayFee) = feeConf.getConfig("repay_fee");
    fee = borrowed * repayFee / PercentBase;
    if (amount > borrowed + fee) {  // repay all.
      actualRepay = borrowed;
    } else {
      actualRepay = amount * PercentBase / (PercentBase + repayFee);
      fee = amount - actualRepay;
    }
  }

  // 获取多个用户的价值 (only calculate valid vault)
  function usersVaules(address[] memory users, bool dp) external view returns(uint[] memory totalDeposits, uint[] memory totalBorrows) {
    uint len = users.length;
    totalDeposits = new uint[](len);
    totalBorrows = new uint[](len);

    for (uint256 i = 0; i < len; i++) {
      (totalDeposits[i], totalBorrows[i]) = controller.userValues(users[i], dp);
    }
  }

  // 获取多个用户的价值
  function usersTotalVaules(address[] memory users, bool dp) external view returns(uint[] memory totalDeposits, uint[] memory totalBorrows) {
    uint len = users.length;
    totalDeposits = new uint[](len);
    totalBorrows = new uint[](len);

    for (uint256 i = 0; i < len; i++) {
      (totalDeposits[i], totalBorrows[i]) = controller.userTotalValues(users[i], dp);
    }
  }

  function getValidVault(address vault, address user) external view returns(IController.ValidVault) {

    IController.ValidVault _state = controller.validVaultsOfUser(vault, user);

    IController.ValidVault state = 
        _state == IController.ValidVault.UnInit? controller.validVaults(vault) : _state;

    return state;
  }

  function getValueOfTokenToLp(
        address token, 
        uint amount, 
        address [] memory pathArr0,
        address [] memory pathArr1
    ) external view returns(uint inputVaule, uint outputValue) {
        {
          (address oracle, ,) = controller.getValueConf(token);
          uint scale = 10 ** IERC20Metadata(token).decimals();
          inputVaule = IUSDOracle(oracle).getPrice(token) * amount / scale;
        }
        
        address token0;
        address token1;
        uint amountOut0;
        uint amountOut1;
        uint112[] memory reserves = new uint112[](2);

        {
          address lp;
          // get token reserves before swapping
          (reserves, lp) = _getReserves(token, pathArr0, pathArr1);

          (token0, amountOut0, reserves) = _predictSwapAmount(token, amount / 2, pathArr0, reserves, lp);
          (token1, amountOut1, reserves) = _predictSwapAmount(token, amount - amount / 2, pathArr1, reserves, lp);
        }
        _checkAmountOut(token0, token1, amountOut0, amountOut1);

        (uint actualAmountOut0, uint actualAmountOut01) = _getQuoteAmount(token0, amountOut0, token1, amountOut1, reserves);

        uint price0 = _getPrice(token, pathArr0);
        uint price1 = _getPrice(token, pathArr1);

        uint scale0 = 10 ** IERC20Metadata(token0).decimals();
        uint scale1 = 10 ** IERC20Metadata(token1).decimals();

        outputValue = actualAmountOut0 * price0 / scale0 + actualAmountOut01 * price1 / scale1;
    }

    function getValueOfTokenToToken(
        address token, 
        uint amount, 
        address [] memory pathArr
    ) external view returns(uint inputVaule, uint outputValue) {
        (address oracle, ,) = controller.getValueConf(token);
        uint scaleIn = 10 ** IERC20Metadata(token).decimals();
        inputVaule = IUSDOracle(oracle).getPrice(token) * amount / scaleIn;

        address targetToken;
        uint amountOut;
        uint112[] memory reserves = new uint112[](2);

        (targetToken, amountOut, reserves) = _predictSwapAmount(token, amount, pathArr, reserves, address(0));

        uint price = _getPrice(token, pathArr);

        uint scaleOut = 10 ** IERC20Metadata(targetToken).decimals();

        outputValue = amountOut * price / scaleOut;
    }

    function _predictSwapAmount(
        address originToken,
        uint amount, 
        address [] memory pathArr,
        uint112 [] memory reserves,
        address lp
    ) internal view returns (address targetToken, uint amountOut, uint112 [] memory _reserves) {
        if (pathArr.length == 0) {
              return (originToken, amount, reserves);
        }

        // check busd -> dusd
        for (uint i = 0; i < pathArr.length; i++) {
            if(pathArr[i] == IDusdMinter(minter).stableToken() && i < pathArr.length - 1) {
                if(pathArr[i+1] == IDusdMinter(minter).dusd()) {
                    return _predictSwapOfStableTokentoDUSD(pathArr, i, amount, reserves, lp);
                }
            }
        }

        (amountOut, _reserves) = _getAmountOut(amount, pathArr, reserves, lp);
        return (pathArr[pathArr.length - 1], amountOut, _reserves);
    }

    function _predictSwapOfStableTokentoDUSD(
        address[] memory pathArr, 
        uint position,
        uint amount,
        uint112 [] memory reserves,
        address lp
        ) internal view returns(address targetToken, uint amountOut, uint112 [] memory _reserves) {
        uint len = pathArr.length;

        // len = 2, busd -> dusd
        if(len == 2) {
            (amountOut, ) = IDusdMinter(minter).calcOutputFee(amount);
            return (pathArr[1], amountOut, reserves);
        }

        // len > 2, ...busd -> dusd...
        uint busdAmout;
        uint dusdAmount;
        if(position == 0) {
            // busd -> dusd, and then swap [dusd, ...]
            (dusdAmount, ) = IDusdMinter(minter).calcOutputFee(amount);
            address[] memory newPathArr = _fillArrbyPosition(1, len-1, pathArr);
            (amountOut, _reserves) = _getAmountOut(dusdAmount, newPathArr, reserves, lp);
            return (pathArr[pathArr.length - 1], amountOut, _reserves);
        }else if(position == len - 2) {
            // swap [..., busd], and then busd -> dusd
            address[] memory newPathArr = _fillArrbyPosition(0, len-2, pathArr);
            (busdAmout, _reserves) = _getAmountOut(amount, newPathArr, reserves, lp);
            (amountOut, ) = IDusdMinter(minter).calcOutputFee(busdAmout);
            return (pathArr[pathArr.length - 1], amountOut, _reserves);
        } else {
            // swap [..., busd], and then busd -> dusd, and swap [dusd, ...]
            address[] memory newPathArr0 = _fillArrbyPosition(0, position, pathArr);
            address[] memory newPathArr1 = _fillArrbyPosition(position+1, len-1, pathArr);
            (busdAmout, _reserves) = _getAmountOut(amount, newPathArr0, reserves, lp);
            (dusdAmount, ) = IDusdMinter(minter).calcOutputFee(busdAmout);
            (amountOut, _reserves) = _getAmountOut(dusdAmount, newPathArr1, _reserves, lp);
            return (pathArr[pathArr.length - 1], amountOut, _reserves);
        }
    }
    
    function _fillArrbyPosition(
        uint start,
        uint end,
        address[] memory originArr
    ) internal view returns (address[] memory) {
        uint newLen = end-start+1;
        address[] memory newArr = new address[](newLen);
        for (uint i = 0; i < newLen; i++) {
            newArr[i] = originArr[i+start];
        }
        return newArr;
    }

    function _getAmountOut(
      uint amount, 
      address[] memory path,
      uint112 [] memory reserves,
      address lp
      ) internal view returns (uint amountOut, uint112 [] memory){
  
        if(lp != address(0)){
          // swap Token to Lp. 
          IPair pair = IPair(lp);
          address token0 = pair.token0();
          address token1 = pair.token1();
          uint slow = 0;
          uint fast = 1;
          uint start = 0; // currently start to swap

          amountOut = amount;

          for (fast; fast < path.length; fast++) {
            if(path[slow] == token0 && path[fast] == token1) {
              // token0 -> token1
              if(start < slow) {
                // ... -> token0, token0 -> token1
                address[] memory newPathArr = _fillArrbyPosition(start, slow, path);
                amountOut = _tryToGetAmountsOut(amountOut, newPathArr);
                uint token0GapAmount = amountOut;
                amountOut = _getAmountsOutByReserves(token0GapAmount, uint(reserves[0]), uint(reserves[1]));
                uint token1GapAmount = amountOut;
                reserves[0] += uint112(token0GapAmount);
                reserves[1] -= uint112(token1GapAmount);
              } else {
                // start = slow, means token0 -> token1
                uint token0GapAmount = amountOut;
                amountOut = _getAmountsOutByReserves(token0GapAmount, uint(reserves[0]), uint(reserves[1]));
                uint token1GapAmount = amountOut;
                reserves[0] += uint112(token0GapAmount);
                reserves[1] -= uint112(token1GapAmount);
              }
              // reassignment
              start = fast;
            } else if(path[slow] == token1 && path[fast] == token0) {
              // token1 -> token0
              if(start < slow) {
                // ... -> token1, token1 -> token0
                address[] memory newPathArr = _fillArrbyPosition(start, slow, path);
                amountOut = _tryToGetAmountsOut(amountOut, newPathArr);
                uint token1GapAmount = amountOut;
                amountOut = _getAmountsOutByReserves(token1GapAmount, uint(reserves[1]), uint(reserves[0]));
                uint token0GapAmount = amountOut;
                reserves[1] += uint112(token1GapAmount);
                reserves[0] -= uint112(token0GapAmount);
              } else {
                // start = slow, means token1 -> token0
                uint token1GapAmount = amountOut;
                amountOut = _getAmountsOutByReserves(token1GapAmount, uint(reserves[1]), uint(reserves[0]));
                uint token0GapAmount = amountOut;
                reserves[1] += uint112(token1GapAmount);
                reserves[0] -= uint112(token0GapAmount);
              }
              // reassignment
              start = fast;
            } else {
              if(fast == path.length - 1) {
                // path end
                address[] memory newPathArr = _fillArrbyPosition(start, fast, path);
                amountOut = _tryToGetAmountsOut(amountOut, newPathArr);
              }
            }
            slow++;
          }

        } else {
          // swap Token to Token
          amountOut = _tryToGetAmountsOut(amount, path);
        }
        return(amountOut, reserves);
    }

    function _tryToGetAmountsOut(
      uint amount, 
      address[] memory path
    ) internal view returns(uint amountOut) {
      try router.getAmountsOut(amount, path) returns (uint[] memory amounts) {
        amountOut = amounts[amounts.length - 1];
      } catch {
        revert("Wrong Path");
      }
    }

    function _getAmountsOutByReserves(
      uint amountIn, 
      uint reserveIn, 
      uint reserveOut
    ) internal view returns(uint amountOut) {
      require(amountIn > 0, 'Reader: INSUFFICIENT_INPUT_AMOUNT');
      require(reserveIn > 0 && reserveOut > 0, 'Reader: INSUFFICIENT_LIQUIDITY');
      uint amountInWithFee = amountIn.mul(9975);
      uint numerator = amountInWithFee.mul(reserveOut);
      uint denominator = reserveIn.mul(10000).add(amountInWithFee);
      amountOut = numerator / denominator;
    }

    function _getPrice(
        address token,
        address[] memory pathArr
    ) internal view returns (uint price) {
        if (pathArr.length == 0) {
            // tokenInput 
            (address oracle, ,) = controller.getValueConf(token);
            return IUSDOracle(oracle).getPrice(token);
        }
        // tokenOutput
        address _token = pathArr[pathArr.length - 1];
        (address oracle, ,) = controller.getValueConf(token);
        price = IUSDOracle(oracle).getPrice(_token);
    }

    function _getQuoteAmount(
        address token0,
        uint amountOut0,
        address token1,
        uint amountOut1,
        uint112[] memory reserves
    ) internal view returns (uint actualAmountOut0, uint actualAmountOut1) {
        address lp = factory.getPair(token0, token1);
        IPair pair = IPair(lp);
        address _token0 = pair.token0();
        address _token1 = pair.token1();

        uint112 reserve0 = reserves[0];
        uint112 reserve1 = reserves[1];
        
        if(_token0 != token0) {
          // switch places when not match
          uint112 temp = reserve0;
          reserve0 = reserve1;
          reserve1 = temp;
        }

        uint quoteAmountOut1 = router.quote(amountOut0, reserve0, reserve1);
        uint quoteAmountOut0 = router.quote(amountOut1, reserve1, reserve0);

        if(quoteAmountOut1 <= amountOut1) {
          return(amountOut0, quoteAmountOut1);
        } else if(quoteAmountOut0 <= amountOut0) {
          return(quoteAmountOut0, amountOut1);
        } else {
          revert("Reader: predict addLiquidity error");
        }
    }

    function _checkAmountOut(
        address token0,
        address token1,
        uint amountOut0,
        uint amountOut1
    ) internal view {
        address lp = factory.getPair(token0, token1);
        IPair pair = IPair(lp);
        address _token0 = pair.token0();
        address _token1 = pair.token1();

        require(amountOut0 > 0 && amountOut1 > 0, "Wrong Path: amountOut is zero");
        require(token0 == _token0 || token0 == _token1, "Wrong Path: target tokens don't match");
        require(token1 == _token0 || token1 == _token1, "Wrong Path: target tokens don't match");
    }

    function _getReserves(
        address token,
        address[] memory pathArr0,
        address[] memory pathArr1
    ) internal view returns(uint112[] memory, address lp){
        address token0 = pathArr0.length == 0? token: pathArr0[pathArr0.length - 1];
        address token1 = pathArr1.length == 0? token: pathArr1[pathArr1.length - 1];

        require(token0 != token1, "Zap: target tokens should't be the same");

        lp = factory.getPair(token0, token1);
        IPair pair = IPair(lp);

        uint112[] memory _reserves = new uint112[](2);
        (_reserves[0], _reserves[1], ) = pair.getReserves();
        return (_reserves, lp);
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

// for PancakePair or UniswapPair
interface IPair {

  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function balanceOf(address owner) external view returns (uint);

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IVault {
  // call from controller must impl.
  function underlying() external view returns (address);
  function isDuetVault() external view returns (bool);
  function liquidate(address liquidator, address borrower, bytes calldata data) external;
  function userValue(address user, bool dp) external view returns(uint);
  function pendingValue(address user, int pending) external view returns(uint);
  function underlyingAmountValue(uint amount, bool dp) external view returns(uint value);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IController {
  function dyTokens(address) external view returns (address);
  function getValueConf(address _underlying) external view returns (address oracle, uint16 dr, uint16 pr);
  function getValueConfs(address token0, address token1) external view returns (address oracle0, uint16 dr0, uint16 pr0, address oracle1, uint16 dr1, uint16 pr1);

  function strategies(address) external view returns (address);
  function dyTokenVaults(address) external view returns (address);

  function beforeDeposit(address , address _vault, uint) external view;
  function beforeBorrow(address _borrower, address _vault, uint256 _amount) external view;
  function beforeWithdraw(address _redeemer, address _vault, uint256 _amount) external view;
  function beforeRepay(address _repayer , address _vault, uint256 _amount) external view;

  function joinVault(address _user, bool isDeposit) external;
  function exitVault(address _user, bool isDeposit) external;

  function userValues(address _user, bool _dp) external view returns(uint totalDepositValue, uint totalBorrowValue);
  function userTotalValues(address _user, bool _dp) external view returns(uint totalDepositValue, uint totalBorrowValue);

  function liquidate(address _borrower, bytes calldata data) external;

  // ValidVault 0: uninitialized, default value
  // ValidVault 1: No, vault can not be collateralized
  // ValidVault 2: Yes, vault can be collateralized
  enum ValidVault { UnInit, No, Yes }
  function validVaults(address _vault) external view returns(ValidVault);
  function validVaultsOfUser(address _vault, address _user) external view returns(ValidVault);

}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IUSDOracle {
  // Must 8 dec, same as chainlink decimals.
  function getPrice(address token) external view returns (uint256);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;
interface IRouter02 {
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface IPancakeFactory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IDusdMinter {
    function dusd() external view returns(address);
    function stableToken() external view returns(address);
    function mineDusd(uint amount, uint minDusd, address to) external returns(uint amountOut);
    function calcInputFee(uint amountOut) external view returns (uint amountIn, uint fee);
    function calcOutputFee(uint amountIn) external view returns (uint amountOut, uint fee);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;


interface IDYToken {
  function deposit(uint _amount, address _toVault) external;
  function depositTo(address _to, uint _amount, address _toVault) external;
  function depositCoin(address to, address _toVault) external payable;

  function withdraw(address _to, uint _shares, bool needWETH) external;
  function underlyingTotal() external view returns (uint);

  function underlying() external view returns(address);
  function balanceOfUnderlying(address _user) external view returns (uint);
  function underlyingAmount(uint amount) external view returns (uint);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IFeeConf {
  function getConfig(bytes32 _key) external view returns (address, uint); 
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMintVault {

  function borrows(address user) external view returns(uint amount);
  function borrow(uint256 amount) external;
  function repay(uint256 amount) external;
  function repayTo(address to, uint256 amount) external;

  function valueToAmount(uint value, bool dp) external view returns(uint amount);

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IDepositVault {

  function deposits(address user) external view returns(uint amount);
  function deposit(address dtoken, uint256 amount) external;
  function depositTo(address dtoken, address to, uint256 amount) external;
  function syncDeposit(address dtoken, uint256 amount, address user) external;

  function withdraw(uint256 amount, bool unpack) external;
  function withdrawTo(address to, uint256 amount, bool unpack) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Constants {
  uint internal constant PercentBase = 10000;
}