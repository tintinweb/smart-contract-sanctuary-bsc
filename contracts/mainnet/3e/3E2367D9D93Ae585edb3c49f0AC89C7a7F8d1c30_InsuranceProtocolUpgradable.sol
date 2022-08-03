pragma solidity ^0.8.9;

import "../../../../ERC20contract/CheckDot.DAOProxyContract/contracts/Proxy.sol";

contract InsuranceProtocolUpgradable is Proxy {
    constructor(address _cdtGouvernanceAddress) Proxy(_cdtGouvernanceAddress) { }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ProxyUpgrades
 * @author Jeremy Guyet (@jguyet)
 * @dev Provides a library allowing the management of updates.
 * Library usable for proxies.
 */
library ProxyUpgrades {

    struct Upgrade {
        uint256 id;
        address submitedNewFunctionalAddress;
        uint256 utcStartVote;
        uint256 utcEndVote;
        uint256 totalApproved;
        uint256 totalUnapproved;
        bool isFinished;
    }

    struct Upgrades {
        mapping(uint256 => Upgrade) upgrades;
        mapping(uint256 => mapping(address => address)) participators;
        uint256 counter;
    }

    struct UpgradesSlot {
        Upgrades value;
    }

    /////////
    // Upgrades View
    /////////

    function isEmpty(Upgrades storage upgrades) internal view returns (bool) {
        return upgrades.counter == 0;
    }

    function current(Upgrades storage upgrades) internal view returns (Upgrade storage) {
        return upgrades.upgrades[upgrades.counter - 1];
    }

    function all(Upgrades storage upgrades) internal view returns (Upgrade[] memory) {
        uint256 totalUpgrades = upgrades.counter;
        Upgrade[] memory results = new Upgrade[](totalUpgrades);
        uint256 index = 0;

        for (index; index < totalUpgrades; index++) {
            Upgrade storage upgrade = upgrades.upgrades[index];

            results[index].id = upgrade.id;
            results[index].submitedNewFunctionalAddress = upgrade.submitedNewFunctionalAddress;
            results[index].utcStartVote = upgrade.utcStartVote;
            results[index].utcEndVote = upgrade.utcEndVote;
            results[index].totalApproved = upgrade.totalApproved;
            results[index].totalUnapproved = upgrade.totalUnapproved;
            results[index].isFinished = upgrade.isFinished;
        }
        return results;
    }

    function getLastUpgrade(Upgrades storage upgrades) internal view returns (Upgrade memory) {
        Upgrade memory result;
        Upgrade storage upgrade = upgrades.upgrades[upgrades.counter - 1];
                    
        result.id = upgrade.id;
        result.submitedNewFunctionalAddress = upgrade.submitedNewFunctionalAddress;
        result.utcStartVote = upgrade.utcStartVote;
        result.utcEndVote = upgrade.utcEndVote;
        result.totalApproved = upgrade.totalApproved;
        result.totalUnapproved = upgrade.totalUnapproved;
        result.isFinished = upgrade.isFinished;
        return result;
    }

    /////////
    // Upgrade View
    /////////

    function hasVoted(Upgrade storage upgrade, Upgrades storage upgrades, address _checkAddress) internal view returns (bool) {
        return upgrades.participators[upgrade.id][_checkAddress] == _checkAddress;
    }

    function voteInProgress(Upgrade storage upgrade) internal view returns (bool) {
        return upgrade.utcStartVote < block.timestamp
            && upgrade.utcEndVote > block.timestamp;
    }

    function voteFinished(Upgrade storage upgrade) internal view returns (bool) {
        return upgrade.utcStartVote < block.timestamp
            && upgrade.utcEndVote < block.timestamp;
    }

    /////////
    // Upgrades Functions
    /////////

    function add(Upgrades storage upgrades, address _submitedNewFunctionalAddress, uint256 _utcStartVote, uint256 _utcEndVote) internal {
        unchecked {
            uint256 id = upgrades.counter++;
            
            upgrades.upgrades[id].id = id;
            upgrades.upgrades[id].submitedNewFunctionalAddress = _submitedNewFunctionalAddress;
            upgrades.upgrades[id].utcStartVote = _utcStartVote;
            upgrades.upgrades[id].utcEndVote = _utcEndVote;
            upgrades.upgrades[id].totalApproved = 0;
            upgrades.upgrades[id].totalUnapproved = 0;
            upgrades.upgrades[id].isFinished = false;
        }
    }

    /////////
    // Upgrade Functions
    /////////

    function vote(Upgrade storage upgrade, Upgrades storage upgrades, address _from, uint256 _votes, bool _approved) internal {
        unchecked {
            if (_approved) {
                upgrade.totalApproved += _votes;
            } else {
                upgrade.totalUnapproved += _votes;
            }
            upgrades.participators[upgrade.id][_from] = _from;
        }
    }

    function setFinished(Upgrade storage upgrade, bool _finished) internal {
        unchecked {
            upgrade.isFinished = _finished;
        }
    }

    /**
     * @dev Returns an `UpgradesSlot` with member `value` located at `slot`.
     */
    function getUpgradesSlot(bytes32 slot) internal pure returns (UpgradesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ProxyAddresses
 * @author Jeremy Guyet (@jguyet)
 * @dev Library to manage the storage of addresses for proxies.
 */
library ProxyAddresses {
    struct AddressSlot {
        address value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IOwnedProxy.sol";
import "../utils/ProxyUpgrades.sol";

/**
 * @title IUpgradableProxyDAO
 * @author Jeremy Guyet (@jguyet)
 * @dev See {UpgradableProxyDAO}.
 */
interface IUpgradableProxyDAO is IOwnedProxy {

    function getImplementation() external view returns (address);

    function getOwner() external view returns (address);

    function getGovernance() external view returns (address);

    function transferOwnership(address _newOwner) external payable;

    function upgrade(address _newAddress, uint256 _utcStartVote, uint256 _utcEndVote) external payable;

    function voteUpgradeCounting() external payable;

    function voteUpgrade(bool approve) external payable;

    function getAllUpgrades() external view returns (ProxyUpgrades.Upgrade[] memory);

    function getLastUpgrade() external view returns (ProxyUpgrades.Upgrade memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IOwnedProxy
 * @author Jeremy Guyet (@jguyet)
 * @dev See {UpgradableProxyDAO}.
 */
interface IOwnedProxy {

    function getOwner() external view returns (address);

    function transferOwnership(address _newOwner) external payable;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./utils/ProxyUpgrades.sol";
import "./utils/ProxyAddresses.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUpgradableProxyDAO.sol";

/**
 * @title UpgradableProxyDAO
 * @author Jeremy Guyet (@jguyet)
 * @dev Smart contract to implement on a contract proxy.
 * This contract allows the management of the important memory of a proxy.
 * The memory spaces are extremely far from the beginning of the memory
 * which allows a high security against collisions.
 * This contract allows updates using a DAO program governed by an
 * ERC20 governance token. A voting session is mandatory for each update.
 * All holders of at least one whole token are eligible to vote.
 * There are several memory locations dedicated to the proper functioning
 * of the proxy (Implementation, admin, governance, upgrades).
 * For more information about the security of these locations please refer
 * to the discussions around the EIP-1967 standard we have been inspired by.
 */
contract UpgradableProxyDAO is IUpgradableProxyDAO {
    using ProxyAddresses for ProxyAddresses.AddressSlot;
    using ProxyUpgrades for ProxyUpgrades.Upgrades;
    using ProxyUpgrades for ProxyUpgrades.Upgrade;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Storage slot with the address of the gorvenance token of the contract.
     * This is the keccak-256 hash of "eip1968.proxy.governance-token" subtracted by 1
     */
    bytes32 private constant _GOVERNANCE_SLOT = 0x30b33623300d2f507028cc1d95db722efbe7e60e35c0f3a911d7ab127466b894;

    /**
     * @dev Storage slot with the upgrades of the contract.
     * This is the keccak-256 hash of "eip1968.proxy.upgrades" subtracted by 1
     */
    bytes32 private constant _UPGRADES_SLOT = 0x67f5f25d7811ed1b64340ddd2bfcd19a70241d311fd280b43f6d718f6b60767e;

    constructor(address _cdtGouvernanceAddress) {
        _setOwner(msg.sender);
        _setGovernance(_cdtGouvernanceAddress);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /**
     * @dev Returns the current Owner address.
     */
    function getOwner() external view returns (address) {
        return _getOwner();
    }

    /**
     * @dev Returns the current Governance address.
     */
    function getGovernance() external view returns (address) {
        return _getGovernance();
    }

    /**
     * @dev Transfer the ownership onlyOwner can call this function.
     */
    function transferOwnership(address _newOwner) external payable {
        require(_getOwner() == msg.sender, "Proxy: FORBIDDEN");
        _setOwner(_newOwner);
    }

    /**
     * @dev Creation and update function of the proxified implementation,
     * the entry of a start date and an end date of the voting period by
     * the governance is necessary. The start date of the period must be
     * greater or equals than the `block.timestamp`.
     * The start date and end date of the voting period must be at least
     * 86400 seconds apart.
     */
    function upgrade(address _newAddress, uint256 _utcStartVote, uint256 _utcEndVote) external payable {
        require(_getOwner() == msg.sender, "Proxy: FORBIDDEN");
        require(_utcStartVote >= block.timestamp, "Proxy: EXPIRED");
        require(_utcEndVote >= (_utcStartVote + 86400), "Proxy: MINIMUM_SPACING");
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(_proxyUpgrades.isEmpty() || _proxyUpgrades.current().isFinished, "Proxy: UPGRADE_ALREADY_INPROGRESS");
        _proxyUpgrades.add(_newAddress, _utcStartVote, _utcEndVote);
    }

    /**
     * @dev Function to check the result of the vote of the implementation
     * update.
     * Only called by the owner and if the vote is favorable the
     * implementation is changed and a call to the initialize function of
     * the new implementation will be made.
     */
    function voteUpgradeCounting() external payable {
        require(_getOwner() == msg.sender, "Proxy: FORBIDDEN");
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(!_proxyUpgrades.isEmpty(), "Proxy: EMPTY");
        require(_proxyUpgrades.current().voteFinished(), "Proxy: VOTE_ALREADY_INPROGRESS");
        require(!_proxyUpgrades.current().isFinished, "Proxy: UPGRADE_ALREADY_FINISHED");

        _proxyUpgrades.current().setFinished(true);
        if (_proxyUpgrades.current().totalApproved > _proxyUpgrades.current().totalUnapproved) {
            _upgrade(_proxyUpgrades.current().submitedNewFunctionalAddress);
        }
    }

    /**
     * @dev Function callable by the holder of at least one unit of the
     * governance token.
     * A voter can only vote once per update.
     */
    function voteUpgrade(bool approve) external payable {
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(!_proxyUpgrades.isEmpty(), "Proxy: EMPTY");
        require(!_proxyUpgrades.current().isFinished, "Proxy: VOTE_FINISHED");
        require(_proxyUpgrades.current().voteInProgress(), "Proxy: VOTE_NOT_STARTED");
        require(!_proxyUpgrades.current().hasVoted(_proxyUpgrades, msg.sender), "Proxy: ALREADY_VOTED");
        IERC20 token = IERC20(_getGovernance());
        uint256 votes = token.balanceOf(msg.sender) - (1**token.decimals());
        require(votes >= 1, "Proxy: INSUFFISANT_POWER");

        _proxyUpgrades.current().vote(_proxyUpgrades, msg.sender, votes, approve);
    }

    /**
     * @dev Returns the array of all upgrades.
     */
    function getAllUpgrades() external view returns (ProxyUpgrades.Upgrade[] memory) {
        return ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value.all();
    }

    /**
     * @dev Returns the last upgrade.
     */
    function getLastUpgrade() external view returns (ProxyUpgrades.Upgrade memory) {
        return ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value.getLastUpgrade();
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address _newImplementation) private {
        ProxyAddresses.getAddressSlot(_IMPLEMENTATION_SLOT).value = _newImplementation;
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getOwner() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setOwner(address _owner) private {
        ProxyAddresses.getAddressSlot(_ADMIN_SLOT).value = _owner;
    }

    /**
     * @dev Returns the governance address.
     */
    function _getGovernance() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_GOVERNANCE_SLOT).value;
    }

    /**
     * @dev Stores a new address in the governance slot.
     */
    function _setGovernance(address _newGovernance) private {
        ProxyAddresses.getAddressSlot(_GOVERNANCE_SLOT).value = _newGovernance;
    }

    /**
     * @dev Stores the new implementation address in the implementation slot
     * and call the internal _afterUpgrade function used for calling functions
     * on the new implementation just after the set in the same nonce block.
     */
    function _upgrade(address _newFunctionalAddress) internal {
        _setImplementation(_newFunctionalAddress);
        _afterUpgrade(_newFunctionalAddress);
    }

    /**
     * @dev internal virtual function implemented in the Proxy contract.
     * This is called just after all upgrades of the proxy implementation.
     */
    function _afterUpgrade(address _newFunctionalAddress) internal virtual { }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./UpgradableProxyDAO.sol";

/**
 * @title Proxy
 * @author Jeremy Guyet (@jguyet)
 * @dev Proxy contract allows the binding of a version by version
 * implementation which can be updated thanks to the
 * UpgradableProxyDAO abstraction which allows the proxy a
 * DAO governance.
 */
contract Proxy is UpgradableProxyDAO {

    constructor(address _cdtGouvernanceAddress) UpgradableProxyDAO(_cdtGouvernanceAddress) { }

    /**
     * @dev This is the fallback function a fall back function is triggered if someone
     * sends a function call or a transaction to this contract AND there is no function
     * that corresponds to the name the callers is trying to execute.
     * Each call is then passed to the _delegate function which will call the functions
     * of the functional implementation.
     */
    fallback() external payable {
        _delegate(_getImplementation());
    }

    /**
     * @dev This is the receive function is triggered if someone send transaction to
     * this contract. Each call is then passed to the _delegate function which will
     * call the functions of the functional implementation.
     */
    receive() external payable {
        _delegate(_getImplementation());
    }

    /**
     * @dev This is the fallback function a fall back function is triggered if someone
     * sends a function call or a transaction to this contract AND there is no function
     * that corresponds to the name the callers is trying to execute 
     * e.g. if someone tries to call HelloWorld() to this contract, which doesn't exist
     * in this contract, then the fallback function will be called. 
     * In this case, the fallback function will redirect the call to the functional contract
     */
    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This function is called once the implementation is updated.
     * It calls the initialize function of the proxy contract,
     * this allows an update of some variables if necessary
     * when updating the proxy code again.
     */
    function _afterUpgrade(address _newFunctionalAddress) internal virtual override {
        address implementation = _newFunctionalAddress;
        bytes memory data = abi.encodeWithSignature("initialize()");

        assembly {
            let result := delegatecall(
                gas(),
                implementation,
                add(data, 0x20), // add is another assembly function; this changes the format to something that delegate call can read
                mload(data), // mload is memory load
                0,
                0
            )
            let size := returndatasize()
            let ptr := mload(0x40) // ptr as in pointer
            returndatacopy(ptr, 0, size)
            switch result // result will either be 0 (as in function call failed), or 1 (function call success)
            case 0 {
                revert(ptr, size)
            } // revert if function call failed
            default {
                return(ptr, size)
            } // default means "else"; else return
        }
    }
}