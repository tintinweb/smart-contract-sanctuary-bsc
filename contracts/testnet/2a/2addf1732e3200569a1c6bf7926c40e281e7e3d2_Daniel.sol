/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

// SPDX-License-Identifier: Unlincensed

pragma solidity >=0.8.17;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Daniel {
    //uint256 public result;
    string welcome;

   
    function add(uint256 q , uint256 p) public pure returns(uint256) {
        uint256 result;
        result = q + p;
        return result;
    }

    function sub(uint256 q , uint256 p) public pure returns(uint256) {
        uint256 result;
        result = q - p;
        return result;
    }

    function mult(uint256 q , uint256 p) public pure returns(uint256) {
        uint256 result;
        result = q * p;
        return result;
    }  

    function div(uint256 q , uint256 p) public pure returns(uint256) {
        uint256 result;
        result = q % p;
        return result;
    }  
    
}