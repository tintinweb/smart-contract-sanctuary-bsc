/**
 *Submitted for verification at BscScan.com on 2022-08-12
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

    bytes32 public constant SIGNATURE_PERMIT_TYPEHASH = keccak256("Permit(address user,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Store value in variable
     * @param num value to store
     * https://github.com/SniperDev716
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public pure returns (uint256){
        return type(uint256).max;
    }
}