/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/**
 * Contract that exposes the needed erc20 token functions
 */

abstract contract ERC20Interface {
  // Send _value amount of tokens to address _to
  function transfer(address _to, uint256 _value)
    public
    virtual
    returns (bool success);

  // Get the account balance of another account with address _owner
  function balanceOf(address _owner)
    public
    virtual
    view
    returns (uint256 balance);
}
/**
 *
 * Batcher
 * =======
 *
 * Contract that can take a batch of transfers, presented in the form of a recipients array and a values array, and
 * funnel off those funds to the correct accounts in a single transaction. This is useful for saving on gas when a
 * bunch of funds need to be transferred to different accounts.
 *
 * If more ETH is sent to `batch` than it is instructed to transfer, contact the contract owner in order to recover the excess.
 * If any tokens are accidentally transferred to this account, contact the contract owner in order to recover them.
 *
 */

contract Batcher {
  event BatchTransfer(address sender, address recipient, uint256 value);
  event OwnerChange(address prevOwner, address newOwner);
  event TransferGasLimitChange(
    uint256 prevTransferGasLimit,
    uint256 newTransferGasLimit
  );

  address public owner;
  uint256 public lockCounter;
  uint256 public transferGasLimit;

  constructor() {
    lockCounter = 1;
    owner = msg.sender;
    emit OwnerChange(address(0), owner);
    transferGasLimit = 20000;
    emit TransferGasLimitChange(0, transferGasLimit);
  }

  modifier lockCall() {
    lockCounter++;
    uint256 localCounter = lockCounter;
    _;
    require(localCounter == lockCounter, 'Reentrancy attempt detected');
  }

  modifier onlyOwner() {
    require(msg.sender == owner, 'Not owner');
    _;
  }

  /**
   * Transfer funds in a batch to each of recipients
   * @param recipients The list of recipients to send to
   * @param values The list of values to send to recipients.
   *  The recipient with index i in recipients array will be sent values[i].
   *  Thus, recipients and values must be the same length
   */
  function batch(address[] calldata recipients, uint256[] calldata values)
    external
    payable
    lockCall
  {
    require(recipients.length != 0, 'Must send to at least one person');
    require(
      recipients.length == values.length,
      'Unequal recipients and values'
    );
    require(recipients.length < 256, 'Too many recipients');

    // Try to send all given amounts to all given recipients
    // Revert everything if any transfer fails
    for (uint8 i = 0; i < recipients.length; i++) {
      require(recipients[i] != address(0), 'Invalid recipient address');
      (bool success, ) = recipients[i].call{
        value: values[i],
        gas: transferGasLimit
      }('');
      require(success, 'Send failed');
      emit BatchTransfer(msg.sender, recipients[i], values[i]);
    }
  }

  /**
   * Recovery function for the contract owner to recover any ERC20 tokens or ETH that may get lost in the control of this contract.
   * @param to The recipient to send to
   * @param value The ETH value to send with the call
   * @param data The data to send along with the call
   */
  function recover(
    address to,
    uint256 value,
    bytes calldata data
  ) external onlyOwner returns (bytes memory) {
    (bool success, bytes memory returnData) = to.call{ value: value }(data);
    require(success, 'Recover failed');
    return returnData;
  }

  /**
   * Transfers ownership of the contract ot the new owner
   * @param newOwner The address to transfer ownership of the contract to
   */
  function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0), 'Invalid new owner');
    emit OwnerChange(owner, newOwner);
    owner = newOwner;
  }

  /**
   * Change the gas limit that is sent along with batched transfers.
   * This is intended to protect against any EVM level changes that would require
   * a new amount of gas for an internal send to complete.
   * @param newTransferGasLimit The new gas limit to send along with batched transfers
   */
  function changeTransferGasLimit(uint256 newTransferGasLimit)
    external
    onlyOwner
  {
    require(newTransferGasLimit >= 2300, 'Transfer gas limit too low');
    emit TransferGasLimitChange(transferGasLimit, newTransferGasLimit);
    transferGasLimit = newTransferGasLimit;
  }

  fallback() external payable {
    revert('Invalid fallback');
  }

  receive() external payable {
    revert('Invalid receive');
  }
}

library TransferHelper {
  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(0xa9059cbb, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeTransfer: transfer failed'
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    (bool success, bytes memory returndata) = token.call(
      abi.encodeWithSelector(0x23b872dd, from, to, value)
    );
    Address.verifyCallResult(
      success,
      returndata,
      'TransferHelper::transferFrom: transferFrom failed'
    );
  }
}

