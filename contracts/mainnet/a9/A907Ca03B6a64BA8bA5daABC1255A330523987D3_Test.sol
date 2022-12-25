/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;
/// @custom:natspec for contract-definition
/**
   * @title ContractName
   * @dev ContractDescription
   * @custom:dev-run-script ./contracts/Test.sol
   */
contract Test {
    /// @custom:natspec for storage-definition
    uint256 public x = 0;
    /// @custom:natspec for event-definition
    event Incremented();
    /// @custom:natspec for function-definition
    function incr() external returns (uint256) {
        
        /// @custom: natspec for event
        emit Incremented();
        /// @custom: natspec for variable-assignement
        return ++x;
    }
}