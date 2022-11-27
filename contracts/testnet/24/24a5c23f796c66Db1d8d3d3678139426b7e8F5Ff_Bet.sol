// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import './interfaces/IStarTicket.sol';
import './libraries/VerifyBetInfo.sol';

contract Bet is Ownable {
    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    uint8 constant NOT_END = 0;
    uint8 constant A_WIN = 1;
    uint8 constant DRAW = 2;
    uint8 constant B_WIN = 3;

    uint8 constant FIRST_HALF = 0;
    uint8 constant SECOND_HALF = 1;
    uint8 constant FULLTIME = 2;

    Counters.Counter public matchIds;
    Counters.Counter public betIds;
    address public treasury;
    address public agbToken;
    address public starTicket;
    mapping(uint256 => MatchInfo) public idToMatchInfo;
    mapping(uint256 => BetInfo) public idToBetInfo;

    event MatchStatus(
        uint256 itemId,
        string matchCode,
        uint8 firstHalfResult,
        uint8 secondHalfResult,
        uint8 fulltimeResult
    );

    event BetStatus(
        uint256 betId,
        uint256 matchId,
        uint8 betType,
        uint8 betResult,
        uint16 oddsBet, // 2/100 ~ 0.02
        uint256 amount,
        uint8 starTicketId,
        address user,
        bool isClaim
    );

    struct MatchInfo {
        uint256 itemId;
        string matchCode;
        uint8 firstHalfResult;
        uint8 secondHalfResult;
        uint8 fulltimeResult;
    }

    struct BetInfo {
        uint256 betId;
        uint256 matchId;
        uint8 betType;
        uint8 betResult;
        uint16 oddsBet; // 2/100 ~ 0.02
        uint256 amount;
        uint8 starTicketId;
        address user;
        bool isClaim;
    }

    constructor(
        address _treasury,
        address _agbToken,
        address _starTicket
    ) {
        treasury = _treasury;
        agbToken = _agbToken;
        starTicket = _starTicket;
    }

    function createMatch(string memory _matchCode) public onlyOwner {
        uint256 itemId = matchIds.current();
        idToMatchInfo[itemId] = MatchInfo(itemId, _matchCode, 0, 0, 0);
        matchIds.increment();
        emit MatchStatus(
            itemId,
            _matchCode,
            0,
            0,
            0
        );
    }

    function updateFirstHalf(uint256 _matchId, uint8 _result) public onlyOwner {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        require(matchInfo.firstHalfResult == NOT_END, 'First half was updated');
        idToMatchInfo[_matchId].firstHalfResult = _result;
        emit MatchStatus(
            _matchId,
            matchInfo.matchCode,
            _result,
            0,
            0
        );
    }

    function updateSecondHalf(uint256 _matchId, uint8 _result)
    public
    onlyOwner
    {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        require(
            matchInfo.firstHalfResult != NOT_END,
            'First half was not updated'
        );
        require(
            matchInfo.secondHalfResult == NOT_END,
            'Second half was updated'
        );
        idToMatchInfo[_matchId].secondHalfResult = _result;
        emit MatchStatus(
            _matchId,
            matchInfo.matchCode,
            matchInfo.firstHalfResult,
            _result,
            0
        );
    }

    function updateFulltime(uint256 _matchId, uint8 _result) public onlyOwner {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        require(
            matchInfo.firstHalfResult != NOT_END,
            'First half was not updated'
        );
        require(
            matchInfo.secondHalfResult != NOT_END,
            'Second half was not updated'
        );
        require(matchInfo.fulltimeResult == NOT_END, 'Fulltime was updated');
        idToMatchInfo[_matchId].fulltimeResult = _result;
        emit MatchStatus(
            _matchId,
            matchInfo.matchCode,
            matchInfo.firstHalfResult,
            matchInfo.secondHalfResult,
            _result
        );
    }

    function userBet(
        uint256 _matchId,
        uint8 _betType,
        uint256 _amount,
        uint16 _oddsBet,
        uint8 _betResult,
        uint8 _starTicketId,
        bytes memory _hashedMessage
    ) public {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        bool isValidBet = true;
        if (_betType == FIRST_HALF && matchInfo.firstHalfResult != NOT_END) {
            isValidBet = false;
        }
        if (_betType == SECOND_HALF && matchInfo.secondHalfResult != NOT_END) {
            isValidBet = false;
        }
        if (_betType == FULLTIME && matchInfo.fulltimeResult != NOT_END) {
            isValidBet = false;
        }
        require(isValidBet, 'This bet information is invalid');
        isValidBet = VerifyBetInfo.verify(
            owner(),
            _matchId,
            _betType,
            _betResult,
            _amount,
            _oddsBet,
            _hashedMessage
        );
        require(isValidBet, 'This bet signature is invalid');
        if (_starTicketId > 0) {
            require(
                IERC1155(starTicket).balanceOf(msg.sender, _starTicketId) > 0,
                'Star ticket is invalid'
            );
        }
        uint256 itemId = betIds.current();
        idToBetInfo[itemId] = BetInfo(
            itemId,
            _matchId,
            _betType,
            _betResult,
            _oddsBet,
            _amount,
            _starTicketId,
            msg.sender,
            false
        );
        betIds.increment();
        IERC20(agbToken).transferFrom(msg.sender, treasury, _amount);
        if (_starTicketId > 0) {
            IERC1155(starTicket).safeTransferFrom(msg.sender, treasury, _starTicketId, 1, '');
        }
        emit BetStatus(
            itemId,
            _matchId,
            _betType,
            _betResult,
            _oddsBet,
            _amount,
            _starTicketId,
            msg.sender,
            false
        );
    }

    function userClaim(uint256 _betId) public {
        BetInfo storage betInfo = idToBetInfo[_betId];
        MatchInfo memory matchInfo = idToMatchInfo[betInfo.matchId];
        require(msg.sender == betInfo.user, 'You are not owner of this bet');
        bool isValidClaim = true;
        if (
            betInfo.betType == FIRST_HALF &&
            matchInfo.firstHalfResult == NOT_END
        ) {
            isValidClaim = false;
        }
        if (
            betInfo.betType == SECOND_HALF &&
            matchInfo.secondHalfResult == NOT_END
        ) {
            isValidClaim = false;
        }
        if (
            betInfo.betType == FULLTIME && matchInfo.fulltimeResult == NOT_END
        ) {
            isValidClaim = false;
        }
        require(isValidClaim, 'This claim information is invalid');
        require(!betInfo.isClaim, 'User claimed');
        bool isWin = false;
        if (
            betInfo.betType == FIRST_HALF &&
            betInfo.betResult == matchInfo.firstHalfResult
        ) {
            isWin = true;
        }
        if (
            betInfo.betType == SECOND_HALF &&
            betInfo.betResult == matchInfo.secondHalfResult
        ) {
            isWin = true;
        }
        if (
            betInfo.betType == FULLTIME &&
            betInfo.betResult == matchInfo.fulltimeResult
        ) {
            isWin = true;
        }
        require(isWin, 'You lose');
        betInfo.isClaim = true;
        uint16 bonus = 0;
        if (betInfo.starTicketId > 0) {
            bonus = IStarTicket(starTicket).getBonusProfit(
                betInfo.starTicketId
            );
        }
        uint256 reward = (betInfo.oddsBet * betInfo.amount) /
        100 +
        (bonus * betInfo.amount * (betInfo.oddsBet - 100)) /
        100;
        IERC20(agbToken).transferFrom(treasury, msg.sender, reward);
        emit BetStatus(
            _betId,
            matchInfo.itemId,
            betInfo.betType,
            betInfo.betResult,
            betInfo.oddsBet,
            betInfo.amount,
            betInfo.starTicketId,
            msg.sender,
            true
        );
    }

    function getMessageHash(
        uint256 _matchId,
        uint8 _betType,
        uint8 _betResult,
        uint256 _amount,
        uint256 _oddsBet
    ) public pure returns (bytes32) {
        return
        keccak256(abi.encodePacked(_matchId, _betType, _betResult, _amount, _oddsBet));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

interface IStarTicket is IERC1155 {
    function getBonusProfit(uint8 _ticketId) external view returns (uint16);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library VerifyBetInfo {
    function getMessageHash(
        uint256 _matchId,
        uint8 _betType,
        uint8 _betResult,
        uint256 _amount,
        uint256 _oddsBet
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_matchId, _betType, _betResult, _amount, _oddsBet));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
    internal
    pure
    returns (bytes32)
    {
        return
        keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function verify(
        address _signer,
        uint256 _matchId,
        uint8 _betType,
        uint8 _betResult,
        uint256 _amount,
        uint256 _oddsBet,
        bytes memory signature
    ) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_matchId, _betType, _betResult, _amount, _oddsBet);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        address signer = recoverSigner(ethSignedMessageHash, signature);
        return signer == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
    internal
    pure
    returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
    internal
    pure
    returns (
        bytes32 r,
        bytes32 s,
        uint8 v
    )
    {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}