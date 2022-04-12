/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

pragma solidity >=0.8.0;

/// @title DynamicBuffer
/// @author David Huber (@cxkoda) and Simon Fremaux (@dievardump). See also
///         https://raw.githubusercontent.com/dievardump/solidity-dynamic-buffer
/// @notice This library is used to allocate a big amount of container memory
//          which will be subsequently filled without needing to reallocate
///         memory.
/// @dev First, allocate memory.
///      Then use `buffer.appendUnchecked(theBytes)` or `appendSafe()` if
///      bounds checking is required.
library DynamicBuffer {
    /// @notice Allocates container space for the DynamicBuffer
    /// @param capacity The intended max amount of bytes in the buffer
    /// @return buffer The memory location of the buffer
    /// @dev Allocates `capacity + 0x60` bytes of space
    ///      The buffer array starts at the first container data position,
    ///      (i.e. `buffer = container + 0x20`)
    function allocate(uint256 capacity) internal pure returns (bytes memory buffer) {
        assembly {
            // Get next-free memory address
            let container := mload(0x40)

            // Allocate memory by setting a new next-free address
            {
                // Add 2 x 32 bytes in size for the two length fields
                // Add 32 bytes safety space for 32B chunked copy
                let size := add(capacity, 0x60)
                let newNextFree := add(container, size)
                mstore(0x40, newNextFree)
            }

            // Set the correct container length
            {
                let length := add(capacity, 0x40)
                mstore(container, length)
            }

            // The buffer starts at idx 1 in the container (0 is length)
            buffer := add(container, 0x20)

            // Init content with length 0
            mstore(buffer, 0)
        }

        return buffer;
    }

    /// @notice Appends data to buffer, and update buffer length
    /// @param buffer the buffer to append the data to
    /// @param data the data to append
    /// @dev Does not perform out-of-bound checks (container capacity)
    ///      for efficiency.
    function appendUnchecked(bytes memory buffer, bytes memory data) internal pure {
        assembly {
            let length := mload(data)
            for {
                data := add(data, 0x20)
                let dataEnd := add(data, length)
                let copyTo := add(buffer, add(mload(buffer), 0x20))
            } lt(data, dataEnd) {
                data := add(data, 0x20)
                copyTo := add(copyTo, 0x20)
            } {
                // Copy 32B chunks from data to buffer.
                // This may read over data array boundaries and copy invalid
                // bytes, which doesn't matter in the end since we will
                // later set the correct buffer length, and have allocated an
                // additional word to avoid buffer overflow.
                mstore(copyTo, mload(data))
            }

            // Update buffer length
            mstore(buffer, add(mload(buffer), length))
        }
    }

    /// @notice Appends data to buffer, and update buffer length
    /// @param buffer the buffer to append the data to
    /// @param data the data to append
    /// @dev Performs out-of-bound checks and calls `appendUnchecked`.
    function appendSafe(bytes memory buffer, bytes memory data) internal pure {
        uint256 capacity;
        uint256 length;
        assembly {
            capacity := sub(mload(sub(buffer, 0x20)), 0x40)
            length := mload(buffer)
        }

        require(length + data.length <= capacity, "DynamicBuffer: Appending out of bounds.");
        appendUnchecked(buffer, data);
    }
}

pragma solidity >=0.6.0;

/// @title Base64
/// @author Brecht Devos - <[email protected]>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

pragma solidity >=0.5.0;

interface ILayerZeroUserApplicationConfig {
    // @notice set the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _configType - type of configuration. every messaging library has its own convention.
    // @param _config - configuration in the bytes. can encode arbitrary content.
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;

    // @notice set the send() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setSendVersion(uint16 _version) external;

    // @notice set the lzReceive() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setReceiveVersion(uint16 _version) external;

    // @notice Only when the UA needs to resume the message flow in blocking mode and clear the stored payload
    // @param _srcChainId - the chainId of the source chain
    // @param _srcAddress - the contract address of the source contract at the source chain
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}

// File: contracts/interfaces/ILayerZeroEndpoint.sol



pragma solidity >=0.5.0;


interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {
    // @notice send a LayerZero message to the specified address at a LayerZero endpoint.
    // @param _dstChainId - the destination chain identifier
    // @param _destination - the address on destination chain (in bytes). address length/format may vary by chains
    // @param _payload - a custom bytes payload to send to the destination contract
    // @param _refundAddress - if the source transaction is cheaper than the amount of value passed, refund the additional amount to this address
    // @param _zroPaymentAddress - the address of the ZRO token holder who would pay for the transaction
    // @param _adapterParams - parameters for custom functionality. e.g. receive airdropped native gas from the relayer on destination
    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;

    // @notice used by the messaging library to publish verified payload
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source contract (as bytes) at the source chain
    // @param _dstAddress - the address on destination chain
    // @param _nonce - the unbound message ordering nonce
    // @param _gasLimit - the gas limit for external contract execution
    // @param _payload - verified payload to send to the destination contract
    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;

    // @notice get the inboundNonce of a receiver from a source chain which could be EVM or non-EVM chain
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);

    // @notice get the outboundNonce from this source chain which, consequently, is always an EVM
    // @param _srcAddress - the source chain contract address
    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);

    // @notice gets a quote in source native gas, for the amount that send() requires to pay for message delivery
    // @param _dstChainId - the destination chain identifier
    // @param _userApplication - the user app address on this EVM chain
    // @param _payload - the custom message to send over LayerZero
    // @param _payInZRO - if false, user app pays the protocol fee in native token
    // @param _adapterParam - parameters for the adapter service, e.g. send some dust native token to dstChain
    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);

    // @notice get this Endpoint's immutable source identifier
    function getChainId() external view returns (uint16);

    // @notice the interface to retry failed message on this Endpoint destination
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    // @param _payload - the payload to be retried
    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;

    // @notice query if any STORED payload (message blocking) at the endpoint.
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);

    // @notice query if the _libraryAddress is valid for sending msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getSendLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the _libraryAddress is valid for receiving msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getReceiveLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the non-reentrancy guard for send() is on
    // @return true if the guard is on. false otherwise
    function isSendingPayload() external view returns (bool);

    // @notice query if the non-reentrancy guard for receive() is on
    // @return true if the guard is on. false otherwise
    function isReceivingPayload() external view returns (bool);

    // @notice get the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _userApplication - the contract address of the user application
    // @param _configType - type of configuration. every messaging library has its own convention.
    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);

    // @notice get the send() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getSendVersion(address _userApplication) external view returns (uint16);

    // @notice get the lzReceive() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getReceiveVersion(address _userApplication) external view returns (uint16);
}

// File: contracts/interfaces/ILayerZeroReceiver.sol



pragma solidity >=0.5.0;

interface ILayerZeroReceiver {
    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination
    // @param _srcChainId - the source endpoint identifier
    // @param _srcAddress - the source sending contract address from the source chain
    // @param _nonce - the ordered message nonce
    // @param _payload - the signed payload is the UA bytes has encoded to be sent
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}
// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


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



pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: contracts/NonblockingReceiver.sol


pragma solidity ^0.8.6;




abstract contract NonblockingReceiver is Ownable, ILayerZeroReceiver {

    ILayerZeroEndpoint internal endpoint;

    struct FailedMessages {
        uint payloadLength;
        bytes32 payloadHash;
    }

    mapping(uint16 => mapping(bytes => mapping(uint => FailedMessages))) public failedMessages;
    mapping(uint16 => bytes) public trustedRemoteLookup;

    event MessageFailed(uint16 _srcChainId, bytes _srcAddress, uint64 _nonce, bytes _payload);

    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) external override {
        require(msg.sender == address(endpoint)); // boilerplate! lzReceive must be called by the endpoint for security
        require(_srcAddress.length == trustedRemoteLookup[_srcChainId].length && keccak256(_srcAddress) == keccak256(trustedRemoteLookup[_srcChainId]),
            "NonblockingReceiver: invalid source sending contract");

        // try-catch all errors/exceptions
        // having failed messages does not block messages passing
        try this.onLzReceive(_srcChainId, _srcAddress, _nonce, _payload) {
            // do nothing
        } catch {
            // error / exception
            failedMessages[_srcChainId][_srcAddress][_nonce] = FailedMessages(_payload.length, keccak256(_payload));
            emit MessageFailed(_srcChainId, _srcAddress, _nonce, _payload);
        }
    }

    function onLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) public {
        // only internal transaction
        require(msg.sender == address(this), "NonblockingReceiver: caller must be Bridge.");

        // handle incoming message
        _LzReceive( _srcChainId, _srcAddress, _nonce, _payload);
    }

    // abstract function
    function _LzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) virtual internal;

    function _lzSend(uint16 _dstChainId, bytes memory _payload, address payable _refundAddress, address _zroPaymentAddress, bytes memory _txParam) internal {
        endpoint.send{value: msg.value}(_dstChainId, trustedRemoteLookup[_dstChainId], _payload, _refundAddress, _zroPaymentAddress, _txParam);
    }

    function retryMessage(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes calldata _payload) external payable {
        // assert there is message to retry
        FailedMessages storage failedMsg = failedMessages[_srcChainId][_srcAddress][_nonce];
        require(failedMsg.payloadHash != bytes32(0), "NonblockingReceiver: no stored message");
        require(_payload.length == failedMsg.payloadLength && keccak256(_payload) == failedMsg.payloadHash, "LayerZero: invalid payload");
        // clear the stored message
        failedMsg.payloadLength = 0;
        failedMsg.payloadHash = bytes32(0);
        // execute the message. revert if it fails again
        this.onLzReceive(_srcChainId, _srcAddress, _nonce, _payload);
    }

    function setTrustedRemote(uint16 _chainId, bytes calldata _trustedRemote) external onlyOwner {
        trustedRemoteLookup[_chainId] = _trustedRemote;
    }
}

// File: contracts/GhostlyGhosts.sol



pragma solidity ^0.8.7;


