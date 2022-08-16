// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IOracleRegistry.sol";

/// @title For centrally managing a list of oracle providers
/// @author Rolla
/// @notice oracle provider registry for holding a list of oracle providers and their id
contract OracleRegistry is Ownable, IOracleRegistry {
    struct OracleInfo {
        bool isActive;
        uint248 oracleId;
    }

    /// @inheritdoc IOracleRegistry
    mapping(address => OracleInfo) public override oracleInfo;

    /// @inheritdoc IOracleRegistry
    address[] public override oracles;

    /// @inheritdoc IOracleRegistry
    function addOracle(address _oracle) external override onlyOwner returns (uint248) {
        require(oracleInfo[_oracle].oracleId == 0, "OracleRegistry: Oracle already exists in registry");

        oracles.push(_oracle);

        uint248 currentId = getOraclesLength();

        emit AddedOracle(_oracle, currentId);

        oracleInfo[_oracle] = OracleInfo(false, currentId);
        return currentId;
    }

    /// @inheritdoc IOracleRegistry
    function deactivateOracle(address _oracle) external override onlyOwner returns (bool) {
        require(oracleInfo[_oracle].isActive, "OracleRegistry: Oracle is already deactivated");

        emit DeactivatedOracle(_oracle);

        return oracleInfo[_oracle].isActive = false;
    }

    /// @inheritdoc IOracleRegistry
    function activateOracle(address _oracle) external override onlyOwner returns (bool) {
        require(!oracleInfo[_oracle].isActive, "OracleRegistry: Oracle is already activated");

        emit ActivatedOracle(_oracle);

        return oracleInfo[_oracle].isActive = true;
    }

    /// @inheritdoc IOracleRegistry
    function isOracleRegistered(address _oracle) external view override returns (bool) {
        return oracleInfo[_oracle].oracleId != 0;
    }

    /// @inheritdoc IOracleRegistry
    function isOracleActive(address _oracle) external view override returns (bool) {
        return oracleInfo[_oracle].isActive;
    }

    /// @inheritdoc IOracleRegistry
    function getOracleId(address _oracle) external view override returns (uint248) {
        uint248 oracleId = oracleInfo[_oracle].oracleId;
        require(oracleId != 0, "OracleRegistry: Oracle doesn't exist in registry");
        return oracleId;
    }

    /// @inheritdoc IOracleRegistry
    function getOraclesLength() public view override returns (uint248) {
        uint256 length = oracles.length;
        require(length <= uint256(type(uint248).max), "OracleRegistry: oracles limit exceeded");
        return uint248(length);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title For centrally managing a list of oracle providers
/// @author Rolla
/// @notice oracle provider registry for holding a list of oracle providers and their id
interface IOracleRegistry {
    event AddedOracle(address oracle, uint248 oracleId);

    event ActivatedOracle(address oracle);

    event DeactivatedOracle(address oracle);

    /// @notice Add an oracle to the oracle registry which will generate an id. By default oracles are deactivated
    /// @param _oracle the address of the oracle
    /// @return the id of the oracle
    function addOracle(address _oracle) external returns (uint248);

    /// @notice Deactivate an oracle so no new options can be created with this oracle address.
    /// @param _oracle the oracle to deactivate
    function deactivateOracle(address _oracle) external returns (bool);

    /// @notice Activate an oracle so options can be created with this oracle address.
    /// @param _oracle the oracle to activate
    function activateOracle(address _oracle) external returns (bool);

    /// @notice oracle address => OracleInfo
    function oracleInfo(address) external view returns (bool, uint248);

    /// @notice exhaustive list of oracles in map
    function oracles(uint256) external view returns (address);

    /// @notice Check if an oracle is registered in the registry
    /// @param _oracle the oracle to check
    function isOracleRegistered(address _oracle) external view returns (bool);

    /// @notice Check if an oracle is active i.e. are we allowed to create options with this oracle
    /// @param _oracle the oracle to check
    function isOracleActive(address _oracle) external view returns (bool);

    /// @notice Get the numeric id of an oracle
    /// @param _oracle the oracle to get the id of
    function getOracleId(address _oracle) external view returns (uint248);

    /// @notice Get total number of oracles in registry
    /// @return the number of oracles in the registry
    function getOraclesLength() external view returns (uint248);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}