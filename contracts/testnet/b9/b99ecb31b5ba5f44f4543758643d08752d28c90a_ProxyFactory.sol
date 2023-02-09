/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract SimpleProxy {
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(
            msg.data
        );
    }
}

contract ProxyFactory {
    event CreateProxy(address proxy, address implementation);

    function newProxy(address implementation) external {
        SimpleProxy proxy = new SimpleProxy(implementation);
        emit CreateProxy(address(proxy), implementation);
    }
}