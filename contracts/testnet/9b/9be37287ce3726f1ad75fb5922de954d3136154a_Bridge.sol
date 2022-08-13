// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// ============ Internal imports ============
import "./interfaces/IRouter.sol";

// ============ External imports ============
import {IInterchainGasPaymaster} from "@abacus-network/core/interfaces/IInterchainGasPaymaster.sol";
import {IOutbox} from "@abacus-network/core/interfaces/IOutbox.sol";
import {IAbacusConnectionManager} from "@abacus-network/core/interfaces/IAbacusConnectionManager.sol";


contract Bridge {
  // ============ Variables ============
  IRouter public router;

  IAbacusConnectionManager public abacusConnectionManager;
  // Interchain Gas Paymaster contract. The relayer associated with this contract
  // must be willing to relay messages dispatched from the current Outbox contract,
  // otherwise payments made to the paymaster will not result in relayed messages.
  IInterchainGasPaymaster public interchainGasPaymaster;

  // chainId => address
  mapping(uint32 => bytes32) public bridgeAddress;

  // ============ Modifiers ============
  // @notice Ensures the caller is the router.
  modifier onlyRouter() {
    require(msg.sender == address(router));
    _;
  }

  /**
   * @notice Only accept messages from an Abacus Inbox contract
   */
  modifier onlyInbox() {
      require(_isInbox(msg.sender), "!inbox");
      _;
  }

  constructor(
    address _router,
    address _abacusConnectionManager,
    address _interchainGasPaymaster
  ) {
    router = IRouter(_router);
    abacusConnectionManager = IAbacusConnectionManager(_abacusConnectionManager);
    interchainGasPaymaster = IInterchainGasPaymaster(_interchainGasPaymaster);
  }

  // ============ External functions ============
  function sendSwapMessage(
    uint256 srcPoolId,
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 amount,
    address fromAddress,
    bytes32 toAddress,
    bytes calldata data
  ) external payable onlyRouter {
    bytes memory payload = abi.encodePacked(
      srcPoolId,
      dstChainPoolId,
      bytes32(bytes20(fromAddress)),
      amount,
      toAddress,
      router.numPools(),
      router.genCreditsData(dstChainId, dstChainPoolId),
      data
    );

    uint256 leafIndex = _outbox().dispatch(
      dstChainId,
      bridgeAddress[dstChainId],
      payload
    );
    interchainGasPaymaster.payGasFor{value:msg.value}(
      address(_outbox()),
      leafIndex,
      dstChainId
    );
  }

  function handle(
    uint32 origin,
    bytes32 sender,
    bytes calldata payload
  ) external onlyInbox {
    require(sender == bridgeAddress[origin]);

    uint256 numPools = uint256(bytes32(payload[160:192]));

    uint256[] memory receivedCredits = new uint256[](numPools);

    for (uint256 i = 0; i < numPools; i++) {
      receivedCredits[i] = uint256(bytes32(payload[192 + 32 * i:224 + 32 * i]));
    }

    router.receiveSwapMessage(
      origin,
      uint256(bytes32(payload[:32])), // srcPoolId
      uint256(bytes32(payload[32:64])), // dstChainPoolId
      bytes32(payload[64:96]), // fromAddress
      uint256(bytes32(payload[96:128])), // amount
      address(bytes20(payload[128:160])), // toAddress
      receivedCredits,
      payload[192 + 32 * numPools:]
    );
  }

  function addBridge(
    uint32 chainId,
    bytes32 _bridgeAddress
  ) external onlyRouter {
    require(bridgeAddress[chainId] == bytes32(0));
    bridgeAddress[chainId] = _bridgeAddress;
  }

  // ============ Internal functions ============
  /**
   * @notice Determine whether _potentialInbox is an enrolled Inbox from the abacusConnectionManager
   * @return True if _potentialInbox is an enrolled Inbox
   */
  function _isInbox(address _potentialInbox) internal view returns (bool) {
      return abacusConnectionManager.isInbox(_potentialInbox);
  }

  /**
   * @notice Get the local Outbox contract from the abacusConnectionManager
   * @return The local Outbox contract
   */
  function _outbox() internal view returns (IOutbox) {
      return abacusConnectionManager.outbox();
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;


interface IRouter {
  function sendSwapMessage(
    uint256 srcPoolId,
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 amount,
    address fromAddress,
    bytes32 toAddress,
    bytes calldata data
  ) external payable;

  function receiveSwapMessage(
    uint32 srcChainId,
    uint256 srcPoolId,
    uint256 dstChainPoolId,
    bytes32 fromAddress,
    uint256 amount,
    address toAddress,
    uint256[] memory receivedCredits,
    bytes calldata data
  ) external;

  function callCallback(
    address toAddress,
    address token,
    uint256 amount,
    uint32 srcChainId,
    bytes32 fromAddress,
    bytes calldata data
  ) external;

  function numPools() external view returns (uint256);

  function genCreditsData(
    uint32 dstChainId,
    uint256 dstChainPoolId
  ) external view returns (bytes memory);
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

/**
 * @title IInterchainGasPaymaster
 * @notice Manages payments on a source chain to cover gas costs of relaying
 * messages to destination chains.
 */
interface IInterchainGasPaymaster {
    function payGasFor(
        address _outbox,
        uint256 _leafIndex,
        uint32 _destinationDomain
    ) external payable;
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

import {IMailbox} from "./IMailbox.sol";

interface IOutbox is IMailbox {
    function dispatch(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        bytes calldata _messageBody
    ) external returns (uint256);

    function cacheCheckpoint() external;

    function latestCheckpoint() external view returns (bytes32, uint256);

    function count() external returns (uint256);

    function fail() external;

    function cachedCheckpoints(bytes32) external view returns (uint256);

    function latestCachedCheckpoint()
        external
        view
        returns (bytes32 root, uint256 index);
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

import {IOutbox} from "./IOutbox.sol";

interface IAbacusConnectionManager {
    function outbox() external view returns (IOutbox);

    function isInbox(address _inbox) external view returns (bool);

    function localDomain() external view returns (uint32);
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

interface IMailbox {
    function localDomain() external view returns (uint32);
}