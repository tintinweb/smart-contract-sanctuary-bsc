// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2021 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "../../Auth.sol";
import "../../interfaces/vault-managers/parameters/IAssetsBooleanParameters.sol";


/**
 * @title AssetsBooleanParameters
 **/
contract AssetsBooleanParameters is Auth, IAssetsBooleanParameters {

    mapping(address => uint256) internal values;

    constructor(address _vaultParameters, address[] memory _initialAssets, uint8[] memory _initialParams) Auth(_vaultParameters) {
        require(_initialAssets.length == _initialParams.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");

        for (uint i = 0; i < _initialAssets.length; i++) {
            _set(_initialAssets[i], _initialParams[i], true);
        }
    }

    /**
     * @notice Get value of _param for _asset
     * @dev see ParametersConstants
     **/
    function get(address _asset, uint8 _param) external override view returns (bool) {
        return values[_asset] & (1 << _param) != 0;
    }

    /**
     * @notice Get values of all params for _asset. The 0th bit of returned uint id the value of param=0, etc
     **/
    function getAll(address _asset) external override view returns (uint256) {
        return values[_asset];
    }

    /**
     * @notice Set value of _param for _asset
     * @dev see ParametersConstants
     **/
    function set(address _asset, uint8 _param, bool _value) public override onlyManager {
        _set(_asset, _param, _value);
    }

    function _set(address _asset, uint8 _param, bool _value) internal {
        require(_asset != address(0), "Unit Protocol: ZERO_ADDRESS");

        if (_value) {
            values[_asset] |= (1 << _param);
            emit ValueSet(_asset, _param, values[_asset]);
        } else {
            values[_asset] &= ~(1 << _param);
            emit ValueUnset(_asset, _param, values[_asset]);
        }
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
  Copyright 2021 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface IAssetsBooleanParameters {

    event ValueSet(address indexed asset, uint8 param, uint256 valuesForAsset);
    event ValueUnset(address indexed asset, uint8 param, uint256 valuesForAsset);

    function get(address _asset, uint8 _param) external view returns (bool);
    function getAll(address _asset) external view returns (uint256);
    function set(address _asset, uint8 _param, bool _value) external;
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