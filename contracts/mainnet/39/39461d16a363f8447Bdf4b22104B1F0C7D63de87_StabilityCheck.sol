/**
 * @title Stability Check
 * @dev StabilityCheck contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./IRouter2.sol";

pragma solidity 0.6.12;

contract StabilityCheck {
    uint256 public unstableValue = 900000000000000000;

    address[] public outputToUSDRoute = [
        0x7DF1938170869AFE410098540c051A8A50308988,
        0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
    ];

    // Pre-Check how many tokens can be created.
    function isStabilityOK() public view returns (bool) {
        if (rewardsAvailableInBUSD() <= unstableValue) {
            return false;
        }
        return true;
    }

    function rewardsAvailableInBUSD() public view returns (uint256) {
        uint256 amountIn = 1000000000000000000;
        uint256 USDOut;
        try
            IRouter2(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(
                amountIn,
                outputToUSDRoute
            )
        returns (uint256[] memory amountOut) {
            USDOut = amountOut[amountOut.length - 1];
        } catch {}

        return USDOut;
    }

    function setUnstableValue(uint256 _unstableValue) public {
        unstableValue = _unstableValue;
    }
}