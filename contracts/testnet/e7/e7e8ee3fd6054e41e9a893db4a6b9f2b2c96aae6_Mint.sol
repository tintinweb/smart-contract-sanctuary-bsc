// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./LandName.sol";
import "./MetaLootName.sol";
import "./MintNodeName.sol";
import "./Alchemist.sol";

contract Mint is Initializable, AccessControlUpgradeable {
    event Received(address caller, uint amount, string message);
    MetaLootName private metaLootName;
    LandName private landName;
    MintNodeName private mintNodeName;
    Alchemist private alchemist;
    function initialize(MetaLootName _metaLootName, LandName _landName, MintNodeName _mintNodeName, Alchemist _alchemist) public initializer {
        __AccessControl_init();
        metaLootName = _metaLootName;
        landName = _landName;
        mintNodeName = _mintNodeName;
        alchemist = _alchemist;
    }

    fallback() external {}
    
    receive() external payable {
        emit Received(msg.sender, msg.value, "Receive was called");
    }

    function mintMetaLoot(string calldata metaLootsName, string calldata mintNodesName) external payable {
        metaLootName.mintRoute{value: msg.value}(metaLootsName, mintNodesName, _msgSender());
    }

    function mintAlchemist() external {
        return alchemist.mint();
    }

    function mintLand(string calldata landsName) external {
        return landName.mintRoute(landsName, _msgSender());
    }

    function mintMintNode(string calldata mintNodesName) external {
        return mintNodeName.mintRoute(mintNodesName, _msgSender());
    }

    function  tokenURIByDomainOfLand(string memory landsName) public view returns (string memory) {
        return landName.tokenURIByDomain(landsName);
    }

    function  tokenURIOfAlchemist(uint256 tokenId) public view returns (string memory) {
        return alchemist.tokenURI(tokenId);
    }

    function  tokenURIByDomainOfNode(string memory mintNodesName) public view returns (string memory) {
        return mintNodeName.tokenURIByDomain(mintNodesName);
    }

    function  tokenURIByDomainOfMetaLoot(string memory metaLootsName) public view returns (string memory) {
        return metaLootName.tokenURIByDomain(metaLootsName);
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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

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
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        require(!_exists(tokenId), "ERC721: token already minted");

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
        address owner = ERC721Upgradeable.ownerOf(tokenId);

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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <[email protected]>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a 'slice'. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first '.',
 *      modifying s to only contain the remainder of the string after the '.'.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew('.')` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

library StringLib {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len_) private pure {
        // Copy word-length chunks while possible
        for(; len_ >= 32; len_ -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len_) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string memory self) internal pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (uint(self) & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (uint(self) & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (uint(self) & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (uint(self) & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (uint(self) & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-terminated utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {
        // Allocate space for `self` in memory, copy it there, and point ret at it
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice memory self) internal pure returns (slice memory) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice memory self) internal pure returns (string memory) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice memory self) internal pure returns (uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice memory self) internal pure returns (bool) {
        return self._len == 0;
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
    function compare(slice memory self, slice memory other) internal pure returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint256 mask = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice memory self, slice memory other) internal pure returns (bool) {
        return compare(self, other) == 0;
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        // Check for truncated codepoints
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice memory self) internal pure returns (slice memory ret) {
        nextRune(self, ret);
    }

    /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
    function ord(slice memory self) internal pure returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        // Load the rune into the MSBs of b
        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        // Check for truncated codepoints
        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                // Invalid UTF-8 sequence
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice memory self) internal pure returns (bytes32 ret) {
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    // Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found.
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        split(self, needle, token);
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        rsplit(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice memory self, slice memory needle) internal pure returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice memory self, slice memory other) internal pure returns (string memory) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {
        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(uint i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";

library Rand {
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getRand(string memory input, uint256 tokenId) internal pure returns (uint256) {
        return random(string(abi.encodePacked(input, Strings.toString(tokenId))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;
        
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract SkinDog is Initializable, AccessControlUpgradeable {
    bytes32 public constant SKIN_ADMIN = keccak256("SKIN_ADMIN");

    function initialize() public initializer {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SKIN_ADMIN, msg.sender);
    }

    function image(uint256 tokenId) external pure returns (string memory) {
        string[4] memory parts;
        parts[0] = '<svg width="738" height="738" viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="400" height="400" fill="#b3aaaa"/><g transform="translate(15, 0)">';
        parts[1] = body(tokenId);
        parts[2] = header(tokenId);
        parts[3] = string(abi.encodePacked('</g></g><text x="200" y="393" text-anchor="middle" font-size="28"  fill="white">', Strings.toString(tokenId), '.alchemist</text></svg>'));
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));
        return output;
    }

    function body(uint256 tokenId) public pure returns (string memory body_description) {
        uint256 rand = random(string(abi.encodePacked('body', Strings.toString(tokenId))));
        uint256 id = rand % 6;
        if (id == 0) {
            return '<g transform="translate(0, 0)"><g id="body" transform="translate(122.5, 87)"><path d="M4 279.282C4 274.864 7.58172 271.282 12 271.282H40V279.282H4Z" fill="#D69A6E"/><rect x="-3" y="197.282" width="32" height="88" rx="16" transform="rotate(-15 -3 197.282)" fill="#D69A6E"/><path d="M119.686 279.282C119.686 274.864 116.104 271.282 111.686 271.282H83.6858V279.282H119.686Z" fill="#D69A6E"/><rect width="32" height="88" rx="16" transform="matrix(-0.965926 -0.258819 -0.258819 0.965926 126.686 197.282)" fill="#D69A6E"/><path d="M36.5504 14.8832C37.137 6.50054 44.1083 0 52.5114 0H71.4886C79.8917 0 86.863 6.50054 87.4496 14.8832L104.802 262.883C105.45 272.137 98.1176 280 88.8413 280H35.1587C25.8824 280 18.5502 272.137 19.1977 262.883L36.5504 14.8832Z" fill="#ca931c"/><path d="M32 169.879C44.6175 163.285 57.924 121.879 63 102V278C52.9607 241.787 32.7058 169.466 32 169.879Z" fill="#FCEEC0"/><path d="M93 169.879C80.7895 163.285 67.9123 121.879 63 102V278C72.7154 241.787 92.317 169.466 93 169.879Z" fill="#FCEEC0"/><path d="M32 268H20C16.6863 268 12 273.373 12 280H40C40 273.373 35.3137 268 32 268Z" fill="white"/><path d="M20 280C20 277 20 272 22 271" stroke="black"/><path d="M31 280C31 277 31 272 29 271" stroke="black"/><path d="M102 268H90C86.6863 268 82 273.373 82 280H110C110 273.373 105.314 268 102 268Z" fill="white"/><path d="M91 280C91 277 91 272 93 271" stroke="black"/><path d="M102 280C102 277 102 272 100 271" stroke="black"/></g>';
        } else if (id == 1) {
            return '<g transform="translate(0, 66)"><g id="body" transform="translate(90, 87)"><path d="M4 148C4 143.029 8.02944 139 13 139H40V148H4Z" fill="#D69A6E"/><rect x="-3" y="65.2822" width="32" height="88" rx="16" transform="rotate(-15 -3 65.2822)" fill="#D69A6E"/><path d="M185 148C185 143.029 180.971 139 176 139H149V148H185Z" fill="#D69A6E"/><rect width="32" height="88" rx="16" transform="matrix(-0.965926 -0.258819 -0.258819 0.965926 191.686 65.2822)" fill="#D69A6E"/><rect x="13" width="160" height="148" rx="65" fill="#F6D5A9"/><path d="M58 136H46C42.6863 136 38 141.373 38 148H66C66 141.373 61.3137 136 58 136Z" fill="white"/><path d="M46 148C46 145 46 140 48 139" stroke="black"/><path d="M57 148C57 145 57 140 55 139" stroke="black"/><path d="M143 136H131C127.686 136 123 141.373 123 148H151C151 141.373 146.314 136 143 136Z" fill="white"/><path d="M132 148C132 145 132 140 134 139" stroke="black"/><path d="M143 148C143 145 143 140 141 139" stroke="black"/></g>';
        } else if (id == 2) {
            return '<g transform="translate(0, 21)"><g id="body" transform="translate(114.5, 87)"><path d="M4 238C4 231.925 8.92487 227 15 227H48V238H4Z" fill="#D69A6E"/><rect width="38.3375" height="97.3001" rx="19.1687" transform="matrix(0.971448 -0.237252 0.282043 0.959402 -4 146.096)" fill="#D69A6E"/><path d="M136 238C136 231.925 131.075 227 125 227H92V238H136Z" fill="#D69A6E"/><rect width="38.5238" height="97.7728" rx="19.2619" transform="matrix(-0.971448 -0.237252 -0.282043 0.959402 144 146.14)" fill="#D69A6E"/><path d="M43.5928 34.013C45.25 19.7547 57.327 9 71.6813 9C86.1072 9 98.2205 19.8591 99.7909 34.1993L119.086 210.387C120.641 224.592 109.517 237 95.2282 237H46.951C32.5982 237 21.4545 224.486 23.1115 210.229L43.5928 34.013Z" fill="#F6D5A9"/><path d="M43 130C54.6324 124.305 67.3203 101.168 72 84V237.147C62.7445 205.873 43.6507 129.643 43 130Z" fill="#FCEEC0"/><path d="M99 128.579C88.0105 122.809 76.4211 101.394 72 84V237C80.7439 205.314 98.3853 128.217 99 128.579Z" fill="#FCEEC0"/><path d="M48 226H36C32.6863 226 28 231.373 28 238H56C56 231.373 51.3137 226 48 226Z" fill="white"/><path d="M36 238C36 235 36 230 38 229" stroke="black"/><path d="M47 238C47 235 47 230 45 229" stroke="black"/><path d="M104 226H92C88.6863 226 84 231.373 84 238H112C112 231.373 107.314 226 104 226Z" fill="white"/><path d="M93 238C93 235 93 230 95 229" stroke="black"/><path d="M104 238C104 235 104 230 102 229" stroke="black"/></g>';
        }else if (id == 3) {
            return '<g transform="translate(0, 57)"><g id="body" transform="translate(128.5, 87)"><path d="M11.0496 166C11.0496 162.686 13.7359 160 17.0496 160H36.2971V166H11.0496Z" fill="#D69A6E"/><rect width="22.7664" height="62.0755" rx="11.2789" transform="matrix(0.966558 -0.256449 0.261208 0.965283 6 107.838)" fill="#D69A6E"/><path d="M100.95 166C100.95 162.686 98.2641 160 94.9504 160H75.7029V166H100.95Z" fill="#D69A6E"/><rect width="22.7639" height="62.0688" rx="11.2777" transform="matrix(-0.966558 -0.256449 -0.261208 0.965283 106 107.838)" fill="#D69A6E"/><path d="M28.9481 45.305C30.4311 31.4816 42.0973 21 56 21C69.9027 21 81.5689 31.4816 83.0519 45.305L93.1507 139.44C94.6726 153.627 83.5555 166 69.2876 166H42.7124C28.4445 166 17.3274 153.627 18.8494 139.44L28.9481 45.305Z" fill="#F6D5A9"/><path d="M30 93.9375C40.8016 90.1075 52.5831 74.5465 56.9286 63L57 166C48.4056 144.966 30.6042 93.6976 30 93.9375Z" fill="#FCEEC0"/><path d="M82 92.9818C71.7955 89.1014 61.0338 74.6984 56.9286 63L57 166C65.1193 144.689 81.4292 92.7387 82 92.9818Z" fill="#FCEEC0"/><path d="M41.198 154H29.0792C25.7327 154 21 159.373 21 166H49.2772C49.2772 159.373 44.5445 154 41.198 154Z" fill="white"/><path d="M29.0791 166C29.0791 163 29.0791 158 31.0989 157" stroke="black"/><path d="M40.1882 166C40.1882 163 40.1882 158 38.1684 157" stroke="black"/><path d="M83.198 154H71.0792C67.7327 154 63 159.373 63 166H91.2772C91.2772 159.373 86.5445 154 83.198 154Z" fill="white"/><path d="M72.0891 166C72.0891 163 72.0891 158 74.1089 157" stroke="black"/><path d="M83.198 166C83.198 163 83.198 158 81.1782 157" stroke="black"/></g>';
        } else if (id == 4) {
            return '<g transform="translate(0, 77)"><g id="body" transform="translate(128.5, 87)"><path d="M14.9998 127C14.9998 124.239 17.2383 122 19.9998 122H36.9998V127H14.9998Z" fill="#D69A6E"/><rect width="20.223" height="48.4798" rx="10.1115" transform="matrix(0.974853 -0.222847 0.299646 0.95405 10.0474 81.5067)" fill="#D69A6E"/><path d="M96.2888 127C96.2888 124.239 94.0502 122 91.2888 122H74.2888V127H96.2888Z" fill="#D69A6E"/><rect width="20.223" height="48.4798" rx="10.1115" transform="matrix(-0.974853 -0.222847 -0.299646 0.95405 101.241 81.5067)" fill="#D69A6E"/><path d="M34.1495 49.0505C35.9074 38.6294 44.9317 31 55.5 31C66.0683 31 75.0926 38.6294 76.8505 49.0505L84.2612 92.9807C87.2632 110.776 73.5471 127 55.5 127C37.4529 127 23.7368 110.776 26.7388 92.9807L34.1495 49.0505Z" fill="#F6D5A9"/><path d="M34 79C43.1398 76.4714 52.1088 66.6229 55.7857 59L55.8462 127C48.574 113.114 34.5112 78.8416 34 79Z" fill="#FCEEC0"/><path d="M77 78C68.3654 75.4382 59.2594 66.7232 55.7857 59L55.8462 127C62.7163 112.931 76.517 77.8395 77 78Z" fill="#FCEEC0"/><path d="M44.3439 117H33.9376C31.0639 117 27 121.477 27 127H51.2815C51.2815 121.477 47.2175 117 44.3439 117Z" fill="white"/><path d="M33.0703 127C33.0703 124 33.0703 119 35.0938 118" stroke="black"/><path d="M44.1995 127C44.1995 124 44.1995 119 42.176 118" stroke="black"/><path d="M77.3439 117H66.9376C64.0639 117 60 121.477 60 127H84.2815C84.2815 121.477 80.2175 117 77.3439 117Z" fill="white"/><path d="M66.0703 127C66.0703 124 66.0703 119 68.0938 118" stroke="black"/><path d="M77.1995 127C77.1995 124 77.1995 119 75.176 118" stroke="black"/></g>';
        } else if (id == 5) {
            return '<g transform="translate(0, 77)"><g id="body" transform="translate(128.5, 87)"><path d="M26 126C26 123.239 28.2386 121 31 121H47V126H26Z" fill="#D69A6E"/><rect width="18.5976" height="50.7449" rx="9.29882" transform="matrix(0.966506 -0.256645 0.261009 0.965336 22 78.7729)" fill="#D69A6E"/><path d="M85 126C85 123.239 82.7614 121 80 121H64V126H85Z" fill="#D69A6E"/><rect width="18.5976" height="50.7449" rx="9.29882" transform="matrix(-0.966506 -0.256645 -0.261009 0.965336 89.2195 78.7729)" fill="#D69A6E"/><path d="M43.4802 40.162C44.4699 34.2952 49.5503 30 55.5 30C61.4497 30 66.5301 34.2952 67.5198 40.162L77.5919 99.8692C79.8978 113.538 69.3622 126 55.5 126C41.6378 126 31.1022 113.538 33.4081 99.8692L43.4802 40.162Z" fill="#F6D5A9"/><path d="M47.2857 118H38.7143C36.3474 118 33 121.582 33 126H53C53 121.582 49.6526 118 47.2857 118Z" fill="white"/><path d="M39 126C39 123.667 39 119.778 41 119" stroke="black"/><path d="M48 126C48 123.667 48 119.778 46 119" stroke="black"/><path d="M72.2857 118H63.7143C61.3474 118 58 121.582 58 126H78C78 121.582 74.6526 118 72.2857 118Z" fill="white"/><path d="M64 126C64 123.667 64 119.778 65 119" stroke="black"/><path d="M72 126C72 123.667 72 119.778 70 119" stroke="black"/></g>';
        }
    }



    function header(uint256 tokenId) public pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked('header', Strings.toString(tokenId))));
        uint256 id = rand % 2;
        string[9] memory parts;
        if (id == 0) {
            parts[0] = '<g id="header" transform="translate(148.5, 0)"><path d="M6.17724 66C2.99651 51.0676 14.3832 37 29.6506 37H42.3494C57.6168 37 69.0035 51.0676 65.8228 66L48.6138 146.79C47.3456 152.744 42.0872 157 36 157C29.9128 157 24.6544 152.744 23.3862 146.79L6.17724 66Z" fill="#DEDBDA"/><g transform="translate(0, 0)">';
            parts[2] = '</g><g transform="translate(0, -5)">';
            parts[4] = '</g><g id="ears" transform="translate(0, 0)">';
            parts[6] = '<g transform="translate(7, 0)">';
        }else if (id == 1) {
            parts[0] = '<g id="header" transform="translate(110, 0)"><path d="M2.55479 65.3425C3.9369 48.7572 17.8014 36 34.4443 36H114.556C131.199 36 145.063 48.7572 146.445 65.3425L148.585 91.0173C151.5 125.998 123.894 156 88.792 156H60.208C25.1056 156 -2.49987 125.998 0.415228 91.0173L2.55479 65.3425Z" fill="#F6D5A9"/><g transform="translate(39, -3)">';
            parts[2] = '</g><g transform="translate(39, -23)">';
            parts[4] = '</g><g id="ears" transform="translate(0, 0)">';
            parts[6] = '<g transform="translate(84, 0)">';
        }

        parts[1] = getEyes(tokenId);
        parts[3] = getNose(tokenId);
        parts[5] = getEars(tokenId)[0];
        parts[7] = getEars(tokenId)[1];
        parts[8] = '</g></g></g>';
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        return output;
    }

    function eyes(uint id) internal pure returns (string memory eyes_description) {
        if (id == 0) {
            return '<g id="eyes" transform="translate(23, 103)"><circle cx="0" r="3" fill="black"/><circle cx="26" r="3" fill="black"/></g>';
        } else if (id == 1) {
            return '<g id="eyes" transform="translate(14, 85)"><path d="M9.18431 0.5C6.59096 4.43492 0.783919 11.9034 1.00621 20.2979C1.28406 30.791 5.60992 29.9837 6.99921 29C8.91413 27.6441 11.4372 22.2653 9.49921 22.2653C6.86327 22.2653 8.36794 29.6971 13.225 29.4793C17.6707 29.28 20.6352 22 17.9992 22C15.7763 22 17.4417 29.8073 22.9992 29.8073C28.5567 29.8073 30.4445 22.5932 27.673 22.5932C24.9015 22.5932 28.8958 29.8073 32.675 29.8073C36.558 29.8073 38.722 22.5932 36.4992 22.5932C33.2584 22.5932 35.4509 31.4005 41.7508 29.8073C46.9374 28.4956 47.2429 13.9067 36.4993 0.5" stroke="black"/></g>';
        } else if (id == 2) {
            return '<g id="eyes" transform="translate(15, 91)"><path d="M16 8.92051C16 13.1082 11.2432 16.5029 6.91892 16.949C1.3252 17.5259 0 13.1082 0 8.92051C0 4.73284 4.15618 0 8.21622 0C12.2763 0 16 4.73284 16 8.92051Z" fill="white"/><circle cx="8" cy="12" r="3" fill="black"/><circle cx="34" cy="12" r="3" fill="black"/></g>';
        } else if (id == 3) {
            return '<g id="eyes" transform="translate(20, 93)"><path d="M20 8.39577C20 12.3371 24.7568 15.5322 29.0811 15.952C34.6748 16.495 36 12.3371 36 8.39577C36 4.45444 31.8438 0 27.7838 0C23.7237 0 20 4.45444 20 8.39577Z" fill="white"/><circle cx="3" cy="10" r="3" fill="black"/><circle cx="29" cy="10" r="3" fill="black"/></g>';
        } else if (id ==4) {
            return '<g id="eyes" transform="translate(14, 92)"><path d="M27 8.39577C27 12.3371 31.7568 15.5322 36.0811 15.952C41.6748 16.495 43 12.3371 43 8.39577C43 4.45444 38.8438 0 34.7838 0C30.7237 0 27 4.45444 27 8.39577Z" fill="white"/><path d="M16 8.92051C16 13.1082 11.2432 16.5029 6.91892 16.949C1.3252 17.5259 0 13.1082 0 8.92051C0 4.73284 4.15618 0 8.21622 0C12.2763 0 16 4.73284 16 8.92051Z" fill="white"/><circle cx="9" cy="11" r="3" fill="black"/><circle cx="35" cy="11" r="3" fill="black"/></g>';
        }
    }

    function nose(uint id) internal pure returns (string memory nose_description) {
        if (id == 0) {
            return '<g id="nose" transform="translate(20.5, 103)"><path d="M9.80645 47.7888C14.3484 48.7534 15.828 46.1811 16 44.7745V0H14C14 0 10.934 11.0019 8.19355 17.4543C5.78868 23.1167 0 30.9087 0 30.9087L3.6129 42.9659C3.78495 44.1716 5.26452 46.8242 9.80645 47.7888Z" fill="white"/><path d="M21.8065 47.7888C17.5484 48.7534 16.1613 46.1811 16 44.7745V0H18C18 0 20.5989 10.9782 23.1935 17.4543C25.4528 23.0932 31 30.9087 31 30.9087L27.6129 42.9659C27.4516 44.1716 26.0645 46.8242 21.8065 47.7888Z" fill="white"/><path d="M16 46.387C12.7794 49.465 6 48 4 43.9384L0.5 34" stroke="black"/><path d="M15 46.387C18.2206 49.465 25 48 27 43.9384L30.5 34" stroke="black"/><path d="M8 42C8 40.3431 9.34315 39 11 39H21C22.6569 39 24 40.3431 24 42V43H8V42Z" fill="black"/><ellipse cx="16" cy="43" rx="8" ry="4" fill="black"/></g>';
        } else if (id == 1) {
            return '<g id="nose" transform="translate(0, 0)"><ellipse cx="36" cy="149" rx="8" ry="4" fill="black"/></g>';
        }else if (id == 2) {
            return '<g id="nose" transform="translate(-11, 144)"><path d="M2.11942 41.5062C7.76732 13.4568 34.3931 3.48148 47 2V73.1111C39.7383 73.1111 33.2165 71.1358 30.8633 70.1481C28.3419 73.6049 15.5342 82 11.7007 82C7.55411 82 -4.94044 76.5679 2.11942 41.5062Z" fill="white"/><path d="M91.9306 41.5062C86.2764 13.4568 59.6209 3.48148 47 2V73.1111C54.2698 73.1111 60.7989 71.1358 63.1547 70.1481C65.6789 73.6049 76.4925 82 82.3386 82C85.9901 82 98.9983 76.5679 91.9306 41.5062Z" fill="white"/><path d="M47 2C34.3931 3.48148 7.76728 13.4568 2.11938 41.5062" stroke="black"/><path d="M26 67C27.8333 69.1667 34.8 73 46 73" stroke="black"/><path d="M66 67C64.1667 69.1667 57.2 73 46 73" stroke="black"/><path d="M47 11V17.5" stroke="black"/><path d="M57 26.5C57 21.2533 52.7467 17 47.5 17C42.2533 17 38 21.2533 38 26.5" stroke="black"/><path d="M38.5 23C36.9 23 36.8334 19 37 17C37 19 39.5 19.8333 40.5 20C40 20.8333 38.5 22.6 38.5 23Z" stroke="black" stroke-linejoin="round"/><path d="M56.5 23C58.1 23 58.1667 19 58 17C58 19 55.5 19.8333 54.5 20C55 20.8333 56.5 22.6 56.5 23Z" stroke="black" stroke-linejoin="round"/><path d="M47 2C59.6069 3.48148 86.2327 13.4568 91.8806 41.5062" stroke="black"/><circle cx="39.5" cy="2.5" r="2.5" fill="black"/><circle cx="54.5" cy="2.5" r="2.5" fill="black"/><path d="M54.6191 0H39.381L37.4762 4L43.6667 10C43.9841 10.3333 45.0952 11 47 11C48.9048 11 50.0159 10.3333 50.3333 10C50.6508 9.66667 56.5238 4 56.5238 4L54.6191 0Z" fill="black"/></g>';
        }
    }

    function ears(uint id) internal pure returns (string[2] memory ears_description) {
        if (id == 0) {
            return ['<g id="left" transform="translate(-13, 0)"><path fill-rule="evenodd" clip-rule="evenodd" d="M38.9998 42.9999C39.1205 42.4761 39.1842 41.9312 39.1842 41.3717C39.1842 37.3004 35.8104 34 31.6487 34C29.1817 34 26.9915 35.1598 25.6169 36.9525L3.01416 60.5383L3.07347 60.6284C1.17403 62.4947 0 65.0682 0 67.9099C0 67.9605 0.000371644 68.0109 0.0011124 68.0613L0.184326 93H0.18457C0.18457 100.18 6.22873 106 13.6846 106C20.4136 106 25.9928 101.259 27.0166 95.0568L39 43L38.9998 42.9999Z" fill="#482712"/></g>', '<g id="right" transform="translate(37, 0)"><path fill-rule="evenodd" clip-rule="evenodd" d="M2.18441 42.9999C2.06371 42.4761 2 41.9312 2 41.3717C2 37.3004 5.37374 34 9.53545 34C12.0025 34 14.1927 35.1598 15.5673 36.9525L38.17 60.5383L38.1107 60.6284C40.0102 62.4947 41.1842 65.0682 41.1842 67.9099C41.1842 67.9605 41.1838 68.0109 41.1831 68.0613L40.9999 93H40.9996C40.9996 100.18 34.9555 106 27.4996 106C20.7706 106 15.1914 101.259 14.1676 95.0568L2.18418 43L2.18441 42.9999Z" fill="#482712"/></g>'];
        } else if (id == 1) {
            return ['<g id="left" transform="translate(7, 0)"><path d="M0 58L20 4V41.4759L0 58Z" fill="#482712"/></g>','<g id="right" transform="translate(38, 0)"><path d="M20 58L1.52588e-05 4V41.4759L20 58Z" fill="#482712"/></g>'];
        }else if (id == 2) {
            return ['<g id="left" transform="translate(-10, 0)"><path d="M8 32H26.9762C34.0621 32 37.6499 40.5317 32.6936 45.5957L13.7174 64.9844C8.70305 70.1078 0 66.5575 0 59.3887V40C0 35.5817 3.58172 32 8 32Z" fill="#482712"/></g>','<g id="right" transform="translate(40, 0)"><path d="M27 32H8.02379C0.937946 32 -2.64985 40.5317 2.30643 45.5957L21.2826 64.9844C26.297 70.1078 35 66.5575 35 59.3887V40C35 35.5817 31.4183 32 27 32Z" fill="#482712"/></g>'];
        }
    }

    function getEyes(uint256 tokenId) public pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked('eyes', Strings.toString(tokenId))));
        uint256 id = rand % 5;
        return eyes(id);
    }

    function getNose(uint256 tokenId) public pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked('nose', Strings.toString(tokenId))));
        uint256 id = rand % 3;
        return nose(id);
    }

    function getEars(uint256 tokenId) public pure returns (string[2] memory) {
        uint256 rand = random(string(abi.encodePacked('nose', Strings.toString(tokenId))));
        uint256 id = rand % 3;
        return ears(id);
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../utils/Rand.sol";
import "./SketchEyes.sol";

interface Component {
    function data(uint8) external pure returns (string memory);
}

interface Component2 {
    function data(string memory color) external pure returns (string memory);
}

interface Component3 {
    function data(uint8, string memory color) external pure returns (string memory);
}

contract SketchURI is Initializable, AccessControlUpgradeable {
    using SafeCast for uint;
    bytes32 public constant SKIN_ADMIN = keccak256("SKIN_ADMIN");
    Component constant face = Component(0xf7ce109F63f6BE202DEf88Db1f062816c567aA54);
    SketchEyes constant eyes = SketchEyes(0x375068176f83B105F2D0A2ec846eD9ea80Ec4D9e);
    Component3 constant nose = Component3(0xf898B03668d6607E6C1F32fF43Db007B43E19d5A);
    Component3 constant mouth = Component3(0x338dDe6f2D3B8A46d606F7681e124391aCD1e4Bb);
    Component3 constant bread = Component3(0x5021Ab117842a56519D1ef98D9be95E0B56Afb17);
    Component3 constant hairMan = Component3(0x4F2E094DB8d783f2D9B880c0Cd3cA124501D5B3f);
    Component3 constant hairHat = Component3(0x895330F39097192c039e8be7BE813D9877c9f34E);
    Component2 constant hairWomana = Component2(0x597D3E39DAb86FC69c2Cbe078aaBF0Cf02B3dFCb);
    Component2 constant hairWomanb = Component2(0x4145c55A3e6E1Df8BDc6c5A1fB482F6B39100aF5);
    Component constant colors = Component(0xDD8CFC662427eD3BdFE8b1e8F138f1d397072f31);

    string[31] private names;

    string[4] private lands;

    function initialize() public initializer {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SKIN_ADMIN, msg.sender);

    }

    function getHair(uint256 tokenId) public pure returns (string memory hairData) {
        uint256 id = Rand.getRand("gender", tokenId);
        if (id % 4 < 2) {
            return hairMan.data((id % 3).toUint8(), colors.data(getRandMod("hair-man-color", tokenId, 27)));
        } else {
            uint _id = id % 2;
            if (_id == 0) {
                return hairWomana.data(colors.data(getRandMod("hair-woman-color", tokenId, 27)));
            } else if (_id == 1) {
                return hairWomanb.data(colors.data(getRandMod("hair-woman-color", tokenId, 27)));
            }
        }

    }

    function getBread(uint256 tokenId) public pure returns (string memory) {
        uint256 id = Rand.getRand("gender", tokenId);
        if (id % 8 < 4) {
            if (id % 4 < 2) {
                return bread.data((id % 2).toUint8(), colors.data(getRandMod("bread-color", tokenId, 27)));
            }
            return '';
        } else {
            return '';
        }
    }

    function getRandMod(string memory input, uint256 tokenId, uint8 count) internal pure returns (uint8) {
        return (Rand.getRand(input, tokenId) % count).toUint8();
    }
    function getPolygon(uint256 tokenId) public pure returns (string memory) {
        string[7] memory parts;
        parts[0] = face.data(getRandMod("face", tokenId, 8));
        parts[1] = eyes.data(getRandMod("eyes", tokenId, 3), colors.data(getRandMod("eyes-color", tokenId, 27)), colors.data(getRandMod("eyes-plus-color", tokenId, 27)));
        parts[2] = nose.data(getRandMod("nose", tokenId, 3), colors.data(getRandMod("nose-color", tokenId, 27)));
        parts[3] = mouth.data(getRandMod("mouth", tokenId, 3), colors.data(getRandMod("mouth-color", tokenId, 27)));
        parts[4] = getBread(tokenId);
        parts[5] = '</g>';
        parts[6] = getHair(tokenId);
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6]));
        return output;
    }

    function rarity(uint256 tokenId) internal pure returns (string memory ratiryVal) {
        uint256 rarityRand = getRandMod("ratity", tokenId, 100);
        if (rarityRand >= 0 && rarityRand <= 59) {
            return 'N';
        } else if (rarityRand > 59 && rarityRand <= 84) {
            return 'R';
        }else if (rarityRand > 84 && rarityRand <= 94) {
            return 'SR';
        }else if (rarityRand > 94 && rarityRand <= 98) {
            return 'SSR';
        } else if (rarityRand == 99) {
            return 'UR';
        }
    }

    function positionY(uint256 tokenId) internal pure returns (string memory) {
        uint256 _id = Rand.getRand("gender", tokenId);
        if (_id % 4 < 2) {
            if (getRandMod("face", tokenId, 8) == 0|| getRandMod("face", tokenId, 8) == 3 || getRandMod("face", tokenId, 8) == 5) {
                return '25';
            } else  if (getRandMod("face", tokenId, 8) == 1|| getRandMod("face", tokenId, 8) == 7){
                return '55';
            } else {
                return '45';
            }
        } else {
            return '35';
        }
    }

    function image(uint256 tokenId, string memory name) external pure returns (string memory) {
        string[7] memory parts;
        parts[0] = '<svg width="532" height="532" viewBox="0 0 276 276" fill="none" xmlns="http://www.w3.org/2000/svg">';
        parts[1] = string(abi.encodePacked('<rect width="276" height="276" fill="#', colors.data(getRandMod("colors", tokenId, 27)), '"/><rect width="256" height="226" rx="3" x="10" y="30" fill="white"/>'));
        parts[2] = string(abi.encodePacked('<text x="138" y="22" font-weight="bold" font-size="16" text-anchor="middle" fill="white">', name, '</text>'));
        parts[3] = string(abi.encodePacked('<text x="10" y="270" font-weight="bold" font-size="12" text-anchor="start" fill="white">Rarity:', rarity(tokenId), '</text>'));
        parts[4] = string(abi.encodePacked('<text x="266" y="270" font-weight="bold" font-size="12" text-anchor="end" fill="white">Level:', Strings.toString(getRandMod("level", tokenId, 8)), '</text><g transform="translate(25, ', positionY(tokenId), ')">'));
        parts[5] = getPolygon(tokenId);
        parts[6] = '</g></svg>';
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6]));
        return output;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol";


contract SketchEyes is Initializable, AccessControlUpgradeable {
    bytes32 public constant SKETCH_EYES_ADMIN = keccak256("SKETCH_EYES_ADMIN");

    function initialize() public initializer {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SKETCH_EYES_ADMIN, msg.sender);
    }

    function data(uint8 id, string memory color, string memory colorPlus) public pure returns (string memory) {
        require(id >= 0 && id <=2, "ID is invalid");
        if (id == 0) {
            return string(abi.encodePacked('<g id="eyes" transform="translate(64, 86)"><path fill-rule="evenodd" clip-rule="evenodd" d="M71.5525 1.25951C70.0685 1.67601 67.7075 2.6315 66.3055 3.3835C62.935 5.1905 58.3505 9.60451 58.584 10.8175C58.924 12.5815 60.4995 12.1455 63.277 9.5185C64.7755 8.1015 67.4965 6.247 69.3515 5.379C72.739 3.794 75.264 3.52651 81.5 4.09151C82.951 4.22301 83.2755 4.073 83.398 3.2155C83.7125 1.016 76.6025 -0.157993 71.5525 1.25951ZM2.25 4.3315C0.6235 4.781 -0.033504 5.5285 0.445496 6.385C0.804496 7.026 2.195 7.16951 8.5645 7.22301C17.0975 7.29451 20.1985 8.0385 24.3315 11.0055C26.646 12.667 27.882 12.889 28.329 11.7245C28.9575 10.086 24.496 6.9295 19.0495 5.1595C16.7195 4.402 4.2225 3.786 2.25 4.3315ZM70.75 13.437C67.052 14.4125 64 16.7635 64 18.636C64 20.26 66.8285 23.47 69.2145 24.5535C70.334 25.062 72.2745 25.483 73.527 25.489C77.7905 25.5095 83.349 21.661 84.252 18.0635C84.8725 15.5925 81.3195 13.6955 75.25 13.2575C73.6 13.1385 71.575 13.2195 70.75 13.437ZM9.32401 16.4845C6.97301 17.237 4.50699 19.1675 4.50349 20.259C4.49799 21.924 6.859 24.875 9.381 26.3555C11.2775 27.469 12.348 27.7425 14.75 27.727C16.5205 27.716 18.369 27.377 19.2605 26.9005C22.4115 25.2155 25.3265 21.316 24.7625 19.5395C24.0475 17.2865 13.401 15.1795 9.32401 16.4845ZM75.5 17.25C75.5 18.0565 75.042 18.1765 73.794 17.6975C72.776 17.307 73.272 16.5 74.5295 16.5C75.0635 16.5 75.5 16.8375 75.5 17.25ZM69.9845 18.21C70.261 18.936 71.471 19.935 73.0115 20.709L75.5785 21.998L77.0395 20.5375C77.8425 19.734 78.5 18.6095 78.5 18.0385C78.5 16.9345 79.277 16.7165 80.487 17.4815C81.107 17.8735 81.028 18.1575 79.987 19.2725C76.539 22.966 71.7965 23.4525 68.6805 20.4325L66.947 18.7525L68.029 17.876C69.4065 16.7605 69.4355 16.7655 69.9845 18.21ZM15.715 20.5565C15.2105 21.373 14.5 21.0115 14.5 19.939C14.5 19.0555 14.625 18.981 15.2445 19.4955C15.654 19.8355 15.8655 20.313 15.715 20.5565ZM11.5 21.189C11.5 23.267 12.5415 24.2 14.8615 24.2C16.171 24.2 16.937 23.8425 17.815 22.822C18.4665 22.0645 19 21.1195 19 20.722C19 19.929 19.8905 19.7875 20.89 20.4215C21.887 21.054 19.903 23.2305 17.425 24.2215C14.583 25.359 12.084 24.8745 9.6655 22.718C7.8125 21.0665 7.7815 20.986 8.7205 20.2555C10.43 18.925 11.5 19.2845 11.5 21.189Z" fill="#', color, '"/></g>'));
        } else if (id == 1) {
            return string(abi.encodePacked('<g id="eyes" transform="translate(72, 78)"><path fill-rule="evenodd" clip-rule="evenodd" d="M28.197 3.64c-4.705 4.894-8.068 6.553-13.25 6.535-3.038-.01-4.336-.28-6.838-1.427-3.199-1.464-4.162-1.42-4.162.19 0 1.28 1.638 2.34 5.428 3.515 5.624 1.743 10.758.996 15.943-2.32 4.575-2.928 9.037-7.912 8.45-9.441-.564-1.47-2.113-.65-5.57 2.948Zm25.75 2.797c-1.263 2.36.794 6.022 4.201 7.476 3.287 1.402 5.577 1.676 6.479.774 1.169-1.17.482-2.134-1.793-2.518-4.567-.772-6.08-2.065-6.12-5.231-.022-1.667-1.955-2.018-2.766-.501Zm-41.95 9.525C1.793 18.634-2.08 25.046 1.065 34.057c1.96 5.614 7.584 9.578 13.558 9.558 3.801-.013 7.838-1.17 10.92-3.128 2.107-1.339 2.45-1.829 3.375-4.822 1.354-4.384 1.4-11.112.097-13.982-1.17-2.575-4.059-5.104-6.313-5.527-.97-.183-1.89-.531-2.04-.775-.454-.735-4.735-.448-8.665.58Zm7.7 2.476c.17.275.802.5 1.405.502 1.77.003 4.107 1.737 5.067 3.759.712 1.5.85 2.796.69 6.434-.26 5.85-1.276 8.067-4.412 9.624-9.148 4.544-18.096.337-19.27-9.06-.182-1.458-.176-3.14.014-3.738.535-1.688 3.212-4.478 5.334-5.561 3.858-1.968 10.452-3.125 11.172-1.96Zm35.37 3.167c-4.06 1.472-7.115 5.24-7.118 8.775-.006 7.08 4.95 11.542 11.218 10.1 3.25-.748 5.234-2.331 7.009-5.592 1.827-3.357 2.009-6.716.475-8.788-1.457-1.967-3.984-3.585-6.135-3.927-1-.16-2.21-.503-2.687-.763-.477-.26-.927-.455-1-.434-.072.02-.866.304-1.762.63ZM6.229 23.002c-1.557 1.225-1.688 3.183-.263 3.946 2.132 1.14 4.062-.891 3.257-3.428-.465-1.466-1.55-1.654-2.994-.518Zm55.886 3.086c.725.475 1.673 1.404 2.106 2.065 1.812 2.766-1.89 8.74-5.872 9.478-3.72.689-6.723-1.654-7.261-5.665-.35-2.612.59-4.809 2.658-6.215 1.392-.945 2.075-1.075 4.35-.824 1.485.163 3.294.686 4.019 1.16Zm-8.121 7.044c-.807.972.114 2.806 1.41 2.806 1.371 0 2.357-1.39 1.713-2.417-.693-1.107-2.356-1.314-3.123-.39Z" fill="#', color, '"/></g>'));
        } else if (id == 2) {
            return string(abi.encodePacked('<g id="eyes" transform="translate(59, 72)"><path fill-rule="evenodd" clip-rule="evenodd" d="M0.288571 0.641998C-0.00442916 0.994498 -0.0884221 1.5275 0.102078 1.8255C1.38108 3.827 26.9516 16.6295 39.6986 21.6505C47.0556 24.5485 57.3936 28.1005 59.8516 28.5755C60.6656 28.733 60.7676 29.4655 60.8841 36C61.0281 44.099 61.6891 46.6345 64.5191 49.945C68.7841 54.9335 79.5806 57.466 87.0841 55.2375C90.9156 54.1 92.5121 52.518 93.2701 49.1075C94.0586 45.558 94.0741 35.434 93.2951 32.759C92.7216 30.7905 92.7401 30.7415 94.8991 28.509C97.7331 25.578 105.821 14.567 105.893 13.5415C105.924 13.1015 105.505 12.6955 104.949 12.6265C104.185 12.5315 102.844 14.0255 99.2631 18.9615C96.6861 22.5145 93.8736 26.0935 93.0131 26.9155L91.4486 28.4105L87.9186 27.502C79.1401 25.243 63.8741 24.2335 62.1451 25.798C61.3306 26.5355 60.5831 26.367 52.3561 23.5895C37.5731 18.599 22.4366 11.8465 8.61308 4.0755C4.62608 1.834 1.24157 0 1.09207 0C0.943068 0 0.581571 0.288998 0.288571 0.641998ZM63.7456 31.653C63.0926 32.306 63.0016 31.5825 63.5586 30.166C63.9061 29.2825 63.9256 29.283 64.1056 30.178C64.2086 30.6885 64.0461 31.3525 63.7456 31.653ZM81.1986 31.9705C81.1986 32.2295 80.9736 32.58 80.6986 32.75C80.4236 32.92 80.1986 32.708 80.1986 32.2795C80.1986 31.851 80.4236 31.5 80.6986 31.5C80.9736 31.5 81.1986 31.7115 81.1986 31.9705ZM85.1986 32C85.1986 32.275 84.9736 32.5 84.6986 32.5C84.4236 32.5 84.1986 32.275 84.1986 32C84.1986 31.725 84.4236 31.5 84.6986 31.5C84.9736 31.5 85.1986 31.725 85.1986 32ZM88.1986 31.9705C88.1986 32.8365 87.3186 32.997 86.6941 32.2445C86.1796 31.625 86.2541 31.5 87.1376 31.5C87.7211 31.5 88.1986 31.7115 88.1986 31.9705ZM91.1986 35.25C91.1986 35.905 90.9736 36.58 90.6986 36.75C90.4006 36.9345 90.1986 36.3285 90.1986 35.25C90.1986 34.1715 90.4006 33.5655 90.6986 33.75C90.9736 33.92 91.1986 34.595 91.1986 35.25ZM64.0401 42.094C63.8806 42.4925 63.7621 42.374 63.7381 41.7915C63.7166 41.2645 63.8346 40.9695 64.0006 41.1355C64.1666 41.3015 64.1846 41.733 64.0401 42.094ZM68.6986 49.25C68.6986 49.6625 68.4871 50 68.2281 50C67.5976 50 67.1461 49.219 67.5456 48.8195C68.1086 48.2565 68.6986 48.477 68.6986 49.25ZM82.6986 51.5C82.6986 53.141 82.5256 53.5 81.7356 53.5C80.8061 53.5 80.8016 53.431 81.6106 51.505C82.0716 50.408 82.5051 49.508 82.5736 49.505C82.6421 49.5025 82.6986 50.4 82.6986 51.5ZM74.0006 52.3645C73.4926 52.873 73.0731 52.1075 73.4901 51.433C73.8051 50.923 73.9231 50.923 74.0921 51.431C74.2081 51.7785 74.1666 52.1985 74.0006 52.3645ZM78.0006 53.3645C77.4926 53.873 77.0731 53.1075 77.4901 52.433C77.8051 51.923 77.9231 51.923 78.0921 52.431C78.2081 52.7785 78.1666 53.1985 78.0006 53.3645Z" fill="#', color, '"/><path fill-rule="evenodd" clip-rule="evenodd" d="M15.3388 18.4516C8.98078 19.3826 6.88628 20.5356 8.54378 22.1931C9.09828 22.7471 9.62927 22.7886 10.9873 22.3841C17.2078 20.5311 24.8438 20.9806 29.5248 23.4756C32.3858 25.0006 33.9728 25.1021 33.9728 23.7606C33.9728 21.8596 29.1148 19.2766 23.9698 18.4421C20.3248 17.8506 19.4383 17.8516 15.3388 18.4516ZM69.6123 18.4776C64.8678 19.1586 62.7478 19.9841 62.5713 21.2196C62.3778 22.5751 63.4643 22.9891 65.5693 22.3606C71.6628 20.5421 79.5318 20.9991 83.8233 23.4211C86.8253 25.1151 87.7333 25.2536 88.1813 24.0851C88.9008 22.2101 83.8803 19.2851 78.4728 18.4296C74.7958 17.8476 73.9693 17.8521 69.6123 18.4776ZM19.4138 30.0981C15.4203 31.5251 11.2353 35.0561 11.5573 36.7276C11.8688 38.3436 13.3468 38.0286 15.5658 35.8736C17.3803 34.1111 17.7473 33.9276 17.8758 34.7181C18.5478 38.8421 21.4783 40.4646 24.9828 38.6526C27.3713 37.4176 28.2678 34.6901 26.7108 33.3976C25.4428 32.3456 26.2268 32.2866 29.4548 33.1926C31.8063 33.8521 32.6638 33.9166 33.1133 33.4671C35.6923 30.8881 24.7403 28.1946 19.4138 30.0981ZM23.7038 35.7331C22.0808 36.9201 20.5368 36.2651 21.1558 34.6516C21.3753 34.0796 21.7338 34.0506 23.0268 34.5016C24.5203 35.0221 24.5653 35.1036 23.7038 35.7331Z" fill="#', colorPlus, '"/></g>'));
        }else {
            return '';
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "../../node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../utils/Base64.sol";
import "../interface/ItokenURI.sol";
import "./LandURI.sol";
import "../NNS/BaseRegistrarImplementation.sol";
import "../utils/StringLib.sol";
import "../ILoot.sol";

contract MintNodeName is ReentrancyGuardUpgradeable, AccessControlUpgradeable, BaseRegistrarImplementation{
    bytes32 private constant ROOT_NODE = bytes32(0);
    //NNS of the tokenId
    mapping(uint256 => string) private  _domainOfTokenId;
    //tokenId of the NNS
    mapping(string => uint256) private  _tokenIdOfDomain;
    using StringLib for string;
    using StringLib for StringLib.slice;
    using Counters for Counters.Counter;
    string[] private names;
    mapping(uint256 => Counters.Counter) private  _metaLootCounter;
    ILoot private _loot;
    address payable private alchemistDAO;
    address payable private lootDAO;
    address payable private mintNodeDAO;
    address payable private farmPool;
    mapping(uint256 => uint256[]) private  _relationshipsOfmetaLoot;

    function initialize(NNS _nns) public initializer {
        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        super.initialize("MintNode", "NODE", _nns);
    }

    function start(uint256 input) internal pure returns (uint256) {
        require(input >= 0 && input <= 216, "Input invalid");
        return 269 - input;
    }

    function getOne(uint256 count) internal pure returns (string memory) {
        uint256 rand = count % 10;
        uint256 eyesRandY = rand * 24;
        return string(abi.encodePacked('<rect x="286" y="', Strings.toString(start(eyesRandY)), '" width="22" height="', Strings.toString(eyesRandY), '" rx="11" fill="#533AED"/>'));
    }

    function getTwo(uint256 count) internal pure returns (string memory) {
        uint256 mouthRand = (count % 100) / 10;
        uint256 mouthRandY = mouthRand * 24;
        return string(abi.encodePacked('<rect x="238" y="', Strings.toString(start(mouthRandY)), '" width="22" height="', Strings.toString(mouthRandY), '" rx="11" fill="#4BC769"/>'));
    }

    function getThree(uint256 count) internal pure returns (string memory) {
        uint256 faceRand = (count % 1000) / 100;
        uint256 faceRandY = faceRand * 24;
        return string(abi.encodePacked('<rect x="190" y="', Strings.toString(start(faceRandY)), '" width="22" height="', Strings.toString(faceRandY), '" rx="11" fill="#F37F33"/>'));
    }

    function getFour(uint256 count) internal pure returns (string memory) {
        uint256 topRand = (count % 10000) / 1000;
        uint256 topRandY = topRand * 24;
        return string(abi.encodePacked('<rect x="142" y="', Strings.toString(start(topRandY)), '" width="22" height="', Strings.toString(topRandY), '" rx="11" fill="#2DB6F5"/>'));
    }

    function getFive(uint256 count) internal pure returns (string memory) {
        uint256 sideRand = (count % 100000) / 10000;
        uint256 sideRandY = sideRand * 24;
        return string(abi.encodePacked('<rect x="94" y="', Strings.toString(start(sideRandY)), '" width="22" height="', Strings.toString(sideRandY), '" rx="11" fill="#E289F2"/>'));
    }

    function price(uint256 count) internal pure returns(uint256) {
        uint256 eplch = 0;
        if(count > 10){
            eplch = 500*(10**18);
        }
        return eplch;
    }
    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        require(_exists(tokenId), "id does not exist");
        string memory domain = getDomainOfTokenId(tokenId);
        uint256 count = countOfrelationships(tokenId);
        string[8] memory parts;
        parts[0] = '<svg width="706" height="706" viewBox="0 0 353 353" fill="none" xmlns="http://www.w3.org/2000/svg"><style>.base { fill: white; font-family: serif; font-size: 15px; }</style><rect width="353" height="353" rx="6" fill="black"/><text x="17" y="35" class="base">10</text><text x="22" y="83" class="base">8</text><text x="22" y="131" class="base">6</text><text x="22" y="179" class="base">4</text><text x="22" y="227" class="base">2</text><text x="22" y="275" class="base">0</text><g><line x1="54" y1="20" x2="54" y2="333" stroke="#A9A9A9"/><line x1="38" y1="270" x2="54" y2="270" stroke="white"/><line x1="38" y1="222" x2="54" y2="222" stroke="white"/><line x1="38" y1="174" x2="54" y2="174" stroke="white"/><line x1="38" y1="126" x2="54" y2="126" stroke="white"/><line x1="38" y1="78" x2="54" y2="78" stroke="white"/><line x1="38" y1="30" x2="54" y2="30" stroke="white"/></g><g><line x1="38" y1="297" x2="326" y2="297" stroke="#A9A9A9"/><line x1="103" y1="297" x2="103" y2="313" stroke="white"/><line x1="151" y1="297" x2="151" y2="313" stroke="white"/><line x1="199" y1="297" x2="199" y2="313" stroke="white"/><line x1="247" y1="297" x2="247" y2="313" stroke="white"/><line x1="295" y1="297" x2="295" y2="313" stroke="white"/></g><text x="99" y="329" class="base">x10k</text><text x="147" y="329" class="base">x1000</text><text x="195" y="329" class="base">x100</text><text x="243" y="329" class="base">x10</text><text x="291" y="329" class="base">x1</text><g>';

        parts[1] = getFive(count);

        parts[2] = getFour(count);

        parts[3] = getThree(count);

        parts[4] = getTwo(count);

        parts[5] = getOne(count);

        parts[6] = string(abi.encodePacked('<text x="94" y="35" class="base" text-anchor="start">', domain, '</text>'));

        parts[7] = string(abi.encodePacked('<text x="313" y="35" class="base" text-anchor="end">Count: ', Strings.toString(count), '</text></g></svg>'));

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7]));

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', domain, '", "description": "meta ID is.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function mint(string calldata _domain) public nonReentrant {
        uint256 balanceOf = _loot.balanceOf(_msgSender());
        uint256 _currentPrice = price(totalSupply());
        if(_currentPrice > 0){
            require(balanceOf >= _currentPrice, "Insufficient balance");

            _loot.transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), _currentPrice*2/10);
            _loot.transferFrom(msg.sender, farmPool, _currentPrice*2/10);
            _loot.transferFrom(msg.sender, lootDAO, _currentPrice*2/10);
            _loot.transferFrom(msg.sender, mintNodeDAO, _currentPrice*1/10);
            _loot.transferFrom(msg.sender, alchemistDAO, _currentPrice*3/10);
        }
        (bytes32 name, bytes32 rootDomain) = domainSplit(_domain);

        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, rootDomain));

        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, name));
        uint256 tokenId = uint256(subNode);
        _domainOfTokenId[tokenId] = _domain;
        _tokenIdOfDomain[_domain] = tokenId;
        register(tokenId, parentsNode, name, address(this));
    }

    function mintRoute(string calldata _domain, address owner) public nonReentrant {
        uint256 balanceOf = _loot.balanceOf(owner);
        uint256 _currentPrice = price(totalSupply());
        if(_currentPrice > 0){
            require(balanceOf >= _currentPrice, "Insufficient balance");

            _loot.transferFrom(owner, address(0x000000000000000000000000000000000000dEaD), _currentPrice*2/10);
            _loot.transferFrom(owner, farmPool, _currentPrice*2/10);
            _loot.transferFrom(owner, lootDAO, _currentPrice*2/10);
            _loot.transferFrom(owner, mintNodeDAO, _currentPrice*1/10);
            _loot.transferFrom(owner, alchemistDAO, _currentPrice*3/10);
        }
        (bytes32 name, bytes32 rootDomain) = domainSplit(_domain);

        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, rootDomain));

        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, name));
        uint256 tokenId = uint256(subNode);
        _domainOfTokenId[tokenId] = _domain;
        _tokenIdOfDomain[_domain] = tokenId;
        require(!_exists(tokenId), "Name has been registered");
        _mint(owner, tokenId);
        _register(parentsNode, name, address(this));
    }

    function setLoot(ILoot loot) public onlyOwner nonReentrant {
        _loot = loot;
    }

    function setAlchemistDAO(address payable alchemistDAO_) public onlyOwner nonReentrant {
        alchemistDAO = alchemistDAO_;
    }

    function setLootDAO(address payable lootDAO_) public onlyOwner nonReentrant {
        lootDAO = lootDAO_;
    }

    function setMintNodeDAO(address payable mintNodeDAO_) public onlyOwner nonReentrant {
        mintNodeDAO = mintNodeDAO_;
    }

    function setFarmPool(address payable farmPool_) public onlyOwner nonReentrant {
        farmPool = farmPool_;
    }

    function getDomainOfTokenId(uint256 _tokenId) public view returns (string memory) {
        return _domainOfTokenId[_tokenId];
    }

    function getTokenIdOfDomain(string memory _domain) public view returns (uint256) {
        return _tokenIdOfDomain[_domain];
    }

    function  tokenURIByDomain(string memory _domain) public view returns (string memory) {
        uint256 tokenId = getTokenIdOfDomain(_domain);
        return tokenURI(tokenId);
    }

    function domainSplit(string memory input) internal pure returns (bytes32, bytes32) {
        StringLib.slice  memory s = input.toSlice();
        StringLib.slice  memory delim = string(".").toSlice();
        require(s.count(delim) == 1, "domain format error");
        StringLib.slice memory name;
        StringLib.slice memory rootDomain;
        s.split(delim, name);
        s.split(delim, rootDomain);
        require(rootDomain.keccak() == keccak256(bytes("node")), "Root domain format error");
        return (name.keccak(), rootDomain.keccak());
    }

    function currentPrice() public view returns (uint256) {
        return price(totalSupply());
    }

    function increment(uint256 _tokenId) public nonReentrant {
        require(_exists(_tokenId), "id does not exist");
        _metaLootCounter[_tokenId].increment();
    }

    function updateRelationship(uint256 nodeTokenId, uint256 metaLootTokenId) public nonReentrant {
        require(_exists(nodeTokenId), "id does not exist");
        _relationshipsOfmetaLoot[nodeTokenId].push(metaLootTokenId);
    }

    function countOfrelationships(uint256 tokenId) public view returns (uint256) {
        return _relationshipsOfmetaLoot[tokenId].length;
    }

    function supportsInterface(bytes4 interfaceId) public view override(BaseRegistrarImplementation, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        // uint256 _currentPrice = 500*(10**18);
        // _loot.transferFrom(from, farmPool, _currentPrice*1/10);
        // _loot.transferFrom(from, lootDAO, _currentPrice*2/10);
        // _loot.transferFrom(from, mintNodeDAO, _currentPrice*1/10);
        // _loot.transferFrom(from, alchemistDAO, _currentPrice*3/10);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "../../node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "../utils/Base64.sol";
import "./SketchURI.sol";
import "../NNS/BaseRegistrarImplementation.sol";
import "../utils/StringLib.sol";
import "./MintNodeName.sol";
import "./LandName.sol";
import "../ILoot.sol";

contract MetaLootName is ReentrancyGuardUpgradeable, AccessControlUpgradeable, BaseRegistrarImplementation {
    SketchURI constant skin = SketchURI(0x4E933687dE1d055DC7AD60878091FEdAC24a8093);
    bytes32 private constant ROOT_NODE = bytes32(0);
    uint256 constant private _totalSupply = 100*1000;
    MintNodeName private _mintNode;  
    LandName private _landName;
    //NNS of the tokenId
    mapping(uint256 => string) private  _domainOfTokenId;
    //tokenId of the NNS
    mapping(string => uint256) private  _tokenIdOfDomain;
    ILoot private _loot;
    address payable private alchemistDAO;
    address payable private lootLp;
    address payable private lootDAO;
    address payable private mintNodeDAO;
    address payable private farmPool;
    mapping(uint256 => uint256) private  _relationshipsOfNode;
    mapping(uint256 => uint256) private  _relationshipsOfLand;
    address private EOAOf;
    mapping(uint256 => address) private _paymentOfRoyalties;
    // uint256 private _royalty = 20*(10**18);

    using StringLib for string;
    using StringLib for StringLib.slice;
    using Address for address;
    function initialize(NNS _nns, LandName _landName_, MintNodeName _mintNode_) public initializer {
        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _landName = _landName_;
        _mintNode = _mintNode_;
        super.initialize("MetaLoot", "DID", _nns);
    }

    function price(uint256 count) internal pure returns(uint256) {
        if (count <=20) {
            return 10*(10**15);
        } else if(count > 20 && count <=40){
            return 20*(10**15);
        } else if(count > 40 && count <=60){
            return 30*(10**15);
        } else if(count > 60 && count <=80){
            return 40*(10**15);
        } else if(count > 80 && count <=100){
            return 50*(10**15);
        } else if(count > 100 && count <=120){
            return 60*(10**15);
        } else if(count > 120 && count <=140){
            return 70*(10**15);
        } else if(count > 140 && count <=160){
            return 80*(10**15);
        } else if(count > 160 && count <=180){
            return 90*(10**15);
        } else {
            return 100*(10**15);
        }
    }
    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        require(_exists(tokenId), "id does not exist");
        string memory domain = getDomainOfTokenId(tokenId);
        string memory output = skin.image(tokenId, domain);

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', domain, '", "description": "meta loot is.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function mint(string calldata _domain, string calldata _node) public payable {
        require(totalSupply() < _totalSupply, "Mint has been completed");
        // require(_loot.allowance(_msgSender(), address(this)) >= price(totalSupply()), "Not enough approve tokens");
        require(alchemistDAO != address(0) && lootLp != address(0) && farmPool != address(0) && lootDAO != address(0) && mintNodeDAO != address(0), "Address cannot be 0");
        uint256 currentPrice = price(totalSupply());
        require(msg.value >= currentPrice, "Not enough payments"); 

        transfer(alchemistDAO, currentPrice * 30 / 100);
        transfer(lootLp, currentPrice * 20 / 100);
        uint256 nodeTokenId = uint256(getSubNode(_node));
        address mintNodeOwner = _mintNode.ownerOf(nodeTokenId);
        payable(mintNodeOwner).transfer(currentPrice * 45 / 100);

        (, bytes32 rootDomain) = domainSplit(_domain);
        uint256 landTokenId = _landTokenId(rootDomain);
        address landOwner = _landName.ownerOf(landTokenId);
        payable(landOwner).transfer(currentPrice * 5 / 100);
        if(msg.value > currentPrice){
            payable(msg.sender).transfer(msg.value - currentPrice);
        }
        _loot.mint(msg.sender, 300 ether);
        _loot.mint(farmPool, 100 ether);
        _loot.mint(lootDAO, 200 ether);
        _loot.mint(mintNodeDAO, 100 ether);
        _loot.mint(alchemistDAO, 300 ether);
        _create(_domain, _node);
    }

    function landOwnerOf(string calldata _domain, string calldata _node) external view returns(address, address) {

        uint256 nodeTokenId = uint256(getSubNode(_node));
        address mintNodeOwner = _mintNode.ownerOf(nodeTokenId);

        (, bytes32 rootDomain) = domainSplit(_domain);
        uint256 landTokenId = _landTokenId(rootDomain);
        address landOwner = _landName.ownerOf(landTokenId);
        return (landOwner, mintNodeOwner);
    }

    function currentPriceOf() public view returns (uint256) {
        return price(totalSupply());
    }

    function transfer(address payable _to, uint _amount) internal nonReentrant {
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send BNB");
    }

    function _create(string calldata _domain, string calldata _node) internal nonReentrant {

        uint256 nodeTokenId = uint256(getSubNode(_node));
        // require(_mintNode.ownerOf(nodeTokenId) != address(0x0), "No node found");

        (bytes32 name, bytes32 rootDomain) = domainSplit(_domain);
        uint256 landTokenId = _landTokenId(rootDomain);
        // require(_landName.ownerOf(landTokenId) != address(0x0), "Not found on the land");

        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, rootDomain));
        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, name));
        uint256 tokenId = uint256(subNode);

        _domainOfTokenId[tokenId] = _domain;
        _tokenIdOfDomain[_domain] = tokenId;
        register(tokenId, parentsNode, name, address(this));

        _landName.updateRelationship(landTokenId, tokenId);
        _mintNode.updateRelationship(nodeTokenId, tokenId);
        _relationshipsOfNode[tokenId] = nodeTokenId;
        _relationshipsOfLand[tokenId] = landTokenId;
    }

    function mintRoute(string calldata _domain, string calldata _node, address owner) public payable {
        require(totalSupply() < _totalSupply, "Mint has been completed");
        // require(_loot.allowance(_msgSender(), address(this)) >= price(totalSupply()), "Not enough approve tokens");
        require(alchemistDAO != address(0) && lootLp != address(0) && farmPool != address(0) && lootDAO != address(0) && mintNodeDAO != address(0), "Address cannot be 0");
        uint256 currentPrice = price(totalSupply());
        require(msg.value >= currentPrice, "Not enough payments"); 

        transfer(alchemistDAO, currentPrice * 30 / 100);
        transfer(lootLp, currentPrice * 20 / 100);
        uint256 nodeTokenId = uint256(getSubNode(_node));
        address mintNodeOwner = _mintNode.ownerOf(nodeTokenId);
        payable(mintNodeOwner).transfer(currentPrice * 45 / 100);

        (, bytes32 rootDomain) = domainSplit(_domain);
        uint256 landTokenId = _landTokenId(rootDomain);
        address landOwner = _landName.ownerOf(landTokenId);
        payable(landOwner).transfer(currentPrice * 5 / 100);
        if(msg.value > currentPrice){
            payable(owner).transfer(msg.value - currentPrice);
        }
        _loot.mint(owner, 300 ether);
        _loot.mint(farmPool, 100 ether);
        _loot.mint(lootDAO, 200 ether);
        _loot.mint(mintNodeDAO, 100 ether);
        _loot.mint(alchemistDAO, 300 ether);
        _createRoute(_domain, _node, owner);
    }

    function _createRoute(string calldata _domain, string calldata _node, address owner) internal nonReentrant {

        uint256 nodeTokenId = uint256(getSubNode(_node));
        // require(_mintNode.ownerOf(nodeTokenId) != address(0x0), "No node found");

        (bytes32 name, bytes32 rootDomain) = domainSplit(_domain);
        uint256 landTokenId = _landTokenId(rootDomain);
        // require(_landName.ownerOf(landTokenId) != address(0x0), "Not found on the land");

        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, rootDomain));
        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, name));
        uint256 tokenId = uint256(subNode);

        _domainOfTokenId[tokenId] = _domain;
        _tokenIdOfDomain[_domain] = tokenId;
        // register(tokenId, parentsNode, name, address(this));

        require(!_exists(tokenId), "Name has been registered");
        _mint(owner, tokenId);
        _register(parentsNode, name, address(this));
    
        _landName.updateRelationship(landTokenId, tokenId);
        _mintNode.updateRelationship(nodeTokenId, tokenId);
        _relationshipsOfNode[tokenId] = nodeTokenId;
        _relationshipsOfLand[tokenId] = landTokenId;
    }

    function isNode(string memory _node) public view returns (bool) {
        uint256 nodeTokenId = uint256(getSubNode(_node));
        return _mintNode.ownerOf(nodeTokenId) != address(0x0);
    }

    function _landTokenId(bytes32 label) internal pure returns (uint256) {
        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, keccak256(bytes("land"))));
        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, label));
        uint256 _tokenId = uint256(subNode);
        return _tokenId;
    }

    function getSubNode(string memory _domain) internal pure returns (bytes32) {
        (bytes32 name, bytes32 rootDomain) = domainSplit(_domain);
        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, rootDomain));
        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, name));
        return subNode;
    }

    function setLoot(ILoot loot) public onlyOwner nonReentrant {
        _loot = loot;
    }

    function setAlchemistDAO(address payable alchemistDAO_) public onlyOwner nonReentrant {
        alchemistDAO = alchemistDAO_;
    }

    function setLootLp(address payable lootLp_) public onlyOwner nonReentrant {
        lootLp = lootLp_;
    }

    function setLootDAO(address payable lootDAO_) public onlyOwner nonReentrant {
        lootDAO = lootDAO_;
    }

    function setMintNodeDAO(address payable mintNodeDAO_) public onlyOwner nonReentrant {
        mintNodeDAO = mintNodeDAO_;
    }

    function setFarmPool(address payable farmPool_) public onlyOwner nonReentrant {
        farmPool = farmPool_;
    }

    function getDomainOfTokenId(uint256 _tokenId) public view returns (string memory) {
        return _domainOfTokenId[_tokenId];
    }

    function getTokenIdOfDomain(string memory _domain) public view returns (uint256) {
        return _tokenIdOfDomain[_domain];
    }

    function  tokenURIByDomain(string memory _domain) public view returns (string memory) {
        uint256 tokenId = getTokenIdOfDomain(_domain);
        return tokenURI(tokenId);
    }

    function domainSplit(string memory input) internal pure returns (bytes32, bytes32) {
        StringLib.slice  memory s = input.toSlice();
        StringLib.slice  memory delim = string(".").toSlice();
        require(s.count(delim) == 1, "domain format error");
        StringLib.slice memory name;
        StringLib.slice memory rootDomain;
        s.split(delim, name);
        s.split(delim, rootDomain);
        return (name.keccak(), rootDomain.keccak());
    }

    function paymentOfRoyalties(string memory domain) public nonReentrant {
        uint256 _royalty = 20*(10**18);
        uint256 tokenId = getTokenIdOfDomain(domain);
        require(_exists(tokenId), "id does not exist");
        uint256 allowanceOf = _loot.allowance(_msgSender(), address(this));
        require(allowanceOf >= _royalty, "Payments on behalf of Error");
        _paymentOfRoyalties[tokenId] = _msgSender();
    }

    function supportsInterface(bytes4 interfaceId) public view override(BaseRegistrarImplementation, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        uint256 _royalty = 20*(10**18);
        if((from != address(0) || to != address(0) || to != address(0x000000000000000000000000000000000000dEaD)) && !to.isContract() && to != EOAOf){
            uint256 allowanceOf = _loot.allowance(EOAOf, address(this));
            address payer;
            if (allowanceOf >= _royalty) {
                payer = EOAOf;
            } else {
                address payerOf = _paymentOfRoyalties[tokenId];
                require(payerOf != address(0), "Payer Error");
                allowanceOf = _loot.allowance(payerOf, address(this));
                if(allowanceOf >= _royalty){
                    payer = payerOf;
                }
            }
            require(payer != address(0), "Insufficient balance");
            uint256 nodeTokenId = _relationshipsOfNode[tokenId];
            uint256 landTokenId = _relationshipsOfLand[tokenId];
            address mintNodeOwner = _mintNode.ownerOf(nodeTokenId);
            address landOwner = _landName.ownerOf(landTokenId);
            _loot.transferFrom(payer, mintNodeOwner, _royalty*25/100);
            _loot.transferFrom(payer, landOwner, _royalty*5/100);
            _loot.transferFrom(payer, farmPool, _royalty*1/10);
            _loot.transferFrom(payer, lootDAO, _royalty*2/10);
            _loot.transferFrom(payer, mintNodeDAO, _royalty*1/10);
            _loot.transferFrom(payer, alchemistDAO, _royalty*3/10);
        }
        if(!to.isContract()){
            EOAOf = to;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract LandURI is Initializable, AccessControlUpgradeable {
    using SafeCast for uint;
    bytes32 public constant SKIN_ADMIN = keccak256("SKIN_ADMIN");
    string[] private names;
    function initialize() public initializer {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SKIN_ADMIN, msg.sender);
        
    }

    function W(uint8 r) internal pure returns (uint16) {
        return (r + 9) * 1000;
    }

    function H(uint8 r) internal pure returns (uint16) {
        return (r + 9) * 1732 / 2;
    }

    function transformX(uint8 r) internal pure returns (uint16) {
        return 18000 - W(r);
    }

    function transformY(uint8 r) internal pure returns (uint16) {
        return 15588 - H(r);
    }
    function pointA(uint8 r) internal pure returns (string memory) {
        return string(abi.encodePacked(' ', Strings.toString(transformX(r)), ',', Strings.toString(H(r) + transformY(r)), ' '));
    }

    function pointB(uint8 r) internal pure returns (string memory) {
        return string(abi.encodePacked(' ', Strings.toString(W(r)/2 + transformX(r)), ',', Strings.toString(H(r)*2 + transformY(r)), ' '));
    }

    function pointC(uint8 r) internal pure returns (string memory) {
        return string(abi.encodePacked(' ', Strings.toString(uint32(W(r))*15/10 + transformX(r)), ',', Strings.toString(H(r)*2 + transformY(r)), ' '));
    }

    function pointD(uint8 r) internal pure returns (string memory) {
        return string(abi.encodePacked(' ', Strings.toString(W(r)*2 + transformX(r)), ',', Strings.toString(H(r) + transformY(r)), ' '));
    }

    function pointE(uint8 r) internal pure returns (string memory) {
        return string(abi.encodePacked(' ', Strings.toString(uint32(W(r))*15/10 + transformX(r)), ',', Strings.toString(transformY(r)), ' '));
    }

    function pointF(uint8 r) internal pure returns (string memory) {
        return string(abi.encodePacked(' ', Strings.toString(W(r)/2 + transformX(r)), ',', Strings.toString(transformY(r)), ' '));
    }

    function image(uint256 count, string memory name) external pure returns (string memory) {
        string[5] memory parts;
        parts[0] = '<svg width="500" height="500" viewBox="0 0 42000 42000" xmlns="http://www.w3.org/2000/svg"><rect x="0" y="0" width="42000" height="42000" fill="black"/><g transform="translate(0, 3912)"><g transform="translate(3000, 0)"><polygon points="0,15588 9000,31176 27000,31176 36000,15588 27000,0 9000,0" fill="white"/>';
        parts[1] = getPolygon(count);
        parts[2] = string(abi.encodePacked('<text x="18000" y="34176" font-weight="bold" font-size="3000" text-anchor="middle" fill="white">', name, '</text>'));
        parts[3] = string(abi.encodePacked('<text x="18000" y="36176" font-size="2000" text-anchor="middle" fill="white">count:', Strings.toString(count), '</text>'));
        parts[4] = '</g></g></svg>';
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4]));
        return output;
    }

    function getOne(uint256 count) internal pure returns (string memory) {
        uint8 rand = (count % 10).toUint8();

        if (rand == 0) {
            return '';
        } else {
            return string(abi.encodePacked('<polygon points="', pointE(9), pointD(rand), '18000,15588" fill="#FD3D39"/>'));
        }
    }

    function getTwo(uint256 count) internal pure returns (string memory) {
        uint8 rand = ((count % 100) / 10).toUint8();
        if (rand == 0) {
            return '';
        } else {
            return string(abi.encodePacked('<polygon points="', pointD(9), pointC(rand), '18000,15588" fill="#FE9526"/>'));
        }
    }

    function getThree(uint256 count) internal pure returns (string memory) {
        uint8 rand = ((count % 1000) / 100).toUint8();
        if (rand == 0) {
            return '';
        } else {
            return string(abi.encodePacked('<polygon points="', pointC(9), pointB(rand), '18000,15588" fill="#FFCB2F"/>'));
        }
    }

    function getFour(uint256 count) internal pure returns (string memory) {
        uint8 rand = ((count % 10000) / 1000).toUint8();
        if (rand == 0) {
            return '';
        } else {
            return string(abi.encodePacked('<polygon points="', pointB(9), pointA(rand), '18000,15588" fill="#39C86A"/>'));
        }
    }

    function getFive(uint256 count) internal pure returns (string memory) {
        uint8 rand = ((count % 100000) / 10000).toUint8();

        if (rand == 0) {
            return '';
        } else {
            return string(abi.encodePacked('<polygon points="', pointA(9), pointF(rand), '18000,15588" fill="#2DB6F5"/>'));
        }
    }

    function getSix(uint256 count) internal pure returns (string memory) {
        uint8 rand = ((count % 1000000) / 100000).toUint8();

        if (rand == 0) {
            return '';
        } else {
            
            return string(abi.encodePacked('<polygon points="', pointF(9), pointE(rand), '18000,15588" fill="#855CF8"/>'));
        }
    }

    function getPolygon(uint256 count) internal pure returns (string memory) {
        string[6] memory parts;
        parts[0] = getOne(count);
        parts[1] = getTwo(count);
        parts[2] = getThree(count);
        parts[3] = getFour(count);
        parts[4] = getFive(count);
        parts[5] = getSix(count);
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]));
        return output;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "../../node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "../../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "../utils/Base64.sol";
import "../interface/ItokenURI.sol";
import "./LandURI.sol";
import "../NNS/BaseRegistrarImplementation.sol";
import "../utils/StringLib.sol";
import "../ILoot.sol";
// import "https://github.com/Arachnid/solidity-stringutils/blob/master/src/strings.sol";

contract LandName is ReentrancyGuardUpgradeable, AccessControlUpgradeable, BaseRegistrarImplementation {
    LandURI constant skin = LandURI(0x3222203B920c8e38fc1d6815f6d2b62e979a18C6);
    bytes32 private constant ROOT_NODE = bytes32(0);
    uint256 constant private _totalSupply = 2100;
    //NNS of the tokenId
    mapping(uint256 => string) private  _domainOfTokenId;
    //tokenId of the NNS
    mapping(string => uint256) private  _tokenIdOfDomain;
    mapping(uint256 => Counters.Counter) private  _metaLootCounter;
    address private _metaLoot;
    ILoot private _loot;
    address payable private alchemistDAO;
    address payable private lootDAO;
    address payable private mintNodeDAO;
    address payable private farmPool;
    mapping(uint256 => uint256[]) private  _relationshipsOfmetaLoot;
    
    using StringLib for string;
    using StringLib for StringLib.slice;
    using Counters for Counters.Counter;
    // constructor(string memory name_, string memory symbol_, NNS _nns, bytes32 _baseNode) ERC721(name_, symbol_) {
    //     nns = _nns;
    //     baseNode = _baseNode;
    // }
    function initialize(NNS _nns) public initializer {
        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        super.initialize("Land", "LAND", _nns);
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function price(uint256 count) internal pure returns(uint256) {
        uint256 eplch = count / 10;
        return eplch*100*(10**18);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        require(_exists(tokenId), "id does not exist");
        string memory domain = getDomainOfTokenId(tokenId);
        uint256 count = countOfrelationships(tokenId);
        string memory output = skin.image(count, domain);

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', domain,'", "description": "meta loot is.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function mint(string calldata _domain) public nonReentrant {
        require(totalSupply() < _totalSupply, "Mint has been completed");
        uint256 balanceOf = _loot.balanceOf(_msgSender());
        uint256 _currentPrice = price(totalSupply());
        if(_currentPrice > 0){
            require(balanceOf >= _currentPrice, "Insufficient balance");

            _loot.transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), _currentPrice*2/10);
            _loot.transferFrom(msg.sender, farmPool, _currentPrice*2/10);
            _loot.transferFrom(msg.sender, lootDAO, _currentPrice*2/10);
            _loot.transferFrom(msg.sender, mintNodeDAO, _currentPrice*1/10);
            _loot.transferFrom(msg.sender, alchemistDAO, _currentPrice*3/10);
        }
        (bytes32 name, bytes32 rootDomain) = domainSplit(_domain);
        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, rootDomain));

        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, name));
        uint256 tokenId = uint256(subNode);
        _domainOfTokenId[tokenId] = _domain;
        _tokenIdOfDomain[_domain] = tokenId;
        register(tokenId, parentsNode, name, address(this));
        
        require(_metaLoot != address(0x0), "MetaLoot is not initialized");
        _register(ROOT_NODE, name, _metaLoot);

    }

    function mintRoute(string calldata _domain, address owner) public nonReentrant {
        require(totalSupply() < _totalSupply, "Mint has been completed");
        uint256 balanceOf = _loot.balanceOf(owner);
        uint256 _currentPrice = price(totalSupply());
        if(_currentPrice > 0){
            require(balanceOf >= _currentPrice, "Insufficient balance");

            _loot.transferFrom(owner, address(0x000000000000000000000000000000000000dEaD), _currentPrice*2/10);
            _loot.transferFrom(owner, farmPool, _currentPrice*2/10);
            _loot.transferFrom(owner, lootDAO, _currentPrice*2/10);
            _loot.transferFrom(owner, mintNodeDAO, _currentPrice*1/10);
            _loot.transferFrom(owner, alchemistDAO, _currentPrice*3/10);
        }
        (bytes32 name, bytes32 rootDomain) = domainSplit(_domain);
        bytes32 parentsNode = keccak256(abi.encodePacked(ROOT_NODE, rootDomain));

        bytes32 subNode = keccak256(abi.encodePacked(parentsNode, name));
        uint256 tokenId = uint256(subNode);
        _domainOfTokenId[tokenId] = _domain;
        _tokenIdOfDomain[_domain] = tokenId;

        require(!_exists(tokenId), "Name has been registered");
        _mint(owner, tokenId);
        _register(parentsNode, name, address(this));

        require(_metaLoot != address(0x0), "MetaLoot is not initialized");
        _register(ROOT_NODE, name, _metaLoot);

    }

    function setLoot(ILoot loot) public onlyOwner nonReentrant {
        _loot = loot;
    }

    function setAlchemistDAO(address payable alchemistDAO_) public onlyOwner nonReentrant {
        alchemistDAO = alchemistDAO_;
    }

    function setLootDAO(address payable lootDAO_) public onlyOwner nonReentrant {
        lootDAO = lootDAO_;
    }

    function setMintNodeDAO(address payable mintNodeDAO_) public onlyOwner nonReentrant {
        mintNodeDAO = mintNodeDAO_;
    }

    function setFarmPool(address payable farmPool_) public onlyOwner nonReentrant {
        farmPool = farmPool_;
    }

    function getDomainOfTokenId(uint256 _tokenId) public view returns (string memory) {
        return _domainOfTokenId[_tokenId];
    }

    function getTokenIdOfDomain(string memory _domain) public view returns (uint256) {
        return _tokenIdOfDomain[_domain];
    }

    function  tokenURIByDomain(string memory _domain) public view returns (string memory) {
        uint256 tokenId = getTokenIdOfDomain(_domain);
        return tokenURI(tokenId);
    }

    function domainSplit(string memory input) internal pure returns (bytes32, bytes32) {
        StringLib.slice  memory s = input.toSlice();
        StringLib.slice  memory delim = string(".").toSlice();
        require(s.count(delim) == 1, "domain format error");
        StringLib.slice memory name;
        StringLib.slice memory rootDomain;
        s.split(delim, name);
        s.split(delim, rootDomain);
        require(rootDomain.keccak() == keccak256(bytes("land")), "Root domain format error");
        return (name.keccak(), rootDomain.keccak());
    }

    function increment(uint256 _tokenId) public nonReentrant {
        require(_exists(_tokenId), "id does not exist");
        _metaLootCounter[_tokenId].increment();
    }

    function currentPrice() public view returns (uint256) {
        return price(totalSupply());
    }

    function updateRelationship(uint256 landTokenId, uint256 metaLootTokenId) public nonReentrant {
        require(_exists(landTokenId), "id does not exist");
        _relationshipsOfmetaLoot[landTokenId].push(metaLootTokenId);
    }

    function countOfrelationships(uint256 tokenId) public view returns (uint256) {
        return _relationshipsOfmetaLoot[tokenId].length;
    }

    function setMetaLootAddress(address _metaLootAddress) public onlyOwner nonReentrant {
        _metaLoot = _metaLootAddress;
    }

    function supportsInterface(bytes4 interfaceId) public view override(BaseRegistrarImplementation, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "../utils/Base64.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "./SkinDog.sol";


contract Alchemist is ReentrancyGuardUpgradeable, AccessControlUpgradeable, ERC721EnumerableUpgradeable {
    bytes32 public constant WHITE_LIST= keccak256("WHITE_LIST");
    SkinDog constant skin = SkinDog(0x560C4b009E5CF19e36E3220b90ae330f38DFD5a0);
    uint public next_id;
    function initialize() public initializer {
        __ERC721_init("Alchemist", "ALCH");
        __AccessControl_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(WHITE_LIST, msg.sender);
        next_id = 1000;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        require(tokenId >= 0 && tokenId <next_id, "ID is invalid");
        string memory output = skin.image(tokenId);

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', Strings.toString(tokenId),'.alchemist", "description": "meta loot is.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function mint() public {
        require(hasRole(WHITE_LIST, msg.sender), "No permission");
        require(next_id >= 1000 && next_id <= 4000, "ID invalid");
        uint256 id = next_id;
        _mint(_msgSender(), id);
        next_id++;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, ERC721EnumerableUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ItokenURI {
    function image(uint256) external pure returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface NNS {

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when an operator is added or removed.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setApprovalForAll(address operator, bool approved) external;
    function ownerOf(bytes32 node) external view returns (address);
    function resolverOf(bytes32 node) external view returns (address);
    function recordExists(bytes32 node) external view returns (bool);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./NNS.sol";
// import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./BaseRegistrar.sol";

contract BaseRegistrarImplementation is ERC721EnumerableUpgradeable, BaseRegistrar  {

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 constant private ERC721_ID = bytes4(
        keccak256("balanceOf(address)") ^
        keccak256("ownerOf(uint256)") ^
        keccak256("approve(address,uint256)") ^
        keccak256("getApproved(uint256)") ^
        keccak256("setApprovalForAll(address,bool)") ^
        keccak256("isApprovedForAll(address,address)") ^
        keccak256("transferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256,bytes)")
    );
    bytes4 constant private RECLAIM_ID = bytes4(keccak256("reclaim(uint256,address)"));
    /**
     * v2.1.3 version of _isApprovedOrOwner which calls ownerOf(tokenId) and takes grace period into consideration instead of ERC721.ownerOf(tokenId);
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.1.3/contracts/token/ERC721/ERC721.sol#L187
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // constructor(string memory name_, string memory symbol_, NNS _nns, bytes32 _baseNode) ERC721(name_, symbol_) {
    //     nns = _nns;
    //     baseNode = _baseNode;
    // }
    function initialize(string memory name_, string memory symbol_, NNS _nns) virtual public initializer {
        __ERC721_init(name_, symbol_);
        __Ownable_init();
        nns = _nns;
    }

    modifier live(bytes32 baseNode) {
        require(nns.ownerOf(baseNode) == address(this) || nns.isApprovedForAll(nns.ownerOf(baseNode), address(this)), "BaseRegistrarImplementation: Caller is not approved or not the owner");
        _;
    }

    modifier onlyController {
        require(controllers[msg.sender], "BaseRegistrarImplementation: Caller is not a controller");
        _;
    }

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external override onlyOwner {
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    // Revoke controller permission for an address.
    function removeController(address controller) external override onlyOwner {
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    // Set the resolver for the TLD this registrar manages.
    function setResolver(bytes32 baseNode, address resolver) external override onlyOwner {
        nns.setResolver(baseNode, resolver);
    }

    /**
     * @dev Register a name.
     * @param id The token ID (keccak256 of the label).
     * @param owner The address that should own the registration.
     */
    function register(uint256 id, bytes32 baseNode, bytes32 label, address owner) internal override returns(bytes32) {
        require(!_exists(id), "Name has been registered");
        _safeMint(_msgSender(), id);
      return _register(baseNode,  label, owner);
    }

    function _register(bytes32 baseNode, bytes32 label, address owner) internal live(baseNode) returns(bytes32) {
        bytes32 subnode = nns.setSubnodeOwner(baseNode, label, owner);
        emit NameRegistered(label, owner);
        return subnode;
    }

    /**
     * @dev Reclaim ownership of a name in NNS, if you own it in the registrar.
     */
    // function reclaim(uint256 id, address owner) external override live {
    //     require(_isApprovedOrOwner(msg.sender, id));
    //     nns.setSubnodeOwner(baseNode, bytes32(id), owner);
    // }
    
    function supportsInterface(bytes4 interfaceId) public virtual override(ERC721EnumerableUpgradeable, IERC165Upgradeable) view returns (bool) {
        return 
        // interfaceID == INTERFACE_META_ID ||
            //    interfaceID == ERC721_ID ||
        interfaceId == RECLAIM_ID || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./NNS.sol";
// import "../../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "../../node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract BaseRegistrar is OwnableUpgradeable, IERC721EnumerableUpgradeable {

    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);
    event NameRegistered(bytes32 indexed label, address indexed owner);

    // The ENS registry
    NNS public nns;

    // A map of addresses that are authorised to register and renew names.
    mapping(address=>bool) public controllers;

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) virtual external;

    // Revoke controller permission for an address.
    function removeController(address controller) virtual external;

    // Set the resolver for the TLD this registrar manages.
    function setResolver(bytes32 baseNode, address resolver) virtual external;

    /**
     * @dev Register a name.
     */
    function register(uint256 id, bytes32 baseNode, bytes32 label, address owner) virtual internal returns(bytes32);

    /**
     * @dev Reclaim ownership of a name in ENS, if you own it in the registrar.
     */
    // function reclaim(uint256 id, address owner) virtual external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ILoot is IERC20, IERC20Metadata {
    function mint(address, uint256) external;
}