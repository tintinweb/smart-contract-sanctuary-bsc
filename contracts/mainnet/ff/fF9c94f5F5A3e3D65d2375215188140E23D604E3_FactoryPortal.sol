// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./IFactory.sol";

contract FactoryPortal {
    address public erc20GatewayFactory;
    address public erc721GatewayFactory;
    address public erc1155GatewayFactory;
    address public erc677GatewayFactory;

    address public anyCall;

    uint256 constant Fee_Type_Preload = 0;
    uint256 constant Fee_Type_Fixed = 2;

    event Created(
        address addr,
        address token,
        address owner,
        uint256 feeType,
        GatewayType gatewayType
    );

    constructor(
        address anyCall_,
        address erc20GatewayFactory_,
        address erc721GatewayFactory_,
        address erc1155GatewayFactory_,
        address erc677GatewayFactory_
    ) {
        anyCall = anyCall_;
        erc20GatewayFactory = erc20GatewayFactory_;
        erc721GatewayFactory = erc721GatewayFactory_;
        erc1155GatewayFactory = erc1155GatewayFactory_;
        erc677GatewayFactory = erc677GatewayFactory_;
    }

    function create(
        address token,
        address owner,
        uint256 feeType,
        GatewayType gatewayType
    ) external payable returns (address) {
        require(feeType == Fee_Type_Preload || feeType == Fee_Type_Fixed);
        address addr;
        if (
            gatewayType == GatewayType.ERC20MintBurn ||
            gatewayType == GatewayType.ERC20MintBurnFrom ||
            gatewayType == GatewayType.ERC20Pool
        ) {
            addr = IFactory(erc20GatewayFactory).create(
                anyCall,
                token,
                owner,
                feeType,
                gatewayType
            );
        }
        if (
            gatewayType == GatewayType.ERC721MintBurn ||
            gatewayType == GatewayType.ERC721Pool
        ) {
            addr = IFactory(erc721GatewayFactory).create(
                anyCall,
                token,
                owner,
                feeType,
                gatewayType
            );
        }
        if (
            gatewayType == GatewayType.ERC1155MintBurn ||
            gatewayType == GatewayType.ERC1155Pool
        ) {
            addr = IFactory(erc1155GatewayFactory).create(
                anyCall,
                token,
                owner,
                feeType,
                gatewayType
            );
        }
        if (
            gatewayType == GatewayType.ERC677MintBurn ||
            gatewayType == GatewayType.ERC677MintBurnFrom ||
            gatewayType == GatewayType.ERC677Pool
        ) {
            addr = IFactory(erc677GatewayFactory).create(
                anyCall,
                token,
                owner,
                feeType,
                gatewayType
            );
        }
        emit Created(addr, token, owner, feeType, gatewayType);
        return addr;
    }
}