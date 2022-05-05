// SPDX-License-Identifier: MIT
// Developed by: dxsoftware.net

pragma solidity 0.7.6;

import "./interfaces/ISummitswapRouter02.sol"; // for swap, for add liquidity
import "./interfaces/ISummitswapLocker.sol"; // for locking (lockTokens)
import "./interfaces/ISummitswapFactory.sol";
import "./interfaces/IERC20.sol"; // for token functions

contract SummitswapOnboarding {
  ISummitswapRouter02 public summitswapRouter02;
  ISummitswapLocker public summitswapLocker;
  IERC20 public userToken;
  IERC20 public lpToken;
  ISummitswapFactory public summitswapFactory;

  address public kodaAddress = 0x063646d9C4eCB1c341bECdEE162958f072C43561;
  address public summitReferralAddress = 0xDF8b4F4414aeB9598000666eF703E18A9aFfF47b;
  address[] public pathForBnbToKoda = [
    0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd,
    0x063646d9C4eCB1c341bECdEE162958f072C43561
  ]; // bnb to koda
  address[] public pathForUserToken;

  function onboardToken(
    uint256 bnbAmount,
    uint256 deadline, // now + 20 minutes
    uint256 amountOutMin,
    address userTokenAddress,
    uint256 kodaAmountDesired,
    uint256 userTokenAmountDesired,
    uint256 kodaAmountMin,
    uint256 userTokenAmountMin,
    uint256 amountForLockTokens,
    uint256 unlockTime,
    address payable withdrawer,
    uint256 amountForTransfer
  ) public {
    uint256 _deadline = deadline;
    summitswapRouter02.swapExactETHForTokens{value: bnbAmount}(amountOutMin, pathForBnbToKoda, msg.sender, _deadline);
    summitswapRouter02.addLiquidity(
      kodaAddress,
      userTokenAddress,
      kodaAmountDesired,
      userTokenAmountDesired,
      kodaAmountMin,
      userTokenAmountMin,
      address(this),
      _deadline
    );
    address pairAddress = summitswapFactory.getPair(kodaAddress, userTokenAddress);
    summitswapLocker.lockTokens(pairAddress, amountForLockTokens, unlockTime, withdrawer, 2);
    userToken.transfer(summitReferralAddress, amountForTransfer);
  }
}

pragma solidity >=0.6.2;

import "./ISummitswapRouter01.sol";

interface ISummitswapRouter02 is ISummitswapRouter01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  // Supporting Fee cause We are sending fee
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

pragma solidity 0.7.6;

interface ISummitswapLocker {
  function lockTokens(
    address lpToken,
    uint256 amount,
    uint256 unlockTime,
    address payable withdrawer,
    uint8 feePaymentMode
  ) external view returns (uint256 lockId);
}

pragma solidity >=0.5.0;

interface ISummitswapFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.2;

interface ISummitswapRouter01 {
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
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

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

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}