/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 number;
    uint256 total;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

     function totalFourNumber(uint256 num1, uint256 num2, uint256 num3, uint256 num4) public {
         total = num1 + num2 + num3 + num4;

     }
    function retrieve() public view returns (uint256){
        return number;
    }

    function retrieveTotal() public view returns (uint256) {
        return total;
    }
}