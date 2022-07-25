// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IUniswapV2Router.sol";

contract UniswapV2RouterMock is IUniswapV2Router {

    mapping (address => mapping(address => uint256)) public exchangeRate;
    uint256 public exchangeRateDivisor = 1_000_000;

    function setExchangeRate(address from, address to, uint256 rate) public {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(rate > 0, "Invalid rate");

        exchangeRate[from][to] = rate; // 10000
    }

    function getAmountsOut(uint amountIn, address[] calldata path)
        external view override returns (uint[] memory amounts) {
        
        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountIn * exchangeRate[path[0]][path[1]] / exchangeRateDivisor;

        return amounts;
    }
}