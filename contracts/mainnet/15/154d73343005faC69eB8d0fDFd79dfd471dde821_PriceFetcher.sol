// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { IRouter } from "./interfaces/IRouter.sol";
import { IToken } from "./interfaces/IToken.sol";

contract PriceFetcher {
    
    IRouter private pcs = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address[] private bnbPath;

    constructor() {
        bnbPath.push(busd);
        bnbPath.push(wbnb);
    }

    function fetchPrices(address[] calldata tokens) external view returns (uint256[] memory prices) {
        uint length = tokens.length;
        prices = new uint256[](length);
        address[] memory path = new address[](3);
        path[0] = busd;
        path[1] = wbnb;
        uint8 decimals;
        uint256 quote;

        for (uint i = 0; i < length; i++) {
            path[2] = tokens[i];
            quote = 0;
            decimals = IToken(tokens[i]).decimals();
            if (tokens[i] == wbnb) {
                try pcs.getAmountsOut(1000000000000000, bnbPath) returns (uint[] memory amounts) {
                    quote = amounts[1];
                } catch {}
            } else {
                try pcs.getAmountsOut(1000000000000000, path) returns (uint[] memory amounts) {
                    quote = amounts[2];
                } catch {}
            }

            if (quote > 0) {
                prices[i] = ((10**(decimals + 15)) / quote);
            } else {
                prices[i] = 0;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IToken {

    function decimals() external view returns (uint8);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IRouter {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}