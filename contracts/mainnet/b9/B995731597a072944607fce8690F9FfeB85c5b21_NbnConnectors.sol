pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NbnConnectors
 * @dev Registry for Connectors.
 */

interface ConnectorInterface {
    function name() external view returns (string memory);
}

contract Controllers is Ownable{

    event LogController(address indexed addr, bool indexed isChief);

    // Enabled Chief(Address of Chief => bool).
    mapping(address => bool) public chief;
    // Enabled Connectors(Connector name => address).
    mapping(string => address) public connectors;

    /**
    * @dev Throws if the sender is not ChiefNbn
    * or an Enabled Chief.
    */
    modifier isChief {
        require(chief[msg.sender] || msg.sender == owner(), "Controllers: not a chief");
        _;
    }

    /**
     * @dev Toggle a Chief. Enable if disabled & vice versa
     * @param _chiefAddress Chief Address.
    */
    function toggleChief(address _chiefAddress) external {
        require(msg.sender == owner(), "Controllers: not ChiefNbn");
        chief[_chiefAddress] = !chief[_chiefAddress];
        emit LogController(_chiefAddress, chief[_chiefAddress]);
    }
}


contract NbnConnectors is Controllers {
    event LogConnectorAdded(string indexed connectorName, address indexed connector);
    event LogConnectorUpdated(string indexed connectorName, address indexed oldConnector, address indexed newConnector);
    event LogConnectorRemoved(string indexed connectorName, address indexed connector);

    constructor() public {}

    /**
     * @dev Add Connectors
     * @param _connectorNames Array of Connector Names.
     * @param _connectors Array of Connector Address.
    */
    function addConnectors(string[] calldata _connectorNames, address[] calldata _connectors) external isChief {
        require(_connectors.length == _connectors.length, "addConnectors: not same length");
        for (uint i = 0; i < _connectors.length; i++) {
            require(connectors[_connectorNames[i]] == address(0), "addConnectors: _connectorName added already");
            require(_connectors[i] != address(0), "addConnectors: _connectors address not vaild");
            ConnectorInterface(_connectors[i]).name(); // Checking if connector has function name()
            connectors[_connectorNames[i]] = _connectors[i];
            emit LogConnectorAdded(_connectorNames[i], _connectors[i]);
        }
    }

    /**
     * @dev Update Connectors
     * @param _connectorNames Array of Connector Names.
     * @param _connectors Array of Connector Address.
    */
    function updateConnectors(string[] calldata _connectorNames, address[] calldata _connectors) external isChief {
        require(_connectorNames.length == _connectors.length, "updateConnectors: not same length");
        for (uint i = 0; i < _connectors.length; i++) {
            require(connectors[_connectorNames[i]] != address(0), "updateConnectors: _connectorName not added to update");
            require(_connectors[i] != address(0), "updateConnectors: _connector address is not vaild");
            ConnectorInterface(_connectors[i]).name(); // Checking if connector has function name()
            emit LogConnectorUpdated(_connectorNames[i], connectors[_connectorNames[i]], _connectors[i]);
            connectors[_connectorNames[i]] = _connectors[i];
        }
    }

    /**
     * @dev Remove Connectors
     * @param _connectorNames Array of Connector Names.
    */
    function removeConnectors(string[] calldata _connectorNames) external isChief {
        for (uint i = 0; i < _connectorNames.length; i++) {
            require(connectors[_connectorNames[i]] != address(0), "removeConnectors: _connectorName not added to update");
            emit LogConnectorRemoved(_connectorNames[i], connectors[_connectorNames[i]]);
            delete connectors[_connectorNames[i]];
        }
    }

    /**
     * @dev Check if Connector addresses are enabled.
     * @param _connectors Array of Connector Names.
    */
    function isConnectors(string[] calldata _connectorNames) external view returns (bool isOk, address[] memory _connectors) {
        isOk = true;
        uint len = _connectorNames.length;
        _connectors = new address[](len);
        for (uint i = 0; i < _connectors.length; i++) {
            _connectors[i] = connectors[_connectorNames[i]];
            if (_connectors[i] == address(0)) {
                isOk = false;
                break;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}