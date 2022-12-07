/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Call {

    function call() public {

        address addr = 0x73c8Eda378f4E40cd4d85440472C8C021F777775;
        bytes4 selector = bytes4(keccak256("retrieve()"));
        bytes memory proxyCallData = abi.encodeWithSelector(selector);
        (bool didSucceed, bytes memory returnData) = addr.call(proxyCallData);

    }
}