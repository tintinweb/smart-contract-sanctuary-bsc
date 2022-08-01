// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;
pragma abicoder v2;

import "../VaultParameters.sol";
import "../interfaces/IOracleRegistry.sol";

contract OracleRegistry is IOracleRegistry, Auth {
    
    uint public override maxOracleType;

    address public immutable override WETH;

    // map asset to oracle type ID
    mapping(address => uint) public override oracleTypeByAsset;

    // map oracle type ID to oracle address
    mapping(uint => address) public override oracleByType;

    // map oracle address to oracle type ID
    mapping(address => uint) public override oracleTypeByOracle;

    // list of keydonix oracleType IDs
    uint[] public override keydonixOracleTypes;

    modifier validAddress(address asset) {
        require(asset != address(0), "Unit Protocol: ZERO_ADDRESS");
        _;
    }

    modifier validType(uint _type) {
        require(_type != 0, "Unit Protocol: INVALID_TYPE");
        _;
    }

    constructor(address vaultParameters, address _weth)
        Auth(vaultParameters)
        validAddress(vaultParameters)
        validAddress(_weth)
    {
        WETH = _weth;
    }

    function setKeydonixOracleTypes(uint[] calldata _keydonixOracleTypes) public override onlyManager {
        for (uint i = 0; i < _keydonixOracleTypes.length; i++) {
            require(_keydonixOracleTypes[i] != 0, "Unit Protocol: INVALID_TYPE");
            require(oracleByType[_keydonixOracleTypes[i]] != address(0), "Unit Protocol: INVALID_ORACLE");
        }

        keydonixOracleTypes = _keydonixOracleTypes;

        emit KeydonixOracleTypes();
    }

    function setOracle(uint oracleType, address oracle) public
        override
        onlyManager
        validType(oracleType)
        validAddress(oracle)
    {
        if (oracleType > maxOracleType) {
            maxOracleType = oracleType;
        }

        address oldOracle = oracleByType[oracleType];
        if (oldOracle != address(0)) {
            delete oracleTypeByOracle[oldOracle];
        }

        uint oldOracleType = oracleTypeByOracle[oracle];
        if (oldOracleType != 0) {
            delete oracleByType[oldOracleType];
        }

        oracleByType[oracleType] = oracle;
        oracleTypeByOracle[oracle] = oracleType;

        emit OracleType(oracleType, oracle);
    }

    function unsetOracle(uint oracleType) public override onlyManager validType(oracleType) validAddress(oracleByType[oracleType]) {
        address oracle = oracleByType[oracleType];
        delete oracleByType[oracleType];
        delete oracleTypeByOracle[oracle];

        emit OracleType(oracleType, address(0));
    }

    function setOracleTypeForAsset(address asset, uint oracleType) public
        override
        onlyManager
        validAddress(asset)
        validType(oracleType)
        validAddress(oracleByType[oracleType])
    {
        oracleTypeByAsset[asset] = oracleType;
        emit AssetOracle(asset, oracleType);
    }

    function setOracleTypeForAssets(address[] calldata assets, uint oracleType) public override {
        for (uint i = 0; i < assets.length; i++) {
            setOracleTypeForAsset(assets[i], oracleType);
        }
    }

    function unsetOracleForAsset(address asset) public
        override
        onlyManager
        validAddress(asset)
        validType(oracleTypeByAsset[asset])
    {
        delete oracleTypeByAsset[asset];
        emit AssetOracle(asset, 0);
    }

    function unsetOracleForAssets(address[] calldata assets) public override {
        for (uint i = 0; i < assets.length; i++) {
            unsetOracleForAsset(assets[i]);
        }
    }

    function getOracles() external override view returns (Oracle[] memory foundOracles) {

        Oracle[] memory allOracles = new Oracle[](maxOracleType);

        uint actualOraclesCount;

        for (uint _type = 1; _type <= maxOracleType; ++_type) {
            if (oracleByType[_type] != address(0)) {
                allOracles[actualOraclesCount++] = Oracle(_type, oracleByType[_type]);
            }
        }

        foundOracles = new Oracle[](actualOraclesCount);

        for (uint i = 0; i < actualOraclesCount; ++i) {
            foundOracles[i] = allOracles[i];
        }
    }

    function getKeydonixOracleTypes() external override view returns (uint[] memory) {
        return keydonixOracleTypes;
    }

    function oracleByAsset(address asset) external override view returns (address) {
        uint oracleType = oracleTypeByAsset[asset];
        if (oracleType == 0) {
            return address(0);
        }
        return oracleByType[oracleType];
    }

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

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2021 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

import "./IVaultParameters.sol";

interface IWithVaultParameters {
    function vaultParameters (  ) external view returns ( IVaultParameters );
}