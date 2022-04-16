/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File contracts/modules/kanaloa/module/IModule.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

enum SecurityLevel {
    CRITICAL,
    HIGH,
    MEDIUM,
    LOW
}

struct ModuleMetadata {
    bytes32 signature;
    uint256 version;
    bytes4[] selectors;
    bytes4 initializer;
    SecurityLevel securityLevel;
}

enum InitLevel {
    NOT_INITIALIZED,
    INITIALIZING,
    INITIALIZED
}

interface IModule {
    function getModuleMetadata() external view returns (ModuleMetadata memory);
    function getStorageAddress() external pure returns (bytes32);
}


// File contracts/modules/kanaloa/refraction-engine/IRefractionEngine.sol

pragma solidity ^0.8.0;

struct RefractionEngineStorage {
    InitLevel init;
    address deployer;
    address operator;
    uint256 stateVersion;
    mapping(bytes4 => address) selectorToContract;
}

interface IRefractionEngine is IModule {

    enum VtableOpCode {
        NO_OP,
        ADD,
        REPLACE,
        REMOVE
    }

    struct VtableOps {
        address implementation;
        VtableOpCode op;
        bytes4[] functionSelectors;
    }

    event ModuleInitialized(
        bytes32 indexed moduleSignature,
        uint256 moduleVersion,
        bytes initData
    );

    struct VtableActionTaken {
        VtableOpCode op;
        bytes4 selector;
    }

    event VtableEdited(
        address indexed issuer,
        VtableOps[] operations
    );

    event ModuleInstalled(
        bytes32 indexed moduleSignature,
        uint256 moduleVersion,
        VtableActionTaken[] actionsTaken
    );


    function selectorToContract(bytes4 selector) external returns (address);
    function editVtable(VtableOps[] calldata ops) external;
    function installModule(IModule module) external;
    function installAndInitModule(IModule module, bytes calldata _calldata) external;
    function installAndInitModules(IModule[] calldata module, bytes[] calldata _calldata) external;
    function initialize(address op, address refractionEngine) external;
}


// File contracts/modules/kanaloa/refraction-engine/LibRefractionEngine.sol

pragma solidity ^0.8.0;

library LibRefractionEngine {
    bytes32 constant REFRACTION_ENGINE_STORAGE =
        keccak256("modules.kanaloa.refraction-engine");

    function getRefractionEngineStorage()
        internal pure
        returns (RefractionEngineStorage storage state) {
        bytes32 position = REFRACTION_ENGINE_STORAGE;
        assembly {
            state.slot := position
        }
    }

    function getRefractionEngineSignature()
        internal pure
        returns (bytes32) {
            return REFRACTION_ENGINE_STORAGE;
    }
}


// File contracts/modules/kanaloa/refraction-engine/RefractionProxy.sol

pragma solidity ^0.8.0;

contract RefractionProxy {

    constructor(address op, address rE) {
        (bool success, ) = rE.delegatecall(
            abi.encodeWithSignature("initialize(address,address)", op, rE)
        );
        require(success, "RefractionProxy: Could not initialize RefractionEngine.");
    }

    fallback() external payable {
        RefractionEngineStorage storage state =
            LibRefractionEngine.getRefractionEngineStorage();

        address impl = state.selectorToContract[msg.sig];
        require(impl != address(0), "RefractionProxy: function signature not found");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0,0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}