// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface PoolGateway {
    
    function setClientPeers(
        uint256[] calldata _chainIds,
        address[] calldata _peers
    ) external;

    
    function changeAdmin(address _admin) external;
}

interface PoolGatewayFactory {
    function createPoolGateway(
        address token,
        address owner,
        uint256 salt
    ) external returns (address);

}

contract createAndSetPeersContract{
    PoolGatewayFactory public poolGatewayFactory;

    constructor(PoolGatewayFactory _factory) {
        poolGatewayFactory = _factory;
    }

    function createAndSetPeers(
        address token,
        address owner,
        uint256 salt,
        uint256[] calldata _chainIds,
        address[] calldata _peers
    ) external {
        // Call the createPoolGateway function in the factory contract to create a new gateway

        // give admin to this contract temp
        address gateway = poolGatewayFactory.createPoolGateway(token, address(this), salt);


        // Call the setClientPeers function on the new gateway
        PoolGateway(gateway).setClientPeers(_chainIds, _peers);

        // transfer admin to the owner
        PoolGateway(gateway).changeAdmin(owner);
    }
}