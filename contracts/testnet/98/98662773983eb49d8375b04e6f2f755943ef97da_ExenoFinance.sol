/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
// File: contracts/IExenoFinance.sol


pragma solidity 0.8.16;

interface IExenoFinanceNode {
    function isDebitId(bytes32) external view returns(bool);
    function isCreditId(bytes32) external view returns(bool);

    function getSpinoffIds(bytes32) external view returns(bytes32[2] memory);
    function getSpinoffList(bytes32) external view returns(bytes32[] memory, uint256);

    function getDeposits(address, address) external view returns(uint256);
    function getUndeposits(address, address) external view returns(uint256);
    
    function getStakes(address, address) external view returns(uint256);
    function getUnstakes(address, address) external view returns(uint256);
    
    function getTokenList() external view returns(address[] memory, uint256);
    
    function coreToken() external view returns(address);
    function nativeToken() external view returns(address);
    
    function ownedTokens(address) external view returns(uint256);
    function availableTokens(address) external view returns(uint256);
}

interface IExenoToken {
    function manager() external view returns(address);
    function mint(address, uint256) external;
    function burn(uint256) external;
}

// File: erc-payable-token/contracts/token/ERC1363/IERC1363Spender.sol



pragma solidity ^0.8.0;

/**
 * @title IERC1363Spender Interface
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Interface for any contract that wants to support approveAndCall
 *  from ERC1363 token contracts as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
interface IERC1363Spender {
    /**
     * @notice Handle the approval of ERC1363 tokens
     * @dev Any ERC1363 smart contract calls this function on the recipient
     * after an `approve`. This function MAY throw to revert and reject the
     * approval. Return of other than the magic value MUST result in the
     * transaction being reverted.
     * Note: the token contract address is always the message sender.
     * @param sender address The address which called `approveAndCall` function
     * @param amount uint256 The amount of tokens to be spent
     * @param data bytes Additional data with no specified format
     * @return `bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))` unless throwing
     */
    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);
}

// File: erc-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol



pragma solidity ^0.8.0;

/**
 * @title IERC1363Receiver Interface
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Interface for any contract that wants to support transferAndCall or transferFromAndCall
 *  from ERC1363 token contracts as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
interface IERC1363Receiver {
    /**
     * @notice Handle the receipt of ERC1363 tokens
     * @dev Any ERC1363 smart contract calls this function on the recipient
     * after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the
     * transfer. Return of other than the magic value MUST result in the
     * transaction being reverted.
     * Note: the token contract address is always the message sender.
     * @param spender address The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender address The address which are token transferred from
     * @param amount uint256 The amount of tokens transferred
     * @param data bytes Additional data with no specified format
     * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))` unless throwing
     */
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
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

// File: @openzeppelin/contracts/utils/introspection/ERC165Checker.sol


// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;


/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol


// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: erc-payable-token/contracts/token/ERC1363/IERC1363.sol



pragma solidity ^0.8.0;



