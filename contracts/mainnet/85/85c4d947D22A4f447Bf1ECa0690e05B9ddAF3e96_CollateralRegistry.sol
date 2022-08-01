// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;


import "./Auth.sol";
import "./interfaces/ICollateralRegistry.sol";


/**
 * @title CollateralRegistry
 **/
contract CollateralRegistry is ICollateralRegistry, Auth {

    mapping(address => uint) public override collateralId;

    address[] public override collateralList;
    
    constructor(address _vaultParameters, address[] memory assets) Auth(_vaultParameters) {
        for (uint i = 0; i < assets.length; i++) {
            require(!isCollateral(assets[i]), "Unit Protocol: ALREADY_EXIST");
            collateralList.push(assets[i]);
            collateralId[assets[i]] = i;
            emit CollateralAdded(assets[i]);
        }
    }

    function addCollateral(address asset) public override onlyManager {
        require(asset != address(0), "Unit Protocol: ZERO_ADDRESS");

        require(!isCollateral(asset), "Unit Protocol: ALREADY_EXIST");

        collateralId[asset] = collateralList.length;
        collateralList.push(asset);

        emit CollateralAdded(asset);
    }

    function removeCollateral(address asset) public override onlyManager {
        require(asset != address(0), "Unit Protocol: ZERO_ADDRESS");

        require(isCollateral(asset), "Unit Protocol: DOES_NOT_EXIST");

        uint id = collateralId[asset];

        delete collateralId[asset];

        uint lastId = collateralList.length - 1;

        if (id != lastId) {
            address lastCollateral = collateralList[lastId];
            collateralList[id] = lastCollateral;
            collateralId[lastCollateral] = id;
        }

        collateralList.pop();

        emit CollateralRemoved(asset);
    }

    function isCollateral(address asset) public override view returns(bool) {
        if (collateralList.length == 0) { return false; }
        return collateralId[asset] != 0 || collateralList[0] == asset;
    }

    function collaterals() external override view returns (address[] memory) {
        return collateralList;
    }

    function collateralsCount() external override view returns (uint) {
        return collateralList.length;
    }
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "./interfaces/IVaultParameters.sol";
import "./interfaces/IWithVaultParameters.sol";

/**
 * @title Auth
 * @dev Manages USDP's system access
 **/
contract Auth is IWithVaultParameters {

    // address of the the contract with vault parameters
    IVaultParameters public immutable override vaultParameters;

    constructor(address _parameters) {
        vaultParameters = IVaultParameters(_parameters);
    }

    // ensures tx's sender is a manager
    modifier onlyManager() {
        require(vaultParameters.isManager(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    // ensures tx's sender is able to modify the Vault
    modifier hasVaultAccess() {
        require(vaultParameters.canModifyVault(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    // ensures tx's sender is the Vault
    modifier onlyVault() {
        require(msg.sender == vaultParameters.vault(), "Unit Protocol: AUTH_FAILED");
        _;
    }
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface ICollateralRegistry {
    event CollateralAdded(address indexed asset);
    event CollateralRemoved(address indexed asset);

    function addCollateral ( address asset ) external;
    function collateralId ( address ) external view returns ( uint256 );
    function collaterals (  ) external view returns ( address[] memory );
    function removeCollateral ( address asset ) external;
    function isCollateral ( address asset ) external view returns ( bool );
    function collateralList ( uint id ) external view returns ( address );
    function collateralsCount (  ) external view returns ( uint );
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface IVaultParameters {
    event ManagerAdded(address indexed who);
    event ManagerRemoved(address indexed who);
    event FoundationChanged(address indexed newFoundation);
    event VaultAccessGranted(address indexed who);
    event VaultAccessRevoked(address indexed who);
    event StabilityFeeChanged(address indexed asset, uint newValue);
    event LiquidationFeeChanged(address indexed asset, uint newValue);
    event OracleTypeEnabled(address indexed asset, uint _type);
    event OracleTypeDisabled(address indexed asset, uint _type);
    event TokenDebtLimitChanged(address indexed asset, uint limit);

    function canModifyVault ( address ) external view returns ( bool );
    function foundation (  ) external view returns ( address );
    function isManager ( address ) external view returns ( bool );
    function isOracleTypeEnabled ( uint256, address ) external view returns ( bool );
    function liquidationFee ( address ) external view returns ( uint256 );
    function setCollateral ( address asset, uint256 stabilityFeeValue, uint256 liquidationFeeValue, uint256 usdpLimit, uint256[] calldata oracles ) external;
    function setFoundation ( address newFoundation ) external;
    function setLiquidationFee ( address asset, uint256 newValue ) external;
    function setManager ( address who, bool permit ) external;
    function setOracleType ( uint256 _type, address asset, bool enabled ) external;
    function setStabilityFee ( address asset, uint256 newValue ) external;
    function setTokenDebtLimit ( address asset, uint256 limit ) external;
    function setVaultAccess ( address who, bool permit ) external;
    function stabilityFee ( address ) external view returns ( uint256 );
    function tokenDebtLimit ( address ) external view returns ( uint256 );
    function vault (  ) external view returns ( address payable );
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2021 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

import "./IVaultParameters.sol";

interface IWithVaultParameters {
    function vaultParameters (  ) external view returns ( IVaultParameters );
}