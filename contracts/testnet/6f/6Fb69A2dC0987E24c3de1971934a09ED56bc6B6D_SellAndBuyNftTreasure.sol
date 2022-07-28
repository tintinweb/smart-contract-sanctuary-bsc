// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '../interfaces/ISellAndBuyNftTreasure.sol';

contract SellAndBuyNftTreasure is ISellAndBuyNftTreasure
{
    uint8 x = 110;

    function get() external view returns(uint8) {
        return x;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ISellAndBuyNftTreasure
{

}