/**
 * @title IERC1363 Interface
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Interface for a Payable Token contract as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
interface IERC1363 is IERC20, IERC165 {
    /**
     * @notice Transfer tokens from `msg.sender` to another address and then call `onTransferReceived` on receiver
     * @param to address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @return true unless throwing
     */
    function transferAndCall(address to, uint256 amount) external returns (bool);

    /**
     * @notice Transfer tokens from `msg.sender` to another address and then call `onTransferReceived` on receiver
     * @param to address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @param data bytes Additional data with no specified format, sent in call to `to`
     * @return true unless throwing
     */
    function transferAndCall(
        address to,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    /**
     * @notice Transfer tokens from one address to another and then call `onTransferReceived` on receiver
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @return true unless throwing
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @notice Transfer tokens from one address to another and then call `onTransferReceived` on receiver
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @param data bytes Additional data with no specified format, sent in call to `to`
     * @return true unless throwing
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    /**
     * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
     * and then call `onApprovalReceived` on spender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender address The address which will spend the funds
     * @param amount uint256 The amount of tokens to be spent
     */
    function approveAndCall(address spender, uint256 amount) external returns (bool);

    /**
     * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
     * and then call `onApprovalReceived` on spender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender address The address which will spend the funds
     * @param amount uint256 The amount of tokens to be spent
     * @param data bytes Additional data with no specified format, sent in call to `spender`
     */
    function approveAndCall(
        address spender,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

// File: erc-payable-token/contracts/payment/ERC1363Payable.sol



pragma solidity ^0.8.0;







/**
 * @title ERC1363Payable
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Implementation proposal of a contract that wants to accept ERC1363 payments
 */
contract ERC1363Payable is IERC1363Receiver, IERC1363Spender, ERC165, Context {
    using ERC165Checker for address;

    /**
     * @dev Emitted when `amount` tokens are moved from one account (`sender`) to
     * this by spender (`operator`) using {transferAndCall} or {transferFromAndCall}.
     */
    event TokensReceived(address indexed operator, address indexed sender, uint256 amount, bytes data);

    /**
     * @dev Emitted when the allowance of this for a `sender` is set by
     * a call to {approveAndCall}. `amount` is the new allowance.
     */
    event TokensApproved(address indexed sender, uint256 amount, bytes data);

    // The ERC1363 token accepted
    IERC1363 private _acceptedToken;

    /**
     * @param acceptedToken_ Address of the token being accepted
     */
    constructor(IERC1363 acceptedToken_) {
        require(address(acceptedToken_) != address(0), "ERC1363Payable: acceptedToken is zero address");
        require(acceptedToken_.supportsInterface(type(IERC1363).interfaceId));

        _acceptedToken = acceptedToken_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return
            interfaceId == type(IERC1363Receiver).interfaceId ||
            interfaceId == type(IERC1363Spender).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /*
     * @dev Note: remember that the token contract address is always the message sender.
     * @param spender The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender The address which are token transferred from
     * @param amount The amount of tokens transferred
     * @param data Additional data with no specified format
     */
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {
        require(_msgSender() == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensReceived(spender, sender, amount, data);

        _transferReceived(spender, sender, amount, data);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /*
     * @dev Note: remember that the token contract address is always the message sender.
     * @param sender The address which called `approveAndCall` function
     * @param amount The amount of tokens to be spent
     * @param data Additional data with no specified format
     */
    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {
        require(_msgSender() == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensApproved(sender, amount, data);

        _approvalReceived(sender, amount, data);

        return IERC1363Spender.onApprovalReceived.selector;
    }

    /**
     * @dev The ERC1363 token accepted
     */
    function acceptedToken() public view returns (IERC1363) {
        return _acceptedToken;
    }

    /**
     * @dev Called after validating a `onTransferReceived`. Override this method to
     * make your stuffs within your contract.
     * @param spender The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender The address which are token transferred from
     * @param amount The amount of tokens transferred
     * @param data Additional data with no specified format
     */
    function _transferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        // optional override
    }

    /**
     * @dev Called after validating a `onApprovalReceived`. Override this method to
     * make your stuffs within your contract.
     * @param sender The address which called `approveAndCall` function
     * @param amount The amount of tokens to be spent
     * @param data Additional data with no specified format
     */
    function _approvalReceived(
        address sender,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        // optional override
    }
}

// File: contracts/ExenoFinanceNode.sol


pragma solidity 0.8.16;










/**
 * This contract facilitates cross-chain bridging of ERC20 tokens (including EXN token) and native currencies.
 * Users (referred to as 'beneficiaries') are expected to deposit tokens on one chain (i.e. origin chain) 
 * and then receive a payout denominated in corresponding tokens (or native currency) on another chain (i.e. destination chain),
 * whereas all transfers are coordinated and authorized by Exeno's off-chain cloud infrastructure.
 * Additionally, this contract supports a whole range of other services: swapping, staking, futures, options, vouchers, revoking payments by payers (escrow), ceding payments by payees etc.
 */

contract ExenoFinanceNode is
    Ownable,
    Pausable,
    ReentrancyGuard,
    ERC1363Payable,
    IExenoFinanceNode
{
    bytes32 private constant CLASS_DEBIT = bytes32("debit");
    bytes32 private constant CLASS_CREDIT = bytes32("credit");
    bytes32 private constant CLASS_SWAP = bytes32("swap");
    bytes32 private constant CLASS_OPTION = bytes32("option");
    bytes32 private constant CLASS_VOUCHER = bytes32("voucher");
    bytes32 private constant CLASS_ESCROW = bytes32("escrow");

    bytes32 private constant ACTION_DEBIT_OPTION = bytes32("debit_option");
    bytes32 private constant ACTION_DEBIT_REWARD = bytes32("debit_reward");
    bytes32 private constant ACTION_CREDIT_ORACLE = bytes32("credit_oracle");
    // bytes32 private constant ACTION_CREDIT_REWARD = bytes32("credit_reward");
    bytes32 private constant ACTION_VOUCHER_CEDE = bytes32("voucher_cede");
    bytes32 private constant ACTION_VOUCHER_CLAIM = bytes32("voucher_claim");
    bytes32 private constant ACTION_ESCROW_CEDE = bytes32("escrow_cede");
    bytes32 private constant ACTION_ESCROW_REVOKE = bytes32("escrow_revoke");

    enum Ccy {CASH, CORE}
    
    // Number of signer addresses whose private keys are used for signing playloads
    uint8 public constant SIGNER_SIZE = 5;
    
    // Encoded name of the blockchain network where this contract is deployed
    bytes32 public immutable NETWORK;

    // Reference to the previous incarnation of this contract - if it exists
    IExenoFinanceNode public immutable PREDECESSOR;

    // Amount of frozen EXN tokens corresponding to the amount of EXN tokens minted on other blockchains
    uint256 public frozenTokens;
    
    // List of signers
    address[SIGNER_SIZE] public signerList;

    // Map of signers
    mapping(address => bool) public signers;

    // Map of already used nonces for debit transactions
    mapping(bytes32 => bool) public debitIds;

    // Map of already used nonces for credit transactions
    mapping(bytes32 => bool) public creditIds;

    // Map of credit title spinoffs - tracks how an existing title has been replaced by two new titles (one for the new beneficiary and the other for the old one)
    mapping(bytes32 => bytes32[2]) public spinoffIds;

    // Map of deposits (beneficiary => token => amount)
    mapping(address => mapping(address => uint256)) private deposits;

    // Map of withdrawn deposits (beneficiary => token => amount)
    mapping(address => mapping(address => uint256)) private undeposits;

    // Map of deposited stakes (beneficiary => token => amount)
    mapping(address => mapping(address => uint256)) private stakes;

    // Map of withdrawn stakes (beneficiary => token => amount)
    mapping(address => mapping(address => uint256)) private unstakes;

    // Amount of accumulated fees (platform | affiliate => amounts): first value is denominated in cash (i.e. native currency), while the second value is denominated in core token (i.e. EXN token)
    mapping(address => uint256[2]) public earnedFees;

    // Amount of overpaid fees (platform => amounts): first value is denominated in cash (i.e. native currency), while the second value is denominated in core token (i.e. EXN token)
    mapping(address => uint256[2]) public extraFees;

    // List of deposited tokens
    address[] private tokenList;

    // Map of deposited tokens
    mapping(address => bool) private tokens;

    // Indicates that a new deposit has been made
    event Deposit(
        address indexed beneficiary,
        address indexed token,
        uint256 amount
    );

    // Indicates that an existing deposit has been withdrawn
    event Withdraw(
        address indexed beneficiary,
        address indexed token,
        uint256 amount,
        bool status
    );

    // Indicates that new signers have been set
    event SetSigners(
        address[SIGNER_SIZE] signers
    );

    // Indicates that core tokens have been frozen
    event FreezeTokens (
        uint256 amount
    );

    // Indicates that core tokens have been unfrozen
    event UnfreezeTokens (
        uint256 amount
    );

    // Indicates that funds have been released
    event ReleaseFunds (
        address indexed token,
        uint256 amount
    );

    // Indicates that earned fees have been reset
    // event ResetEarnedFees (
    //     address actor,
    //     uint256[2] fee
    // );

    // Indicates that extra fees have been released
    // event ReleaseExtraFees (
    //     address platform,
    //     uint256[2] fee
    // );

    constructor(
        bytes32 network,
        address token,
        IExenoFinanceNode predecessor
    )
        ERC1363Payable(IERC1363(token))
    {
        NETWORK = network;
        PREDECESSOR = predecessor;
        _registerToken(nativeToken());
        _registerToken(coreToken());
    }

    /**
     * Gateway for deposit transactions
     */
    function deposit(
        address beneficiary,
        address token,
        uint256 amount
    )
        external payable nonReentrant whenNotPaused
    {
        _collectDeposit(msg.sender, token, amount, msg.value);
        _processDeposit(beneficiary, token, amount);
    }

    /**
     * Gateway for withdraw transactions
     */
    function withdraw(
        address wallet,
        address token,
        uint256 amount
    )
        external nonReentrant whenNotPaused returns(bool)
    {
        return(_processWithdraw(wallet, token, amount));
    }

    /**
     * Gateway for debit transactions
     */
    function debit(
        bytes calldata encodedData
    )
        external payable nonReentrant whenNotPaused
    {
        (ExenoFinance.Data memory d, bytes memory params, uint256[2] memory fee) = _unpackAndValidateSingleSignedData(encodedData, CLASS_DEBIT);
        _collectInboundCashPayments(d, fee, msg.sender, msg.value);
        _processDebit(d, msg.sender, params);
    }

    /**
     * Gateway for credit transacions
     */
    function credit(
        bytes calldata encodedData
    )
        external payable nonReentrant whenNotPaused
    {
        (ExenoFinance.Data memory d, bytes memory params, uint256[2] memory fee) = _unpackAndValidateTripleSignedData(encodedData, CLASS_CREDIT);
        _collectOutboundCashPayments(d, fee, msg.value);
        _processCredit(d, params);
    }

    /**
     * Gateway for swap transactions
     */
    function swap(
        bytes calldata encodedData
    )
        external payable nonReentrant whenNotPaused
    {
        (ExenoFinance.Data memory d,, uint256[2] memory fee) = _unpackAndValidateTripleSignedData(encodedData, CLASS_SWAP);
        address sender = (d.beneficiary[0] == address(this) ? address(this) : msg.sender);
        _collectInboundCashPayments(d, fee, sender, msg.value);
        _processSwap(d, sender);
    }

    /**
     * Gateway for option transactions
     */
    function option(
        bytes calldata encodedData
    )
        external payable nonReentrant whenNotPaused
    {
        (ExenoFinance.Data memory d,, uint256[2] memory fee) = _unpackAndValidateSingleSignedData(encodedData, CLASS_OPTION);
        _collectOutboundCashPayments(d, fee, msg.value);
        _processOption(d);
    }

    /**
     * Gateway for managing a voucher
     */
    function voucher(
        bytes calldata encodedData
    )
        external payable nonReentrant whenNotPaused
    {
        (ExenoFinance.Data memory d, bytes memory params, uint256[2] memory fee) = _unpackAndValidateSingleSignedData(encodedData, CLASS_VOUCHER);
        _collectOutboundCashPayments(d, fee, msg.value);
        _processVoucher(d, msg.sender, params);
    }

    /**
     * Gateway for managing an escrow
     */
    function escrow(
        bytes calldata encodedData
    )
        external payable nonReentrant whenNotPaused
    {
        (ExenoFinance.Data memory d, bytes memory params, uint256[2] memory fee) = _unpackAndValidateSingleSignedData(encodedData, CLASS_ESCROW);
        _collectOutboundCashPayments(d, fee, msg.value);
        _processEscrow(d, msg.sender, params);
    }

    /**
     * We need to be able to add liquidity to the contract
     */
    receive()
        external payable
    {}

    /**
     * Implementation of ERC1363Payable
     * @param sender The address performing the action
     * @param value The amount of tokens transferred
     * @param encodedData Encoded payload which specifies the details of the intended operation
     */
    function _transferReceived(
        address,
        address sender,
        uint256 value,
        bytes memory encodedData
    )
        internal override nonReentrant whenNotPaused
    {
        if (encodedData.length == 0) {
            _processDeposit(sender, coreToken(), value);
            return;
        }
        (bytes32 operation, bytes memory data) = abi.decode(encodedData, (bytes32, bytes));
        if (operation == CLASS_DEBIT) {
            (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes memory signature) = _unpackSingleSignedData(data);
            ExenoFinance.Data memory d = _verifySingleSignature(operation, payload, params, fee, signature);
            _collectInboundCorePayments(d, fee, sender, value);
            _processDebit(d, sender, params);
        } else if (operation == CLASS_CREDIT) {
            (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes[3] memory signature) = _unpackTripleSignedData(data);
            ExenoFinance.Data memory d = _verifyTripleSignature(operation, payload, params, fee, signature);
            _collectOutboundCorePayments(d, fee, value);
            _processCredit(d, params);
        } else if (operation == CLASS_SWAP) {
            (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes[3] memory signature) = _unpackTripleSignedData(data);
            ExenoFinance.Data memory d = _verifyTripleSignature(operation, payload, params, fee, signature);
            _collectInboundCorePayments(d, fee, sender, value);
            _processSwap(d, sender);
        } else if (operation == CLASS_OPTION) {
            (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes memory signature) = _unpackSingleSignedData(data);
            ExenoFinance.Data memory d = _verifySingleSignature(operation, payload, params, fee, signature);
            _collectOutboundCorePayments(d, fee, value);
            _processOption(d);
        } else if (operation == CLASS_VOUCHER) {
            (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes memory signature) = _unpackSingleSignedData(data);
            ExenoFinance.Data memory d = _verifySingleSignature(operation, payload, params, fee, signature);
            _collectOutboundCorePayments(d, fee, value);
            _processVoucher(d, sender, params);
        } else if (operation == CLASS_ESCROW) {
            (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes memory signature) = _unpackSingleSignedData(data);
            ExenoFinance.Data memory d = _verifySingleSignature(operation, payload, params, fee, signature);
            _collectOutboundCorePayments(d, fee, value);
            _processEscrow(d, sender, params);
        } else {
            revert("EFN: unknown operation");
        }
    }

    /**
     * Validate payload class
     */
    function _validateClass(
        bytes32 operation,
        bytes32 class
    )
        internal pure
    {
        require(operation == class,
            "EFN: operation mismatch");
    }

    /**
     * Ensure that the attached payment or allowance matches the amount defined in the deposit
     */
    function _collectDeposit(
        address sender,
        address token,
        uint256 amount,
        uint256 value
    )
        internal
    {
        if (_isNative(token)) {
            require(value >= amount,
                "EFN: n/a cash");
        } else {
            ExenoFinance.transferFrom(sender, token, amount);
        }
    }

    /**
     * When fee is paid in cash (i.e. native currency), ensure that the attached payment (and/or allowance) matches the values defined in the payload
     */
    function _collectInboundCashPayments(
        ExenoFinance.Data memory d,
        uint256[2] memory fee,
        address sender,
        uint256 value
    )
        internal
    {
        if (_isNative(d.token[0]) && d.explicit[0]) {
            require(value >= d.amount[0] + fee[0],
                "EFN: n/e cash for a/t & fee");
            _registerFees(Ccy.CASH, d.platform, d.affiliate, fee[0], value - d.amount[0] - fee[0]);
        } else {
            if (d.explicit[0]) {
                ExenoFinance.transferFrom(sender, d.token[0], d.amount[0]);
            } else {
                require(_depositBalance(sender, d.token[0]) >= d.amount[0],
                    "EFN: n/e deposit balance for a/t");
                _registerUndeposits(sender, d.token[0], d.amount[0]);
            }
            require(value >= fee[0],
                "EFN: n/e cash for fee");
            _registerFees(Ccy.CASH, d.platform, d.affiliate, fee[0], value - fee[0]);
        }
    }

    /**
     * When fee is paid in core tokens, ensure that the transferred amount (and/or allowance) matches the values defined in the payload
     */
    function _collectInboundCorePayments(
        ExenoFinance.Data memory d,
        uint256[2] memory fee,
        address sender,
        uint256 value
    )
        internal
    {
        if (_isCore(d.token[0]) && d.explicit[0]) {
            require(value >= d.amount[0] + fee[1],
                "EFN: n/e core tokens for a/t & fee");
            _registerFees(Ccy.CORE, d.platform, d.affiliate, fee[1], value - d.amount[0] - fee[1]);
        } else {
            if (d.explicit[0]) {
                ExenoFinance.transferFrom(sender, d.token[0], d.amount[0]);
            } else {
                require(_depositBalance(sender, d.token[0]) >= d.amount[0],
                    "EFN: n/e deposit balance for a/t");
                _registerUndeposits(sender, d.token[0], d.amount[0]);
            }
            require(value >= fee[1],
                "EFN: n/e core tokens for fee");
            _registerFees(Ccy.CORE, d.platform, d.affiliate, fee[1], value - fee[1]);
        }
    }

    /**
     * When fee is paid in cash (i.e. native currency), ensure that the attached payment matches the value defined in the payload
     */
    function _collectOutboundCashPayments(
        ExenoFinance.Data memory d,
        uint256[2] memory fee,
        uint256 value
    )
        internal
    {
        require(value >= fee[0],
            "EFN: n/e cash for fee");
        _registerFees(Ccy.CASH, d.platform, d.affiliate, fee[0], value - fee[0]);
    }

    /**
     * When fee is paid in core tokens, ensure that the transferred amount matches the value defined in the payload
     */
    function _collectOutboundCorePayments(
        ExenoFinance.Data memory d,
        uint256[2] memory fee,
        uint256 value
    )
        internal
    {
        require(value >= fee[1],
            "EFN: n/e core tokens for fee");
        _registerFees(Ccy.CORE, d.platform, d.affiliate, fee[1], value - fee[1]);
    }

    /**
     * Process a deposit transaction
     */
    function _processDeposit(
        address sender,
        address token,
        uint256 amount
    )
        internal
    {
        _registerDeposits(sender, token, amount);
        _registerToken(token);
        emit Deposit(sender, token, amount);
    }

    /**
     * Process a withdraw transaction
     */
    function _processWithdraw(
        address wallet,
        address token,
        uint256 amount
    )
        internal returns(bool status)
    {
        require(_depositBalance(msg.sender, token) >= amount,
            "EFN: a/t exceeds deposit balance");    
        if (amount <= availableTokens(token)) {
            _registerUndeposits(msg.sender, token, amount);
            if (_isNative(token)) {
                Address.sendValue(payable(wallet), amount);
            } else {
                ExenoFinance.transferTo(wallet, token, amount, amount);
            }
            status = true;
        }
        emit Withdraw(msg.sender, token, amount, status);
        return(status);
    }

    /**
     * Process a debit transaction according to the instruction defined in the `method[0]` parameter:
     * (a) METHOD_BURN - when the token on the origin chain is mintable
     * (b) METHOD_FREEZE - when the token on the destination chain is mintable
     */
    function _processDebit(
        ExenoFinance.Data memory d,
        address sender,
        bytes memory params
    )
        internal
    {
        (bytes32 action, bytes memory args) = abi.decode(params, (bytes32, bytes));
        ExenoFinance.validateDebit(d, !isDebitId(d.id), NETWORK, sender);
        debitIds[d.id] = true;
        if (d.method[0] == ExenoFinance.METHOD_BURN) {
            require(_isMintable(d.token[0]),
                "EFN: burn for non-mintable token");
            require(ownedTokens(d.token[0]) >= d.amount[0],
                "EFN: n/e owned tokens");
            IExenoToken(d.token[0]).burn(d.amount[0]);
        } else if (d.method[0] == ExenoFinance.METHOD_FREEZE) {
            require(_isCore(d.token[0]),
                "EFN: freeze for non-core token");
            require(availableTokens(d.token[0]) >= d.amount[0],
                "EFN: n/e available tokens");
            frozenTokens += d.amount[0];
        }
        _registerToken(d.token[0]);
        if (d.method[0] == ExenoFinance.METHOD_STAKE) {
            _registerStakes(d.beneficiary[0], d.token[0], d.amount[0]);
        }
        if (d.method[0] != ExenoFinance.METHOD_SWAP) {
            ExenoFinance.emitDebit(d);
        }
        if (action == ACTION_DEBIT_REWARD) {
            (bytes32 id, address token, uint256 amount) = abi.decode(args, (bytes32, address, uint256));
            _executeReward(d, id, token, amount);
        } else if (action == ACTION_DEBIT_OPTION) {
            (bytes32[2] memory ids, address[2] memory token, uint256[2] memory amount, uint32 timeout) = abi.decode(args, (bytes32[2], address[2], uint256[2], uint32));
            ExenoFinance.validateOption(d, token[0], amount[0]);
            ExenoFinance.emitOption(d, ids[0], token[0], amount[0], timeout);
            _executeReward(d, ids[1], token[1], amount[1]);
        }
    }

    /**
     * Process a credit transaction according to the instruction defined in the `method[1]` parameter:
     * (a) METHOD_MINT - when the token on the destination chain is mintable
     * (b) METHOD_UNFREEZE - when the token on the origin chain is mintable
     */
    function _processCredit(
        ExenoFinance.Data memory d,
        bytes memory params
    )
        internal
    {
        (bytes32 action, bytes memory args) = abi.decode(params, (bytes32, bytes));
        if (action == ACTION_CREDIT_ORACLE) {
            (uint256 amount) = abi.decode(args, (uint256));
            ExenoFinance.validateOracle(d, amount);
            d.amount[1] = amount;
        }
        ExenoFinance.validateCredit(d, !isCreditId(d.id), NETWORK);
        creditIds[d.id] = true;
        if (d.method[1] == ExenoFinance.METHOD_MINT) {
            require(_isMintable(d.token[1]),
                "EFN: mint for non-mintable token");
            if (d.explicit[1]) {
                IExenoToken(d.token[1]).mint(d.beneficiary[1], d.amount[1]);
            } else {
                IExenoToken(d.token[1]).mint(address(this), d.amount[1]);
                _registerDeposits(d.beneficiary[1], d.token[1], d.amount[1]);
            }
        } else if (d.method[1] == ExenoFinance.METHOD_UNFREEZE) {
            require(_isCore(d.token[1]),
                "EFN: unfreeze for non-core token");
            require(ownedTokens(d.token[1]) >= d.amount[1],
                "EFN: n/e owned tokens");
            require(frozenTokens >= d.amount[1],
                "EFN: n/e frozen tokens");
            frozenTokens -= d.amount[1];
            if (d.explicit[1]) {
                ExenoFinance.transferTo(d.beneficiary[1], d.token[1], d.amount[1], d.amount[1]);
            } else {
                _registerDeposits(d.beneficiary[1], d.token[1], d.amount[1]);
            }
        } else {
            if (d.explicit[1]) {
                if (_isNative(d.token[1])) {
                    Address.sendValue(payable(d.beneficiary[1]), d.amount[1]);
                } else {
                    ExenoFinance.transferTo(d.beneficiary[1], d.token[1], d.amount[1], availableTokens(d.token[1]));
                }
            } else {
                _registerDeposits(d.beneficiary[1], d.token[1], d.amount[1]);
            }
        }
        if (d.method[1] == ExenoFinance.METHOD_UNSTAKE) {
            _registerUnstakes(d.beneficiary[0], d.token[0], d.amount[0]);
        }
        if (d.method[1] != ExenoFinance.METHOD_SWAP) {
            ExenoFinance.emitCredit(d);
        }
        // if (action == ACTION_CREDIT_REWARD) {
        //     (address token, uint256 amount) = abi.decode(args, (address, uint256));
        //     if (d.explicit[1]) {
        //         if (_isNative(token)) {
        //             Address.sendValue(payable(d.beneficiary[1]), amount);
        //         } else {
        //             ExenoFinance.transferTo(d.beneficiary[1], token, amount, availableTokens(token));
        //         }
        //     } else {
        //         _registerDeposits(d.beneficiary[1], token, amount);
        //     }
        // }
    }

    /**
     * Process a swap transaction - payout is done immediately after funds are paid in
     */
    function _processSwap(
        ExenoFinance.Data memory d,
        address sender
    )
        internal
    {
        ExenoFinance.validateSwap(d);
        _processDebit(d, sender, bytes(""));
        _processCredit(d, bytes(""));
        ExenoFinance.emitSwap(d);
    }

    /**
     * Process an option transaction
     */
    function _processOption(
        ExenoFinance.Data memory d
    )
        internal
    {   
        ExenoFinance.validateOption(d, !isDebitId(d.id));
        ExenoFinance.emitOption(d);
        debitIds[d.id] = true;
    }

    /**
     *  Process a voucher transaction
     */
    function _processVoucher(
        ExenoFinance.Data memory d,
        address sender,
        bytes memory params
    )
        internal
    {
        (bytes32 action, bytes memory args) = abi.decode(params, (bytes32, bytes));
        if (action == ACTION_VOUCHER_CEDE) {
            (bytes32[2] memory ids, address beneficiary, bytes memory proof, uint256 amount) = abi.decode(args, (bytes32[2], address, bytes, uint256));
            ExenoFinance.validateVoucherCede(d, [!isCreditId(d.id), !isCreditId(ids[0]), !isCreditId(ids[1])], NETWORK, sender, ids, beneficiary, proof, amount);
            ExenoFinance.emitSpinoffForVoucherCede(d, ids, beneficiary, amount);
            _executeWaive(d.id, ids);
        } else if (action == ACTION_VOUCHER_CLAIM) {
            (bytes32[2] memory ids, address beneficiary, bytes memory proof, uint256 amount) = abi.decode(args, (bytes32[2], address, bytes, uint256));
            ExenoFinance.validateVoucherClaim(d, [!isCreditId(d.id), !isCreditId(ids[0]), !isCreditId(ids[1])], NETWORK, sender, ids, beneficiary, proof, amount);
            ExenoFinance.emitSpinoffForVoucherClaim(d, ids, beneficiary, amount);
            _executeWaive(d.id, ids);
        } else {
            revert("EFN: unknown action");
        }
    }

    /**
     * Process an escrow transaction:
     * (a) If it's a cede request: invalidate the current credit title and create a spinoff for another beneficiary (in case cession is partial: the remainder is returned to the original owner with an additional spinoff)
     * (b) If it's a revocation request: invalidate the orginal credit title and all subsequent spinoffs made from this title
     * The history of spinoffs is stored in the `spinoffIds` map, so that all of them can be invalidated in case revocation made
     */
    function _processEscrow(
        ExenoFinance.Data memory d,
        address sender,
        bytes memory params
    )
        internal
    {
        (bytes32 action, bytes memory args) = abi.decode(params, (bytes32, bytes));
        if (action == ACTION_ESCROW_CEDE) {
            (bytes32[2] memory ids, address beneficiary, uint256 amount) = abi.decode(args, (bytes32[2], address, uint256));
            ExenoFinance.validateEscrowCede(d, [!isCreditId(d.id), !isCreditId(ids[0]), !isCreditId(ids[1])], NETWORK, sender, ids, beneficiary, amount);
            ExenoFinance.emitSpinoffForEscrowCede(d, ids, beneficiary, amount);
            _executeWaive(d.id, ids);
        } else if (action == ACTION_ESCROW_REVOKE) {
            ExenoFinance.validateEscrowRevoke(d, !isCreditId(d.id), NETWORK, sender);
            _executeRevoke(d);
        } else {
            revert("EFN: unknown action");
        }
    }

    /**
     * Use this contract's balance to pay reward to the beneficiary
     */
    function _executeReward(
        ExenoFinance.Data memory d,
        bytes32 id,
        address token,
        uint256 amount
    )
        internal
    {
        require(_depositBalance(address(this), token) >= amount,
            "EFN: n/e deposit balance for reward");
        _registerUndeposits(address(this), token, amount);
        ExenoFinance.emitDebitReward(d, id, token, amount);
    }

    /**
     * Waive the original credit title and create spinoffs
     */
    function _executeWaive(
        bytes32 id,
        bytes32[2] memory ids
    )
        internal
    {
        ExenoFinance.emitWaive(id, ids);
        creditIds[id] = true;
        spinoffIds[id] = ids;
    }

    /**
     * Revoke the original credit title and subsequent spinoffs
     */
    function _executeRevoke(
       ExenoFinance.Data memory d
    )
        internal
    {
        ExenoFinance.emitRevoke(d);
        creditIds[d.id] = true;
        (bytes32[] memory list, uint256 size) = getSpinoffList(d.id);
        for (uint256 i = 0; i < size; i++) {
            require(!isCreditId(list[i]),
                "EFN: spinoff a/y recalled");
            creditIds[list[i]] = true;
            ExenoFinance.emitRecall(list[i], d.id);
        }
    }

    /**
     * For inbound transactions only payloads signed by the signer are accepted
     */
    function _verifySingleSignature(
        bytes32 operation,
        bytes memory payload,
        bytes memory params,
        uint256[2] memory fee,
        bytes memory signature
    )
        internal view returns(ExenoFinance.Data memory)
    {
        require(signers[ExenoFinance.verifySingleSignature(operation, payload, params, fee, signature)],
            "EFN: unauthorized signer");
        return(_unpackPayload(payload));
    }

    /**
     * For outbound transactions only payloads signed by 3 signers are accepted
     */
    function _verifyTripleSignature(
        bytes32 operation,
        bytes memory payload,
        bytes memory params,
        uint256[2] memory fee,
        bytes[3] memory signature
    )
        internal view returns(ExenoFinance.Data memory)
    {
        (address[3] memory signer, bool unique) = ExenoFinance.verifyTripleSignature(operation, payload, params, fee, signature);
        require(unique && signers[signer[0]] && signers[signer[1]] && signers[signer[2]],
            "EFN: unauthorized signer");
        return(_unpackPayload(payload));
    }

    /**
     * Unpack encoded unsigned payload
     */
    function _unpackPayload(bytes memory payload)
        internal pure returns(ExenoFinance.Data memory)
    {
        (
            bytes32 id,
            address platform,
            address affiliate,
            bytes32[2] memory network,
            address[2] memory beneficiary,
            address[2] memory token,
            uint256[2] memory amount,
            int32[2] memory timeout,
            bytes32[2] memory method,
            bool[2] memory explicit,
            bytes memory memo
        ) = abi.decode(payload, (bytes32, address, address, bytes32[2], address[2], address[2],  uint256[2], int32[2], bytes32[2], bool[2], bytes));
        return(ExenoFinance.Data(id, platform, affiliate, network, beneficiary, token, amount, timeout, method, explicit, memo));
    }

    /**
     * Unpack encoded signed data with one signature
     */
    function _unpackSingleSignedData(bytes memory encodedData)
        internal pure returns(bytes memory, bytes memory, uint256[2] memory, bytes memory)
    {
        (
            bytes memory payload,
            bytes memory params,
            uint256[2] memory fee,
            bytes memory signature
        ) = abi.decode(encodedData, (bytes, bytes, uint256[2], bytes));
        return(payload, params, fee, signature);
    }
    
    /**
     * Unpack encoded signed data with three signatures
     */
    function _unpackTripleSignedData(bytes memory encodedData)
        internal pure returns(bytes memory, bytes memory, uint256[2] memory, bytes[3] memory)
    {
        (
            bytes memory payload,
            bytes memory params,
            uint256[2] memory fee,
            bytes[3] memory signature
        ) = abi.decode(encodedData, (bytes, bytes, uint256[2], bytes[3]));
        return(payload, params, fee, signature);
    }

    /**
     * Unpack and validate signle-signed data
     */
    function _unpackAndValidateSingleSignedData(
        bytes calldata encodedData,
        bytes32 class
    )
        internal view returns(ExenoFinance.Data memory, bytes memory, uint256[2] memory)
    {
        (bytes32 operation, bytes memory data) = abi.decode(encodedData, (bytes32, bytes));
        _validateClass(operation, class);
        (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes memory signature) = _unpackSingleSignedData(data);
        return(_verifySingleSignature(operation, payload, params, fee, signature), params, fee);
    }

    /**
     * Unpack and validate triple-signed data
     */
    function _unpackAndValidateTripleSignedData(
        bytes calldata encodedData,
        bytes32 class
    )
        internal view returns(ExenoFinance.Data memory, bytes memory, uint256[2] memory)
    {
        (bytes32 operation, bytes memory data) = abi.decode(encodedData, (bytes32, bytes));
        _validateClass(operation, class);
        (bytes memory payload, bytes memory params, uint256[2] memory fee, bytes[3] memory signature) = _unpackTripleSignedData(data);
        return(_verifyTripleSignature(operation, payload, params, fee, signature), params, fee);
    }

    /**
     * Register a token transacted with this contract
     */
    function _registerToken(address token)
        internal
    {
        if (!tokens[token]) {
            tokenList.push(token);
            tokens[token] = true;
        }
    }

    /**
     * Register deposit made by a beneficiary
     */
    function _registerDeposits(
        address beneficiary,
        address token,
        uint256 amount
    )
        internal
    {
        deposits[beneficiary][token] += amount;
        deposits[address(0)][token] += amount;
    }

    /**
     * Register withdrawing a deposit by a beneficiary
     */
    function _registerUndeposits(
        address beneficiary,
        address token,
        uint256 amount
    )
        internal
    {
        undeposits[beneficiary][token] += amount;
        undeposits[address(0)][token] += amount;
    }

    /**
     * Register an act of staking by a beneficiary
     */
    function _registerStakes(
        address beneficiary,
        address token,
        uint256 amount
    )
        internal
    {
        stakes[beneficiary][token] += amount;
        stakes[address(0)][token] += amount;
    }

    /**
     * Register an act of unstaking by a beneficiary
     */
    function _registerUnstakes(
        address beneficiary,
        address token,
        uint256 amount
    )
        internal
    {
        unstakes[beneficiary][token] += amount;
        unstakes[address(0)][token] += amount;
    }

    /**
     * Register fees allocated to platform & affiliate
     */
    function _registerFees(
        Ccy ccy,
        address platform,
        address affiliate,
        uint256 earnedFee,
        uint256 extraFee
    )
        internal
    {
        earnedFees[platform][uint8(ccy)] += earnedFee;
        earnedFees[affiliate][uint8(ccy)] += earnedFee;
        earnedFees[address(0)][uint8(ccy)] += earnedFee;
        extraFees[platform][uint8(ccy)] += extraFee;
        extraFees[address(0)][uint8(ccy)] += extraFee;
    }

    /**
     * Check whether we are dealing with the native currency
     */
    function _isNative(address token)
        internal pure returns(bool)
    {
        return(token == nativeToken());
    }

    /**
     * Check whether we are dealing with the core token (i.e. EXN token)
     */
    function _isCore(address token)
        internal view returns(bool)
    {
        return(token == coreToken());
    }

    /**
     * Check whether we are dealing with a mintable core token (not all incarnations of the EXN token are mintable)
     */
    function _isMintable(address token)
        internal view returns(bool)
    {
        if (!_isCore(token)) {
            return(false);
        }
        IExenoToken mintable = IExenoToken(token);
        try mintable.manager() returns(address manager) {
            return(manager == address(this));
        } catch (bytes memory) {
            return(false);
        }
    }

    /**
     * Count the number of spinoffs for a given credit title
     */
    function _countSpinoffs(
        bytes32 id,
        uint256 count,
        bool reentry
    )
        internal view returns(uint256)
    {
        bytes32[2] memory ids = getSpinoffIds(id);
        if (ids[0] != bytes32(0)) {
            count = _countSpinoffs(ids[0], count, true);
            if (ids[1] != bytes32(0)) {
                count = _countSpinoffs(ids[1], count, true);
            }
        } else if (reentry) {
            count++;
        }
        return(count);
    }

    /**
     * Populate the list of spinoffs for a given credit title
     */
    function _populateSpinoffs(
        bytes32 id,
        uint256 index,
        bytes32[] memory list,
        bool reentry
    )
        internal view returns(uint256)
    {
        bytes32[2] memory ids = getSpinoffIds(id);
        if (ids[0] != bytes32(0)) {
            index = _populateSpinoffs(ids[0], index, list, true);
            if (ids[1] != bytes32(0)) {
                index = _populateSpinoffs(ids[1], index, list, true);
            }
        } else if (reentry) {
            list[index++] = id;
        }
        return(index);
    }

    /**
     * Retrieve the net deposit balance for a given beneficiary and a given token
     */
    function _depositBalance(
        address beneficiary,
        address token
    )
        internal view returns(uint256)
    {
        uint256 inflow = getDeposits(beneficiary, token);
        uint256 outflow = getUndeposits(beneficiary, token);
        return(inflow >= outflow ? inflow - outflow : 0);
    }
    
    /**
     * Return the the native currency (indicated as zero address)
     */
    function nativeToken()
        public pure override returns(address)
    {
        return(address(0));
    }

    /**
     * Return the IERC1363 token associated with this contract, i.e. EXN token
     */
    function coreToken()
        public view override returns(address)
    {
        return(address(acceptedToken()));
    }

    /**
     * Verify if debit id has already been used - takes into account previous deployments of this contract
     */
    function isDebitId(bytes32 id)
        public view override returns(bool)
    {
        return(debitIds[id] || (address(PREDECESSOR) != address(0) && PREDECESSOR.isDebitId(id)));
    }

    /**
     * Verify if credit id has already been used - takes into account previous deployments of this contract
     */
    function isCreditId(bytes32 id)
        public view override returns(bool)
    {
        return(creditIds[id] || (address(PREDECESSOR) != address(0) && PREDECESSOR.isCreditId(id)));
    }

    /**
     * Retrieve ids of spinoffs for a given credit title - takes into account previous deployments of this contract
     */
    function getSpinoffIds(bytes32 id)
        public view returns(bytes32[2] memory ids)
    {
        if (spinoffIds[id][0] != bytes32(0)) {
            ids = spinoffIds[id];
        } else if (address(PREDECESSOR) != address(0)) {
            ids = PREDECESSOR.getSpinoffIds(id);
        }
        return(ids);
    }

    /**
     * Retrieve the list of all spinoffs for a given credit title
     */
    function getSpinoffList(bytes32 id)
        public view override returns(bytes32[] memory, uint256)
    {
        uint256 size = _countSpinoffs(id, 0, false);
        bytes32[] memory list = new bytes32[](size);
        uint256 index = _populateSpinoffs(id, 0, list, false);
        assert(index == size);
        return(list, size);
    }

    /**
     * Retrieve the list all deposited tokens
     */
    function getTokenList()
        external view override returns(address[] memory, uint256)
    {
        return(tokenList, tokenList.length);
    }

    /**
     * Retrieve the total of deposits made by a given beneficiary and a given token - takes into account previous deployments of this contract
     */
    function getDeposits(
        address beneficiary,
        address token
    )
        public view override returns(uint256)
    {
        return(deposits[beneficiary][token] + (address(PREDECESSOR) != address(0) ? PREDECESSOR.getDeposits(beneficiary, token) : 0));
    }

    /**
     * Retrieve the total of deposits withdrawn by a given beneficiary and a given token - takes into account previous deployments of this contract
     */
    function getUndeposits(
        address beneficiary,
        address token
    )
        public view override returns(uint256)
    {
        return(undeposits[beneficiary][token] + (address(PREDECESSOR) != address(0) ? PREDECESSOR.getUndeposits(beneficiary, token) : 0));
    }

    /**
     * Retrieve the total of stakes deposited by a given beneficiary and a given token - takes into account previous deployments of this contract
     */
    function getStakes(
        address beneficiary,
        address token
    )
        external view override returns(uint256)
    {
        return(stakes[beneficiary][token] + (address(PREDECESSOR) != address(0) ? PREDECESSOR.getStakes(beneficiary, token) : 0));
    }

    /**
     * Retrieve the total of stakes withdrawn by a given beneficiary and a given token - takes into account previous deployments of this contract
     */
    function getUnstakes(
        address beneficiary,
        address token
    )
        external view override returns(uint256)
    {
        return(unstakes[beneficiary][token] + (address(PREDECESSOR) != address(0) ? PREDECESSOR.getUnstakes(beneficiary, token) : 0));
    }

    /**
     * Current balance of a token
     */
    function ownedTokens(address token)
        public view override returns(uint256)
    {
        if (_isNative(token)) {
            return(address(this).balance);
        }
        return(IERC20(token).balanceOf(address(this)));
    }

    /**
     * How many tokens are available for payouts
     */
    function availableTokens(address token)
        public view override returns(uint256)
    {
        uint256 balance = ownedTokens(token);
        if (_isCore(token)) {
            // Frozen tokens should be excluded from the liquidity pool
            return(balance >= frozenTokens ? balance - frozenTokens : 0);
        }
        return(balance);
    }

    /**
     * Freeze core tokens - only to be used when initializing the contract
     */
    function freezeTokens(
        uint256 amount,
        address wallet
    )
        external onlyOwner nonReentrant
    {
        ExenoFinance.transferFrom(wallet, coreToken(), amount);
        frozenTokens += amount;
        emit FreezeTokens(amount);
    }

    /**
     * Unfreeze core tokens - only to be used when decommissioning the contract
     */
    function unfreezeTokens(
        uint256 amount,
        address wallet
    )
        external onlyOwner nonReentrant
    {
        ExenoFinance.transferTo(wallet, coreToken(), amount, frozenTokens);
        frozenTokens -= amount;
        emit UnfreezeTokens(amount);
    }

    /**
     * Release a specified amount of available funds in native currency
     */
    function releaseAvailableCash(
        uint256 amount,
        address wallet
    )
        public onlyOwner
    {
        Address.sendValue(payable(wallet), amount);
        emit ReleaseFunds(nativeToken(), amount);
    }

    /**
     * Release a specified amount of an ERC20 token
     */
    function releaseAvailableTokens(
        address token,
        uint256 amount,
        address wallet
    )
        external onlyOwner nonReentrant
    {
        ExenoFinance.transferTo(wallet, token, amount, availableTokens(token));
        emit ReleaseFunds(token, amount);
    }

    /**
     * Release all available funds
     */
    function releaseEverything(address wallet)
        external onlyOwner nonReentrant
    {
        uint256 size = tokenList.length;
        for (uint256 i = 0; i < size; i++) {
            address token = tokenList[i];
            uint256 amount = availableTokens(token);
            if (amount > 0) {
                if (_isNative(token)) {
                    Address.sendValue(payable(wallet), amount);
                } else {
                    ExenoFinance.transferTo(wallet, token, amount, amount);
                }
                emit ReleaseFunds(token, amount);
            }
        }
    }

    /**
     * Reset earned fees for an actor 
     */
    // function resetEarnedFees(address actor)
    //     external
    // {
    //     require(msg.sender == owner() || msg.sender == actor,
    //         "EFN: unauthorized sender");
    //     require(earnedFees[actor][0] > 0 || earnedFees[actor][1] > 0,
    //         "EFN: no fees");
    //     emit ResetEarnedFees(actor, earnedFees[actor]);
    //     earnedFees[actor][0] = 0;
    //     earnedFees[actor][1] = 0;
    // }

    /**
     * Release extra fees
     */
    // function releaseExtraFees(address platform)
    //     external nonReentrant
    // {
    //     require(msg.sender == owner() || msg.sender == platform,
    //         "EFN: unauthorized sender");
    //     require(extraFees[platform][0] > 0 || extraFees[platform][1] > 0,
    //         "EFN: no fees");
    //     emit ReleaseExtraFees(platform, extraFees[platform]);
    //     if (extraFees[platform][0] > 0) {
    //         Address.sendValue(payable(platform), extraFees[platform][0]);
    //         extraFees[platform][0] = 0;
    //     }
    //     if (extraFees[platform][1] > 0) {
    //         ExenoFinance.transferTo(platform, coreToken(), extraFees[platform][1], availableTokens(coreToken()));
    //         extraFees[platform][1] = 0;
    //     }
    // }

    /**
     * Configure signers
     */
    function setSigners(address[SIGNER_SIZE] calldata newSigners)
        external onlyOwner
    {
        for (uint8 i = 0; i < SIGNER_SIZE; i++) {
            signers[signerList[i]] = false;
        }
        for (uint8 i = 0; i < SIGNER_SIZE; i++) {
            signers[newSigners[i]] = true;
            signerList[i] = newSigners[i];
        }
        emit SetSigners(newSigners);
    }

    /**
     * Pause all operations
     */
    function pause()
        external onlyOwner
    {
        _pause();
    }
    
    /**
     * Unpause all operations
     */
    function unpause()
        external onlyOwner
    {
        _unpause();
    }

    /**
     * Decommission this contract
     */
    function decommission(address wallet)
        external onlyOwner
    {
        selfdestruct(payable(wallet));
    }
}

/**
 * Stateless logic extracted into a library to reduce the contract's size
 */

library ExenoFinance {
    bytes32 public constant METHOD_MINT = bytes32("mint");
    bytes32 public constant METHOD_BURN = bytes32("burn");
    bytes32 public constant METHOD_FREEZE = bytes32("freeze");
    bytes32 public constant METHOD_UNFREEZE = bytes32("unfreeze");
    bytes32 public constant METHOD_STAKE = bytes32("stake");
    bytes32 public constant METHOD_UNSTAKE = bytes32("unstake");
    bytes32 public constant METHOD_SWAP = bytes32("swap");
    bytes32 public constant METHOD_ORACLE = bytes32("oracle");
    bytes32 public constant METHOD_REWARD = bytes32("reward");
    bytes32 public constant METHOD_VOUCHER = bytes32("voucher");
    bytes32 public constant METHOD_ESCROW = bytes32("escrow");

    /**
     * Data payload describing the entire cross-blockchain transfer
     * For pairs: the first value refers to what happens on the origin chain (debit side), the second value refers to what happens on the destination chain (credit side)
     */
    struct Data {
        bytes32 id;
        address platform;
        address affiliate;
        bytes32[2] network;
        address[2] beneficiary;
        address[2] token;
        uint256[2] amount;
        int32[2] timeout;
        bytes32[2] method;
        bool[2] explicit;
        bytes memo;
    }

    // Indicates that a debit transaction has been made
    event Debit(
        bytes32 indexed id,
        address indexed platform,
        address indexed affiliate,
        bytes32[2] network,
        address[2] beneficiary,
        address[2] token,
        uint256[2] amount,
        int32[2] timeout,
        bytes32[2] method,
        bool[2] explicit,
        bytes memo
    );

    // Indicates that a credit transaction has been made
    event Credit(
        bytes32 indexed id,
        address indexed platform,
        address indexed affiliate,
        bytes32[2] network,
        address[2] beneficiary,
        address[2] token,
        uint256[2] amount,
        int32[2] timeout,
        bytes32[2] method,
        bool[2] explicit,
        bytes memo
    );

    // Indicates that a swap transaction has been made
    event Swap(
        bytes32 indexed id,
        address indexed platform,
        address indexed affiliate,
        bytes32[2] network,
        address[2] beneficiary,
        address[2] token,
        uint256[2] amount,
        int32[2] timeout,
        bytes32[2] method,
        bool[2] explicit,
        bytes memo
    );

    // Indicates that an option transaction has been made
    event Option(
        bytes32 indexed id,
        address indexed platform,
        address indexed affiliate,
        bytes32[2] network,
        address[2] beneficiary,
        address[2] token,
        uint256[2] amount,
        int32[2] timeout,
        bytes32[2] method,
        bool[2] explicit,
        bytes memo
    );

    // Indicates that a new credit titles has been added on top of an existing one
    event Spinoff(
        bytes32 indexed id,
        address indexed platform,
        address indexed affiliate,
        bytes32[2] network,
        address[2] beneficiary,
        address[2] token,
        uint256[2] amount,
        int32[2] timeout,
        bytes32[2] method,
        bool[2] explicit,
        bytes memo
    );

    // Indicates that a credit title has been revoked by the payer during escrow
    event Revoke(
        bytes32 indexed id,
        address indexed platform,
        address indexed affiliate,
        bytes32[2] network,
        address[2] beneficiary,
        address[2] token,
        uint256[2] amount,
        int32[2] timeout,
        bytes32[2] method,
        bool[2] explicit,
        bytes memo
    );

    // Indicates that a credit title has been waived by the payee (with one or two spinoffs)
    event Waive(
        bytes32 indexed id,
        bytes32[2] spinoffIds
    );

    // Indicates that a spinoff has been recalled by the payer during escrow
    event Recall(
        bytes32 indexed id,
        bytes32 indexed originId
    );

    /**
     * Validate pre-conditions for a debit operation
     */
    function validateDebit(
        Data calldata d,
        bool unprocessed,
        bytes32 network,
        address sender
    )
        external view
    {
        require(d.platform != address(0),
            "EFN: undefined platform");
        require(d.affiliate != address(0),
            "EFN: undefined affiliate");
        require(d.network[0] == network,
            "EFN: network mismatch");
        require(d.beneficiary[0] == sender,
            "EFN: unexpected sender");
        require(d.amount[0] > 0,
            "EFN: undefined a/t");
        require(verifyTimeout(d.timeout[0]),
            "EFN: time-window a/y expired");
        require(unprocessed || d.method[0] == METHOD_SWAP,
            "EFN: debit a/y processed");
        if (d.method[0] == METHOD_BURN || d.method[0] == METHOD_FREEZE) {
            require(d.method[1] == METHOD_MINT || d.method[1] == METHOD_UNFREEZE,
                "EFN: method mismatch");
        } else if (d.method[0] == METHOD_SWAP) {
            require(d.method[1] == METHOD_SWAP,
                "EFN: method mismatch");
            require(d.network[0] == d.network[1],
                "EFN: network mismatch");
        } else if (d.method[0] == METHOD_STAKE) {
            require(d.method[1] == METHOD_UNSTAKE,
                "EFN: method mismatch");
            require(d.network[0] == d.network[1],
                "EFN: network mismatch");
            require(d.beneficiary[0] == d.beneficiary[1],
                "EFN: beneficiary mismatch");
            require(d.token[0] == d.token[1],
                "EFN: token mismatch");
        } else if (d.method[0] == METHOD_ORACLE) {
            require(d.method[1] == METHOD_ORACLE,
                "EFN: method mismatch");
            require(d.timeout[1] < 0,
                "EFN: timeout mismatch");
        } else if (d.method[0] == METHOD_VOUCHER) {
            require(d.method[1] == METHOD_VOUCHER,
                "EFN: method mismatch");
            require(d.network[0] == network,
                "EFN: network mismatch");
            require(d.beneficiary[1] == address(0),
                "EFN: beneficiary mismatch");
            require(d.amount[0] == d.amount[1],
                "EFN: amount mismatch");
        } else if (d.method[0] == METHOD_ESCROW) {
            require(d.method[1] == METHOD_ESCROW,
                "EFN: method mismatch");
            require(d.timeout[1] < 0,
                "EFN: timeout mismatch");
        } else {
            require(d.method[0] == bytes32(0),
                "EFN: method mismatch");
            require(d.method[1] == bytes32(0),
                "EFN: method mismatch");
        }
    }

    /**
     * Validate pre-conditions for a credit operation
     */
    function validateCredit(
        Data calldata d,
        bool unprocessed,
        bytes32 network
    )
        external view
    {
        require(d.platform != address(0),
            "EFN: undefined platform");
        require(d.affiliate != address(0),
            "EFN: undefined affiliate");
        require(d.network[1] == network,
            "EFN: network mismatch");
        require(d.beneficiary[1] != address(0),
            "EFN: undefined beneficiary");
        require(d.amount[1] > 0,
            "EFN: undefined a/t");
        require(verifyTimeout(d.timeout[1]),
            "EFN: time-window a/y expired");
        require(unprocessed,
            "EFN: credit a/y processed");
        if (d.method[1] == METHOD_MINT || d.method[1] == METHOD_UNFREEZE) {
            require(d.method[0] == METHOD_BURN || d.method[0] == METHOD_FREEZE,
                "EFN: method mismatch");
        } else if (d.method[1] == METHOD_SWAP) {
             require(d.method[0] == METHOD_SWAP,
                "EFN: method mismatch");
            require(d.network[0] == d.network[1],
                "EFN: network mismatch");
        } else if (d.method[1] == METHOD_UNSTAKE) {
            require(d.method[0] == METHOD_STAKE,
                "EFN: method mismatch");
            require(d.network[0] == d.network[1],
                "EFN: network mismatch");
            require(d.beneficiary[0] == d.beneficiary[1],
                "EFN: beneficiary mismatch");
            require(d.token[0] == d.token[1],
                "EFN: token mismatch");
        } else if (d.method[0] == METHOD_ORACLE) {
            require(d.method[1] == METHOD_ORACLE,
                "EFN: method mismatch");
            require(d.timeout[1] < 0,
                "EFN: timeout mismatch");
        } else if (d.method[1] == METHOD_VOUCHER) {
            require(d.method[0] == METHOD_VOUCHER,
                "EFN: method mismatch");
            require(d.network[0] == network,
                "EFN: network mismatch");
            require(d.amount[0] == d.amount[1],
                "EFN: amount mismatch");
        } else if (d.method[1] == METHOD_ESCROW) {
            require(d.method[0] == METHOD_ESCROW,
                "EFN: method mismatch");
            require(d.timeout[1] < 0,
                "EFN: timeout mismatch");
        } else {
            require(d.method[0] == bytes32(0),
                "EFN: method mismatch");
            require(d.method[1] == bytes32(0),
                "EFN: method mismatch");
        }
    }

    /**
     * Validate pre-conditions for a swap
     */
    function validateSwap(
        Data calldata d
    )
        external pure
    {
        require(d.method[0] == METHOD_SWAP
            && d.method[1] == METHOD_SWAP,
            "EFN: method mismatch");
    }

    /**
     * Validate pre-conditions for an option
     */
    function validateOption(
        Data calldata d,
        bool unprocessed
    )
        external pure
    {
        require(unprocessed,
            "EFN: option a/y processed");
        require(d.token[0] != d.token[1],
            "EFN: token mismatch");
        require(d.timeout[0] > 0 && d.timeout[1] == 0,
            "EFN: timeout mismatch");
        require(d.method[0] == METHOD_SWAP
            && d.method[1] == METHOD_SWAP,
            "EFN: method mismatch");
    }

    /**
     * Validate pre-conditions for a sell option
     */
    function validateOption(
        Data calldata d,
        address token,
        uint256 amount
    )
        external pure
    {
        require(token != d.token[0],
            "EFN: token mismatch");
        require(amount > 0,
            "EFN: amount mismatch");
        require(d.timeout[0] > 0 && d.timeout[1] == 0,
            "EFN: timeout mismatch");
        require(d.method[0] == METHOD_SWAP
            && d.method[1] == METHOD_SWAP,
            "EFN: method mismatch");
    }

    /**
     * Validate pre-conditions for an oracle
     */
    function validateOracle(
        Data calldata d,
        uint256 amount
    )
        external pure
    {
        require(d.amount[1] == 0,
            "EFN: amount a/y defined");
        require(amount > 0,
            "EFN: undefined a/t");
        require(d.method[0] == METHOD_ORACLE
            && d.method[1] == METHOD_ORACLE,
            "EFN: method mismatch");
    }

    /**
     * Validate for ceding a voucher
     */
    function validateVoucherCede(
        Data calldata d,
        bool[3] calldata unprocessed,
        bytes32 network,
        address sender,
        bytes32[2] calldata ids,
        address beneficiary,
        bytes calldata proof,
        uint256 amount
    )
        external pure
    {
        require(d.network[0] == network,
            "EFN: network mismatch");
        require(d.beneficiary[1] == address(0),
            "EFN: beneficiary a/y defined");
        require(d.amount[0] == d.amount[1],
            "EFN: amount mismatch");
        require(ids[0] != bytes32(0),
            "EFN: undefined ids[0]");
        require(amount == d.amount[1] || ids[1] != bytes32(0),
            "EFN: undefined ids[1]");
        require(sender == d.beneficiary[0]
            || ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(beneficiary))), proof) == d.beneficiary[0],
            "EFN: unexpected sender or failed proof");
        require(amount <= d.amount[0],
            "EFN: spinoff a/t exceeds original a/t");
        require(unprocessed[0] && unprocessed[1] && unprocessed[2],
            "EFN: credit a/y processed");
        require(d.method[0] == METHOD_VOUCHER
            && d.method[1] == METHOD_VOUCHER,
            "EFN: method mismatch");
    }

    /**
     * Validate pre-conditions for claiming a voucher
     */
    function validateVoucherClaim(
        Data calldata d,
        bool[3] calldata unprocessed,
        bytes32 network,
        address sender,
        bytes32[2] calldata ids,
        address beneficiary,
        bytes calldata proof,
        uint256 amount
    )
        external pure
    {
        require(d.network[0] == network,
            "EFN: network mismatch");
        require(d.beneficiary[1] == address(0),
            "EFN: beneficiary a/y defined");
        require(d.amount[0] == d.amount[1],
            "EFN: amount mismatch");
        require(ids[0] != bytes32(0),
            "EFN: undefined ids[0]");
        require(amount == d.amount[1] || ids[1] != bytes32(0),
            "EFN: undefined ids[1]");
        require(sender == d.beneficiary[0]
            || ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(beneficiary))), proof) == d.beneficiary[0],
            "EFN: unexpected sender or failed proof");
        require(amount <= d.amount[0],
            "EFN: spinoff a/t exceeds original a/t");
        require(unprocessed[0] && unprocessed[1] && unprocessed[2],
            "EFN: credit a/y processed");
        require(d.method[0] == METHOD_VOUCHER
            && d.method[1] == METHOD_VOUCHER,
            "EFN: method mismatch");
    }

    /**
     * Validate pre-conditions for ceding an escrow
     */
    function validateEscrowCede(
        Data calldata d,
        bool[3] calldata unprocessed,
        bytes32 network,
        address sender,
        bytes32[2] calldata ids,
        address beneficiary,
        uint256 amount
    )
        external pure
    {
        require(d.network[1] == network,
            "EFN: network mismatch");
        require(sender == d.beneficiary[1],
            "EFN: unexpected sender");
        require(ids[0] != bytes32(0),
            "EFN: undefined ids[0]");
        require(amount == d.amount[1] || ids[1] != bytes32(0),
            "EFN: undefined ids[1]");
        require(beneficiary != d.beneficiary[1],
            "EFN: beneficiary a/y applied");
        require(amount <= d.amount[1],
            "EFN: spinoff a/t exceeds original a/t");
        require(unprocessed[0] && unprocessed[1] && unprocessed[2],
            "EFN: credit a/y processed");
        require(d.method[0] == METHOD_ESCROW
            && d.method[1] == METHOD_ESCROW,
            "EFN: method mismatch");
    }

    /**
     * Validate pre-conditions for revoking an escrow
     */
    function validateEscrowRevoke(
        Data calldata d,
        bool unprocessed,
        bytes32 network,
        address sender
    )
        external view
    {
        require(d.network[1] == network,
            "EFN: network mismatch");
        require(verifyTimeout(d.timeout[1]),
            "EFN: time-window a/y expired");
        require(sender == d.beneficiary[0],
            "EFN: unexpected sender");
        require(unprocessed,
            "EFN: credit a/y revoked");
        require(d.method[0] == METHOD_ESCROW
            && d.method[1] == METHOD_ESCROW,
            "EFN: method mismatch");
    }

    /**
     * Check balance and apply ERC20 `transfer`
     */
    function transferTo(
        address payee,
        address token,
        uint256 amount,
        uint256 balance
    )
        external
    {
        if (payee == address(this)) {
            return;
        }
        require(balance >= amount,
            "EFN: n/e available tokens");
        require(IERC20(token).transfer(payee, amount),
            "EFN: transfer failed");
    }

    /**
     * Check allowance and apply ERC20 `transferFrom`
     */
    function transferFrom(
        address payer,
        address token,
        uint256 amount
    )
        external
    {
        if (payer == address(this)) {
            return;
        }
        require(IERC20(token).allowance(payer, address(this)) >= amount,
            "EFN: unapproved a/t");
        require(IERC20(token).transferFrom(payer, address(this), amount),
            "EFN: transfer failed");
    }

    /**
     * Publish a debit event
     */
    function emitDebit(Data calldata d)
        external
    {
        emit Debit(d.id, d.platform, d.affiliate, d.network, d.beneficiary, d.token, d.amount, d.timeout, d.method, d.explicit, d.memo);
    }
    
    /**
     * Publish a credit event
     */
    function emitCredit(Data calldata d)
        external
    {
        emit Credit(d.id, d.platform, d.affiliate, d.network, d.beneficiary, d.token, d.amount, d.timeout, d.method, d.explicit, d.memo);
    }

    /**
     * Publish a swap event
     */
    function emitSwap(Data calldata d)
        external
    {
        emit Swap(d.id, d.platform, d.affiliate, d.network, d.beneficiary, d.token, d.amount, d.timeout, d.method, d.explicit, d.memo);
    }

    /**
     * Publish an option event
     */
    function emitOption(Data calldata d)
        external
    {
        emit Option(d.id, d.platform, d.affiliate, d.network, d.beneficiary, d.token, d.amount, d.timeout, d.method, d.explicit, d.memo);
    }

    /**
     * Publish a revoke event
     */
    function emitRevoke(Data calldata d)
        external
    {
        emit Revoke(d.id, d.platform, d.affiliate, d.network, d.beneficiary, d.token, d.amount, d.timeout, d.method, d.explicit, d.memo);
    }

    /**
     * Publish a waive event, including identifiers of its spinoffs
     */
    function emitWaive(
        bytes32 id,
        bytes32[2] calldata spinoffIds
    )
        external
    {
        emit Waive(id, spinoffIds);
    }

    /**
     * Publish a recall event
     */
    function emitRecall(
        bytes32 id,
        bytes32 originId
    )
        external
    {
        emit Recall(id, originId);
    }

    /**
     * Publish a debit event resulting from a reward payout
     */
    function emitDebitReward(
        Data calldata d,
        bytes32 id,
        address token,
        uint256 amount
    )
        external
    {
        emit Debit(
            id,
            d.platform,
            d.affiliate,
            d.network,
            [address(this), d.beneficiary[1]],
            [token, token],
            [amount, amount],
            d.timeout,
            [METHOD_REWARD, METHOD_REWARD],
            d.explicit,
            d.memo
        );
    }

    /**
     * Publish a spinoff events resulting from an option
     */
    function emitOption(
        Data calldata d,
        bytes32 id,
        address token,
        uint256 amount,
        uint32 timeout
    )
        external
    {
        emit Option(
            id,
            d.platform,
            d.affiliate,
            d.network,
            [address(this), d.beneficiary[0]],
            [d.token[0], token],
            [d.amount[0], amount],
            [int32(timeout), int32(0)],
            d.method,
            d.explicit,
            d.memo
        );
        emit Debit(
            id,
            d.platform,
            d.affiliate,
            d.network,
            [address(this), d.beneficiary[0]],
            d.token,
            d.amount,
            [int32(0), int32(0 - timeout)],
            d.method,
            d.explicit,
            d.memo
        );
    }

    /**
     * Publish spinoff events resulting from ceding a voucher
     */
    function emitSpinoffForVoucherCede(
        Data calldata d,
        bytes32[2] calldata ids,
        address beneficiary,
        uint256 amount
    )
        external
    {
        amount = amount > 0 ? amount : d.amount[0];
        emit Spinoff(
            ids[0],
            d.platform,
            d.affiliate,
            d.network,
            [beneficiary, d.beneficiary[1]],
            d.token,
            [amount, amount],
            d.timeout,
            d.method,
            d.explicit,
            d.memo
        );
        if (amount < d.amount[0]) {
            emit Spinoff(
                ids[1],
                d.platform,
                d.affiliate,
                d.network,
                d.beneficiary,
                d.token,
                [d.amount[0] - amount, d.amount[0] - amount],
                d.timeout,
                d.method,
                d.explicit,
                d.memo
            );
        }
    }

    /**
     * Publish spinoff events resulting from claiming a voucher
     */
    function emitSpinoffForVoucherClaim(
        Data calldata d,
        bytes32[2] calldata ids,
        address beneficiary,
        uint256 amount
    )
        external
    {
        amount = amount > 0 ? amount : d.amount[0];
        emit Spinoff(
            ids[0],
            d.platform,
            d.affiliate,
            d.network,
            [d.beneficiary[0], beneficiary],
            d.token,
            [amount, amount],
            d.timeout,
            d.method,
            d.explicit,
            d.memo
        );
        if (amount < d.amount[0]) {
            emit Spinoff(
                ids[1],
                d.platform,
                d.affiliate,
                d.network,
                d.beneficiary,
                d.token,
                [d.amount[0] - amount, d.amount[0] - amount],
                d.timeout,
                d.method,
                d.explicit,
                d.memo
            );
        }
    }

    /**
     * Publish spinoff events resulting from ceding an escrow
     */
    function emitSpinoffForEscrowCede(
        Data calldata d,
        bytes32[2] calldata ids,
        address beneficiary,
        uint256 amount
    )
        external
    {
        amount = amount > 0 ? amount : d.amount[1];
        emit Spinoff(
            ids[0],
            d.platform,
            d.affiliate,
            [d.network[1], d.network[1]],
            [d.beneficiary[1], beneficiary],
            [d.token[1], d.token[1]],
            [amount, amount],
            [int32(0), d.timeout[1]],
            d.method,
            d.explicit,
            d.memo
        );
        if (amount < d.amount[1]) {
            emit Spinoff(
                ids[1],
                d.platform,
                d.affiliate,
                [d.network[1], d.network[1]],
                [d.beneficiary[1], d.beneficiary[1]],
                [d.token[1], d.token[1]],
                [d.amount[1] - amount, d.amount[1] - amount],
                [int32(0), d.timeout[1]],
                d.method,
                d.explicit,
                d.memo
            );
        }
    }

    /**
     * Compare arguments contained in the payload with the arguments encoded in the signed message
     * For inbound transactions only payloads signed by the signer are accepted
     */
    function verifySingleSignature(
        bytes32 operation,
        bytes calldata payload,
        bytes calldata params,
        uint256[2] calldata fee,
        bytes calldata signature
    )
        external pure returns(address signer)
    {
        bytes memory message = abi.encodePacked(operation, payload, params, fee);
        signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(message)), signature);
        return(signer);
    }

    /**
     * Compare arguments contained in the payload with the arguments encoded in the signed message
     */
    function verifyTripleSignature(
        bytes32 operation,
        bytes calldata payload,
        bytes calldata params,
        uint256[2] calldata fee,
        bytes[3] calldata signature
    )
        external pure returns(address[3] memory signer, bool unique)
    {
        bytes memory message = abi.encodePacked(operation, payload, params, fee);
        signer = [
            ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(message)), signature[0]),
            ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(message)), signature[1]),
            ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(message)), signature[2])
        ];
        unique = (signer[0] != signer[1] && signer[0] != signer[2] && signer[1] != signer[2]);
        return(signer, unique);
    }

    /**
     * Positive timeout is interpreted as a `not-later-than` requirement
     * Negative timeout is interpreted as a `not-earlier-than` requirement
     */
    function verifyTimeout(
        int32 timeout
    )
        internal view returns(bool)
    {
        if (timeout > 0) {
            return uint256(int256(timeout)) <= block.timestamp;
        }
        if (timeout < 0) {
            return uint256(int256(0 - timeout)) >= block.timestamp;
        }
        return true;
    }
}