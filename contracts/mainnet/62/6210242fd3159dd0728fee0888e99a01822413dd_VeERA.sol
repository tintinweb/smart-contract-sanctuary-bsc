/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface IERA7veFarm { 
    function userInfo(address) external view returns (uint256[5] memory);
}

/**
 * Get balance of veERA
 */
contract VeERA {
    address private farm = 0xD67016118B086B4830F25E137B72d55790cb1869;

    function balanceOf(address user) public view returns(uint256) {
        uint256[5] memory results = IERA7veFarm(farm).userInfo(user);
        return results[3];
    }
}