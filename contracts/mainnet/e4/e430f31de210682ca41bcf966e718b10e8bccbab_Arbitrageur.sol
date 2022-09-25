/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// File: interfaces/IUniswapV2Router.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {
  function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
}
// File: Arbitrageur.sol

pragma solidity ^0.8.0;


contract Arbitrageur {
    function getTokensAmountIn(address[] calldata _tokens, address _baseToken, uint256 amountOut, IUniswapV2Router _router)
        external
        view
        returns (int256[] memory)
    {
        int256[] memory result = new int256[](_tokens.length);

        address[] memory path = new address[](2);
        path[0] = _baseToken;

        for (uint256 i = 0; i < _tokens.length; i++) {
          path[1] = _tokens[i];
          try _router.getAmountsIn(amountOut, path) returns (uint256[] memory amounts) {
            result[i] = int256(amounts[0]);
          } catch Error(string memory) {
            result[i] = -1;
          } catch (bytes memory) {
            result[i] = -1;
          }
        }

        return result;
    }
}