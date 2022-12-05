// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./IFactory.sol";
import "./ERC1155Gateway_MintBurn.sol";
import "./ERC1155Gateway_Pool.sol";

contract ERC1155GatewayFactory is IFactory {
    event Created(
        address addr,
        address token,
        address owner,
        uint256 feeType,
        GatewayType gatewayType
    );

    function create(
        address anyCall,
        address token,
        address owner,
        uint256 feeType,
        GatewayType gatewayType
    ) public payable returns (address) {
        address addr;
        if (gatewayType == GatewayType.ERC1155MintBurn) {
            addr = address(
                new ERC1155Gateway_MintBurn(anyCall, feeType, token)
            );
            ERC1155Gateway_MintBurn(addr).transferAdmin(owner);
        } else if (gatewayType == GatewayType.ERC1155Pool) {
            addr = address(new ERC1155Gateway_Pool(anyCall, feeType, token));
            ERC1155Gateway_Pool(addr).transferAdmin(owner);
        } else {
            revert("Factory: unsupported gateway type");
        }

        emit Created(addr, token, owner, feeType, gatewayType);
        return addr;
    }
}