// 0000KKK0000KKKKKKKKKKKKKKKKKKKKKKKKKKK0KKKKKKKKKKKKKK00000KKKKK0K000000000KKKKKKKK0KKK000KKK000KKKK000KKK00000KK0000000000000000KKKKKKKKKKK000KKKKK000
// 00KKK0000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK00000K0xlloxk000000KKKKKKKKKKK00000KK0000KKKK0000KKK0000K000000KK000000000KKKKKKKKKKK0000KKKK000KK
// KKK0000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK00000KOl.   ..l000KKKKKKKKKKKKKK0KKK00000KKKK00KKKKKKKKK000000KKKK0000000KKKKKKKKKKK0000KKKKKKKKK00
// K0000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK0KKKKKKKKKKKKKK0x;.... .,xKKKKKKKKKKKKK0klcodddddkO0Okkk0KKKKKKKKK00000KKKKKKKKK000KKKKKKKKKK0000KKKKKKKKKK000
// 0000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK0KKKKKKKKKKKKKKK0l.   .. .oKKKKKKKKKKKK0kc'..',,,,,'''....d0KKKKKK0000KKKKKKKKK0000KKKKKKKKKK00000KKKKKKKKK00KKK
// 00KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK0l..;,.    :OKKKKKKKKKKKx,'ccldxxxxd;. ....:k0KKKKKKKKKKKKKKK000000KKKKKKKKK0000KKKKKKKKKKKKKKK00
// KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKO, ,o:'''. .'ck0KOxlcclc'.lxxxxxxxxd:';oxdc,';d0KKKKKKKKKKK0000KKKKKKKKKKKK00KKKKKKKKKKK0KKKKK000
// KKKKKKKKKKKKKKKKKKKKKKKKKKKKKK0000KKKKKKKKKKKKKKKKKKKk' ,dl,.:l:,...:c;;:loo:.,dxxxxxxxxxddxxxxxxo,.lkolok0KKK00000KKKKKKKKKKKKKKKKKKKKKKKKK0KKKK00000
// KKKKKKKKKKKKKKKKKKKKKKKKKKKKK000KKKKKKKKKKKKKKKKKKKKKk, ;xdl;':xxdl'  ,dxxxxc.,dxxxxxxxxxxxxxxxxxxl..... .l00000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK00000KK
// KKKKKKKKKKKKKKKKKKKKKKKKKK0000KKKKKKKKKK0KKKKKKKKKKKK0: 'xOxdl,:xOkxc. 'cdxxc.'oxxxxxxxxxxxxxxxxxo,   .,;.'okk0KKKKKKKKKKKKKKKKKKK00KKKKK000KK00000KKK
// KKKKKKKKKKKKKKKKKKKKKKKK00000KKKKKKKKKK0KKKKKKKKKKKKKKo..ckOkkd,,dkxoc'  'coo;.'cdxxxxxxxxxxxxxxo,.   . .....'d0KKKKKKKKKKKKKKKK000KKKK0000000000KKKKK
// KKKKKKKKKKKKKKKKKKKKKKK0000KKKKKKKKK000KKKKKKKKKKKKKKKO: .oOkkOd,'lxxddl,....''...,:ldxxxxxxxxdc..,,.'lc. ,, .oKKKKKKKKKKKKKKKKKKKKKK000KK00000KKKKKK0
// KKKKKKKKKKKKKKKKKKKKK00000KKKKKKKK0000KKKKKKKKKKKKKKKKKk, ,xOkOkx:.;okkOkdlc:,'..    ..,;;::;,.  .';,''. .xk,.dKKKKKKKKKKKKKKKKKKKK0000KK0000KKKKKKK00
// KKKKKKKKKKKKKKKKKKKK0000KKKKKKKKK000KKKKKKKKKKKKKKKKKKKKo. ;xOkkkko,':dkOOOOOkxoc;;'..            .d0Ok;..;;.;kKKKKKKKKKKKKKKKKKKK000KKK000KKKKKKK0000
// KKKKKKKKKKKKKKKKKK0000KKKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKd,..'dOkkkOkl;',:ldxkkkxolc:;;;;:c;,,,'.  .lkkl' ..  .:OKKKKKKKKKKKKKKKKK000KKKKKKKKKKKKK0000K
// K000KKKK0KKKKKKK0000KKKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKKKd;lc..:oxOkkOkxl;'',,,;;;::;,,,'....    .c,....       .oKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK00000KKK
// 0000KK00KKKKKKK0000KKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKKKKKk;,c'   'coxkOOxc;::c;..........   .:dd:...... .::.   .dKKKKKKKKKKKKKKKKKKKKKKKKKKKKK00000KKKK
// 000K000KKKKKK0000KKKKKKKKK00KKKKKKKKKKKKKKKKKKKKKKKKKK0ko,.,cxOd:'..',:cc:clooc;;:;,'..';lkXWMMWKo'... .;:'. .;x0KKKKKKKKKKKKKKKKKKKKKKKKKK00000KKKKKK
// 000000KKKKK00000KKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKKKK0x:',o0NMMMMWNKOxl;'''',,'',,'.';oOXWMMMMMMMMMXk:...;lc....,kKKKKKKKKKKKKKKKKK00KKKKKK0000KKKK00KK
// K000KKKKKK0000KKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKKKKKk:':kNMMMMMMMMMMMMMWNXKKXXXXXXXXNWMMMMMMMMMMMMMMMW0d;',,.',.'xKKKKKKKKKKKKKK0000KKKKKK000KKKKKK00KK
// 000KKKKKK00KKKKKKKKK0000KKKKKKKKKKKKKKKKKKKKKKKKK0o,;OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO:. .:ok0KKKKKKKKKKKKK0000KKKKK0000KKKKKKKKKKK
// 00KKKK00KKKKKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKKKKK0l'oNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXo. :OKKKKKKKKKKKKK0000KKKKKK000KKKKKKKKKKKKK
// KKKK000KKKKKKKKKK0000KKKKKKKKKKKKKKKKKKKKKKKKKK0l'oNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNd..dKKKKKKKKKKKK000KKKKKKK00KKKKKKKKKKKKKKK
// K00000KKKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKo'lXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWk',kKKKKKKKKKK00KKKKKKKKKKKKKKKKKKKKKKKKKK
// 00000KKKKKKKKK000KKKKKKKKKKKKKKKKKKKKKKK0OkO00d,cXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWk''x00KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// 0000KKKKKKKKK000KKKKKKKKKKKKKKKKKKKKK0Kkc..,''..,ldOKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXl..o0KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// 00KKKKKKKKK0000KKKKKKKKKKKKKKKKKKKKKKKO:.'x0kddoc,...;xKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWNXNNXXXKXNWMMMMWNXKOxlcll.'kKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// 0KKKKKKKKK0000KKKKKK00KKKKKKKKKKKK00K0c.:KNkc,,cxkOkdc:;;ckXNWMMMMMMMMMMMWXK0Odoolc:::::::cc:;;,,ckOxoc;,..,:oKWx.;OKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// KKKKKKKK0000KKKKKKKKKKKKKKKKKKKK000KKo.;KXc       .:ldkkkdc;',:x0KK00OxdddooooooddxxOO0KKKKK0OOx' .lolodkO0XNN0kx;.:O000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// KKKKKKK0000KKKKKKKKKKKKKKKKKKKK00KKKk,,0Xc             .':k0d:,',,...,cxKXOxdolcccccloodk0NWMWWWx'oXNWMMMWKxc'.;00,.:k00KKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// KKKKK00000KKKKKKKKKKKKKKKKKKK000KKK0:.oWO'                .OXkxOKO, 'OWNx,.              .'l0NMMXddNMWXkl,..':xXWWk'.cOKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// KKK00000KKKKKKKKKKKKKKKKKKKK0KKKKKK0l.:XNo.               .xx. .::. :XNl                    .kWMMKdOKl'.'cd0NMMMMMWk,.cOKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
// KK0000KKKKKKKKKKKKKKKKKKKKK0KKKKKKKK0l,dWK,               'x:.lkd' ;0Mk.                     :XMMMX0kdx0NMMMMMMMMMMWk..l0KKKKKKKKKKKKKKKKKKKKKKKKKKKK0
// 00000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKc.lK0o,             co.;XW0;.kWMx.                     ,KMMMMNXWMMMMMMMMMMMMMMNo.'xKKKKKKKKKKKKKKKKKKKKKKKKKK000
// 000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK0Kd. :0NXOl'.       'dk'.kMMWd.,OWK,                    .oNMMWKol0MMMMMMMMMMMMMMMK: ,kKKKKKKKKKKKKKKKKKKKKKKKK000K
// KKKKKKKK00KKKKKKKKKKKKKKKKKKKKKKKKKK0KO,.',,:ldddxxxddxkOO:.lNMMMXl..dXO,                  .dNMMWk;.lXMMMMMMMMMMMMMMMMk. ;OKKKKKKKKKKKKKKKKKKKKKKKKKKK
// KKKK00000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKd.'0Xxlc;'.,cdl:;'.':kNMMMMWK:  ,kKkolc:;,...  ...,cxKWMMNo..c0WMMMMMMMMMMMMMMMMWd. :OKKKKKKKKKKKKKKKKKKKKKKKKKK
// KK00000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKo.,KMMMMWXOdc,';ldkKNMMMMMMMWXx;..:ONWWWWNX0OOO0KXWWMMMMNo..lOWMMMMMMMMMMMMMMMMMMNc .l0KKKKKKKKKKKKKKKKKKKKKKKKK
// 000000KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK0l ,KMMMMMMMMMWNWMMMMMMMMMMMMMMMNOo::::ccclc::ccccclooodxocoOXWMMMMMMMMMMMMMMMMMMMNo. 'xKKKKKKKKKKKKKKKKKKKKKKKKK
// 0000KKKKKKKKKKKKKK0Oxollcccodk0KKKKKK0l .OMMMMMMMMMMMMMMMMMMMMMMMMKdd0WMWNK0OOOOkkkkkkkk0KK00O0XMMMMMMMMMMMMMMMMMMMMMMMk'   :OKKKKKKKKKKKKKKKKKKKKKKKK
// 000KKKKKKKKK0Okxdl:;;,;::ccl:;:lxOKKKKo.'0MMMMMMMMMMMMMMMMMMMMWWNKo..'lKMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNk;  'xKKKKKKKKKKKKKKKKKKKKKKKK
// 0KKKKKKKKKKk:',,;:coddddoollodo:oOKK00l.,KMMMMMMMMMMMMMMNklcc::;,,,ck0kXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx.  .,x000KKKKKKKKKKKKKKKKKK00
// KKKKKKKKKKKd.:kkxxdxxddddxO0KKOlo0K00Ko.'0MMMMMMMMMMMMMMW0kkxxkO0KNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNd,.. .lO0KKKKKKKKKKKKKKKKKKK00
// K00KKKKKK0Kk':KWXKKKKKKKKKKKKKkco0K0KKo.,KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNOdOKl..co. .,d0KKKK00KKKKKKKKKKKKK0
// 000KKKK0KKKO;,0WXKKKKKKKKKKKKKkloOKKKKo.:XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWX0KO, ':'.'x0:   :0KKK00KKKKKKKKKKKK000
// 00KK00KKKKKKl.dNNKKKKKKKK00OOkl;ckKK0Kx.,0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXKXWMMO,..,..o;...lKd. ;xKKK00KKKKKKKKKKKKK000
// KK0000KKKKKKk,;KNKK0kkOO00Oxc,..,o0KKKx..OW0xdkKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx'..;oOo..:,..'.  ..xK,.c0K000KKKKKKKKKKKKKKK00
// K000KKKKKKKKKo'dNOolcllccc:ccdkxokKKKKk'.kXl';:co0WMMMMMXdl0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNWMMMMNc ,c:.'l:':,.c:. ,ldKNl ,kK0KKKKKKKKKKKKKKKK000
// 000KKKKKKKK00k,:0xcdkkdoodk0KKKOok0xddo'.dWd,lxdc:oKWMW0;. ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0:'cOkloOd.'odc.':. .:XNOkXMMMWx..o0KKKKKKKKKKKKKKKK0000
// 000KK0KKKK0000c,OX00000KKKKKKKKOdxc..',:;d0x;:ddddc:O0l. ,,,kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX;   ''...ll'',. .. ..'lKMMMMMMM0' .lOKKKKKKKKKKKKK000000
// 0KKK00000000KKx;dXKKKKKKKKKKKKK0xd;.;oodl'....';lo:... .,:,.,OWMMMMMMWX0kx0NWMMMMMMMMMMMMMMWWK; ';. .'';OX0x, .. .'..oWMMMMMMK;  .lKKKKKKKKKKKKK0000O0
// 0KK00000000KK0x,;o:;;::cllllloddlxx;.;cc,  ;dl'...';:;..xXl...:OWMMW0c.. .;lodkNMMXxlodOKklccxx,',.  ..'kWMWO;..':;,lKMMMMMMMWo. .c0KKKKKKKKKKKKKK0000
// K00O000000K0d;,,:l'.,:,'.. .,,;;;xK0xc'.....,,.. ,odxx, .;:,:xo;:kW0'  ......;;cOWk',lc;..cd,'OO,.  .''.:XMMMNOkKXXNWMMMMMMMMWo.  ,kKKKKKKKKKKKKK00000
// 00O000000KOc.c0NO:..:dxOOo,.',';oOKKK0c  ;oooc'  'okd,..,:o;'OWXd;cc. ,oo'  ,od:cX0;,oc' .cl';Kklo'..:l,:KMMMMMMMMMMMMMMMMMMMNo  ..oKK000KKKKKKKK0KKKK
// 00000000K0c.dNMMWOl;'',;;,,,,'.'dO00Kk, ,llc;;,'....  .oo;.  'cxOo..:'.,'.   .'.:KNo....   .,OWxckc,xkod0WMMMMMMMMMMMMMMMMMMMWd. ..dK000KKKKKKKKKKKKKK
// 0000000KKk',KMMMMMMWNXXKKKKXNNOl',oOKx. oWWX000KK:.;:. .ldc.   ..,;.'clc:.   .;,'xWO'......'dWMXxolxNMMMMMMMMMMMMMMMMMMMMMMMMMO'  'xK00KKKKKKKKKKKKKKK
// 00000KKKKO,'0MMMMMMMMMMMMMMMMMMWKl';dd..xMMMMMMMWl'lo:;;:l;.';'.;xx:':ccc;',codooOWNkooxOo;cxO0NWMWWMMMMMMMMMMMMMMMMMMMMMMMMMMNl  .x00KKKKKKKKKKKKKKKK
// 0000KKKKKKl.dWMMMMMMMMMMMMMMMMMMMWO;.,.'0MMMMMMMWo..cKWNXKxcloll0NXX0kxxxkXWWWNNWMMMMMW0c......';lxKWMMMMMMMMMMMMMMMMMMMMMMMMMMK;  ;kKKKKKKKKKKKKKKKKK
// 000KKKKK0KO;'kWMMMMMMMMMMMMMMMMMMMMNx. ,KMMMMMMMWklkNMMMMMMNXXNMMMMMMMMMMMMMMMMMMMMMMWx,:xOO00koc;,;cdONMMMMMMMMMMMMMMMMMMMMMMMW0:  .oOKKKKKKKKKKKKKK0
// 00KKKK0KKK0x,'OMMMMMMMMMMMMMMMMMMMMWO, .xMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx'oNMMMMMMMMMWKOkddkXWMMMMMMMMMMMMMMMMMMMMMMXd. .l0KKKKKKKKKKKK00
// 0KKK00KKK000x,,OWMMMMMMMMMMMMMMMMMMNo. :KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX:,KMMMMMMMMMMMMMMWKdldKWMMMMMMMMMMMMMMMMMMMMMNk' .oKKKKKKKKKKKKKK
// KKK00KKK000KKk,'xNMMMMMMMMMMMMMMMMWk' .OMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK;;XMMMMMMMMMMMMMMMMW0o:dKNWMMMMMMMMMMMMMMMMMMMWd. 'xKKKKKKKKKKKKK
// KK00KK0000KKKKx..kMMMMMMMMMMMMMMMWk' .dWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK,'0MMMMMMMMMMMMMMMMMMWKxddKMMMMMMMMMMMMMMMMMMMMK,  ;OKKKKKKKKKKK0
// KKKKK0000KKKKK0: :XMMMMMMMMMMMMMWk'  oNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK;.cxXMMMMMMMMMMMMMMMMMMMMWWMMMMMMMMMMMMMMMMMMMMWd. .l0KKKKKKKKK00
// KKKK0000KKKKKK0: .xWMMMMMMMMMMMWO' .cXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWk,. lNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXc  .dKKKKKKKK000
// KKK00000KKKKKK0:  :NMMMMMMMMMMW0;  cNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0; .kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO'  ;OKKKKK0000K
// KK000000KKKKKK0l  .OMMMMMMMMMMXc  ;KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK, :XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNl  .dKKKK0000KK
// K0000000K00KK0Kx' .xMMMMMMMMMNd. ,0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMx..kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx. .oKKK0000KKK
// K000000K000KKKK0l .dMMMMMMMMWO' 'OMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX; :XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO'  c0K0000KKKK
// K00000K000KKKK0Kx. lNMMMMMMMK; .xWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWo .xMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk. .lK000KKKKKK
// 00000K000KKKKK0Kx. ;XMMMMMMNo. cNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd. lWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.  c000KKKKKK0
// 000KK000KKKKK00Kx. .OMMMMMM0, '0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMx. ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM0,  :O0KKKKKK00
// 00K0000KKKKKKKKKx.  oWMMMMNo. lNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk. ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX:  ;OKKKKKKK00
// 0K0000KKKKKK00KKd.  ;XMMMMk. ,0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMO. cNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX:  ;OK0KKKK000
// KK000KKKKKK000K0o.  ,KMMMMd .dWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMO. oWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWMMMMMMMMMX:  :0KKKKK00O0


