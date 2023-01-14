// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

/**
 * @title Multicall
 * @notice Enables calling multiple methods in a single call to the contract.
 */
contract Multicall {
    struct Call {
        address target;
        bytes callData;
    }

    /**
     * @notice Aggregates multiple transactions in a single call
     * @param calls an array of calls : each call has a target and calldata
     */
    function aggregate(Call[] memory calls)
        public
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(
                calls[i].callData
            );
            require(success);
            returnData[i] = ret;
        }
    }
}