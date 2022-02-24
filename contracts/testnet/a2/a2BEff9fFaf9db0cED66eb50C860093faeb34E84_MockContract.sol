// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IToContract {
    function handleSyncData(bytes memory input) external;
}

interface ISyncProtocol {
    event MessagePublished(address indexed fromContract, bytes payload);

    event DepositSideChain(uint256 amount, address token, address receiver);

    // Publish a message to be attested by the SyncProtocol network
    function pushData(bytes memory payload) external payable;

    // Publish a message to be attested by the SyncProtocol network
    function pushMeta(string memory contractAbi, bool emitter)
        external
        returns (uint256);

    function depositSideChain(uint256 amount, address token) external;

    function syncData(
        uint256 nonce,
        address fromContract,
        address sender,
        bytes memory payload,
        address toContract,
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "../interfaces/ISyncProtocol.sol";

contract MockContract {
    address public syncProtocol;
    uint256 public count;
    bytes public data;

    function setSyncProtocol(address _newAddr) external {
        syncProtocol = _newAddr;
    }

    function pushData(bytes memory payload) external {
        ISyncProtocol(syncProtocol).pushData(payload);
    }

    function handleSyncData(bytes memory input)
        external
        returns (bytes memory)
    {
        count = count + 1;
        data = input;
        if (count % 10 == 0) revert("MockContract: handleSyncData random revert");
        return input;
    }
}