contract METAKAYS is Ownable, ERC721, NonblockingReceiver {

    using DynamicBuffer for bytes;
bytes32 public _merkleRoot;

    address public _owner;
    string private baseURI;
    uint256 nextTokenId = 120;
    // uint256 MAX_MINT_ETHEREUM = 3084;
    uint256 MAX_MINT_BNB = 140;

    bytes public checkTHIS;
    mapping (address => bool) public whitelistClaimed;

    struct Features {
      uint256 data1;
      uint256 data2;
      uint256[] colors;
    }

      uint256[] public finalityKustoms; //CHECK THIS

    mapping (uint256 => string) public svgBackgroundColor2;
            mapping (uint256 => string) public misc;
    mapping(uint256 => Features) public features;


    uint gasForDestinationLzReceive = 350000;

    constructor() ERC721("mkay", "mk") {
        _owner = msg.sender;
        endpoint = ILayerZeroEndpoint(0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1);
        baseURI = "www";

    svgBackgroundColor2[0] = '#2dd055"/>';
      svgBackgroundColor2[1] = '#09a137"/>';
      svgBackgroundColor2[2] = '#065535"/>';
      svgBackgroundColor2[3] = '#88b04b"/>';
      svgBackgroundColor2[4] = '#00ffff"/>';
      svgBackgroundColor2[5] = '#5acef3"/>';
      svgBackgroundColor2[6] = '#0050ff"/>';
      svgBackgroundColor2[7] = '#4559cc"/>';
      svgBackgroundColor2[8] = '#34568b"/>';
      svgBackgroundColor2[9] = '#8a2be2"/>';

      misc[0] = '<path d="M0 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[1] = '<path d="M1000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[2] = '<path d="M2000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[3] = '<path d="M3000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[4] = '<path d="M4000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[5] = '<path d="M5000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[6] = '<path d="M6000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[7] = '<path d="M7000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[8] = '<path d="M8000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[9] = '<path d="M9000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[10] = '<path d="M10000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[11] = '<path d="M11000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[12] = '<path d="M0 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[13] = '<path d="M1000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[14] = '<path d="M2000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[15] = '<path d="M3000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[16] = '<path d="M4000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[17] = '<path d="M5000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[18] = '<path d="M6000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[19] = '<path d="M7000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[20] = '<path d="M8000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[21] = '<path d="M9000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[22] = '<path d="M10000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[23] = '<path d="M11000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[24] = '<path d="M0 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[25] = '<path d="M1000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[26] = '<path d="M2000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[27] = '<path d="M3000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[28] = '<path d="M4000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[29] = '<path d="M5000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[30] = '<path d="M6000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[31] = '<path d="M7000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[32] = '<path d="M8000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[33] = '<path d="M9000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[34] = '<path d="M10000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[35] = '<path d="M11000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[36] = '<path d="M0 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[37] = '<path d="M1000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[38] = '<path d="M2000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[39] = '<path d="M3000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        misc[40] = '<path d="M4000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[41] = '<path d="M5000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[42] = '<path d="M6000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[43] = '<path d="M7000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[44] = '<path d="M8000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[45] = '<path d="M9000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[46] = '<path d="M10000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[47] = '<path d="M11000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[48] = '<path d="M0 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[49] = '<path d="M1000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[50] = '<path d="M2000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[51] = '<path d="M3000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[52] = '<path d="M4000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[53] = '<path d="M5000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[54] = '<path d="M6000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[55] = '<path d="M7000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[56] = '<path d="M8000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[57] = '<path d="M9000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[58] = '<path d="M10000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[59] = '<path d="M11000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[60] = '<path d="M0 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[61] = '<path d="M1000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[62] = '<path d="M2000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[63] = '<path d="M3000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[64] = '<path d="M4000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[65] = '<path d="M5000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[66] = '<path d="M6000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[67] = '<path d="M7000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[68] = '<path d="M8000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[69] = '<path d="M9000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[70] = '<path d="M10000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[71] = '<path d="M11000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[72] = '<path d="M0 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[73] = '<path d="M1000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[74] = '<path d="M2000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[75] = '<path d="M3000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[76] = '<path d="M4000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[77] = '<path d="M5000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[78] = '<path d="M6000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[79] = '<path d="M7000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[80] = '<path d="M8000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[81] = '<path d="M9000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[82] = '<path d="M10000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[83] = '<path d="M11000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[84] = '<path d="M0 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[85] = '<path d="M1000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[86] = '<path d="M2000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[87] = '<path d="M3000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[88] = '<path d="M4000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[89] = '<path d="M5000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[90] = '<path d="M6000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[91] = '<path d="M7000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[92] = '<path d="M8000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[93] = '<path d="M9000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[94] = '<path d="M10000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[95] = '<path d="M11000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[96] = '<path d="M0 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[97] = '<path d="M1000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[98] = '<path d="M2000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[99] = '<path d="M3000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[100] = '<path d="M4000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[101] = '<path d="M5000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[102] = '<path d="M6000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[103] = '<path d="M7000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[104] = '<path d="M8000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[105] = '<path d="M9000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[106] = '<path d="M10000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[107] = '<path d="M11000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[108] = '<path d="M0 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[109] = '<path d="M1000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[110] = '<path d="M2000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[111] = '<path d="M3000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[112] = '<path d="M4000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[113] = '<path d="M5000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[114] = '<path d="M6000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[115] = '<path d="M7000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[116] = '<path d="M8000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[117] = '<path d="M9000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[118] = '<path d="M10000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[119] = '<path d="M11000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[120] = '<path d="M0 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[121] = '<path d="M1000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[122] = '<path d="M2000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[123] = '<path d="M3000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[124] = '<path d="M4000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[125] = '<path d="M5000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[126] = '<path d="M6000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[127] = '<path d="M7000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[128] = '<path d="M8000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[129] = '<path d="M9000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[130] = '<path d="M10000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[131] = '<path d="M11000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[132] = '<path d="M0 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[133] = '<path d="M1000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[134] = '<path d="M2000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[135] = '<path d="M3000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[136] = '<path d="M4000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[137] = '<path d="M5000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[138] = '<path d="M6000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[139] = '<path d="M7000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[140] = '<path d="M8000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[141] = '<path d="M9000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[142] = '<path d="M10000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[143] = '<path d="M11000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[144] = '<path d="M11000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[145] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[146] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[147] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[148] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[149] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[150] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[151] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[152] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[153] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[154] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[155] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[156] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[157] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[158] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[159] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[160] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[161] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[162] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[163] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[164] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[165] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[166] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[167] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[168] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[169] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[170] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[171] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[172] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[173] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[174] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[175] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[176] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[177] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[178] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[179] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[180] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[181] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[182] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[183] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[184] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[185] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[186] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[187] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[188] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[189] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[190] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[191] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[192] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[193] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[194] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[195] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[196] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[197] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[198] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[199] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[200] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[201] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[202] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[203] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[204] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[205] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[206] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[207] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[208] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[209] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[210] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[211] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[212] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[213] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[214] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[215] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[216] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';

        // misc[0] = '<path d="M0 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[1] = '<path d="M1000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[2] = '<path d="M2000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[3] = '<path d="M3000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[4] = '<path d="M4000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[5] = '<path d="M5000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[6] = '<path d="M6000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[7] = '<path d="M7000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[8] = '<path d="M8000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[9] = '<path d="M9000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[10] = '<path d="M10000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[11] = '<path d="M11000 11500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[12] = '<path d="M0 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[13] = '<path d="M1000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[14] = '<path d="M2000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[15] = '<path d="M3000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[16] = '<path d="M4000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[17] = '<path d="M5000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[18] = '<path d="M6000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[19] = '<path d="M7000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[20] = '<path d="M8000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[21] = '<path d="M9000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[22] = '<path d="M10000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[23] = '<path d="M11000 10500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[24] = '<path d="M0 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[25] = '<path d="M1000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[26] = '<path d="M2000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[27] = '<path d="M3000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[28] = '<path d="M4000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[29] = '<path d="M5000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[30] = '<path d="M6000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[31] = '<path d="M7000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[32] = '<path d="M8000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[33] = '<path d="M9000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[34] = '<path d="M10000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[35] = '<path d="M11000 9500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[36] = '<path d="M0 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[37] = '<path d="M1000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[38] = '<path d="M2000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[39] = '<path d="M3000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[40] = '<path d="M4000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[41] = '<path d="M5000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[42] = '<path d="M6000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[43] = '<path d="M7000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[44] = '<path d="M8000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[45] = '<path d="M9000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[46] = '<path d="M10000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[47] = '<path d="M11000 8500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[48] = '<path d="M0 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[49] = '<path d="M1000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[50] = '<path d="M2000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[51] = '<path d="M3000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[52] = '<path d="M4000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[53] = '<path d="M5000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[54] = '<path d="M6000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[55] = '<path d="M7000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[56] = '<path d="M8000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[57] = '<path d="M9000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[58] = '<path d="M10000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[59] = '<path d="M11000 7500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[60] = '<path d="M0 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[61] = '<path d="M1000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[62] = '<path d="M2000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[63] = '<path d="M3000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[64] = '<path d="M4000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[65] = '<path d="M5000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[66] = '<path d="M6000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[67] = '<path d="M7000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[68] = '<path d="M8000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[69] = '<path d="M9000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[70] = '<path d="M10000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[71] = '<path d="M11000 6500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[72] = '<path d="M0 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[73] = '<path d="M1000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[74] = '<path d="M2000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[75] = '<path d="M3000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[76] = '<path d="M4000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[77] = '<path d="M5000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[78] = '<path d="M6000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[79] = '<path d="M7000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[80] = '<path d="M8000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[81] = '<path d="M9000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[82] = '<path d="M10000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[83] = '<path d="M11000 5500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[84] = '<path d="M0 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[85] = '<path d="M1000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[86] = '<path d="M2000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[87] = '<path d="M3000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[88] = '<path d="M4000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[89] = '<path d="M5000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[90] = '<path d="M6000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[91] = '<path d="M7000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[92] = '<path d="M8000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[93] = '<path d="M9000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[94] = '<path d="M10000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[95] = '<path d="M11000 4500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[96] = '<path d="M0 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[97] = '<path d="M1000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[98] = '<path d="M2000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[99] = '<path d="M3000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[100] = '<path d="M4000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[101] = '<path d="M5000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[102] = '<path d="M6000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[103] = '<path d="M7000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[104] = '<path d="M8000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[105] = '<path d="M9000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[106] = '<path d="M10000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[107] = '<path d="M11000 3500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[108] = '<path d="M0 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[109] = '<path d="M1000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[110] = '<path d="M2000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[111] = '<path d="M3000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[112] = '<path d="M4000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[113] = '<path d="M5000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[114] = '<path d="M6000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[115] = '<path d="M7000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[116] = '<path d="M8000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[117] = '<path d="M9000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[118] = '<path d="M10000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[119] = '<path d="M11000 2500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[120] = '<path d="M0 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[121] = '<path d="M1000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[122] = '<path d="M2000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[123] = '<path d="M3000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[124] = '<path d="M4000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[125] = '<path d="M5000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[126] = '<path d="M6000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[127] = '<path d="M7000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[128] = '<path d="M8000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[129] = '<path d="M9000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[130] = '<path d="M10000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[131] = '<path d="M11000 1500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[132] = '<path d="M0 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[133] = '<path d="M1000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[134] = '<path d="M2000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[135] = '<path d="M3000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[136] = '<path d="M4000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[137] = '<path d="M5000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[138] = '<path d="M6000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[139] = '<path d="M7000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[140] = '<path d="M8000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[141] = '<path d="M9000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[142] = '<path d="M10000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[143] = '<path d="M11000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[144] = '<path d="M11000 500 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[145] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[146] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[147] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[148] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[149] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[150] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[151] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[152] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[153] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[154] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[155] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[156] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[157] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[158] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[159] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[160] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[161] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[162] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[163] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[164] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[165] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[166] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[167] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[168] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[169] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[170] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[171] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[172] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[173] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[174] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[175] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[176] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[177] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[178] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[179] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[180] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[181] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[182] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[183] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[184] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[185] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[186] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[187] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[188] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[189] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[190] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[191] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[192] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[193] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[194] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[195] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[196] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[197] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[198] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[199] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[200] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[201] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[202] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[203] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[204] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[205] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[206] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[207] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[208] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[209] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[210] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[211] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[212] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[213] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[214] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[215] = '<path d="M2580 4730 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
        // misc[216] = '<path d="M5520 5400 l0 -500 500 0 500 0 0 500 0 500 -500 0 -500 0 0 -500z" fill="';
    }


function setPresaleMerkleRoot(bytes32 root) external onlyOwner {
      _merkleRoot = root;
    }
    // mint function
    // you can choose to mint 1 or 2
    // mint is free, but payments are accepted
    // function mint(uint8 numTokens) external payable {
    //     require(numTokens < 3, "GG: Max 2 NFTs per transaction");
    //     require(nextTokenId + numTokens <= MAX_MINT_ETHEREUM, "GG: Mint exceeds supply");
    //     _safeMint(msg.sender, ++nextTokenId);
    //     if (numTokens == 2) {
    //         _safeMint(msg.sender, ++nextTokenId);
    //     }
    // }

    function mint(uint8 numTokens) external payable {
        require(numTokens < 3, "GG: Max 2 NFTs per transaction");
        require(nextTokenId + numTokens <= MAX_MINT_BNB, "GG: Mint exceeds supply");
        _safeMint(msg.sender, ++nextTokenId);
        if (numTokens == 2) {
            _safeMint(msg.sender, ++nextTokenId);
        }
    }

    function checkTHISset(uint256 _amount) public{
        checkTHIS = abi.encodePacked(msg.sender, _amount);
    }

    function checkTHISpresent() public view returns (bytes memory){
        return checkTHIS;
    }

    function whitelistClaim(uint256 _amount, bytes32[] calldata _merkleProof) external payable {
      require(!whitelistClaimed[msg.sender], "ADDRESS HAS ALREADY CLAIMED!");
      require(nextTokenId + _amount < MAX_MINT_BNB, "MAX SUPPLY!");
    //   require(_amount * price <= msg.value, "INCORRECT AMOUNT SENT!");
      bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));

      require(MerkleProof.verify(_merkleProof, _merkleRoot, leaf),  "INVALID PROOF!");
      whitelistClaimed[msg.sender] = true;
      for (uint256 i = ++nextTokenId; i < _amount+1; i++) {
        _safeMint(msg.sender, i);
      }
    }

    // This function transfers the nft from your address on the
    // source chain to the same address on the destination chain
    function traverseChains(uint16 _chainId, uint tokenId) public payable {
        require(msg.sender == ownerOf(tokenId), "You must own the token to traverse");
        require(trustedRemoteLookup[_chainId].length > 0, "This chain is currently unavailable for travel");

        // burn NFT, eliminating it from circulation on src chain
        _burn(tokenId);

        // abi.encode() the payload with the values to send
        bytes memory payload = abi.encode(msg.sender, tokenId);

        // encode adapterParams to specify more gas for the destination
        uint16 version = 1;
        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);

        // get the fees we need to pay to LayerZero + Relayer to cover message delivery
        // you will be refunded for extra gas paid
        (uint messageFee, ) = endpoint.estimateFees(_chainId, address(this), payload, false, adapterParams);

        require(msg.value >= messageFee, "GG: msg.value not enough to cover messageFee. Send gas for message fees");

        endpoint.send{value: msg.value}(
            _chainId,                           // destination chainId
            trustedRemoteLookup[_chainId],      // destination address of nft contract
            payload,                            // abi.encoded()'ed bytes
            payable(msg.sender),                // refund address
            address(0x0),                       // 'zroPaymentAddress' unused for this
            adapterParams                       // txParameters
        );
    }

    function setBaseURI(string memory URI) external onlyOwner {
        baseURI = URI;
    }

    function donate() external payable {
        // thank you
    }

    // This allows the devs to receive kind donations
    function withdraw(uint amt) external onlyOwner {
        (bool sent, ) = payable(_owner).call{value: amt}("");
        require(sent, "GG: Failed to withdraw Ether");
    }

    function kustomize(uint256 _data1, uint256 _data2, uint256[] memory _colors,  uint256 _itemID) public {
      require(msg.sender == ownerOf(_itemID), "YOU ARE NOT THE OWNER!");

      Features storage feature = features[_itemID];
      feature.data1 = _data1;
      feature.data2 = _data2;
    //   feature.data3 = _data3;
    //   feature.data4 = _data4;

      feature.colors = _colors;
    }



 function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
      require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
