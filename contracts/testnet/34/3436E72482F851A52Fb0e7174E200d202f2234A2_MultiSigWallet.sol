// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./utils/Types.sol";
import "./base/OwnerManager.sol";
import "./base/Executor.sol";
import "./handler/TokensHandler.sol";

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
contract MultiSigWallet is OwnerManager, Executor, TokensHandler, Initializable {
  event Received(address indexed sender, uint256 value);
  event TransactionApproved(address indexed sender, uint256 indexed transactionId);
  event ApprovalRevoked(address indexed sender, uint256 indexed transactionId);
  event TransactionSubmitted(uint256 indexed transactionId);
  event TransactionExecuted(uint256 indexed transactionId);
  event ExecutionFailed(uint256 indexed transactionId);

  struct Transaction {
    Types.Operation operation;
    address target;
    uint256 value;
    bytes data;
    uint8 approval;
    bool executed;
  }

  uint8 constant public MAX_OWNER = 50;

  mapping (uint256 => Transaction) public transactions;
  mapping (uint256 => mapping (address => bool)) public approvals;
  uint256 public transactionCount;

  /// @dev sets initial owners and required number of confirmations.
  /// @param _owners List of initial owners.
  /// @param _required Number of required confirmations.
  function initialize(address[] memory _owners, uint8 _required) public initializer {
    setupOwners(_owners, _required);
  }

  /// @dev deposit native token into this contract.
  receive() external payable {
    emit Received(msg.sender, msg.value);
  }

  /// @dev Allows an owner to submit and approve a transaction.
  /// @param operation external call operation
  /// @param target transaction destination address
  /// @param value transaction value in Wei.
  /// @param data transaction data payload.
  /// @return txnId returns transaction ID.
  function submitTransaction(
    Types.Operation operation, 
    address target, 
    uint256 value, 
    bytes memory data
  ) public returns (uint256 txnId) 
  {
    txnId = _addTransaction(operation, target, value, data);
    approve(txnId);
  }

  /// @dev Allows an owner to approve a transaction.
  /// @param _txnId transaction ID.
  function approve(uint256 _txnId) public
    isOwner(msg.sender)
    hasTransaction(_txnId)
    notApproved(_txnId, msg.sender)
  {
    transactions[_txnId].approval++;
    approvals[_txnId][msg.sender] = true;

    emit TransactionApproved(msg.sender, _txnId);
    executeTransaction(_txnId);
  }

  /// @dev Allows an owner to revoke a approval for a transaction.
  /// @param _txnId transaction ID.
  function revokeApproval(uint256 _txnId) external
    isOwner(msg.sender)
    approved(_txnId, msg.sender)
    notExecuted(_txnId)
  {
    transactions[_txnId].approval--;
    approvals[_txnId][msg.sender] = false;
    
    emit ApprovalRevoked(msg.sender, _txnId);
  }

  /// @dev Allows anyone to execute a approved transaction.
  /// @param _txnId transaction ID.
  /// @return success wether it's success
  function executeTransaction(uint256 _txnId) public
    isOwner(msg.sender)
    approved(_txnId, msg.sender)
    notExecuted(_txnId)
    returns (bool success)
  {
    if (isConfirmed(_txnId)) {
      Transaction storage txn = transactions[_txnId];
      success = execute(txn.operation, txn.target, txn.value, txn.data, (gasleft() - 2500));
      if (success) {
        txn.executed = true;
        emit TransactionExecuted(_txnId);
      } else {
        txn.executed = false;
        emit ExecutionFailed(_txnId);
      }
    }
  }

  /// @dev Returns the confirmation status of a transaction.
  /// @param _txnId transaction ID.
  /// @return status confirmation status.
  function isConfirmed(uint _txnId) public view returns (bool status) {
    status = transactions[_txnId].approval >= getThreshold();
  }

  /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
  /// @param operation external call operation
  /// @param target transaction destination address
  /// @param value transaction value in Wei.
  /// @param data transaction data payload.
  /// @return txnId returns transaction ID.
  function _addTransaction(
    Types.Operation operation, 
    address target, 
    uint256 value, 
    bytes memory data
  ) internal
    isValid(target)
    returns (uint txnId)
  {
    txnId = transactionCount++;
    transactions[txnId] = Transaction({
      operation: operation,
      target: target,
      value: value,
      data: data,
      approval: 0,
      executed: false
    });
    
    emit TransactionSubmitted(txnId);
  }

  /// @dev Returns number of approvals of a transaction.
  /// @param _txnId transaction ID.
  /// @return count Number of approvals.
  function getApprovalCount(uint _txnId) external view returns (uint8 count) {
    count = transactions[_txnId].approval;
  }

  /// @dev Returns total number of transactions which filers are applied.
  /// @param _pending Include pending transactions.
  /// @param _executed Include executed transactions.
  /// @return count Total number of transactions after filters are applied.
  function getTransactionCount(bool _pending, bool _executed) external view returns (uint256 count)
  {
    for (uint256 i=0; i<transactionCount; i++)
      if (_pending && !transactions[i].executed || _executed && transactions[i].executed)
        count++;
  }

  modifier hasTransaction(uint256 _txnId) {
    require(_txnId < transactionCount, "transaction is not exist");
    _;
  }

  modifier approved(uint256 _txnId, address _owner) {
    require(approvals[_txnId][_owner], "not been approved by this owner");
    _;
  }

  modifier notApproved(uint256 _txnId, address _owner) {
    require(!approvals[_txnId][_owner], "has been approved by this owner");
    _;
  }

  modifier notExecuted(uint256 _txnId) {
    require(!transactions[_txnId].executed, "transaction is executed");
    _;
  }

  modifier isValid(address _address) {
    require(_address != address(0), "this address is zero address");
    _;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Types {
  enum Operation {Call, DelegateCall}
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "../utils/SelfAuthorized.sol";

abstract contract OwnerManager is SelfAuthorized {
  event AddedOwner(address owner);
  event RemovedOwner(address owner);
  event ChangedThreshold(uint8 threshold);

  address internal constant SENTINEL_OWNERS = address(0x1);
  mapping(address => address) internal owners;
  uint256 internal ownerCount;
  uint8 internal threshold;

  function setupOwners(address[] memory _owners, uint8 _threshold) internal {
    require(threshold == 0, "can only be called once");
    require(_threshold <= _owners.length, "threshold is more than owners");
    require(_threshold >= 1, "at least one owner");
    address currentOwner = SENTINEL_OWNERS;
    for(uint i=0; i<_owners.length; i++) {
      address owner = _owners[i];
      require(owner != address(0) && owner != address(this) && owner != currentOwner && owner != SENTINEL_OWNERS, "not allowed owner address");
      require(owners[owner] == address(0), "duplicate owner address");
      owners[currentOwner] = owner;
      currentOwner = owner;
    }
    owners[currentOwner] = SENTINEL_OWNERS;
    ownerCount = _owners.length;
    threshold = _threshold;
  } 

  function addOwnerWithThreshold(address owner, uint8 _threshold) public authorized {
    require(owner != address(0) && owner != address(this) && owner != SENTINEL_OWNERS, "not allowed owner address");
    require(owners[owner] == address(0), "duplicate owner address");
    owners[owner] = owners[SENTINEL_OWNERS];
    owners[SENTINEL_OWNERS] = owner;
    ownerCount++;
    emit AddedOwner(owner);

    if(threshold != _threshold) changeThreshold(_threshold);
  }

  function removeOwnerWithThreshold(address prevOwner, address owner, uint8 _threshold) internal authorized {
    require(ownerCount - 1 >= _threshold, "threshold can not be reached");
    require(owner != address(0) && owner != SENTINEL_OWNERS, "invalid owner address");
    require(owners[prevOwner] == owner, "not correspond to the owner");
    owners[prevOwner] = owners[owner];
    owners[owner] = address(0);
    ownerCount--;
    emit RemovedOwner(owner);

    if(threshold != _threshold) changeThreshold(_threshold);
  }

  function swapOwner(address prevOwner, address oldOwner, address newOwner) public authorized {
    require(newOwner != address(0) && newOwner != address(this) && newOwner != SENTINEL_OWNERS, "invalid new owner address");
    require(owners[newOwner] == address(0), "duplicate owner address");
    require(oldOwner != address(0) && oldOwner != SENTINEL_OWNERS, "invalid old owner address");
    require(owners[prevOwner] == oldOwner, "not correspond to the oldOwner");
    owners[newOwner] = owners[oldOwner];
    owners[prevOwner] = newOwner;
    owners[oldOwner] = address(0);
    emit RemovedOwner(oldOwner);
    emit AddedOwner(newOwner);
  }

  function changeThreshold(uint8 _threshold) public authorized {
    require(_threshold <= ownerCount, "threshold is more than owners");
    require(_threshold >= 1, "at least one owner");
    threshold = _threshold;
    emit ChangedThreshold(_threshold);
  }

  function getThreshold() public view returns (uint8) {
    return threshold;
  }

  function checkOwner(address owner) public view returns (bool) {
    return owner != SENTINEL_OWNERS && owners[owner] != address(0);
  }

  function getOwners() public view returns (address[] memory) {
    address[] memory _owners = new address[](ownerCount);

    address currentOwner = owners[SENTINEL_OWNERS];
    for(uint i=0; i<ownerCount; i++) {
      _owners[i] = currentOwner;
      currentOwner = owners[currentOwner];
    }
    return _owners;
  }

  modifier notOwner(address _owner) {
    require(!checkOwner(_owner), "is one of the owners");
    _;
  }

  modifier isOwner(address _owner) {
    require(checkOwner(_owner), "is not one of the owners");
    _;
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../utils/Types.sol";

abstract contract Executor {
  function execute(
    Types.Operation operation,
    address target,
    uint256 value,
    bytes memory data,
    uint256 txGas
  ) internal returns (bool success) {
    if(operation == Types.Operation.Call) {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        success := call(txGas, target, value, add(data, 0x20), mload(data), 0, 0)
      }
    } else {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        success :=delegatecall(txGas, target, add(data, 0x20), mload(data), 0, 0)
      }
    }
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";

abstract contract TokensHandler is IERC165, IERC1155Receiver, IERC721Receiver, IERC777Recipient {
  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    return 0xf23a6e61;
  }

  function onERC1155BatchReceived(
    address,
    address,
    uint256[] calldata,
    uint256[] calldata,
    bytes calldata
  ) external pure override returns (bytes4) {
    return 0xbc197c81;
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    return 0x150b7a02;
  }

  // solhint-disable no-empty-blocks
  function tokensReceived(
    address,
    address,
    address,
    uint256,
    bytes calldata,
    bytes calldata
  ) external pure override {
    // We implement this for completeness, doesn't really have any value
  }

  function supportsInterface(bytes4 interfaceId) external view virtual override returns (bool) {
    return
      interfaceId == type(IERC1155Receiver).interfaceId ||
      interfaceId == type(IERC721Receiver).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

abstract contract SelfAuthorized {
  function _selfCall() private view {
    require(msg.sender == address(this), "required self call");
  }

  modifier authorized() {
    _selfCall();
    _;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Recipient.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777Recipient {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}