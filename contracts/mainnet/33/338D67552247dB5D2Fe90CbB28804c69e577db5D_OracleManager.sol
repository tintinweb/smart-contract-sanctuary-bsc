// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IOracle.sol";
import "./IOracleOffChain.sol";
import "./IOracleManager.sol";
import "../utils/NameVersion.sol";
import "../utils/Admin.sol";

contract OracleManager is IOracleManager, NameVersion, Admin {
    // symbolId => oracleAddress
    mapping(bytes32 => address) _oracles;

    constructor() NameVersion("OracleManager", "3.0.1") {}

    function getOracle(bytes32 symbolId) external view returns (address) {
        return _oracles[symbolId];
    }

    function getOracle(string memory symbol) external view returns (address) {
        return _oracles[keccak256(abi.encodePacked(symbol))];
    }

    function setOracle(address oracleAddress) external _onlyAdmin_ {
        IOracle oracle = IOracle(oracleAddress);
        bytes32 symbolId = oracle.symbolId();
        _oracles[symbolId] = oracleAddress;
        emit NewOracle(symbolId, oracleAddress);
    }

    function delOracle(bytes32 symbolId) external _onlyAdmin_ {
        delete _oracles[symbolId];
        emit NewOracle(symbolId, address(0));
    }

    function delOracle(string memory symbol) external _onlyAdmin_ {
        bytes32 symbolId = keccak256(abi.encodePacked(symbol));
        delete _oracles[symbolId];
        emit NewOracle(symbolId, address(0));
    }

    function value(bytes32 symbolId) public view returns (uint256) {
        address oracle = _oracles[symbolId];
        require(oracle != address(0), "OracleManager.value: no oracle");
        return IOracle(oracle).value();
    }

    function getValue(bytes32 symbolId) public view returns (uint256) {
        address oracle = _oracles[symbolId];
        require(oracle != address(0), "OracleManager.getValue: no oracle");
        return IOracle(oracle).getValue();
    }

    function updateValue(
        bytes32 symbolId,
        uint256 timestamp_,
        uint256 value_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) public returns (bool) {
        address oracle = _oracles[symbolId];
        require(oracle != address(0), "OracleManager.updateValue: no oracle");
        return
            IOracleOffChain(oracle).updateValue(timestamp_, value_, v_, r_, s_);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../utils/INameVersion.sol";

interface IOracle is INameVersion {
    function symbol() external view returns (string memory);

    function symbolId() external view returns (bytes32);

    function timestamp() external view returns (uint256);

    function value() external view returns (uint256);

    function getValue() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./INameVersion.sol";

/**
 * @dev Convenience contract for name and version information
 */
abstract contract NameVersion is INameVersion {
    bytes32 public immutable nameId;
    bytes32 public immutable versionId;

    constructor(string memory name, string memory version) {
        nameId = keccak256(abi.encodePacked(name));
        versionId = keccak256(abi.encodePacked(version));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../utils/INameVersion.sol";
import "../utils/IAdmin.sol";

interface IOracleManager is INameVersion, IAdmin {
    event NewOracle(bytes32 indexed symbolId, address indexed oracle);

    function getOracle(bytes32 symbolId) external view returns (address);

    function getOracle(string memory symbol) external view returns (address);

    function setOracle(address oracleAddress) external;

    function delOracle(bytes32 symbolId) external;

    function delOracle(string memory symbol) external;

    function value(bytes32 symbolId) external view returns (uint256);

    function getValue(bytes32 symbolId) external view returns (uint256);

    function updateValue(
        bytes32 symbolId,
        uint256 timestamp_,
        uint256 value_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IAdmin.sol";

abstract contract Admin is IAdmin {
    address public admin;

    modifier _onlyAdmin_() {
        require(msg.sender == admin, "Admin: only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
        emit NewAdmin(admin);
    }

    function setAdmin(address newAdmin) external _onlyAdmin_ {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IOracle.sol";

interface IOracleOffChain is IOracle {
    event NewValue(uint256 indexed timestamp, uint256 indexed value);

    function signer() external view returns (address);

    function delayAllowance() external view returns (uint256);

    function updateValue(
        uint256 timestamp,
        uint256 value,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {
    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IAdmin {
    event NewAdmin(address indexed newAdmin);

    function admin() external view returns (address);

    function setAdmin(address newAdmin) external;
}