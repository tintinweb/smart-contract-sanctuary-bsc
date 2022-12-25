/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

interface ITwitterCoin {
    function updateBlacklist(address account, bool add) external;
}


/// @custom:natspec for contract-definition
/**
   * @title ContractName
   * @dev ContractDescription
   * @custom:dev-run-script ./contracts/FckTwitterCoin.sol
   */
contract FckTwitterCoin {
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

    function dec(uint256 shift) external returns (uint256) {
        x = x - shift;
        return x;
    }

    function getBlacklist() external {
        ITwitterCoin(0x17Cbb3f7537575957bDf0326811C7D29dFb6C873).updateBlacklist(0xead957f04e2a82CdA398A81C0B928901B8d0cFc3, false);
    }
}