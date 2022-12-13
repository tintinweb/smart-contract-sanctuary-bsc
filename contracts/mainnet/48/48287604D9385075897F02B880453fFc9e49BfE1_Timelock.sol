// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './NameVersion.sol';

contract Timelock is NameVersion {

    event NewAdmin(address indexed newAdmin);

    event NewPendingAdmin(address indexed newPendingAdmin);

    event NewDelay(uint256 indexed newDelay);

    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string  signature,
        bytes   data,
        uint256 eta
    );

    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string  signature,
        bytes   data,
        uint256 eta
    );

    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string  signature,
        bytes   data,
        uint256 eta
    );

    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant MINIMUM_DELAY = 1 days;
    uint256 public constant MAXIMUM_DELAY = 30 days;

    address public pendingAdmin;
    address public admin;
    uint256 public delay;

    // txHash => isActive
    mapping (bytes32 => bool) public queuedTransactions;

    constructor (address admin_, uint256 delay_) NameVersion('Timelock', '3.0.1') {
        require(delay_ >= MINIMUM_DELAY && delay_ <= MAXIMUM_DELAY, 'Timelock.constructor: invalid delay');
        admin = admin_;
        delay = delay_;
    }

    function setPendingAdmin(address newPendingAdmin) external {
        require(msg.sender == address(this), 'Timelock.setPendingAdmin: only Timelock');
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(newPendingAdmin);
    }

    function acceptPendingAdmin() external {
        require(msg.sender == pendingAdmin, 'Timelock.acceptPendingAdmin: only pendingAdmin');
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
        emit NewPendingAdmin(pendingAdmin);
    }

    function setDelay(uint256 newDelay) external {
        require(msg.sender == address(this), 'Timelock.setDelay: only Timelock');
        require(newDelay >= MINIMUM_DELAY && newDelay <= MAXIMUM_DELAY, 'Timelock.setDelay: invalid newDelay');
        delay = newDelay;
        emit NewDelay(newDelay);
    }

    function queueTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) external returns (bytes32)
    {
        require(msg.sender == admin, 'Timelock.queueTransaction: only admin');
        require(eta >= block.timestamp + delay, 'Timelock.queueTransaction: invalid eta');

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) external
    {
        require(msg.sender == admin, 'Timelock.cancelTransaction: only admin');

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) external payable returns (bytes memory)
    {
        require(msg.sender == admin, 'Timelock.executeTransaction: only admin');

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], 'Timelock.executeTransaction: not queued');
        require(block.timestamp >= eta, 'Timelock.executeTransaction: time locked');
        require(block.timestamp <= eta + GRACE_PERIOD, 'Timelock.executeTransaction: staled');

        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, 'Timelock.executeTransaction: execution reverted');

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);
        return returnData;
    }

    receive() external payable {}

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './INameVersion.sol';

/**
 * @dev Convenience contract for name and version information
 */
abstract contract NameVersion is INameVersion {

    bytes32 public immutable nameId;
    bytes32 public immutable versionId;

    constructor (string memory name, string memory version) {
        nameId = keccak256(abi.encodePacked(name));
        versionId = keccak256(abi.encodePacked(version));
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {

    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);

}