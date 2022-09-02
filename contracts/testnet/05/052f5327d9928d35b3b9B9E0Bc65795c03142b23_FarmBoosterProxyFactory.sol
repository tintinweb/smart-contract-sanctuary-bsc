// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./IFarmBooster.sol";
import "./FarmBoosterProxy.sol";

contract FarmBoosterProxyFactory {
    address public immutable Farm_Booster;
    address public immutable ChiefFarmer;
    address public immutable Waya;
    // Record the user proxy contract address
    mapping(address => address) public proxyContract;
    // Record the user address corresponding to the proxy
    mapping(address => address) public proxyUser;
    event NewFarmBoosterProxyContract(address indexed farmBoosterProxyAddress);

    /**
     * @notice Constructor
     * @param _farmBooster: the address of the farm booster
     * @param _ChiefFarmer: the address of the Chieffarmer
     * @param _Waya: the address of the cake token
     */
    constructor(
        address _farmBooster,
        address _ChiefFarmer,
        address _Waya
    ) {
        Farm_Booster = _farmBooster;
        ChiefFarmer = _ChiefFarmer;
        Waya = _Waya;
    }

    /**
     * @notice It creates the farm booster Proxy contract and initializes the contract.
     */
    function createFarmBoosterProxy() external {
        require(proxyContract[msg.sender] == address(0), "The current user already has a proxy");
        bytes memory bytecode = type(FarmBoosterProxy).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, block.number, msg.sender));
        address farmBoosterProxyAddress;

        assembly {
            farmBoosterProxyAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(proxyUser[farmBoosterProxyAddress] == address(0), "Proxy already exists");

        proxyContract[msg.sender] = farmBoosterProxyAddress;
        proxyUser[farmBoosterProxyAddress] = msg.sender;

        FarmBoosterProxy(farmBoosterProxyAddress).initialize(msg.sender, Farm_Booster, ChiefFarmer, Waya);
        IFarmBooster(Farm_Booster).setProxy(msg.sender, farmBoosterProxyAddress);

        emit NewFarmBoosterProxyContract(farmBoosterProxyAddress);
    }
}