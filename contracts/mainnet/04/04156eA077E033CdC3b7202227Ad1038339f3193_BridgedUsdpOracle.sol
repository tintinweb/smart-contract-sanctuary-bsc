// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2022 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "../interfaces/IOracleUsd.sol";
import "../helpers/SafeMath.sol";
import "../Auth.sol";

/**
 * @title BridgedUSDPOracle
 * @dev Oracle to quote bridged from other chains USDP
 **/
contract BridgedUsdpOracle is IOracleUsd, Auth {
    using SafeMath for uint;

    uint public constant Q112 = 2 ** 112;

    mapping (address => bool) public bridgedUsdp;

    event Added(address _usdp);
    event Removed(address _usdp);

    constructor(address vaultParameters, address[] memory _bridgedUsdp) Auth(vaultParameters) {
        for (uint i = 0; i < _bridgedUsdp.length; i++) {
            _add(_bridgedUsdp[i]);
        }
    }

    function add(address _usdp) external onlyManager {
        _add(_usdp);
    }

    function _add(address _usdp) private {
        require(_usdp != address(0), 'Unit Protocol: ZERO_ADDRESS');
        require(!bridgedUsdp[_usdp], 'Unit Protocol: ALREADY_ADDED');

        bridgedUsdp[_usdp] = true;
        emit Added(_usdp);
    }

    function remove(address _usdp) external onlyManager {
        require(_usdp != address(0), 'Unit Protocol: ZERO_ADDRESS');
        require(bridgedUsdp[_usdp], 'Unit Protocol: WAS_NOT_ADDED');

        bridgedUsdp[_usdp] = false;
        emit Removed(_usdp);
    }

    // returns Q112-encoded value
    function assetToUsd(address asset, uint amount) public override view returns (uint) {
        require(bridgedUsdp[asset], 'Unit Protocol: TOKEN_IS_NOT_SUPPORTED');
        return amount.mul(Q112);
    }
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