contract WalletSimple  {
  // Events
  event Deposited(address from, uint256 value, bytes data);
  event SafeModeActivated(address msgSender);
  event Transacted(
    address msgSender, // Address of the sender of the message initiating the transaction
    address otherSigner, // Address of the signer (second signature) used to initiate the transaction
    bytes32 operation, // Operation hash (see Data Formats)
    address toAddress, // The address the transaction was sent to
    uint256 value, // Amount of Wei sent to the address
    bytes data // Data sent when invoking the transaction
  );

  event BatchTransfer(address sender, address recipient, uint256 value);
  // this event shows the other signer and the operation hash that they signed
  // specific batch transfer events are emitted in Batcher
  event BatchTransacted(
    address msgSender, // Address of the sender of the message initiating the transaction
    address otherSigner, // Address of the signer (second signature) used to initiate the transaction
    bytes32 operation // Operation hash (see Data Formats)
  );

  // Public fields
  mapping(address => bool) public signers; // The addresses that can co-sign transactions on the wallet
  bool public safeMode = false; // When active, wallet may only send to signer addresses
  bool public initialized = false; // True if the contract has been initialized

  // Internal fields
  uint256 private constant MAX_SEQUENCE_ID_INCREASE = 10000;
  uint256 constant SEQUENCE_ID_WINDOW_SIZE = 10;
  uint256[SEQUENCE_ID_WINDOW_SIZE] recentSequenceIds;

  /**
   * Set up a simple multi-sig wallet by specifying the signers allowed to be used on this wallet.
   * 2 signers will be required to send a transaction from this wallet.
   * Note: The sender is NOT automatically added to the list of signers.
   * Signers CANNOT be changed once they are set
   *
   * @param allowedSigners An array of signers on the wallet
   */
  function init(address[] calldata allowedSigners) external onlyUninitialized {
    require(allowedSigners.length == 3, 'Invalid number of signers');

    for (uint8 i = 0; i < allowedSigners.length; i++) {
      require(allowedSigners[i] != address(0), 'Invalid signer');
      signers[allowedSigners[i]] = true;
    }

    initialized = true;
  }

  /**
   * Get the network identifier that signers must sign over
   * This provides protection signatures being replayed on other chains
   * This must be a virtual function because chain-specific contracts will need
   *    to override with their own network ids. It also can't be a field
   *    to allow this contract to be used by proxy with delegatecall, which will
   *    not pick up on state variables
   */
  function getNetworkId() internal virtual pure returns (string memory) {
    return '56';
  }

  /**
   * Get the network identifier that signers must sign over for token transfers
   * This provides protection signatures being replayed on other chains
   * This must be a virtual function because chain-specific contracts will need
   *    to override with their own network ids. It also can't be a field
   *    to allow this contract to be used by proxy with delegatecall, which will
   *    not pick up on state variables
   */
  function getTokenNetworkId() internal virtual pure returns (string memory) {
    return 'BEP20';
  }

  /**
   * Get the network identifier that signers must sign over for batch transfers
   * This provides protection signatures being replayed on other chains
   * This must be a virtual function because chain-specific contracts will need
   *    to override with their own network ids. It also can't be a field
   *    to allow this contract to be used by proxy with delegatecall, which will
   *    not pick up on state variables
   */
  function getBatchNetworkId() internal virtual pure returns (string memory) {
    return 'BNB-Batch';
  }

  /**
   * Determine if an address is a signer on this wallet
   * @param signer address to check
   * returns boolean indicating whether address is signer or not
   */
  function isSigner(address signer) public view returns (bool) {
    return signers[signer];
  }

  /**
   * Modifier that will execute internal code block only if the sender is an authorized signer on this wallet
   */
  modifier onlySigner {
    require(isSigner(msg.sender), 'Non-signer in onlySigner method');
    _;
  }

  /**
   * Modifier that will execute internal code block only if the contract has not been initialized yet
   */
  modifier onlyUninitialized {
    require(!initialized, 'Contract already initialized');
    _;
  }

  /**
   * Gets called when a transaction is received with data that does not match any other method
   */
  fallback() external payable {
    if (msg.value > 0) {
      // Fire deposited event if we are receiving funds
      emit Deposited(msg.sender, msg.value, msg.data);
    }
  }

  /**
   * Gets called when a transaction is received with ether and no data
   */
  receive() external payable {
    if (msg.value > 0) {
      // Fire deposited event if we are receiving funds
      // message data is always empty for receive. If there is data it is sent to fallback function.
      emit Deposited(msg.sender, msg.value, '');
    }
  }

  /**
   * Execute a multi-signature transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
   * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
   *
   * @param toAddress the destination address to send an outgoing transaction
   * @param value the amount in Wei to be sent
   * @param data the data to send to the toAddress when invoking the transaction
   * @param expireTime the number of seconds since 1970 for which this transaction is valid
   * @param sequenceId the unique sequence id obtainable from getNextSequenceId
   * @param signature see Data Formats
   */
  function sendMultiSig(
    address toAddress,
    uint256 value,
    bytes calldata data,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {
    // Verify the other signer
    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getNetworkId(),
        toAddress,
        value,
        data,
        expireTime,
        sequenceId
      )
    );

    address otherSigner = verifyMultiSig(
      toAddress,
      operationHash,
      signature,
      expireTime,
      sequenceId
    );

    // Success, send the transaction
    (bool success, ) = toAddress.call{ value: value }(data);
    require(success, 'Call execution failed');

    emit Transacted(
      msg.sender,
      otherSigner,
      operationHash,
      toAddress,
      value,
      data
    );
  }

  /**
   * Execute a batched multi-signature transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
   * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
   * The recipients and values to send are encoded in two arrays, where for index i, recipients[i] will be sent values[i].
   *
   * @param recipients The list of recipients to send to
   * @param values The list of values to send to
   * @param expireTime the number of seconds since 1970 for which this transaction is valid
   * @param sequenceId the unique sequence id obtainable from getNextSequenceId
   * @param signature see Data Formats
   */
  function sendMultiSigBatch(
    address[] calldata recipients,
    uint256[] calldata values,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {
    require(recipients.length != 0, 'Not enough recipients');
    require(
      recipients.length == values.length,
      'Unequal recipients and values'
    );
    require(recipients.length < 256, 'Too many recipients, max 255');

    // Verify the other signer
    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getBatchNetworkId(),
        recipients,
        values,
        expireTime,
        sequenceId
      )
    );

    // the first parameter (toAddress) is used to ensure transactions in safe mode only go to a signer
    // if in safe mode, we should use normal sendMultiSig to recover, so this check will always fail if in safe mode
    require(!safeMode, 'Batch in safe mode');
    address otherSigner = verifyMultiSig(
      address(0x0),
      operationHash,
      signature,
      expireTime,
      sequenceId
    );

    batchTransfer(recipients, values);
    emit BatchTransacted(msg.sender, otherSigner, operationHash);
  }

  /**
   * Transfer funds in a batch to each of recipients
   * @param recipients The list of recipients to send to
   * @param values The list of values to send to recipients.
   *  The recipient with index i in recipients array will be sent values[i].
   *  Thus, recipients and values must be the same length
   */
  function batchTransfer(
    address[] calldata recipients,
    uint256[] calldata values
  ) internal {
    for (uint256 i = 0; i < recipients.length; i++) {
      require(address(this).balance >= values[i], 'Insufficient funds');

      (bool success, ) = recipients[i].call{ value: values[i] }('');
      require(success, 'Call failed');

      emit BatchTransfer(msg.sender, recipients[i], values[i]);
    }
  }

  /**
   * Execute a multi-signature token transfer from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
   * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
   *
   * @param toAddress the destination address to send an outgoing transaction
   * @param value the amount in tokens to be sent
   * @param tokenContractAddress the address of the erc20 token contract
   * @param expireTime the number of seconds since 1970 for which this transaction is valid
   * @param sequenceId the unique sequence id obtainable from getNextSequenceId
   * @param signature see Data Formats
   */
  function sendMultiSigToken(
    address toAddress,
    uint256 value,
    address tokenContractAddress,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {
    // Verify the other signer
    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getTokenNetworkId(),
        toAddress,
        value,
        tokenContractAddress,
        expireTime,
        sequenceId
      )
    );

    verifyMultiSig(toAddress, operationHash, signature, expireTime, sequenceId);

    TransferHelper.safeTransfer(tokenContractAddress, toAddress, value);
  }

  

  /**
   * Do common multisig verification for both eth sends and erc20token transfers
   *
   * @param toAddress the destination address to send an outgoing transaction
   * @param operationHash see Data Formats
   * @param signature see Data Formats
   * @param expireTime the number of seconds since 1970 for which this transaction is valid
   * @param sequenceId the unique sequence id obtainable from getNextSequenceId
   * returns address that has created the signature
   */
  function verifyMultiSig(
    address toAddress,
    bytes32 operationHash,
    bytes calldata signature,
    uint256 expireTime,
    uint256 sequenceId
  ) private returns (address) {
    address otherSigner = recoverAddressFromSignature(operationHash, signature);

    // Verify if we are in safe mode. In safe mode, the wallet can only send to signers
    require(!safeMode || isSigner(toAddress), 'External transfer in safe mode');

    // Verify that the transaction has not expired
    require(expireTime >= block.timestamp, 'Transaction expired');

    // Try to insert the sequence ID. Will revert if the sequence id was invalid
    tryInsertSequenceId(sequenceId);

    require(isSigner(otherSigner), 'Invalid signer');

    require(otherSigner != msg.sender, 'Signers cannot be equal');

    return otherSigner;
  }

  /**
   * Irrevocably puts contract into safe mode. When in this mode, transactions may only be sent to signing addresses.
   */
  function activateSafeMode() external onlySigner {
    safeMode = true;
    emit SafeModeActivated(msg.sender);
  }

  /**
   * Gets signer's address using ecrecover
   * @param operationHash see Data Formats
   * @param signature see Data Formats
   * returns address recovered from the signature
   */
  function recoverAddressFromSignature(
    bytes32 operationHash,
    bytes memory signature
  ) private pure returns (address) {
    require(signature.length == 65, 'Invalid signature - wrong length');

    // We need to unpack the signature, which is given as an array of 65 bytes (like eth.sign)
    bytes32 r;
    bytes32 s;
    uint8 v;

    // solhint-disable-next-line
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := and(mload(add(signature, 65)), 255)
    }
    if (v < 27) {
      v += 27; // Ethereum versions are 27 or 28 as opposed to 0 or 1 which is submitted by some signing libs
    }

    // protect against signature malleability
    // S value must be in the lower half orader
    // reference: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/051d340171a93a3d401aaaea46b4b62fa81e5d7c/contracts/cryptography/ECDSA.sol#L53
    require(
      uint256(s) <=
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
      "ECDSA: invalid signature 's' value"
    );

    // note that this returns 0 if the signature is invalid
    // Since 0x0 can never be a signer, when the recovered signer address
    // is checked against our signer list, that 0x0 will cause an invalid signer failure
    return ecrecover(operationHash, v, r, s);
  }

  /**
   * Verify that the sequence id has not been used before and inserts it. Throws if the sequence ID was not accepted.
   * We collect a window of up to 10 recent sequence ids, and allow any sequence id that is not in the window and
   * greater than the minimum element in the window.
   * @param sequenceId to insert into array of stored ids
   */
  function tryInsertSequenceId(uint256 sequenceId) private onlySigner {
    // Keep a pointer to the lowest value element in the window
    uint256 lowestValueIndex = 0;
    // fetch recentSequenceIds into memory for function context to avoid unnecessary sloads


      uint256[SEQUENCE_ID_WINDOW_SIZE] memory _recentSequenceIds
     = recentSequenceIds;
    for (uint256 i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
      require(_recentSequenceIds[i] != sequenceId, 'Sequence ID already used');

      if (_recentSequenceIds[i] < _recentSequenceIds[lowestValueIndex]) {
        lowestValueIndex = i;
      }
    }

    // The sequence ID being used is lower than the lowest value in the window
    // so we cannot accept it as it may have been used before
    require(
      sequenceId > _recentSequenceIds[lowestValueIndex],
      'Sequence ID below window'
    );

    // Block sequence IDs which are much higher than the lowest value
    // This prevents people blocking the contract by using very large sequence IDs quickly
    require(
      sequenceId <=
        (_recentSequenceIds[lowestValueIndex] + MAX_SEQUENCE_ID_INCREASE),
      'Sequence ID above maximum'
    );

    recentSequenceIds[lowestValueIndex] = sequenceId;
  }

  /**
   * Gets the next available sequence ID for signing when using executeAndConfirm
   * returns the sequenceId one higher than the highest currently stored
   */
  function getNextSequenceId() external view returns (uint256) {
    uint256 highestSequenceId = 0;
    for (uint256 i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
      if (recentSequenceIds[i] > highestSequenceId) {
        highestSequenceId = recentSequenceIds[i];
      }
    }
    return highestSequenceId + 1;
  }
}