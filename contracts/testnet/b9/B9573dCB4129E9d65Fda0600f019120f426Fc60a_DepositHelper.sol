// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {IERC721Receiver} from "../interfaces/IERC721Receiver.sol";

import {TransferItem} from "./HelperStructs.sol";

import {Conduit} from "../conduit/Conduit.sol";

import {ConduitTransfer} from "../conduit/lib/ConduitStructs.sol";

import "../interfaces/HelperErrors.sol";

import {ConduitItemType} from "../conduit/lib/ConduitEnums.sol";

import "../interfaces/DepositHelperInterface.sol";
import "../lib/ConfirmedOwner.sol";

/**
 * @title DepositHelper
 * @notice DepositHelper is a utility contract for transferring
 *         ERC20/ERC721/ERC1155 items in bulk to a fixed recipient.
 */
contract DepositHelper is DepositHelperInterface, Conduit, HelperErrors, ConfirmedOwner {
  // Deposit enabled status
  bool public isEnabled;
  // recipient
  address public recipient;

  /**
   * @dev Reverts if the deposit is not enabled
   */
  modifier checkEnabled() {
    require(isEnabled, "Deposit suspended");
    _;
  }

  /**
   * @dev Set the supplied recipient.
   *
   *
   * @param _recipient The recipient contract address, used to receive
   *                          ERC20/721/1155 tokens.
   */
  constructor(address _recipient) ConfirmedOwner(msg.sender) {
    recipient = _recipient;
    isEnabled = true;
  }

  /**
   * @dev Update recipient
   * @param _recipient  The new recipient.
   */
  function updateRecipient(address _recipient) external override onlyOwner {
    require(_recipient != recipient, "Not changed");
    require(_recipient != address(0), "Cannot set recipient to zero");
    address oldRecipient = recipient;
    recipient = _recipient;
    emit UpdateRecipient(oldRecipient, recipient);
  }

  /**
   * @notice Enable deposit
   */
  function enableDeposit() external override onlyOwner {
    if (!isEnabled) {
      isEnabled = true;

      emit EnableDeposit();
    }
  }

  /**
   * @notice Disable deposit
   */
  function disableDeposit() external override onlyOwner {
    if (isEnabled) {
      isEnabled = false;

      emit DisableDeposit();
    }
  }

  /**
   * @notice Transfer multiple ERC20/ERC721/ERC1155 items to
   *         specified recipients.
   *
   * @param items      The items to transfer to an intended recipient.
   * @param requestId An optional request id from client.
   *
   * @return magicValue A value indicating that the transfers were successful.
   */
  function bulkDeposit(TransferItem[] calldata items, uint256 requestId)
    external
    override
    checkEnabled
    returns (bytes4 magicValue)
  {
    // Use conduit to perform transfers.
    _performTransfersWithConduit(items);

    // emit bulk deposit event
    emit BulkDeposit(requestId);

    // Return a magic value indicating that the transfers were performed.
    magicValue = this.bulkDeposit.selector;
  }

  /**
   * @notice Perform multiple transfers to the specified recipient.
   *
   * @param transfers  The items to transfer the specified recipient.
   */
  function _performTransfersWithConduit(TransferItem[] calldata transfers) internal {
    // Retrieve total number of transfers and place on stack.
    uint256 numTransfers = transfers.length;

    // Declare a new array in memory with length totalItems to populate with
    // each conduit transfer.
    ConduitTransfer[] memory conduitTransfers = new ConduitTransfer[](numTransfers);

    // Declare an index for storing ConduitTransfers in conduitTransfers.
    uint256 itemIndex;

    // Skip overflow checks: all for loops are indexed starting at zero.
    unchecked {
      // Iterate over each item in the transfer to create a
      // corresponding ConduitTransfer.
      for (uint256 j = 0; j < numTransfers; ++j) {
        // Retrieve the item from the transfer.
        TransferItem calldata item = transfers[j];

        if (item.itemType == ConduitItemType.ERC20) {
          // Ensure that the identifier of an ERC20 token is 0.
          if (item.identifier != 0) {
            revert InvalidERC20Identifier();
          }
        }

        // Create a ConduitTransfer corresponding to each
        // TransferItem.
        conduitTransfers[itemIndex] = ConduitTransfer(
          item.itemType,
          item.token,
          msg.sender,
          recipient,
          item.identifier,
          item.amount
        );

        // Increment the index for storing ConduitTransfers.
        ++itemIndex;
      }
    }
    // transfer tokens
    _execute(conduitTransfers);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ConduitItemType} from "../conduit/lib/ConduitEnums.sol";

/**
 * @dev A TransferItem specifies the itemType (ERC20/ERC721/ERC1155),
 *      token address, token identifier, and amount of the token to be
 *      transferred via the Helper. For ERC20 tokens, identifier
 *      must be 0. For ERC721 tokens, amount must be 1.
 */
struct TransferItem {
  ConduitItemType itemType;
  address token;
  uint256 identifier;
  uint256 amount;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ConduitItemType} from "./lib/ConduitEnums.sol";

import {TokenTransferor} from "../lib/TokenTransferor.sol";

import {ConduitTransfer} from "./lib/ConduitStructs.sol";

/**
 * @title Conduit
 * @notice Conduit use to transfer approved ERC20/721/1155 tokens.
 */
contract Conduit is TokenTransferor {
  /**
   * @notice Execute a sequence of ERC20/721/1155 transfers.
   *
   * @param transfers The ERC20/721/1155 transfers to perform.
   */
  function _execute(ConduitTransfer[] memory transfers) internal {
    // Retrieve the total number of transfers and place on the stack.
    uint256 totalStandardTransfers = transfers.length;

    // Iterate over each transfer.
    for (uint256 i = 0; i < totalStandardTransfers; ) {
      // Retrieve the transfer in question and perform the transfer.
      _transfer(transfers[i]);

      // Skip overflow check as for loop is indexed starting at zero.
      unchecked {
        ++i;
      }
    }
  }

  /**
   * @dev Internal function to transfer a given ERC20/721/1155 item. Note that
   *      channels are expected to implement checks against transferring any
   *      zero-amount items if that constraint is desired.
   *
   * @param item The ERC20/721/1155 item to transfer.
   */
  function _transfer(ConduitTransfer memory item) internal {
    // Determine the transfer method based on the respective item type.
    if (item.itemType == ConduitItemType.ERC20) {
      // Transfer ERC20 token. Note that item.identifier is ignored and
      // therefore ERC20 transfer items are potentially malleable — this
      // check should be performed by the calling channel if a constraint
      // on item malleability is desired.
      _performERC20Transfer(item.token, item.from, item.to, item.amount);
    } else if (item.itemType == ConduitItemType.ERC721) {
      // Ensure that exactly one 721 item is being transferred.
      if (item.amount != 1) {
        revert InvalidERC721TransferAmount();
      }

      // Transfer ERC721 token.
      _performERC721Transfer(item.token, item.from, item.to, item.identifier);
    } else if (item.itemType == ConduitItemType.ERC1155) {
      // Transfer ERC1155 token.
      _performERC1155Transfer(item.token, item.from, item.to, item.identifier, item.amount);
    } else {
      // Throw with an error.
      revert InvalidItemType();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @title HelperErrors
 */
interface HelperErrors {
  /**
   * @dev Revert with an error when attempting to execute an ERC721 transfer
   *      to an invalid recipient.
   */
  error InvalidERC721Recipient(address recipient);

  /**
   * @dev Revert with an error when a call to a ERC721 receiver reverts with
   *      bytes data.
   */
  error ERC721ReceiverErrorRevertBytes(bytes reason, address receiver, address sender, uint256 identifier);

  /**
   * @dev Revert with an error when a call to a ERC721 receiver reverts with
   *      string reason.
   */
  error ERC721ReceiverErrorRevertString(string reason, address receiver, address sender, uint256 identifier);

  /**
   * @dev Revert with an error when an ERC20 token has an invalid identifier.
   */
  error InvalidERC20Identifier();
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {TransferItem} from "../helpers/HelperStructs.sol";

interface DepositHelperInterface {
  /**
   * @dev Emit an event when the recipient is updated.
   *
   * @param from The old recipient
   * @param to The new recipient
   */
  event UpdateRecipient(address from, address to);

  /**
   * @dev Emit an event when the deposit is enabled.
   */
  event EnableDeposit();

  /**
   * @dev Emit an event when the deposit is disabled.
   */
  event DisableDeposit();

  /**
   * @dev Emit an event when the batch transfer is successful.
   *
   * @param requestId The request id from client
   */
  event BulkDeposit(uint256 requestId);

  /**
   * @notice Update recipient
   *
   * @param recipient  The new recipient
   */
  function updateRecipient(address recipient) external;

  /**
   * @notice Enable deposit
   */
  function enableDeposit() external;

  /**
   * @notice Disable deposit
   */
  function disableDeposit() external;

  /**
   * @notice Deposit multiple items.
   *
   * @param items The items to transfer.
   * @param requestId  The request id from client.
   */
  function bulkDeposit(TransferItem[] calldata items, uint256 requestId) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

enum ConduitItemType {
  NATIVE, // unused
  ERC20,
  ERC721,
  ERC1155
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ConduitItemType} from "./ConduitEnums.sol";

struct ConduitTransfer {
  ConduitItemType itemType;
  address token;
  address from;
  address to;
  uint256 identifier;
  uint256 amount;
}

struct ConduitBatch1155Transfer {
  address token;
  address from;
  address to;
  uint256[] ids;
  uint256[] amounts;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./TokenTransferorConstants.sol";

import {TokenTransferorErrors} from "../interfaces/TokenTransferorErrors.sol";

import {ConduitBatch1155Transfer} from "../conduit/lib/ConduitStructs.sol";

/**
 * @title TokenTransferor
 * @author 0age
 * @custom:coauthor d1ll0n
 * @custom:coauthor transmissions11
 * @notice TokenTransferor is a library for performing optimized ERC20, ERC721,
 *         ERC1155, and batch ERC1155 transfers, used by both Seaport as well as
 *         by conduits deployed by the ConduitController. Use great caution when
 *         considering these functions for use in other codebases, as there are
 *         significant side effects and edge cases that need to be thoroughly
 *         understood and carefully addressed.
 */
contract TokenTransferor is TokenTransferorErrors {
  /**
   * @dev Internal function to transfer ERC20 tokens from a given originator
   *      to a given recipient. Sufficient approvals must be set on the
   *      contract performing the transfer.
   *
   * @param token      The ERC20 token to transfer.
   * @param from       The originator of the transfer.
   * @param to         The recipient of the transfer.
   * @param amount     The amount to transfer.
   */
  function _performERC20Transfer(
    address token,
    address from,
    address to,
    uint256 amount
  ) internal {
    // Utilize assembly to perform an optimized ERC20 token transfer.
    assembly {
      // The free memory pointer memory slot will be used when populating
      // call data for the transfer; read the value and restore it later.
      let memPointer := mload(FreeMemoryPointerSlot)

      // Write call data into memory, starting with function selector.
      mstore(ERC20_transferFrom_sig_ptr, ERC20_transferFrom_signature)
      mstore(ERC20_transferFrom_from_ptr, from)
      mstore(ERC20_transferFrom_to_ptr, to)
      mstore(ERC20_transferFrom_amount_ptr, amount)

      // Make call & copy up to 32 bytes of return data to scratch space.
      // Scratch space does not need to be cleared ahead of time, as the
      // subsequent check will ensure that either at least a full word of
      // return data is received (in which case it will be overwritten) or
      // that no data is received (in which case scratch space will be
      // ignored) on a successful call to the given token.
      let callStatus := call(gas(), token, 0, ERC20_transferFrom_sig_ptr, ERC20_transferFrom_length, 0, OneWord)

      // Determine whether transfer was successful using status & result.
      let success := and(
        // Set success to whether the call reverted, if not check it
        // either returned exactly 1 (can't just be non-zero data), or
        // had no return data.
        or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
        callStatus
      )

      // Handle cases where either the transfer failed or no data was
      // returned. Group these, as most transfers will succeed with data.
      // Equivalent to `or(iszero(success), iszero(returndatasize()))`
      // but after it's inverted for JUMPI this expression is cheaper.
      if iszero(and(success, iszero(iszero(returndatasize())))) {
        // If the token has no code or the transfer failed: Equivalent
        // to `or(iszero(success), iszero(extcodesize(token)))` but
        // after it's inverted for JUMPI this expression is cheaper.
        if iszero(and(iszero(iszero(extcodesize(token))), success)) {
          // If the transfer failed:
          if iszero(success) {
            // If it was due to a revert:
            if iszero(callStatus) {
              // If it returned a message, bubble it up as long as
              // sufficient gas remains to do so:
              if returndatasize() {
                // Ensure that sufficient gas is available to
                // copy returndata while expanding memory where
                // necessary. Start by computing the word size
                // of returndata and allocated memory. Round up
                // to the nearest full word.
                let returnDataWords := div(add(returndatasize(), AlmostOneWord), OneWord)

                // Note: use the free memory pointer in place of
                // msize() to work around a Yul warning that
                // prevents accessing msize directly when the IR
                // pipeline is activated.
                let msizeWords := div(memPointer, OneWord)

                // Next, compute the cost of the returndatacopy.
                let cost := mul(CostPerWord, returnDataWords)

                // Then, compute cost of new memory allocation.
                if gt(returnDataWords, msizeWords) {
                  cost := add(
                    cost,
                    add(
                      mul(sub(returnDataWords, msizeWords), CostPerWord),
                      div(
                        sub(mul(returnDataWords, returnDataWords), mul(msizeWords, msizeWords)),
                        MemoryExpansionCoefficient
                      )
                    )
                  )
                }

                // Finally, add a small constant and compare to
                // gas remaining; bubble up the revert data if
                // enough gas is still available.
                if lt(add(cost, ExtraGasBuffer), gas()) {
                  // Copy returndata to memory; overwrite
                  // existing memory.
                  returndatacopy(0, 0, returndatasize())

                  // Revert, specifying memory region with
                  // copied returndata.
                  revert(0, returndatasize())
                }
              }

              // Otherwise revert with a generic error message.
              mstore(TokenTransferGenericFailure_error_sig_ptr, TokenTransferGenericFailure_error_signature)
              mstore(TokenTransferGenericFailure_error_token_ptr, token)
              mstore(TokenTransferGenericFailure_error_from_ptr, from)
              mstore(TokenTransferGenericFailure_error_to_ptr, to)
              mstore(TokenTransferGenericFailure_error_id_ptr, 0)
              mstore(TokenTransferGenericFailure_error_amount_ptr, amount)
              revert(TokenTransferGenericFailure_error_sig_ptr, TokenTransferGenericFailure_error_length)
            }

            // Otherwise revert with a message about the token
            // returning false or non-compliant return values.
            mstore(BadReturnValueFromERC20OnTransfer_error_sig_ptr, BadReturnValueFromERC20OnTransfer_error_signature)
            mstore(BadReturnValueFromERC20OnTransfer_error_token_ptr, token)
            mstore(BadReturnValueFromERC20OnTransfer_error_from_ptr, from)
            mstore(BadReturnValueFromERC20OnTransfer_error_to_ptr, to)
            mstore(BadReturnValueFromERC20OnTransfer_error_amount_ptr, amount)
            revert(BadReturnValueFromERC20OnTransfer_error_sig_ptr, BadReturnValueFromERC20OnTransfer_error_length)
          }

          // Otherwise, revert with error about token not having code:
          mstore(NoContract_error_sig_ptr, NoContract_error_signature)
          mstore(NoContract_error_token_ptr, token)
          revert(NoContract_error_sig_ptr, NoContract_error_length)
        }

        // Otherwise, the token just returned no data despite the call
        // having succeeded; no need to optimize for this as it's not
        // technically ERC20 compliant.
      }

      // Restore the original free memory pointer.
      mstore(FreeMemoryPointerSlot, memPointer)

      // Restore the zero slot to zero.
      mstore(ZeroSlot, 0)
    }
  }

  /**
   * @dev Internal function to transfer an ERC721 token from a given
   *      originator to a given recipient. Sufficient approvals must be set on
   *      the contract performing the transfer. Note that this function does
   *      not check whether the receiver can accept the ERC721 token (i.e. it
   *      does not use `safeTransferFrom`).
   *
   * @param token      The ERC721 token to transfer.
   * @param from       The originator of the transfer.
   * @param to         The recipient of the transfer.
   * @param identifier The tokenId to transfer.
   */
  function _performERC721Transfer(
    address token,
    address from,
    address to,
    uint256 identifier
  ) internal {
    // Utilize assembly to perform an optimized ERC721 token transfer.
    assembly {
      // If the token has no code, revert.
      if iszero(extcodesize(token)) {
        mstore(NoContract_error_sig_ptr, NoContract_error_signature)
        mstore(NoContract_error_token_ptr, token)
        revert(NoContract_error_sig_ptr, NoContract_error_length)
      }

      // The free memory pointer memory slot will be used when populating
      // call data for the transfer; read the value and restore it later.
      let memPointer := mload(FreeMemoryPointerSlot)

      // Write call data to memory starting with function selector.
      mstore(ERC721_transferFrom_sig_ptr, ERC721_transferFrom_signature)
      mstore(ERC721_transferFrom_from_ptr, from)
      mstore(ERC721_transferFrom_to_ptr, to)
      mstore(ERC721_transferFrom_id_ptr, identifier)

      // Perform the call, ignoring return data.
      let success := call(gas(), token, 0, ERC721_transferFrom_sig_ptr, ERC721_transferFrom_length, 0, 0)

      // If the transfer reverted:
      if iszero(success) {
        // If it returned a message, bubble it up as long as sufficient
        // gas remains to do so:
        if returndatasize() {
          // Ensure that sufficient gas is available to copy
          // returndata while expanding memory where necessary. Start
          // by computing word size of returndata & allocated memory.
          // Round up to the nearest full word.
          let returnDataWords := div(add(returndatasize(), AlmostOneWord), OneWord)

          // Note: use the free memory pointer in place of msize() to
          // work around a Yul warning that prevents accessing msize
          // directly when the IR pipeline is activated.
          let msizeWords := div(memPointer, OneWord)

          // Next, compute the cost of the returndatacopy.
          let cost := mul(CostPerWord, returnDataWords)

          // Then, compute cost of new memory allocation.
          if gt(returnDataWords, msizeWords) {
            cost := add(
              cost,
              add(
                mul(sub(returnDataWords, msizeWords), CostPerWord),
                div(sub(mul(returnDataWords, returnDataWords), mul(msizeWords, msizeWords)), MemoryExpansionCoefficient)
              )
            )
          }

          // Finally, add a small constant and compare to gas
          // remaining; bubble up the revert data if enough gas is
          // still available.
          if lt(add(cost, ExtraGasBuffer), gas()) {
            // Copy returndata to memory; overwrite existing memory.
            returndatacopy(0, 0, returndatasize())

            // Revert, giving memory region with copied returndata.
            revert(0, returndatasize())
          }
        }

        // Otherwise revert with a generic error message.
        mstore(TokenTransferGenericFailure_error_sig_ptr, TokenTransferGenericFailure_error_signature)
        mstore(TokenTransferGenericFailure_error_token_ptr, token)
        mstore(TokenTransferGenericFailure_error_from_ptr, from)
        mstore(TokenTransferGenericFailure_error_to_ptr, to)
        mstore(TokenTransferGenericFailure_error_id_ptr, identifier)
        mstore(TokenTransferGenericFailure_error_amount_ptr, 1)
        revert(TokenTransferGenericFailure_error_sig_ptr, TokenTransferGenericFailure_error_length)
      }

      // Restore the original free memory pointer.
      mstore(FreeMemoryPointerSlot, memPointer)

      // Restore the zero slot to zero.
      mstore(ZeroSlot, 0)
    }
  }

  /**
   * @dev Internal function to transfer ERC1155 tokens from a given
   *      originator to a given recipient. Sufficient approvals must be set on
   *      the contract performing the transfer and contract recipients must
   *      implement the ERC1155TokenReceiver interface to indicate that they
   *      are willing to accept the transfer.
   *
   * @param token      The ERC1155 token to transfer.
   * @param from       The originator of the transfer.
   * @param to         The recipient of the transfer.
   * @param identifier The id to transfer.
   * @param amount     The amount to transfer.
   */
  function _performERC1155Transfer(
    address token,
    address from,
    address to,
    uint256 identifier,
    uint256 amount
  ) internal {
    // Utilize assembly to perform an optimized ERC1155 token transfer.
    assembly {
      // If the token has no code, revert.
      if iszero(extcodesize(token)) {
        mstore(NoContract_error_sig_ptr, NoContract_error_signature)
        mstore(NoContract_error_token_ptr, token)
        revert(NoContract_error_sig_ptr, NoContract_error_length)
      }

      // The following memory slots will be used when populating call data
      // for the transfer; read the values and restore them later.
      let memPointer := mload(FreeMemoryPointerSlot)
      let slot0x80 := mload(Slot0x80)
      let slot0xA0 := mload(Slot0xA0)
      let slot0xC0 := mload(Slot0xC0)

      // Write call data into memory, beginning with function selector.
      mstore(ERC1155_safeTransferFrom_sig_ptr, ERC1155_safeTransferFrom_signature)
      mstore(ERC1155_safeTransferFrom_from_ptr, from)
      mstore(ERC1155_safeTransferFrom_to_ptr, to)
      mstore(ERC1155_safeTransferFrom_id_ptr, identifier)
      mstore(ERC1155_safeTransferFrom_amount_ptr, amount)
      mstore(ERC1155_safeTransferFrom_data_offset_ptr, ERC1155_safeTransferFrom_data_length_offset)
      mstore(ERC1155_safeTransferFrom_data_length_ptr, 0)

      // Perform the call, ignoring return data.
      let success := call(gas(), token, 0, ERC1155_safeTransferFrom_sig_ptr, ERC1155_safeTransferFrom_length, 0, 0)

      // If the transfer reverted:
      if iszero(success) {
        // If it returned a message, bubble it up as long as sufficient
        // gas remains to do so:
        if returndatasize() {
          // Ensure that sufficient gas is available to copy
          // returndata while expanding memory where necessary. Start
          // by computing word size of returndata & allocated memory.
          // Round up to the nearest full word.
          let returnDataWords := div(add(returndatasize(), AlmostOneWord), OneWord)

          // Note: use the free memory pointer in place of msize() to
          // work around a Yul warning that prevents accessing msize
          // directly when the IR pipeline is activated.
          let msizeWords := div(memPointer, OneWord)

          // Next, compute the cost of the returndatacopy.
          let cost := mul(CostPerWord, returnDataWords)

          // Then, compute cost of new memory allocation.
          if gt(returnDataWords, msizeWords) {
            cost := add(
              cost,
              add(
                mul(sub(returnDataWords, msizeWords), CostPerWord),
                div(sub(mul(returnDataWords, returnDataWords), mul(msizeWords, msizeWords)), MemoryExpansionCoefficient)
              )
            )
          }

          // Finally, add a small constant and compare to gas
          // remaining; bubble up the revert data if enough gas is
          // still available.
          if lt(add(cost, ExtraGasBuffer), gas()) {
            // Copy returndata to memory; overwrite existing memory.
            returndatacopy(0, 0, returndatasize())

            // Revert, giving memory region with copied returndata.
            revert(0, returndatasize())
          }
        }

        // Otherwise revert with a generic error message.
        mstore(TokenTransferGenericFailure_error_sig_ptr, TokenTransferGenericFailure_error_signature)
        mstore(TokenTransferGenericFailure_error_token_ptr, token)
        mstore(TokenTransferGenericFailure_error_from_ptr, from)
        mstore(TokenTransferGenericFailure_error_to_ptr, to)
        mstore(TokenTransferGenericFailure_error_id_ptr, identifier)
        mstore(TokenTransferGenericFailure_error_amount_ptr, amount)
        revert(TokenTransferGenericFailure_error_sig_ptr, TokenTransferGenericFailure_error_length)
      }

      mstore(Slot0x80, slot0x80) // Restore slot 0x80.
      mstore(Slot0xA0, slot0xA0) // Restore slot 0xA0.
      mstore(Slot0xC0, slot0xC0) // Restore slot 0xC0.

      // Restore the original free memory pointer.
      mstore(FreeMemoryPointerSlot, memPointer)

      // Restore the zero slot to zero.
      mstore(ZeroSlot, 0)
    }
  }

  /**
   * @dev Internal function to transfer ERC1155 tokens from a given
   *      originator to a given recipient. Sufficient approvals must be set on
   *      the contract performing the transfer and contract recipients must
   *      implement the ERC1155TokenReceiver interface to indicate that they
   *      are willing to accept the transfer. NOTE: this function is not
   *      memory-safe; it will overwrite existing memory, restore the free
   *      memory pointer to the default value, and overwrite the zero slot.
   *      This function should only be called once memory is no longer
   *      required and when uninitialized arrays are not utilized, and memory
   *      should be considered fully corrupted (aside from the existence of a
   *      default-value free memory pointer) after calling this function.
   *
   * @param batchTransfers The group of 1155 batch transfers to perform.
   */
  function _performERC1155BatchTransfers(ConduitBatch1155Transfer[] calldata batchTransfers) internal {
    // Utilize assembly to perform optimized batch 1155 transfers.
    assembly {
      let len := batchTransfers.length
      // Pointer to first head in the array, which is offset to the struct
      // at each index. This gets incremented after each loop to avoid
      // multiplying by 32 to get the offset for each element.
      let nextElementHeadPtr := batchTransfers.offset

      // Pointer to beginning of the head of the array. This is the
      // reference position each offset references. It's held static to
      // let each loop calculate the data position for an element.
      let arrayHeadPtr := nextElementHeadPtr

      // Write the function selector, which will be reused for each call:
      // safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)
      mstore(ConduitBatch1155Transfer_from_offset, ERC1155_safeBatchTransferFrom_signature)

      // Iterate over each batch transfer.
      for {
        let i := 0
      } lt(i, len) {
        i := add(i, 1)
      } {
        // Read the offset to the beginning of the element and add
        // it to pointer to the beginning of the array head to get
        // the absolute position of the element in calldata.
        let elementPtr := add(arrayHeadPtr, calldataload(nextElementHeadPtr))

        // Retrieve the token from calldata.
        let token := calldataload(elementPtr)

        // If the token has no code, revert.
        if iszero(extcodesize(token)) {
          mstore(NoContract_error_sig_ptr, NoContract_error_signature)
          mstore(NoContract_error_token_ptr, token)
          revert(NoContract_error_sig_ptr, NoContract_error_length)
        }

        // Get the total number of supplied ids.
        let idsLength := calldataload(add(elementPtr, ConduitBatch1155Transfer_ids_length_offset))

        // Determine the expected offset for the amounts array.
        let expectedAmountsOffset := add(ConduitBatch1155Transfer_amounts_length_baseOffset, mul(idsLength, OneWord))

        // Validate struct encoding.
        let invalidEncoding := iszero(
          and(
            // ids.length == amounts.length
            eq(idsLength, calldataload(add(elementPtr, expectedAmountsOffset))),
            and(
              // ids_offset == 0xa0
              eq(
                calldataload(add(elementPtr, ConduitBatch1155Transfer_ids_head_offset)),
                ConduitBatch1155Transfer_ids_length_offset
              ),
              // amounts_offset == 0xc0 + ids.length*32
              eq(calldataload(add(elementPtr, ConduitBatchTransfer_amounts_head_offset)), expectedAmountsOffset)
            )
          )
        )

        // Revert with an error if the encoding is not valid.
        if invalidEncoding {
          mstore(Invalid1155BatchTransferEncoding_ptr, Invalid1155BatchTransferEncoding_selector)
          revert(Invalid1155BatchTransferEncoding_ptr, Invalid1155BatchTransferEncoding_length)
        }

        // Update the offset position for the next loop
        nextElementHeadPtr := add(nextElementHeadPtr, OneWord)

        // Copy the first section of calldata (before dynamic values).
        calldatacopy(
          BatchTransfer1155Params_ptr,
          add(elementPtr, ConduitBatch1155Transfer_from_offset),
          ConduitBatch1155Transfer_usable_head_size
        )

        // Determine size of calldata required for ids and amounts. Note
        // that the size includes both lengths as well as the data.
        let idsAndAmountsSize := add(TwoWords, mul(idsLength, TwoWords))

        // Update the offset for the data array in memory.
        mstore(BatchTransfer1155Params_data_head_ptr, add(BatchTransfer1155Params_ids_length_offset, idsAndAmountsSize))

        // Set the length of the data array in memory to zero.
        mstore(add(BatchTransfer1155Params_data_length_basePtr, idsAndAmountsSize), 0)

        // Determine the total calldata size for the call to transfer.
        let transferDataSize := add(BatchTransfer1155Params_calldata_baseSize, idsAndAmountsSize)

        // Copy second section of calldata (including dynamic values).
        calldatacopy(
          BatchTransfer1155Params_ids_length_ptr,
          add(elementPtr, ConduitBatch1155Transfer_ids_length_offset),
          idsAndAmountsSize
        )

        // Perform the call to transfer 1155 tokens.
        let success := call(
          gas(),
          token,
          0,
          ConduitBatch1155Transfer_from_offset, // Data portion start.
          transferDataSize, // Location of the length of callData.
          0,
          0
        )

        // If the transfer reverted:
        if iszero(success) {
          // If it returned a message, bubble it up as long as
          // sufficient gas remains to do so:
          if returndatasize() {
            // Ensure that sufficient gas is available to copy
            // returndata while expanding memory where necessary.
            // Start by computing word size of returndata and
            // allocated memory. Round up to the nearest full word.
            let returnDataWords := div(add(returndatasize(), AlmostOneWord), OneWord)

            // Note: use transferDataSize in place of msize() to
            // work around a Yul warning that prevents accessing
            // msize directly when the IR pipeline is activated.
            // The free memory pointer is not used here because
            // this function does almost all memory management
            // manually and does not update it, and transferDataSize
            // should be the largest memory value used (unless a
            // previous batch was larger).
            let msizeWords := div(transferDataSize, OneWord)

            // Next, compute the cost of the returndatacopy.
            let cost := mul(CostPerWord, returnDataWords)

            // Then, compute cost of new memory allocation.
            if gt(returnDataWords, msizeWords) {
              cost := add(
                cost,
                add(
                  mul(sub(returnDataWords, msizeWords), CostPerWord),
                  div(
                    sub(mul(returnDataWords, returnDataWords), mul(msizeWords, msizeWords)),
                    MemoryExpansionCoefficient
                  )
                )
              )
            }

            // Finally, add a small constant and compare to gas
            // remaining; bubble up the revert data if enough gas is
            // still available.
            if lt(add(cost, ExtraGasBuffer), gas()) {
              // Copy returndata to memory; overwrite existing.
              returndatacopy(0, 0, returndatasize())

              // Revert with memory region containing returndata.
              revert(0, returndatasize())
            }
          }

          // Set the error signature.
          mstore(0, ERC1155BatchTransferGenericFailure_error_signature)

          // Write the token.
          mstore(ERC1155BatchTransferGenericFailure_token_ptr, token)

          // Increase the offset to ids by 32.
          mstore(BatchTransfer1155Params_ids_head_ptr, ERC1155BatchTransferGenericFailure_ids_offset)

          // Increase the offset to amounts by 32.
          mstore(
            BatchTransfer1155Params_amounts_head_ptr,
            add(OneWord, mload(BatchTransfer1155Params_amounts_head_ptr))
          )

          // Return modified region. The total size stays the same as
          // `token` uses the same number of bytes as `data.length`.
          revert(0, transferDataSize)
        }
      }

      // Reset the free memory pointer to the default value; memory must
      // be assumed to be dirtied and not reused from this point forward.
      // Also note that the zero slot is not reset to zero, meaning empty
      // arrays cannot be safely created or utilized until it is restored.
      mstore(FreeMemoryPointerSlot, DefaultFreeMemoryPointer)
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
 * -------------------------- Disambiguation & Other Notes ---------------------
 *    - The term "head" is used as it is in the documentation for ABI encoding,
 *      but only in reference to dynamic types, i.e. it always refers to the
 *      offset or pointer to the body of a dynamic type. In calldata, the head
 *      is always an offset (relative to the parent object), while in memory,
 *      the head is always the pointer to the body. More information found here:
 *      https://docs.soliditylang.org/en/v0.8.14/abi-spec.html#argument-encoding
 *        - Note that the length of an array is separate from and precedes the
 *          head of the array.
 *
 *    - The term "body" is used in place of the term "head" used in the ABI
 *      documentation. It refers to the start of the data for a dynamic type,
 *      e.g. the first word of a struct or the first word of the first element
 *      in an array.
 *
 *    - The term "pointer" is used to describe the absolute position of a value
 *      and never an offset relative to another value.
 *        - The suffix "_ptr" refers to a memory pointer.
 *        - The suffix "_cdPtr" refers to a calldata pointer.
 *
 *    - The term "offset" is used to describe the position of a value relative
 *      to some parent value. For example, OrderParameters_conduit_offset is the
 *      offset to the "conduit" value in the OrderParameters struct relative to
 *      the start of the body.
 *        - Note: Offsets are used to derive pointers.
 *
 *    - Some structs have pointers defined for all of their fields in this file.
 *      Lines which are commented out are fields that are not used in the
 *      codebase but have been left in for readability.
 */

uint256 constant AlmostOneWord = 0x1f;
uint256 constant OneWord = 0x20;
uint256 constant TwoWords = 0x40;
uint256 constant ThreeWords = 0x60;

uint256 constant FreeMemoryPointerSlot = 0x40;
uint256 constant ZeroSlot = 0x60;
uint256 constant DefaultFreeMemoryPointer = 0x80;

uint256 constant Slot0x80 = 0x80;
uint256 constant Slot0xA0 = 0xa0;
uint256 constant Slot0xC0 = 0xc0;

// abi.encodeWithSignature("transferFrom(address,address,uint256)")
uint256 constant ERC20_transferFrom_signature = (0x23b872dd00000000000000000000000000000000000000000000000000000000);
uint256 constant ERC20_transferFrom_sig_ptr = 0x0;
uint256 constant ERC20_transferFrom_from_ptr = 0x04;
uint256 constant ERC20_transferFrom_to_ptr = 0x24;
uint256 constant ERC20_transferFrom_amount_ptr = 0x44;
uint256 constant ERC20_transferFrom_length = 0x64; // 4 + 32 * 3 == 100

// abi.encodeWithSignature(
//     "safeTransferFrom(address,address,uint256,uint256,bytes)"
// )
uint256 constant ERC1155_safeTransferFrom_signature = (
  0xf242432a00000000000000000000000000000000000000000000000000000000
);
uint256 constant ERC1155_safeTransferFrom_sig_ptr = 0x0;
uint256 constant ERC1155_safeTransferFrom_from_ptr = 0x04;
uint256 constant ERC1155_safeTransferFrom_to_ptr = 0x24;
uint256 constant ERC1155_safeTransferFrom_id_ptr = 0x44;
uint256 constant ERC1155_safeTransferFrom_amount_ptr = 0x64;
uint256 constant ERC1155_safeTransferFrom_data_offset_ptr = 0x84;
uint256 constant ERC1155_safeTransferFrom_data_length_ptr = 0xa4;
uint256 constant ERC1155_safeTransferFrom_length = 0xc4; // 4 + 32 * 6 == 196
uint256 constant ERC1155_safeTransferFrom_data_length_offset = 0xa0;

// abi.encodeWithSignature(
//     "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)"
// )
uint256 constant ERC1155_safeBatchTransferFrom_signature = (
  0x2eb2c2d600000000000000000000000000000000000000000000000000000000
);

bytes4 constant ERC1155_safeBatchTransferFrom_selector = bytes4(bytes32(ERC1155_safeBatchTransferFrom_signature));

uint256 constant ERC721_transferFrom_signature = ERC20_transferFrom_signature;
uint256 constant ERC721_transferFrom_sig_ptr = 0x0;
uint256 constant ERC721_transferFrom_from_ptr = 0x04;
uint256 constant ERC721_transferFrom_to_ptr = 0x24;
uint256 constant ERC721_transferFrom_id_ptr = 0x44;
uint256 constant ERC721_transferFrom_length = 0x64; // 4 + 32 * 3 == 100

// abi.encodeWithSignature("NoContract(address)")
uint256 constant NoContract_error_signature = (0x5f15d67200000000000000000000000000000000000000000000000000000000);
uint256 constant NoContract_error_sig_ptr = 0x0;
uint256 constant NoContract_error_token_ptr = 0x4;
uint256 constant NoContract_error_length = 0x24; // 4 + 32 == 36

// abi.encodeWithSignature(
//     "TokenTransferGenericFailure(address,address,address,uint256,uint256)"
// )
uint256 constant TokenTransferGenericFailure_error_signature = (
  0xf486bc8700000000000000000000000000000000000000000000000000000000
);
uint256 constant TokenTransferGenericFailure_error_sig_ptr = 0x0;
uint256 constant TokenTransferGenericFailure_error_token_ptr = 0x4;
uint256 constant TokenTransferGenericFailure_error_from_ptr = 0x24;
uint256 constant TokenTransferGenericFailure_error_to_ptr = 0x44;
uint256 constant TokenTransferGenericFailure_error_id_ptr = 0x64;
uint256 constant TokenTransferGenericFailure_error_amount_ptr = 0x84;

// 4 + 32 * 5 == 164
uint256 constant TokenTransferGenericFailure_error_length = 0xa4;

// abi.encodeWithSignature(
//     "BadReturnValueFromERC20OnTransfer(address,address,address,uint256)"
// )
uint256 constant BadReturnValueFromERC20OnTransfer_error_signature = (
  0x9889192300000000000000000000000000000000000000000000000000000000
);
uint256 constant BadReturnValueFromERC20OnTransfer_error_sig_ptr = 0x0;
uint256 constant BadReturnValueFromERC20OnTransfer_error_token_ptr = 0x4;
uint256 constant BadReturnValueFromERC20OnTransfer_error_from_ptr = 0x24;
uint256 constant BadReturnValueFromERC20OnTransfer_error_to_ptr = 0x44;
uint256 constant BadReturnValueFromERC20OnTransfer_error_amount_ptr = 0x64;

// 4 + 32 * 4 == 132
uint256 constant BadReturnValueFromERC20OnTransfer_error_length = 0x84;

uint256 constant ExtraGasBuffer = 0x20;
uint256 constant CostPerWord = 3;
uint256 constant MemoryExpansionCoefficient = 0x200;

// Values are offset by 32 bytes in order to write the token to the beginning
// in the event of a revert
uint256 constant BatchTransfer1155Params_ptr = 0x24;
uint256 constant BatchTransfer1155Params_ids_head_ptr = 0x64;
uint256 constant BatchTransfer1155Params_amounts_head_ptr = 0x84;
uint256 constant BatchTransfer1155Params_data_head_ptr = 0xa4;
uint256 constant BatchTransfer1155Params_data_length_basePtr = 0xc4;
uint256 constant BatchTransfer1155Params_calldata_baseSize = 0xc4;

uint256 constant BatchTransfer1155Params_ids_length_ptr = 0xc4;

uint256 constant BatchTransfer1155Params_ids_length_offset = 0xa0;
uint256 constant BatchTransfer1155Params_amounts_length_baseOffset = 0xc0;
uint256 constant BatchTransfer1155Params_data_length_baseOffset = 0xe0;

uint256 constant ConduitBatch1155Transfer_usable_head_size = 0x80;

uint256 constant ConduitBatch1155Transfer_from_offset = 0x20;
uint256 constant ConduitBatch1155Transfer_ids_head_offset = 0x60;
uint256 constant ConduitBatch1155Transfer_amounts_head_offset = 0x80;
uint256 constant ConduitBatch1155Transfer_ids_length_offset = 0xa0;
uint256 constant ConduitBatch1155Transfer_amounts_length_baseOffset = 0xc0;
uint256 constant ConduitBatch1155Transfer_calldata_baseSize = 0xc0;

// Note: abbreviated version of above constant to adhere to line length limit.
uint256 constant ConduitBatchTransfer_amounts_head_offset = 0x80;

uint256 constant Invalid1155BatchTransferEncoding_ptr = 0x00;
uint256 constant Invalid1155BatchTransferEncoding_length = 0x04;
uint256 constant Invalid1155BatchTransferEncoding_selector = (
  0xeba2084c00000000000000000000000000000000000000000000000000000000
);

uint256 constant ERC1155BatchTransferGenericFailure_error_signature = (
  0xafc445e200000000000000000000000000000000000000000000000000000000
);
uint256 constant ERC1155BatchTransferGenericFailure_token_ptr = 0x04;
uint256 constant ERC1155BatchTransferGenericFailure_ids_offset = 0xc0;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @title TokenTransferorErrors
 */
interface TokenTransferorErrors {
  /**
   * @dev Revert with an error when attempting to execute transfers with a
   *      NATIVE itemType.
   */
  error InvalidItemType();

  /**
   * @dev Revert with an error when an ERC721 transfer with amount other than
   *      one is attempted.
   */
  error InvalidERC721TransferAmount();

  /**
   * @dev Revert with an error when attempting to fulfill an order where an
   *      item has an amount of zero.
   */
  error MissingItemAmount();

  /**
   * @dev Revert with an error when attempting to fulfill an order where an
   *      item has unused parameters. This includes both the token and the
   *      identifier parameters for native transfers as well as the identifier
   *      parameter for ERC20 transfers. Note that the conduit does not
   *      perform this check, leaving it up to the calling channel to enforce
   *      when desired.
   */
  error UnusedItemParameters();

  /**
   * @dev Revert with an error when an ERC20, ERC721, or ERC1155 token
   *      transfer reverts.
   *
   * @param token      The token for which the transfer was attempted.
   * @param from       The source of the attempted transfer.
   * @param to         The recipient of the attempted transfer.
   * @param identifier The identifier for the attempted transfer.
   * @param amount     The amount for the attempted transfer.
   */
  error TokenTransferGenericFailure(address token, address from, address to, uint256 identifier, uint256 amount);

  /**
   * @dev Revert with an error when a batch ERC1155 token transfer reverts.
   *
   * @param token       The token for which the transfer was attempted.
   * @param from        The source of the attempted transfer.
   * @param to          The recipient of the attempted transfer.
   * @param identifiers The identifiers for the attempted transfer.
   * @param amounts     The amounts for the attempted transfer.
   */
  error ERC1155BatchTransferGenericFailure(
    address token,
    address from,
    address to,
    uint256[] identifiers,
    uint256[] amounts
  );

  /**
   * @dev Revert with an error when an ERC20 token transfer returns a falsey
   *      value.
   *
   * @param token      The token for which the ERC20 transfer was attempted.
   * @param from       The source of the attempted ERC20 transfer.
   * @param to         The recipient of the attempted ERC20 transfer.
   * @param amount     The amount for the attempted ERC20 transfer.
   */
  error BadReturnValueFromERC20OnTransfer(address token, address from, address to, uint256 amount);

  /**
   * @dev Revert with an error when an account being called as an assumed
   *      contract does not have code and returns no data.
   *
   * @param account The account that should contain code.
   */
  error NoContract(address account);

  /**
   * @dev Revert with an error when attempting to execute an 1155 batch
   *      transfer using calldata not produced by default ABI encoding or with
   *      different lengths for ids and amounts arrays.
   */
  error Invalid1155BatchTransferEncoding();
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    require(msg.sender == s_owner, "Only callable by owner");
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}