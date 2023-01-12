// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;
import "IDappGuardRegistry.sol";
import "IDappGuard.sol";
import "AccessManager.sol";

contract DappGuardRegistry is IDappGuardRegistry, AccessManager {
    mapping(address => address) public dappGuards;

    constructor(IRoleRegistry _roleRegistry) {
        setRoleRegistry(_roleRegistry);
    }

    function setDappGuardForGameContract(
        address gameContract,
        address dappGuardContract
    ) external override onlyRole(Roles.DAPP_GUARD) {
        require(
            dappGuards[gameContract] == address(0),
            "DappGuard already set!"
        );
        dappGuards[gameContract] = dappGuardContract;
    }

    function updateDappGuardForGameContract(
        address gameContract,
        address dappGuardContract
    ) external override onlyRole(Roles.DAPP_GUARD) {
        removeDappGuardForGameContract(gameContract);
        dappGuards[gameContract] = dappGuardContract;
    }

    function getDappGuardForGameContract(address gameContract)
        external
        view
        override
        returns (address)
    {
        return dappGuards[gameContract];
    }

    function isWhitelistedGameContract(address gameContract)
        external
        view
        override
        returns (bool)
    {
        return dappGuards[gameContract] != address(0);
    }

    function removeDappGuardForGameContract(address gameContract)
        public
        override
        onlyRole(Roles.DAPP_GUARD)
    {
        require(
            dappGuards[gameContract] != address(0),
            "DappGuard already set!"
        );
        IDappGuard(dappGuards[gameContract]).kill();
        dappGuards[gameContract] = address(0);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

// Registry of all currently used DappGuard contracts
interface IDappGuardRegistry {
    function setDappGuardForGameContract(
        address gameContract,
        address dappGuardContract
    ) external;

    function updateDappGuardForGameContract(
        address gameContract,
        address dappGuardContract
    ) external;

    function removeDappGuardForGameContract(address gameContract) external;

    function getDappGuardForGameContract(address gameContract)
        external
        view
        returns (address);

    // Function to check if the gameContract is whitelisted
    function isWhitelistedGameContract(address gameContract)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

// This will need to implement the delegation method
interface IDappGuard {
    // Main point of entry for calling the gaming contracts (this will delegatecall to gaming contract)
    function postCallHook(
        address gameContract,
        bytes calldata data_,
        bytes calldata returnData
    ) external;

    function whitelistFunction(
        address gameContract,
        bytes4 selector,
        bool claimFunction
    ) external;

    function batchWhitelistFunction(
        address[] memory gameContracts,
        bytes4[] memory selectors,
        bool[] memory claimFunction
    ) external;

    function removeFunctionsFromWhitelist(address gameContract, bytes4 selector)
        external;

    function kill() external;

    function validateCall(address gameContract, bytes calldata data_)
        external
        view
        returns (bytes memory);

    function validateOasisClaimCall(address gameContract, bytes calldata data_)
        external
        view
        returns (bytes memory);

    function isFunctionsWhitelisted(address gameContract, bytes4 selector)
        external
        view
        returns (bool);

    function isClaimFunction(address gameContract, bytes4 selector)
        external
        view
        returns (bool);

    function gamingContracts() external view returns (address[] memory);

    function getFunctionsForContract(address gameContract)
        external
        view
        returns (bytes4[] memory);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "RoleLibrary.sol";

import "IRoleRegistry.sol";

/**
 * @notice Provides modifiers for authorization
 */
contract AccessManager {
    IRoleRegistry internal roleRegistry;
    bool public isInitialised = false;

    modifier onlyRole(bytes32 role) {
        require(roleRegistry.hasRole(role, msg.sender), "Unauthorized access");
        _;
    }

    modifier onlyGovernance() {
        require(
            roleRegistry.hasRole(Roles.ADMIN, msg.sender),
            "Unauthorized access"
        );
        _;
    }

    modifier onlyRoles2(bytes32 role1, bytes32 role2) {
        require(
            roleRegistry.hasRole(role1, msg.sender) ||
                roleRegistry.hasRole(role2, msg.sender),
            "Unauthorized access"
        );
        _;
    }

    function setRoleRegistry(IRoleRegistry _roleRegistry) public {
        require(!isInitialised, "RoleRegistry already initialised");
        roleRegistry = _roleRegistry;
        isInitialised = true;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.10;

library Roles {
    bytes32 internal constant ADMIN = "admin";
    bytes32 internal constant REVENUE_MANAGER = "revenue_manager";
    bytes32 internal constant MISSION_TERMINATOR = "mission_terminator";
    bytes32 internal constant DAPP_GUARD = "dapp_guard";
    bytes32 internal constant DAPP_GUARD_KILLER = "dapp_guard_killer";
    bytes32 internal constant MISSION_CONFIGURATOR = "mission_configurator";
    bytes32 internal constant VAULT_WITHDRAWER = "vault_withdrawer";
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

interface IRoleRegistry {
    function grantRole(bytes32 _role, address account) external;

    function revokeRole(bytes32 _role, address account) external;

    function hasRole(bytes32 _role, address account)
        external
        view
        returns (bool);
}