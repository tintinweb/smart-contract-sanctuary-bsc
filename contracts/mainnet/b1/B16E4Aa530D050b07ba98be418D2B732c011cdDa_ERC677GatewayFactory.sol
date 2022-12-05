// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./IFactory.sol";
import "./ERC677Gateway_MintBurn.sol";
import "./ERC677Gateway_MintBurnFrom.sol";
import "./ERC677Gateway_Pool.sol";

contract ERC677GatewayFactory is IFactory {
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
        if (gatewayType == GatewayType.ERC677MintBurn) {
            addr = address(new ERC677Gateway_MintBurn(anyCall, feeType, token));
            ERC677Gateway_MintBurn(addr).transferAdmin(owner);
        } else if (gatewayType == GatewayType.ERC677MintBurnFrom) {
            addr = address(
                new ERC677Gateway_MintBurnFrom(anyCall, feeType, token)
            );
            ERC677Gateway_MintBurnFrom(addr).transferAdmin(owner);
        } else if (gatewayType == GatewayType.ERC677Pool) {
            addr = address(new ERC677Gateway_Pool(anyCall, feeType, token));
            ERC677Gateway_Pool(addr).transferAdmin(owner);
        } else {
            revert("Factory: unsupported gateway type");
        }

        emit Created(addr, token, owner, feeType, gatewayType);
        return addr;
    }
}