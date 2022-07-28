// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "../common/System.sol";
import "./interface/IGovernmentHub.sol";

contract PositionAdmin is Context, System, Initializable {
    using SafeCast for uint256;
    using Timers for Timers.BlockNumber;

    // TODO config: quorum
    uint256 private _quorum = 3;

    struct TransactionCore {
        Timers.BlockNumber startTime;
        // executed time or canceled time of transaction
        Timers.BlockNumber executedTime;
        // number of confirmation from signers, need to reach quorum to execute transaction
        uint256 confirmations;
        bool executed;
        bool canceled;
    }

    // Mapping of signer address to active status
    mapping(address => bool) private _signers;
    mapping(uint256 => TransactionCore) private _transactions;

    /**
     * @dev Restrict access to governor executing address. Some module might override the _executor function to make
     * sure this modifier is consistant with the execution model.
     */
    modifier onlySigner() {
        require(_signers[_msgSender()], "PositionAdmin: onlySigner");
        _;
    }

    event TransactionCreated(
        uint256 transactionId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startTime,
        string description
    );

    event TransactionExecuted(
        address executor,
        uint256 transactionId
    );

    event TransactionCanceled(
        address canceler,
        uint256 transactionId
    );

    event TransactionConfirmed(
        address signer,
        uint256 transactionId
    );

    function initialize() public initializer {
        // TODO config: update signer address
        _signers[0x46457e8098ACC53e353b3802746f075314fD1029] = true;
        _signers[0x46457e8098ACC53e353b3802746f075314fD1029] = true;
        _signers[0x46457e8098ACC53e353b3802746f075314fD1029] = true;
        _signers[0x46457e8098ACC53e353b3802746f075314fD1029] = true;
        _signers[0x46457e8098ACC53e353b3802746f075314fD1029] = true;
        _signers[0x46457e8098ACC53e353b3802746f075314fD1029] = true;
        _signers[0x46457e8098ACC53e353b3802746f075314fD1029] = true;
    }

    /**
     * Create new transaction and waiting for confirmations
     *
     * @param _targets      The target contract addresses need to execute transaction
     * @param _values       Value of transaction
     * @param _calldatas    Calldatas of transaction
     * @param _description  Description of transaction
    */
    function createTransaction(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        string memory _description
    ) external onlySigner returns (uint256) {

        uint256 transactionId = hashTransaction(_targets, _values, _calldatas, keccak256(bytes(_description)));

        require(_targets.length == _values.length, "PositionAdmin: invalid transaction length");
        require(_targets.length == _calldatas.length, "PositionAdmin: invalid transaction length");
        require(_targets.length > 0, "PositionAdmin: empty proposal");

        TransactionCore storage transaction = _transactions[transactionId];

        require(transaction.startTime.isUnset(), "PositionAdmin: transaction already exists");

        uint64 _startTime = block.number.toUint64();
        transaction.startTime.setDeadline(_startTime);

        emit TransactionCreated(
            transactionId,
            _msgSender(),
            _targets,
            _values,
            new string[](_targets.length),
            _calldatas,
            _startTime,
            _description
        );

        return transactionId;
    }

    /**
     * Execute a pending transaction after have enough confirmations from signer
     *
     * @param _targets      The target contract addresses need to execute transaction
     * @param _values       Value of transaction
     * @param _calldatas    Calldatas of transaction
     * @param _description  Description of transaction
    */
    function executeTransaction(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        string memory _description
    ) external payable onlySigner {
        uint256 transactionId = hashTransaction(_targets, _values, _calldatas, keccak256(bytes(_description)));

        TransactionCore memory memTransaction = _transactions[transactionId];

        require(!_transactionExecutedOrCanceled(memTransaction), "PositionAdmin: transaction already executed or canceled");
        require(_quorumReached(memTransaction), "PositionAdmin: not reached quorum");

        TransactionCore storage stoTransaction = _transactions[transactionId];

        stoTransaction.executed = true;
        stoTransaction.executedTime.setDeadline(block.number.toUint64());

        IGovernmentHub(GOVERNANCE_HUB_ADDR).executeTransaction(
            _targets,
            _values,
            _calldatas,
            _description
        );

        emit TransactionExecuted(
            _msgSender(),
            transactionId
        );
    }

    /**
     * Cancel a pending transaction
     *
     * @param _targets      The target contract addresses need to execute transaction
     * @param _values       Value of transaction
     * @param _calldatas    Calldatas of transaction
     * @param _description  Description of transaction
    */
    function cancelTransaction(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        string memory _description
    ) external payable onlySigner {
        uint256 transactionId = hashTransaction(_targets, _values, _calldatas, keccak256(bytes(_description)));

        TransactionCore memory memTransaction = _transactions[transactionId];

        require(!_transactionExecutedOrCanceled(memTransaction), "PositionAdmin: transaction already executed or canceled");

        TransactionCore storage stoTransaction = _transactions[transactionId];

        stoTransaction.canceled = true;
        stoTransaction.executedTime.setDeadline(block.number.toUint64());

        emit TransactionCanceled(
            _msgSender(),
            transactionId
        );
    }

    /**
     * Signer confirm a transaction
     *
     * @param _transactionId   Transaction id of a pending transaction
    */
    function confirmTransaction(
        uint256 _transactionId
    ) external payable onlySigner {
        TransactionCore memory memTransaction = _transactions[_transactionId];

        require(!_transactionExecutedOrCanceled(memTransaction), "PositionAdmin: transaction already executed or canceled");

        _transactions[_transactionId].confirmations += 1;

        emit TransactionConfirmed(
            _msgSender(),
            _transactionId
        );
    }

    function hashTransaction(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        bytes32 _descriptionHash
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(_targets, _values, _calldatas, _descriptionHash)));
    }

    function _quorumReached(TransactionCore memory _transaction) internal view returns (bool) {
        return _transaction.confirmations >= _quorum;
    }

    function _transactionExecutedOrCanceled(TransactionCore memory _transaction) internal view returns (bool) {
        return _transaction.executed || _transaction.canceled;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Tooling for timepoints, timers and delays
 */
library Timers {
    struct Timestamp {
        uint64 _deadline;
    }

    function getDeadline(Timestamp memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(Timestamp storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(Timestamp storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(Timestamp memory timer) internal view returns (bool) {
        return timer._deadline > block.timestamp;
    }

    function isExpired(Timestamp memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.timestamp;
    }

    struct BlockNumber {
        uint64 _deadline;
    }

    function getDeadline(BlockNumber memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(BlockNumber storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(BlockNumber storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(BlockNumber memory timer) internal view returns (bool) {
        return timer._deadline > block.number;
    }

    function isExpired(BlockNumber memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.number;
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

abstract contract System {

    bool public alreadyInit;

    // TODO CHANGE GENESIS ADDRESS
    address public POSITION_ADMIN_ADDR = 0x0000000000000000000000000000000000001001;
    address public GOVERNANCE_HUB_ADDR = 0x0000000000000000000000000000000000001002;
    address public SYSTEM_REWARD_ADDR = 0x0000000000000000000000000000000000001003;
    address public RELAYER_HUB_ADDR = 0x0000000000000000000000000000000000001004;
    address public RELAYER_INCENTIVE_ADDR = 0x0000000000000000000000000000000000001005;

    // NOTE: only init those two address on Posi chain
    address public TOKEN_HUB_ADDR = 0x0000000000000000000000000000000000001006;
    address public CROSS_CHAIN_ADDR = 0x0000000000000000000000000000000000001007;

    modifier onlyPositionAdmin() {
        require(
            msg.sender == POSITION_ADMIN_ADDR,
            "Only Position Admin Address"
        );
        _;
    }

    modifier onlyGovernmentHub() {
        require(
            msg.sender == GOVERNANCE_HUB_ADDR,
            "Only Governance Hub Contract"
        );
        _;
    }

    modifier onlySystemReward() {
        require(
            msg.sender == SYSTEM_REWARD_ADDR,
            "Only System Reward Contract"
        );
        _;
    }

    modifier onlyRelayerHub() {
        require(
            msg.sender == RELAYER_HUB_ADDR,
            "Only Relayer Hub Contract"
        );
        _;
    }

    modifier onlyRelayerIncentive() {
        require(
            msg.sender == RELAYER_INCENTIVE_ADDR,
            "Only Relayer Incentive Contract"
        );
        _;
    }

    modifier onlyTokenHub() {
        require(
            msg.sender == TOKEN_HUB_ADDR,
            "Only Token Hub Contract"
        );
        _;
    }

    modifier onlyCrosschain() {
        require(
            msg.sender == CROSS_CHAIN_ADDR,
            "Only Cross-chain Contract"
        );
        _;
    }

    function updateContractAddress(
        address _POSITION_ADMIN_ADDR,
        address _GOVERNANCE_HUB_ADDR,
        address _SYSTEM_REWARD_ADDR,
        address _RELAYER_HUB_ADDR,
        address _RELAYER_INCENTIVE_ADDR,
        address _TOKEN_HUB_ADDR,
        address _CROSS_CHAIN_ADDR
    ) external {
         POSITION_ADMIN_ADDR = _POSITION_ADMIN_ADDR;
         GOVERNANCE_HUB_ADDR = _GOVERNANCE_HUB_ADDR;
         SYSTEM_REWARD_ADDR = _SYSTEM_REWARD_ADDR;
         RELAYER_HUB_ADDR = _RELAYER_HUB_ADDR;
         RELAYER_INCENTIVE_ADDR = _RELAYER_INCENTIVE_ADDR;
         TOKEN_HUB_ADDR = _TOKEN_HUB_ADDR;
         CROSS_CHAIN_ADDR = _CROSS_CHAIN_ADDR;
    }
}

pragma solidity ^0.8.0;

interface IGovernmentHub {
    /**
     * Execute transaction
     *
     * @param _targets      The target contract addresses need to execute transaction
     * @param _values       Value of transaction
     * @param _calldatas    Calldatas of transaction
     * @param _description  Description of transaction
    */
    function executeTransaction(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        string memory _description
    ) external;
}