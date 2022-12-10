/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File contracts/protocols/Minter.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Minter {
    address public immutable factory;
    address public immutable xen;

    constructor(address _xen, address _factory) {
        xen = _xen;
        factory = _factory;
    }

    /**
     * @notice Call XEN contract directly
     * @dev This function can only be called by factory contract
     * @param data The calldata passed in when call XEN contract
     */
    function callXEN(bytes memory data) external {
        require(msg.sender == factory, "invalid caller");
        address xenAddress = xen;
        assembly {
            let succeeded := call(
                gas(),
                xenAddress,
                0,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
        }
    }
}