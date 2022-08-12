// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../../interfaces/IDex.sol";

contract TestCalculator {
    function getERC20PriceInUSD(address _token) public view returns (uint256) {
        address[] memory values =  new address[](2);
        address dexFactory = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        values[0] = _token;
        values[1] = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD

        try IDex(dexFactory).getAmountsOut(1 ether, values) returns (uint256[] memory result) {
            return result[1];
        } catch (bytes memory /*lowLevelData*/) {
            return (0);  // Will not get here
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IDex {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}