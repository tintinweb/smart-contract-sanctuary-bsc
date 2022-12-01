pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

// TODO add this back when we figure out how to deal with imports
// import "src/LightClient/interfaces/ILightClient.sol";

contract LightClientMock {
    uint256 public head;
    mapping(uint256 => bytes32) public headers;
    mapping(uint256 => bytes32) public executionStateRoots;
    event HeadUpdate(uint256 indexed slot, bytes32 indexed root);

    function setHeader(uint256 slot, bytes32 headerRoot) external {
        headers[slot] = headerRoot;
        // NOTE that the stateRoot emitted here is not the same as the header root
        // in the real LightClient
        head = slot;
        emit HeadUpdate(slot, headerRoot);
    }

    function setExecutionRoot(uint256 slot, bytes32 executionRoot) external {
        // NOTE that the root emitted here is not the same as the header root
        // in the real LightClient
        executionStateRoots[slot] = executionRoot;
        head = slot;
        emit HeadUpdate(slot, executionRoot);
    }
}