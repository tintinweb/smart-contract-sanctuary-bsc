// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;
pragma abicoder v2;


import "./Auth.sol";
import "./interfaces/vault-managers/parameters/IVaultManagerParameters.sol";
import "./interfaces/IBearingAssetOracle.sol";
import "./interfaces/IOracleRegistry.sol";
import "./interfaces/ICollateralRegistry.sol";
import "./interfaces/IVault.sol";


/**
 * @title ParametersBatchUpdater
 **/
contract ParametersBatchUpdater is Auth {

    IVaultManagerParameters public immutable vaultManagerParameters;
    IOracleRegistry public immutable oracleRegistry;
    ICollateralRegistry public immutable collateralRegistry;

    uint public constant BEARING_ASSET_ORACLE_TYPE = 9;

    constructor(
        address _vaultManagerParameters,
        address _oracleRegistry,
        address _collateralRegistry
    ) Auth(address(IVaultManagerParameters(_vaultManagerParameters).vaultParameters())) {
        require(
            _vaultManagerParameters != address(0) &&
            _oracleRegistry != address(0) &&
            _collateralRegistry != address(0), "Unit Protocol: ZERO_ADDRESS");
        vaultManagerParameters = IVaultManagerParameters(_vaultManagerParameters);
        oracleRegistry = IOracleRegistry(_oracleRegistry);
        collateralRegistry = ICollateralRegistry(_collateralRegistry);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Grants and revokes manager's status
     * @param who The array of target addresses
     * @param permit The array of permission flags
     **/
    function setManagers(address[] calldata who, bool[] calldata permit) external onlyManager {
        require(who.length == permit.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < who.length; i++) {
            vaultParameters.setManager(who[i], permit[i]);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets a permission for provided addresses to modify the Vault
     * @param who The array of target addresses
     * @param permit The array of permission flags
     **/
    function setVaultAccesses(address[] calldata who, bool[] calldata permit) external onlyManager {
        require(who.length == permit.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < who.length; i++) {
            vaultParameters.setVaultAccess(who[i], permit[i]);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the percentage of the year stability fee for a particular collateral
     * @param assets The array of addresses of the main collateral tokens
     * @param newValues The array of stability fee percentages (3 decimals)
     **/
    function setStabilityFees(address[] calldata assets, uint[] calldata newValues) public onlyManager {
        require(assets.length == newValues.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            vaultParameters.setStabilityFee(assets[i], newValues[i]);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the percentages of the liquidation fee for provided collaterals
     * @param assets The array of addresses of the main collateral tokens
     * @param newValues The array of liquidation fee percentages (0 decimals)
     **/
    function setLiquidationFees(address[] calldata assets, uint[] calldata newValues) public onlyManager {
        require(assets.length == newValues.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            vaultParameters.setLiquidationFee(assets[i], newValues[i]);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Enables/disables oracle types
     * @param _types The array of types of the oracles
     * @param assets The array of addresses of the main collateral tokens
     * @param flags The array of control flags
     **/
    function setOracleTypes(uint[] calldata _types, address[] calldata assets, bool[] calldata flags) public onlyManager {
        require(_types.length == assets.length && _types.length == flags.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < _types.length; i++) {
            vaultParameters.setOracleType(_types[i], assets[i], flags[i]);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets USDP limits for a provided collaterals
     * @param assets The addresses of the main collateral tokens
     * @param limits The borrow USDP limits
     **/
    function setTokenDebtLimits(address[] calldata assets, uint[] calldata limits) public onlyManager {
        require(assets.length == limits.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            vaultParameters.setTokenDebtLimit(assets[i], limits[i]);
        }
    }

    function changeOracleTypes(address[] calldata assets, address[] calldata users, uint[] calldata oracleTypes) public onlyManager {
        require(assets.length == users.length && assets.length == oracleTypes.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            IVault(vaultParameters.vault()).changeOracleType(assets[i], users[i], oracleTypes[i]);
        }
    }

    function setInitialCollateralRatios(address[] calldata assets, uint[] calldata values) public onlyManager {
        require(assets.length == values.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            vaultManagerParameters.setInitialCollateralRatio(assets[i], values[i]);
        }
    }

    function setLiquidationRatios(address[] calldata assets, uint[] calldata values) public onlyManager {
        require(assets.length == values.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            vaultManagerParameters.setLiquidationRatio(assets[i], values[i]);
        }
    }

    function setLiquidationDiscounts(address[] calldata assets, uint[] calldata values) public onlyManager {
        require(assets.length == values.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            vaultManagerParameters.setLiquidationDiscount(assets[i], values[i]);
        }
    }

    function setDevaluationPeriods(address[] calldata assets, uint[] calldata values) public onlyManager {
        require(assets.length == values.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            vaultManagerParameters.setDevaluationPeriod(assets[i], values[i]);
        }
    }

    function setOracleTypesInRegistry(uint[] calldata oracleTypes, address[] calldata oracles) public onlyManager {
        require(oracleTypes.length == oracles.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < oracleTypes.length; i++) {
            oracleRegistry.setOracle(oracleTypes[i], oracles[i]);
        }
    }

    function setOracleTypesToAssets(address[] calldata assets, uint[] calldata oracleTypes) public onlyManager {
        require(oracleTypes.length == assets.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            oracleRegistry.setOracleTypeForAsset(assets[i], oracleTypes[i]);
        }
    }

    function setOracleTypesToAssetsBatch(address[][] calldata assets, uint[] calldata oracleTypes) public onlyManager {
        require(oracleTypes.length == assets.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < assets.length; i++) {
            oracleRegistry.setOracleTypeForAssets(assets[i], oracleTypes[i]);
        }
    }

    function setUnderlyings(address[] calldata bearings, address[] calldata underlyings) public onlyManager {
        require(bearings.length == underlyings.length, "Unit Protocol: ARGUMENTS_LENGTH_MISMATCH");
        for (uint i = 0; i < bearings.length; i++) {
            IBearingAssetOracle(oracleRegistry.oracleByType(BEARING_ASSET_ORACLE_TYPE)).setUnderlying(bearings[i], underlyings[i]);
        }
    }

    function setCollaterals(
        address[] calldata assets,
        uint stabilityFeeValue,
        uint liquidationFeeValue,
        uint initialCollateralRatioValue,
        uint liquidationRatioValue,
        uint liquidationDiscountValue,
        uint devaluationPeriodValue,
        uint usdpLimit,
        uint[] calldata oracles
    ) external onlyManager {
        for (uint i = 0; i < assets.length; i++) {
            vaultManagerParameters.setCollateral(
                assets[i],
                stabilityFeeValue,
                liquidationFeeValue,
                initialCollateralRatioValue,
                liquidationRatioValue,
                liquidationDiscountValue,
                devaluationPeriodValue,
                usdpLimit,
                oracles
            );

            collateralRegistry.addCollateral(assets[i]);
        }
    }

    function setCollateralAddresses(address[] calldata assets, bool add) external onlyManager {
        for (uint i = 0; i < assets.length; i++) {
            add ? collateralRegistry.addCollateral(assets[i]) : collateralRegistry.removeCollateral(assets[i]);
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
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

import "../../IWithVaultParameters.sol";

interface IVaultManagerParameters is IWithVaultParameters {
    event InitialCollateralRatioChanged(address indexed asset, uint newValue);
    event LiquidationRatioChanged(address indexed asset, uint newValue);
    event LiquidationDiscountChanged(address indexed asset, uint newValue);
    event DevaluationPeriodChanged(address indexed asset, uint newValue);

    function devaluationPeriod ( address ) external view returns ( uint256 );
    function initialCollateralRatio ( address ) external view returns ( uint256 );
    function liquidationDiscount ( address ) external view returns ( uint256 );
    function liquidationRatio ( address ) external view returns ( uint256 );
    function setCollateral (
        address asset,
        uint256 stabilityFeeValue,
        uint256 liquidationFeeValue,
        uint256 initialCollateralRatioValue,
        uint256 liquidationRatioValue,
        uint256 liquidationDiscountValue,
        uint256 devaluationPeriodValue,
        uint256 usdpLimit,
        uint256[] calldata oracles
    ) external;
    function setDevaluationPeriod ( address asset, uint256 newValue ) external;
    function setInitialCollateralRatio ( address asset, uint256 newValue ) external;
    function setLiquidationDiscount ( address asset, uint256 newValue ) external;
    function setLiquidationRatio ( address asset, uint256 newValue ) external;
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

import "./IOracleUsd.sol";
import "./IOracleRegistry.sol";

interface IBearingAssetOracle is IOracleUsd {
    function bearingToUnderlying ( address bearing, uint256 amount ) external view returns ( address, uint256 );
    function oracleRegistry (  ) external view returns ( IOracleRegistry );
    function setUnderlying ( address bearing, address underlying ) external;
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;
pragma abicoder v2;

interface IOracleRegistry {

    struct Oracle {
        uint oracleType;
        address oracleAddress;
    }

    event AssetOracle(address indexed asset, uint indexed oracleType);
    event OracleType(uint indexed oracleType, address indexed oracle);
    event KeydonixOracleTypes();

    function WETH (  ) external view returns ( address );
    function getKeydonixOracleTypes (  ) external view returns ( uint256[] memory );
    function getOracles (  ) external view returns ( Oracle[] memory foundOracles );
    function keydonixOracleTypes ( uint256 ) external view returns ( uint256 );
    function maxOracleType (  ) external view returns ( uint256 );
    function oracleByAsset ( address asset ) external view returns ( address );
    function oracleByType ( uint256 ) external view returns ( address );
    function oracleTypeByAsset ( address ) external view returns ( uint256 );
    function oracleTypeByOracle ( address ) external view returns ( uint256 );
    function setKeydonixOracleTypes ( uint256[] memory _keydonixOracleTypes ) external;
    function setOracle ( uint256 oracleType, address oracle ) external;
    function setOracleTypeForAsset ( address asset, uint256 oracleType ) external;
    function setOracleTypeForAssets ( address[] memory assets, uint256 oracleType ) external;
    function unsetOracle ( uint256 oracleType ) external;
    function unsetOracleForAsset ( address asset ) external;
    function unsetOracleForAssets ( address[] memory assets ) external;
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

interface IVault {
    event OracleTypeChanged(address indexed asset, address indexed user, uint newOracleType);

    function DENOMINATOR_1E2 (  ) external view returns ( uint256 );
    function DENOMINATOR_1E5 (  ) external view returns ( uint256 );
    function borrow ( address asset, address user, uint256 amount ) external returns ( uint256 );
    function changeOracleType ( address asset, address user, uint256 newOracleType ) external;
    function chargeFee ( address asset, address user, uint256 amount ) external;
    function decreaseFee ( address asset, address user, uint amount ) external;
    function collaterals ( address, address ) external view returns ( uint256 );
    function debts ( address, address ) external view returns ( uint256 );
    function getFee ( address, address ) external view returns ( uint256 );
    function depositEth ( address user ) external payable;
    function depositMain ( address asset, address user, uint256 amount ) external;
    function destroy ( address asset, address user ) external;
    function getTotalDebt ( address asset, address user ) external view returns ( uint256 );
    function lastUpdate ( address, address ) external view returns ( uint256 );
    function liquidate ( address asset, address positionOwner, uint256 mainAssetToLiquidator, uint256 mainAssetToPositionOwner, uint256 repayment, uint256 penalty, address liquidator ) external;
    function liquidationTs ( address, address ) external view returns ( uint256 );
    function liquidationFee ( address, address ) external view returns ( uint256 );
    function liquidationPrice ( address, address ) external view returns ( uint256 );
    function oracleType ( address, address ) external view returns ( uint256 );
    function repay ( address asset, address user, uint256 amount ) external returns ( uint256 );
    function spawn ( address asset, address user, uint256 _oracleType ) external;
    function stabilityFee ( address, address ) external view returns ( uint256 );
    function tokenDebts ( address ) external view returns ( uint256 );
    function triggerLiquidation ( address asset, address positionOwner, uint256 initialPrice ) external;
    function update ( address asset, address user ) external;
    function usdp (  ) external view returns ( address );
    function weth (  ) external view returns ( address payable );
    function withdrawEth ( address payable user, uint256 amount ) external;
    function withdrawMain ( address asset, address user, uint256 amount ) external;
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

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface IOracleUsd {

    // returns Q112-encoded value
    // returned value 10**18 * 2**112 is $1
    function assetToUsd(address asset, uint amount) external view returns (uint);
}