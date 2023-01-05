// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.9;
import "./interface.sol";

contract Taoli {
    mapping (string => address) COINS;

    constructor() {
        COINS["ETH"] = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
        COINS["USDC"] = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
        COINS["USDT"] = 0x55d398326f99059fF775485246999027B3197955;
    }

    function balanceOf(address coin, address account) public view returns (uint256) {
        return IERC20(coin).balanceOf(account);
    }

    function getBalancesByName(string[] memory tokens, address account) public view returns (uint[] memory) {
        uint[] memory result = new uint[](tokens.length);
        for(uint i=0; i<tokens.length; i++){
            result[i] = this.balanceOf(COINS[tokens[i]], account);
        }
        return result;
    }

    function getBalancesByAddress(address[] memory coins, address account) public view returns (uint[] memory) {
        uint[] memory result = new uint[](coins.length);
        for(uint i=0; i<coins.length; i++){
            result[i] = this.balanceOf(coins[i], account);
        }
        return result;
    }

    function getReserves(address factory) public view returns (uint112, uint112) {
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, ) = UniswapPair(factory).getReserves();
        return (reserve0, reserve1);
    }

    function getReservesByAddress(address[] memory pairs) public view returns (uint[] memory) {
        uint[] memory result = new uint[](pairs.length * 2);
        for(uint i=0; i<pairs.length; i++){
            (result[i * 2], result[i *2 + 1]) = this.getReserves(pairs[i]);
        }
        return result;
    }
}

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view
        returns (uint256);
    function decimals() external view returns (uint8);
}

interface UniswapRoute {
    function factory() external view returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface UniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
}

interface UniswapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}