// string memory firstfirst = CREATE(_tokenId);
// string memory tokenIdString = toString(_tokenId);
    Features memory feature = features[_tokenId];

      bytes memory artData = abi.encodePacked(feature.data1, feature.data2);//abi.encodePacked(art.data1, art.data2);
      bytes memory colorData = abi.encodePacked(feature.colors[0], feature.colors[1]);//,feature.colors[5],feature.colors[6] );//abi.encodePacked(art.data1, art.data2);
      // colorData = abi.encodePacked(colorData, feature.colors[7], feature.colors[8], feature.colors[9], feature.colors[10], feature.colors[11]);//abi.encodePacked(art.data1, art.data2);
      // colorData = abi.encodePacked(colorData, feature.colors[12], feature.colors[13], feature.colors[14], feature.colors[15], feature.colors[16]);//abi.encodePacked(art.data1, art.data2);

      // string memory _last = string(abi.encodePacked(finality[_tokenId] == false ? '<path d="M7330 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z M7720 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z" fill="' : '<path d="M7340 435 l0 -55 -55 0 -55 0 0 -45 0 -45 55 0 55 0 0 -110 0 -110 45 0 45 0 0 110 0 110 55 0 55 0 0 45 0 45 -55 0 -55 0 0 55 0 55 -45 0 -45 0 0 -55z m80 -10 l0 -55 55 0 55 0 0 -35 0 -35 -55 0 -55 0 0 -110 0 -110 -35 0 -35 0 0 110 0 110 -55 0 -55 0 0 35 0 35 55 0 55 0 0 55 0 55 35 0 35 0 0 -55z M7360 415 l0 -55 -55 0 c-52 0 -55 -1 -55 -25 0 -24 3 -25 55 -25 l55 0 0 -110 0 -110 25 0 25 0 0 110 0 110 55 0 c52 0 55 1 55 25 0 24 -3 25 -55 25 l-55 0 0 55 c0 52 -1 55 -25 55 -24 0 -25 -3 -25 -55z m40 -10 l0 -55 55 0 c42 0 55 -3 55 -15 0 -12 -13 -15 -55 -15 l-55 0 0 -110 c0 -91 -3 -110 -15 -110 -12 0 -15 19 -15 110 l0 110 -55 0 c-42 0 -55 3 -55 15 0 12 13 15 55 15 l55 0 0 55 c0 42 3 55 15 55 12 0 15 -13 15 -55z M7382 398 l-2 -57 -57 -4 -58 -3 57 -2 57 -2 4 -112 3 -113 2 112 2 112 58 4 57 3 -57 2 -57 2 -4 58 -3 57 -2 -57z M7730 435 l0 -55 -55 0 -55 0 0 -45 0 -45 55 0 55 0 0 -110 0 -110 45 0 45 0 0 110 0 110 55 0 55 0 0 45 0 45 -55 0 -55 0 0 55 0 55 -45 0 -45 0 0 -55z m80 -10 l0 -55 55 0 55 0 0 -35 0 -35 -55 0 -55 0 0 -110 0 -110 -35 0 -35 0 0 110 0 110 -55 0 -55 0 0 35 0 35 55 0 55 0 0 55 0 55 35 0 35 0 0 -55z M7750 415 l0 -55 -55 0 c-52 0 -55 -1 -55 -25 0 -24 3 -25 55 -25 l55 0 0 -110 0 -110 25 0 25 0 0 110 0 110 55 0 c52 0 55 1 55 25 0 24 -3 25 -55 25 l-55 0 0 55 c0 52 -1 55 -25 55 -24 0 -25 -3 -25 -55z m40 -10 l0 -55 55 0 c42 0 55 -3 55 -15 0 -12 -13 -15 -55 -15 l-55 0 0 -110 c0 -91 -3 -110 -15 -110 -12 0 -15 19 -15 110 l0 110 -55 0 c-42 0 -55 3 -55 15 0 12 13 15 55 15 l55 0 0 55 c0 42 3 55 15 55 12 0 15 -13 15 -55z M7772 398 l-2 -57 -57 -4 -58 -3 57 -2 57 -2 4 -112 3 -113 2 112 2 112 58 4 57 3 -57 2 -57 2 -4 58 -3 57 -2 -57z" fill="', keccak256(bytes(getSlice(0, 4, bytes(featy[_tokenId])))) == keccak256(bytes("00")) ? '#09a137"/>' : '#945610"/>'));
      // string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64, ", Base64.encode(bytes(string(abi.encodePacked('<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="1200.000000pt" height="1200.000000pt" viewBox="0 0 1200.000000 1200.000000" preserveAspectRatio="xMidYMid meet"><g transform="translate(0.000000,1200.000000) scale(0.100000,-0.100000)">', CREATE(_tokenId), finality[_tokenId] == false ? '<path d="M11330 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z M11720 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z" fill="' : '<path d="M11330 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z m90 -20 l0 -55 55 0 55 0 0 -35 0 -35 -55 0 -55 0 0 -110 0 -110 -35 0 -35 0 0 110 0 110 -55 0 -55 0 0 35 0 35 55 0 55 0 0 55 0 55 35 0 35 0 0 -55z M11370 405 l0 -55 -55 0 c-42 0 -55 -3 -55 -15 0 -12 13 -15 55 -15 l55 0 0 -110 c0 -91 3 -110 15 -110 12 0 15 19 15 110 l0 110 55 0 c42 0 55 3 55 15 0 12 -13 15 -55 15 l-55 0 0 55 c0 42 -3 55 -15 55 -12 0 -15 -13 -15 -55z M11720 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z m90 -20 l0 -55 55 0 55 0 0 -35 0 -35 -55 0 -55 0 0 -110 0 -110 -35 0 -35 0 0 110 0 110 -55 0 -55 0 0 35 0 35 55 0 55 0 0 55 0 55 35 0 35 0 0 -55z M11760 405 l0 -55 -55 0 c-42 0 -55 -3 -55 -15 0 -12 13 -15 55 -15 l55 0 0 -110 c0 -91 3 -110 15 -110 12 0 15 19 15 110 l0 110 55 0 c42 0 55 3 55 15 0 12 -13 15 -55 15 l-55 0 0 55 c0 42 -3 55 -15 55 -12 0 -15 -13 -15 -55z" fill="', keccak256(bytes(getSlice(0, 2, bytes(featy[_tokenId])))) == keccak256(bytes("00")) ? '#09a137"/>' : '#945610"/>', '</g></svg>'))))));
      string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64, ", Base64.encode(bytes(string(abi.encodePacked('<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="1200.000000pt" height="1200.000000pt" viewBox="0 0 1200.000000 1200.000000" preserveAspectRatio="xMidYMid meet" xmlns:xlink="http://www.w3.org/1999/xlink"> <defs> <g id="cube" class="cube-unit" transform="scale(.38,.38)"> <polygon style="stroke:#000000;" points="480,112 256,0 32,112 32,400 256,512 480,400 "/> <polygon style="stroke:#000000;" points="256,224 32,112 32,400 256,512 480,400 480,112 "/> <polygon style="stroke:#000000;" points="256,224 256,512 480,400 480,112 "/> </g> </defs> <g transform="translate(0.000000,1200.000000) scale(0.100000,-0.100000)" fill="#000000" stroke="none"> <path d="M0 6000 l0 -6000 6000 0 6000 0 0 6000 0 6000 -6000 0 -6000 0 0 -6000z" fill="#FF0000"/> <path d="M11330 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z M11720 445 l0 -55 -55 0 -55 0 0 -55 0 -55 55 0 55 0 0 -110 0 -110 55 0 55 0 0 110 0 110 55 0 55 0 0 55 0 55 -55 0 -55 0 0 55 0 55 -55 0 -55 0 0 -55z" fill="#000000"/></g>', CREATE(artData, colorData), '</svg>'))))));

    //   string memory finality_ = finality[_tokenId] == false ? 'false' : 'true';


      return string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                "cancan-", toString(_tokenId),
                '", "attributes":[{"trait_type" : "Finality", "value" : "', "finality_" ,'"}], "image":"',imageURI,'"}'
              )
            )
          )
        )
      );
    }

