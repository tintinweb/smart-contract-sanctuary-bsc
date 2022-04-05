// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

//import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "./BEP20Token.sol";
contract Router {
  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts)  {}
}

contract Swapper
{
  Router router = Router(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
  BEP20 BNB_token  = BEP20(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
  BEP20 USDC_token = BEP20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);

  function swapDAIToUSDC(uint amount) public
  {
    BNB_token.transferFrom(
      msg.sender,
      address(this),
      amount
    );

    address[] memory path = new address[](2);
    path[0] = address(BNB_token);
    path[1] = address(USDC_token);

    BNB_token.approve(address(router), amount);

    router.swapExactTokensForTokens(
      amount,
      0,
      path,
      msg.sender,
      block.timestamp
    );
  }
}