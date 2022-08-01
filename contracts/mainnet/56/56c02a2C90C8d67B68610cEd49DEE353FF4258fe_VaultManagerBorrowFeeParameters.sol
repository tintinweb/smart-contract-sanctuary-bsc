// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2021 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "../../VaultParameters.sol";
import "../../interfaces/vault-managers/parameters/IVaultManagerBorrowFeeParameters.sol";
import "../../helpers/SafeMath.sol";


/**
 * @title VaultManagerBorrowFeeParameters
 **/
contract VaultManagerBorrowFeeParameters is Auth, IVaultManagerBorrowFeeParameters {
    using SafeMath for uint;

    uint public constant override BASIS_POINTS_IN_1 = 1e4;

    struct AssetBorrowFeeParams {
        bool enabled; // is custom fee for asset enabled
        uint16 feeBasisPoints; // fee basis points, 1 basis point = 0.0001
    }

    // map token to borrow fee
    mapping(address => AssetBorrowFeeParams) public assetBorrowFee;
    uint16 public baseBorrowFeeBasisPoints;

    address public override feeReceiver;

    modifier nonZeroAddress(address addr) {
        require(addr != address(0), "Unit Protocol: ZERO_ADDRESS");
        _;
    }

    modifier correctFee(uint16 fee) {
        require(fee < BASIS_POINTS_IN_1, "Unit Protocol: INCORRECT_FEE_VALUE");
        _;
    }

    constructor(address _vaultParameters, uint16 _baseBorrowFeeBasisPoints, address _feeReceiver)
        Auth(_vaultParameters)
        nonZeroAddress(_feeReceiver)
        correctFee(_baseBorrowFeeBasisPoints)
    {
        baseBorrowFeeBasisPoints = _baseBorrowFeeBasisPoints;
        feeReceiver = _feeReceiver;
    }

    /// @inheritdoc IVaultManagerBorrowFeeParameters
    function setFeeReceiver(address newFeeReceiver) external override onlyManager nonZeroAddress(newFeeReceiver) {
        feeReceiver = newFeeReceiver;

        emit FeeReceiverChanged(newFeeReceiver);
    }

    /// @inheritdoc IVaultManagerBorrowFeeParameters
    function setBaseBorrowFee(uint16 newBaseBorrowFeeBasisPoints) external override onlyManager correctFee(newBaseBorrowFeeBasisPoints) {
        baseBorrowFeeBasisPoints = newBaseBorrowFeeBasisPoints;

        emit BaseBorrowFeeChanged(newBaseBorrowFeeBasisPoints);
    }

    /// @inheritdoc IVaultManagerBorrowFeeParameters
    function setAssetBorrowFee(address asset, bool newEnabled, uint16 newFeeBasisPoints) external override onlyManager correctFee(newFeeBasisPoints) {
        assetBorrowFee[asset].enabled = newEnabled;
        assetBorrowFee[asset].feeBasisPoints = newFeeBasisPoints;

        if (newEnabled) {
            emit AssetBorrowFeeParamsEnabled(asset, newFeeBasisPoints);
        } else {
            emit AssetBorrowFeeParamsDisabled(asset);
        }
    }

    /// @inheritdoc IVaultManagerBorrowFeeParameters
    function getBorrowFee(address asset) public override view returns (uint16 feeBasisPoints) {
        if (assetBorrowFee[asset].enabled) {
            return assetBorrowFee[asset].feeBasisPoints;
        }

        return baseBorrowFeeBasisPoints;
    }

    /// @inheritdoc IVaultManagerBorrowFeeParameters
    function calcBorrowFeeAmount(address asset, uint usdpAmount) external override view returns (uint) {
        uint16 borrowFeeBasisPoints = getBorrowFee(asset);
        if (borrowFeeBasisPoints == 0) {
            return 0;
        }

        return usdpAmount.mul(uint(borrowFeeBasisPoints)).div(BASIS_POINTS_IN_1);
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
  Copyright 2021 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface IVaultManagerBorrowFeeParameters {

    event AssetBorrowFeeParamsEnabled(address indexed asset, uint16 feeBasisPoints);
    event AssetBorrowFeeParamsDisabled(address indexed asset);
    event FeeReceiverChanged(address indexed newFeeReceiver);
    event BaseBorrowFeeChanged(uint16 newBaseBorrowFeeBasisPoints);

    /**
     * @notice 1 = 100% = 10000 basis points
     **/
    function BASIS_POINTS_IN_1() external view returns (uint);

    /**
     * @notice Borrow fee receiver
     **/
    function feeReceiver() external view returns (address);

    /**
     * @notice Sets the borrow fee receiver. Only manager is able to call this function
     * @param newFeeReceiver The address of fee receiver
     **/
    function setFeeReceiver(address newFeeReceiver) external;

    /**
     * @notice Sets the base borrow fee in basis points (1bp = 0.01% = 0.0001). Only manager is able to call this function
     * @param newBaseBorrowFeeBasisPoints The borrow fee in basis points
     **/
    function setBaseBorrowFee(uint16 newBaseBorrowFeeBasisPoints) external;

    /**
     * @notice Sets the borrow fee for a particular collateral in basis points (1bp = 0.01% = 0.0001). Only manager is able to call this function
     * @param asset The address of the main collateral token
     * @param newEnabled Is custom fee enabled for asset
     * @param newFeeBasisPoints The borrow fee in basis points
     **/
    function setAssetBorrowFee(address asset, bool newEnabled, uint16 newFeeBasisPoints) external;

    /**
     * @notice Returns borrow fee for particular collateral in basis points (1bp = 0.01% = 0.0001)
     * @param asset The address of the main collateral token
     * @return feeBasisPoints The borrow fee in basis points
     **/
    function getBorrowFee(address asset) external view returns (uint16 feeBasisPoints);

    /**
     * @notice Returns borrow fee for usdp amount for particular collateral
     * @param asset The address of the main collateral token
     * @return The borrow fee
     **/
    function calcBorrowFeeAmount(address asset, uint usdpAmount) external view returns (uint);
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
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