function CREATE(bytes memory artData, bytes memory colorData) internal view returns (string memory) {
      // string memory tempWord = '<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="1200.000000pt" height="1200.000000pt" viewBox="0 0 1200.000000 1200.000000" preserveAspectRatio="xMidYMid meet"><g transform="translate(0.000000,1200.000000) scale(0.100000,-0.100000)">';
      bytes memory rects = DynamicBuffer.allocate(2**16);
      // string memory tempWord = "";
         for (uint i = 0; i < 24; i+=8) {
 uint8 workingByte = uint8(artData[i/8]);
 uint8 colorByte = uint8(colorData[i/8]);
for (uint256 ii; ii < 8; ii++) {
if ((workingByte >> (7 - ii)) & 1 == 1) {
  if ((colorByte >> (7 - ii)) & 1 == 1) {
          rects.appendSafe(abi.encodePacked('<use xlink:href="#cube" x="',toString(i+100), '" y="', toString(i+200),'" fill="',svgBackgroundColor2[2]));//'" fill="', svgBackgroundColor2[colorByte]));
  } else { //if ((colorByte >> (7 - ii)) & 1 == 0)
          rects.appendSafe(abi.encodePacked('<use xlink:href="#cube" x="',toString(i+100), '" y="', toString(i+200),'" fill="',svgBackgroundColor2[1]));//'" fill="', svgBackgroundColor2[colorByte]));

  }

      }
}
         }
      return string(rects);
    }

    // just in case this fixed variable limits us from future integrations
    function setGasForDestinationLzReceive(uint newVal) external onlyOwner {
        gasForDestinationLzReceive = newVal;
    }

    function toString(uint256 value) internal pure returns (string memory) {
      if (value == 0) {
        return "0";
      }
      uint256 temp = value;
      uint256 digits;
      while (temp != 0) {
        digits++;
        temp /= 10;
      }
      bytes memory buffer = new bytes(digits);
      while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
      }
      return string(buffer);
    }

    // ------------------
    // Internal Functions
    // ------------------

    function _LzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) override internal {
        // decode
        (address toAddr, uint tokenId) = abi.decode(_payload, (address, uint));

        // mint the tokens back into existence on destination chain
        _safeMint(toAddr, tokenId);
    }

    function _baseURI() override internal view returns (string memory) {
        return baseURI;
    }
}