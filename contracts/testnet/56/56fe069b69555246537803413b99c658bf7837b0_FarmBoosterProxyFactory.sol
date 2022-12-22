// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IFarmBooster.sol";
import "./FarmBoosterProxy.sol";

contract FarmBoosterProxyFactory {
    address public immutable Farm_Booster;
    address public immutable masterchefV2;
    address public immutable cakeToken;
    // Record the user proxy contract address
    mapping(address => address) public proxyContract;
    // Record the user address corresponding to the proxy
    mapping(address => address) public proxyUser;
    event NewFarmBoosterProxyContract(address indexed farmBoosterProxyAddress);

    /**
     * @notice Constructor
     * @param _farmBooster: the address of the farm booster
     * @param _masterchefV2: the address of the Masterchef V2
     * @param _cakeToken: the address of the cake token
     */
    constructor(
        address _farmBooster,
        address _masterchefV2,
        address _cakeToken
    ) {
        Farm_Booster = _farmBooster;
        masterchefV2 = _masterchefV2;
        cakeToken = _cakeToken;
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

        FarmBoosterProxy(farmBoosterProxyAddress).initialize(msg.sender, Farm_Booster, masterchefV2, cakeToken);
        IFarmBooster(Farm_Booster).setProxy(msg.sender, farmBoosterProxyAddress);

        emit NewFarmBoosterProxyContract(farmBoosterProxyAddress);
    }
}