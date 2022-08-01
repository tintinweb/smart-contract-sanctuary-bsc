// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "../../interfaces/vault-managers/parameters/IVaultManagerParameters.sol";
import "../../VaultParameters.sol";


/**
 * @title VaultManagerParameters
 **/
contract VaultManagerParameters is IVaultManagerParameters, Auth {

    // map token to initial collateralization ratio; 0 decimals
    mapping(address => uint) public override initialCollateralRatio;

    // map token to liquidation ratio; 0 decimals
    mapping(address => uint) public override liquidationRatio;

    // map token to liquidation discount; 3 decimals
    mapping(address => uint) public override liquidationDiscount;

    // map token to devaluation period in seconds
    mapping(address => uint) public override devaluationPeriod;

    constructor(address _vaultParameters) Auth(_vaultParameters) {}

    /**
     * @notice Only manager is able to call this function
     * @dev Sets ability to use token as the main collateral
     * @param asset The address of the main collateral token
     * @param stabilityFeeValue The percentage of the year stability fee (3 decimals)
     * @param liquidationFeeValue The liquidation fee percentage (0 decimals)
     * @param initialCollateralRatioValue The initial collateralization ratio
     * @param liquidationRatioValue The liquidation ratio
     * @param liquidationDiscountValue The liquidation discount (3 decimals)
     * @param devaluationPeriodValue The devaluation period in seconds
     * @param usdpLimit The USDP token issue limit
     * @param oracles The enabled oracles type IDs
     **/
    function setCollateral(
        address asset,
        uint stabilityFeeValue,
        uint liquidationFeeValue,
        uint initialCollateralRatioValue,
        uint liquidationRatioValue,
        uint liquidationDiscountValue,
        uint devaluationPeriodValue,
        uint usdpLimit,
        uint[] calldata oracles
    ) external override onlyManager {
        vaultParameters.setCollateral(asset, stabilityFeeValue, liquidationFeeValue, usdpLimit, oracles);
        setInitialCollateralRatio(asset, initialCollateralRatioValue);
        setLiquidationRatio(asset, liquidationRatioValue);
        setDevaluationPeriod(asset, devaluationPeriodValue);
        setLiquidationDiscount(asset, liquidationDiscountValue);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the initial collateral ratio
     * @param asset The address of the main collateral token
     * @param newValue The collateralization ratio (0 decimals)
     **/
    function setInitialCollateralRatio(address asset, uint newValue) public override onlyManager {
        require(newValue != 0 && newValue <= 100, "Unit Protocol: INCORRECT_COLLATERALIZATION_VALUE");
        initialCollateralRatio[asset] = newValue;

        emit InitialCollateralRatioChanged(asset, newValue);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the liquidation ratio
     * @param asset The address of the main collateral token
     * @param newValue The liquidation ratio (0 decimals)
     **/
    function setLiquidationRatio(address asset, uint newValue) public override onlyManager {
        require(newValue != 0 && newValue >= initialCollateralRatio[asset], "Unit Protocol: INCORRECT_COLLATERALIZATION_VALUE");
        liquidationRatio[asset] = newValue;

        emit LiquidationRatioChanged(asset, newValue);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the liquidation discount
     * @param asset The address of the main collateral token
     * @param newValue The liquidation discount (3 decimals)
     **/
    function setLiquidationDiscount(address asset, uint newValue) public override onlyManager {
        require(newValue < 1e5, "Unit Protocol: INCORRECT_DISCOUNT_VALUE");
        liquidationDiscount[asset] = newValue;

        emit LiquidationDiscountChanged(asset, newValue);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the devaluation period of collateral after liquidation
     * @param asset The address of the main collateral token
     * @param newValue The devaluation period in seconds
     **/
    function setDevaluationPeriod(address asset, uint newValue) public override onlyManager {
        require(newValue != 0, "Unit Protocol: INCORRECT_DEVALUATION_VALUE");
        devaluationPeriod[asset] = newValue;

        emit DevaluationPeriodChanged(asset, newValue);
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
pragma solidity 0.7.6;

import "./interfaces/IVaultParameters.sol";
import "./Auth.sol";

/**
 * @title VaultParameters
 **/
contract VaultParameters is IVaultParameters, Auth   {

    // map token to stability fee percentage; 3 decimals
    mapping(address => uint) public override stabilityFee;

    // map token to liquidation fee percentage, 0 decimals
    mapping(address => uint) public override liquidationFee;

    // map token to USDP mint limit
    mapping(address => uint) public override tokenDebtLimit;

    // permissions to modify the Vault
    mapping(address => bool) public override canModifyVault;

    // managers
    mapping(address => bool) public override isManager;

    // enabled oracle types
    mapping(uint => mapping (address => bool)) public override isOracleTypeEnabled;

    // address of the Vault
    address payable public immutable override vault;

    // The foundation address
    address public override foundation;

    /**
     * The address for an Ethereum contract is deterministically computed from the address of its creator (sender)
     * and how many transactions the creator has sent (nonce). The sender and nonce are RLP encoded and then
     * hashed with Keccak-256.
     * Therefore, the Vault address can be pre-computed and passed as an argument before deployment.
    **/
    constructor(address payable _vault, address _foundation) Auth(address(this)) {
        require(_vault != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(_foundation != address(0), "Unit Protocol: ZERO_ADDRESS");

        isManager[msg.sender] = true;
        vault = _vault;
        foundation = _foundation;
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Grants and revokes manager's status of any address
     * @param who The target address
     * @param permit The permission flag
     **/
    function setManager(address who, bool permit) external override onlyManager {
        isManager[who] = permit;

        if (permit) {
            emit ManagerAdded(who);
        } else {
            emit ManagerRemoved(who);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the foundation address
     * @param newFoundation The new foundation address
     **/
    function setFoundation(address newFoundation) external override onlyManager {
        require(newFoundation != address(0), "Unit Protocol: ZERO_ADDRESS");
        foundation = newFoundation;

        emit FoundationChanged(newFoundation);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets ability to use token as the main collateral
     * @param asset The address of the main collateral token
     * @param stabilityFeeValue The percentage of the year stability fee (3 decimals)
     * @param liquidationFeeValue The liquidation fee percentage (0 decimals)
     * @param usdpLimit The USDP token issue limit
     * @param oracles The enables oracle types
     **/
    function setCollateral(
        address asset,
        uint stabilityFeeValue,
        uint liquidationFeeValue,
        uint usdpLimit,
        uint[] calldata oracles
    ) external override onlyManager {
        setStabilityFee(asset, stabilityFeeValue);
        setLiquidationFee(asset, liquidationFeeValue);
        setTokenDebtLimit(asset, usdpLimit);
        for (uint i=0; i < oracles.length; i++) {
            setOracleType(oracles[i], asset, true);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets a permission for an address to modify the Vault
     * @param who The target address
     * @param permit The permission flag
     **/
    function setVaultAccess(address who, bool permit) external override onlyManager {
        canModifyVault[who] = permit;

        if (permit) {
            emit VaultAccessGranted(who);
        } else {
            emit VaultAccessRevoked(who);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the percentage of the year stability fee for a particular collateral
     * @param asset The address of the main collateral token
     * @param newValue The stability fee percentage (3 decimals)
     **/
    function setStabilityFee(address asset, uint newValue) public override onlyManager {
        stabilityFee[asset] = newValue;

        emit StabilityFeeChanged(asset, newValue);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the percentage of the liquidation fee for a particular collateral
     * @param asset The address of the main collateral token
     * @param newValue The liquidation fee percentage (0 decimals)
     **/
    function setLiquidationFee(address asset, uint newValue) public override onlyManager {
        require(newValue <= 100, "Unit Protocol: VALUE_OUT_OF_RANGE");
        liquidationFee[asset] = newValue;

        emit LiquidationFeeChanged(asset, newValue);
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Enables/disables oracle types
     * @param _type The type of the oracle
     * @param asset The address of the main collateral token
     * @param enabled The control flag
     **/
    function setOracleType(uint _type, address asset, bool enabled) public override onlyManager {
        isOracleTypeEnabled[_type][asset] = enabled;

        if (enabled) {
            emit OracleTypeEnabled(asset, _type);
        } else {
            emit OracleTypeDisabled(asset, _type);
        }
    }

    /**
     * @notice Only manager is able to call this function
     * @dev Sets USDP limit for a specific collateral
     * @param asset The address of the main collateral token
     * @param limit The limit number
     **/
    function setTokenDebtLimit(address asset, uint limit) public override onlyManager {
        tokenDebtLimit[asset] = limit;

        emit TokenDebtLimitChanged(asset, limit);
    }
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