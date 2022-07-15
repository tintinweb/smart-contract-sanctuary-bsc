/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IERC0 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
}


interface IPancakeRouter {
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

  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface My {
  function buy(address token) external view returns (uint256);
}


library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

contract test{
  receive() external payable {}
  address router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
  address wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

  
  function buy(address token) internal returns (uint256){
    address[] memory path;
    path[0] = wbnb;
    path[1] = token;
    IPancakeRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value:0.0001*1e18}(0,path,address(this),block.timestamp);
    uint256 balance = IERC0(token).balanceOf(address(this));
    return balance;
  }

  function sss(address _token)  external  view returns(uint256) {
    return My(address(this)).buy(_token);
  }
}