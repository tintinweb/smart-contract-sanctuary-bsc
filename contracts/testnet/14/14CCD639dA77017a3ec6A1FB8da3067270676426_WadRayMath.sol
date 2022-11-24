// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.9;

library WadRayMath {
    uint256 internal constant HALF_RAY = 5e26;
    uint256 internal constant RAY = 1e27;
    uint256 internal constant WAD = 1e18;
    uint256 internal constant WAD_RAY_RATIO = 1e9;

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (b / 2 + a * RAY) / b;
    }

    function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (HALF_RAY + a * b) / RAY;
    }

    function rayToWad(uint256 a) internal pure returns (uint256) {
        return (WAD_RAY_RATIO / 2 + a) / WAD_RAY_RATIO;
    }

    function wadToRay(uint256 a) internal pure returns (uint256) {
        return a * WAD_RAY_RATIO;
    }
}