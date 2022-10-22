// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/ICutaverse.sol";

contract Cutaverse is ICutaverse,ERC20Capped,Ownable{
    using EnumerableSet for EnumerableSet.AddressSet;

    string public constant version = '1';

    // --- EIP712 niceties ---
    bytes32 public DOMAIN_SEPARATOR;

    bytes32 private constant _PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    mapping (address => uint)  public nonces;

    EnumerableSet.AddressSet private minterSet;

    event AddMinter(address indexed minter);
    event RomoveMinter(address indexed minter);

    constructor(uint256 cap, string memory name, string memory symbol) ERC20Capped(cap) ERC20(name, symbol) {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            ));
        EnumerableSet.add(minterSet,msg.sender);
    }


    modifier onlyMinter() {
        require(EnumerableSet.contains(minterSet,msg.sender),"Ownable: caller is not the minter");
        _;
    }

    function cap() public view override(ICutaverse,ERC20Capped) returns (uint256){
        return super.cap();
    }

    function addMinter(address minter) public override{
        require(minter != address(0),"minter is the zero address");
        EnumerableSet.add(minterSet,minter);

        emit AddMinter(minter);
    }

    function removeMinter(address minter) public override{
        require(minter != address(0),"minter is the zero address");
        EnumerableSet.remove(minterSet,minter);

        emit RomoveMinter(minter);
    }

    function mint(address account, uint256 amount) public override onlyMinter {
        _mint(account, amount);
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        bytes32 digest =
        keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(_PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonce,
                deadline))
            ));
        //bytes32 hash = _hashTypedDataV4(digest);

        address signer = ecrecover(digest, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");
        require(deadline == 0 || block.timestamp <= deadline, "Cutaverse/permit-expired");
        nonces[owner] = nonces[owner]+1;
        require(nonce == nonces[owner], "Cutaverse/invalid-nonce");

        _approve(owner, spender, value);
    }

//    function permit(
//        PermitData memory permitData,
//        Sig memory sig
//    ) public override{
//        bytes32 digest =
//        keccak256(abi.encodePacked(
//                "\x19\x01",
//                DOMAIN_SEPARATOR,
//                keccak256(abi.encode(_PERMIT_TYPEHASH,
//                permitData.owner,
//                permitData.spender,
//                permitData.value,
//                permitData.nonce,
//                permitData.deadline))
//            ));
//
//        address signer = ecrecover(digest, sig.v, sig.r, sig.s);
//        require(signer == permitData.owner, "ERC20Permit: invalid signature");
//        require(permitData.deadline == 0 || block.timestamp <= permitData.deadline, "Cutaverse/permit-expired");
//        nonces[permitData.owner] = nonces[permitData.owner]+1;
//        require(permitData.nonce == nonces[permitData.owner], "Cutaverse/invalid-nonce");
//
//        _approve(permitData.owner, permitData.spender, permitData.value);
//    }

    //TODO 验证用，用完即删
    function check(
        address owner, address spender, uint256 value,uint256 nonce, uint256 deadline, uint8 v, bytes32 r, bytes32 s
    ) public view returns(address){
        bytes32 digest =
        keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(_PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonce,
                deadline))
            ));

        address signer = ecrecover(digest, v, r, s);
        return signer;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../storage/CutaverseStorage.sol";

interface ICutaverse is CutaverseStorage,IERC20Metadata{

    function cap() external view returns (uint256);

    function addMinter(address minter) external virtual;

    function removeMinter(address minter) external virtual;

    function mint(address account, uint256 amount) external virtual;

    function permit(
        address owner, address spender, uint256 value,uint256 nonce, uint256 deadline, uint8 v, bytes32 r, bytes32 s
    ) external virtual;

//    function permit(
//        PermitData memory permitData,
//        Sig memory sig
//    ) external virtual;
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface CutaverseStorage {

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct PermitData {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/ISeed.sol";
import "../interfaces/ICutaverse.sol";
import "../utils/Overrun.sol";

contract ShopStorage {

    struct SeedContainer{
        ISeed seed;
        bool onSale;
        uint256 price;
        uint256 shopBuyRoundLimit;
        uint256 userBuyRoundLimit;
    }

    address public feeTo;
    ICutaverse public cutaverse;

    SeedContainer[] public seedContainers;
    mapping(address => uint256) public seedContainersOfPid;

    mapping(address => Overrun.Limit) public seedShopBuyLimit;
    mapping(address => mapping(address => Overrun.Limit)) public seedUserBuyLimit;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../storage/SeedStorage.sol";

//import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


interface ISeed is SeedStorage{
//interface ISeed is IERC20Metadata{
    function restShop(address shop) external virtual;
    function restFarm(address farm) external virtual;
    function restYield(uint256 yield) external virtual;
    function restMatureTime(uint256 matureTime) external virtual;
    function mint(address account, uint256 amount) external virtual;
    function burnFrom(address account, uint256 amount) external virtual;

    function shop() external view virtual returns(address);
    function farm() external view virtual returns(address);
    function yield() external view virtual returns(uint256);
    function matureTime() external view virtual returns(uint256);
    function decimals() external view virtual returns (uint8);
    function initialize(string memory name, string memory symbol, uint256 yield, uint256 matureTime, address shop) external virtual;

//    function permit(
//        SeedPermitData memory permitData,
//        SeedSig memory sig
//    ) external virtual;

    function permit(
        address owner, address spender, uint256 value,uint256 nonce, uint256 deadline, uint8 v, bytes32 r, bytes32 s
    ) external virtual;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library Overrun {
    using SafeMath for uint256;

    struct Limit{
        uint256 timeline;
        uint256 times;
    }

    function isOverrun(Limit memory limit, uint256 curTimes, uint256 roundTime, uint256 limitValue) internal view returns(bool,bool){
        uint256 timeline  = limit.timeline;
        uint256 times  = limit.times;

        bool isOverrun = times.add(curTimes) > limitValue;
        bool isOvertime = timeline.add(roundTime) < block.timestamp;

        if(isOvertime && curTimes > limitValue){
            return (true,true);
        }

        if(!isOvertime && isOverrun){
            return (true,false);
        }

        return (false, isOvertime);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface SeedStorage {

    struct SeedSig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct SeedPermitData {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IShop.sol";

contract Shop is IShop,Ownable,Pausable,ReentrancyGuard{
    using SafeMath for uint256;
    using Overrun for Overrun.Limit;

    constructor (address _feeTo, ICutaverse _cutaverse){
        require(_feeTo != address(0), "_feeTo is the zero address");
        require(address(_cutaverse) != address(0), "_cutaverse is the zero address");

        feeTo = _feeTo;
        cutaverse = _cutaverse;
    }

    function resetFeeTo(address payable _feeTo) external override onlyOwner{
        require(_feeTo != address(0), "_FeeTo is the zero address");
        address oldFeeTo = feeTo;
        feeTo = _feeTo;

        emit ResetFeeTo(oldFeeTo, _feeTo);
    }

    function addSeed(SeedContainer memory seedContainer) public override onlyOwner {
        ISeed _seed = seedContainer.seed;
        bool _onSale = seedContainer.onSale;
        uint256 _price = seedContainer.price;
        uint256 _shopBuyRoundLimit = seedContainer.shopBuyRoundLimit;
        uint256 _userBuyRoundLimit = seedContainer.userBuyRoundLimit;

        require(address(_seed) != address(0), "_seed is the zero address");
        require(!isShopSeed(address(_seed)),"The seed is already there");

        seedContainers.push(SeedContainer({
            seed: ISeed(_seed),
            onSale: _onSale,
            price: _price,
            shopBuyRoundLimit: _shopBuyRoundLimit,
            userBuyRoundLimit: _userBuyRoundLimit
        }));
        seedContainersOfPid[address(_seed)] = seedContainersLength();

        emit AddSeed(address(_seed),_onSale,_price,_shopBuyRoundLimit,_userBuyRoundLimit);
    }

    function resetSeedContainer(SeedContainer memory _seedContainer) external override onlyOwner{
        address seed = address(_seedContainer.seed);
        bool onSale = _seedContainer.onSale;
        uint256 price = _seedContainer.price;
        uint256 shopBuyRoundLimit = _seedContainer.shopBuyRoundLimit;
        uint256 userBuyRoundLimit = _seedContainer.userBuyRoundLimit;

        uint256 pid = seedContainersOfPid[seed];
        require(pid >0, "Not the seed of the shop");

        SeedContainer storage seedContainer = seedContainers[pid-1];
        seedContainer.onSale = onSale;
        seedContainer.price = price;
        seedContainer.shopBuyRoundLimit = shopBuyRoundLimit;
        seedContainer.userBuyRoundLimit = userBuyRoundLimit;

        emit ResetSeedContainer(seed,onSale,price,shopBuyRoundLimit,userBuyRoundLimit);
    }

    function buySeed(address _seed, uint256 _count) public override nonReentrant whenNotPaused{
        uint256 pid = seedContainersOfPid[_seed];
        require(pid > 0, "Not the seed of the shop");

        SeedContainer storage seedContainer = seedContainers[pid-1];
        require(seedContainer.onSale,"Not on sale");

        (bool isSeedShopOverrun, bool isSeedShopOvertime) = isSeedShopOverrun(_seed,_count);
        (bool isSeedUserOverrun, bool isSeedUserOvertime) = isSeedUserOverrun(_seed,_count);
        require(!isSeedShopOverrun && !isSeedUserOverrun,"Exceeding the seed purchase limit");

        Overrun.Limit storage _seedShopBuyLimit = seedShopBuyLimit[_seed];
        if(isSeedShopOvertime){
            _seedShopBuyLimit.times = _count;
            _seedShopBuyLimit.timeline = block.timestamp;
        }else{
            _seedShopBuyLimit.times = _seedShopBuyLimit.times.add(_count);
        }

        Overrun.Limit storage _seedUserBuyLimit = seedUserBuyLimit[_seed][msg.sender];
        if(isSeedUserOvertime){
            _seedUserBuyLimit.times = _count;
            _seedUserBuyLimit.timeline = block.timestamp;
        }else{
            _seedUserBuyLimit.times = _seedUserBuyLimit.times.add(_count);
        }

        ISeed seed = ISeed(_seed);
        uint amount = seedContainer.price.mul(_count.div(10**seed.decimals()));
        cutaverse.transferFrom(msg.sender, feeTo, amount);

        seed.mint(msg.sender, _count);

        emit BuySeed(msg.sender,_seed,_count);
    }

    function buySeed(CutaverseStorage.PermitData memory permitData,CutaverseStorage.Sig memory sig,address _seed, uint256 _count) public override nonReentrant whenNotPaused{
        uint256 pid = seedContainersOfPid[_seed];
        require(pid > 0, "Not the seed of the shop");

        SeedContainer storage seedContainer = seedContainers[pid-1];
        require(seedContainer.onSale,"Not on sale");

        (bool isSeedShopOverrun, bool isSeedShopOvertime) = isSeedShopOverrun(_seed,_count);
        (bool isSeedUserOverrun, bool isSeedUserOvertime) = isSeedUserOverrun(_seed,_count);
        require(!isSeedShopOverrun && !isSeedUserOverrun,"Exceeding the seed purchase limit");

        Overrun.Limit storage _seedShopBuyLimit = seedShopBuyLimit[_seed];
        if(isSeedShopOvertime){
            _seedShopBuyLimit.times = _count;
            _seedShopBuyLimit.timeline = block.timestamp;
        }else{
            _seedShopBuyLimit.times = _seedShopBuyLimit.times.add(_count);
        }

        Overrun.Limit storage _seedUserBuyLimit = seedUserBuyLimit[_seed][msg.sender];
        if(isSeedUserOvertime){
            _seedUserBuyLimit.times = _count;
            _seedUserBuyLimit.timeline = block.timestamp;
        }else{
            _seedUserBuyLimit.times = _seedUserBuyLimit.times.add(_count);
        }

        ISeed seed = ISeed(_seed);
        uint amount = seedContainer.price.mul(_count.div(10**seed.decimals()));

        permitCutaverse(permitData,sig,amount);
        seed.mint(msg.sender, _count);

        emit BuySeed(msg.sender,_seed,_count);
    }

    function permitCutaverse(CutaverseStorage.PermitData memory permitData,CutaverseStorage.Sig memory sig,uint256 amount) internal {
        cutaverse.permit(permitData.owner,permitData.spender,permitData.value,permitData.nonce,permitData.deadline,sig.v,sig.r,sig.s);
        cutaverse.transferFrom(msg.sender, feeTo, amount);
    }

    function seedContainersLength() public view override returns(uint256){
        return seedContainers.length;
    }

    function isShopSeed(address _seed) public view override returns (bool) {
        return seedContainersOfPid[_seed] > 0 ;
    }

//    function isSeedOversold(address _seed, uint256 _count) public view override returns(bool){
//        (bool isSeedShopOverrun,) = isSeedShopOversold(_seed,_count);
//        (bool isSeedUserOverrun,) = isSeedUserOversold(_seed,_count);
//
//        return isSeedShopOverrun || isSeedUserOverrun;
//    }

    function isSeedShopOverrun(address _seed, uint256 _count) public view override returns(bool,bool){
        uint256 pid = seedContainersOfPid[_seed];
        require(pid > 0,"Not the seed of the shop");

        SeedContainer storage seedContainer = seedContainers[pid-1];
        uint256 seedShopBuyRoundLimit = seedContainer.shopBuyRoundLimit;

        Overrun.Limit storage limit = seedShopBuyLimit[_seed];
        return Overrun.isOverrun(limit, _count, 24*60*60, seedShopBuyRoundLimit);
    }

    function isSeedUserOverrun(address _seed, uint256 _count) public view override returns(bool,bool){
        uint256 pid = seedContainersOfPid[_seed];
        require(pid > 0,"Not the seed of the shop");

        SeedContainer storage seedContainer = seedContainers[pid-1];
        uint256 seedUserBuyRoundLimit = seedContainer.userBuyRoundLimit;

        Overrun.Limit storage limit = seedUserBuyLimit[_seed][msg.sender];
        return Overrun.isOverrun(limit, _count, 24*60*60, seedUserBuyRoundLimit);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../storage/ShopStorage.sol";

abstract contract IShop is ShopStorage{

    event ResetFeeTo(address indexed oldFeeTo,address indexed newFeeTo);
    event ResetSeedContainer(address indexed seed, bool onSale,uint256 price,uint256 shopBuyRoundLimit,uint256 userBuyRoundLimit);
    event AddSeed(address indexed seed,bool onSale,uint256 price,uint256 shopBuyRoundLimit,uint256 userBuyRoundLimit);
    event BuySeed(address indexed user,address indexed seed,uint256 amount);

    function resetFeeTo(address payable feeTo) external virtual;
    function resetSeedContainer(SeedContainer memory _seedContainer) external virtual;
    function addSeed(SeedContainer memory seedContainer) external virtual;
    function buySeed(address _seed, uint256 _count) external virtual;
    function buySeed(CutaverseStorage.PermitData memory permitData, CutaverseStorage.Sig memory sig,address _seed, uint256 _count) external virtual;
    function seedContainersLength() external view virtual returns(uint256);
    function isShopSeed(address seed) external view virtual returns (bool);
//    function isSeedOversold(address seed, uint256 count) external view virtual returns(bool);
    function isSeedShopOverrun(address seed, uint256 count) external view virtual returns(bool,bool);
    function isSeedUserOverrun(address seed, uint256 count) external view virtual returns(bool,bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/ICutaverse.sol";
import "../interfaces/ISeed.sol";
import "../interfaces/IShop.sol";
import "../utils/Overrun.sol";

contract FarmStorage {

    struct Land {
        ISeed seed;
        uint256 gain;
        uint256 harvestTime;
    }

    struct PlantAct {
        uint256 pid;
        ISeed seed;
    }

    uint256 public constant initialLandCount = 4;
    uint256 public constant maxLandCount = 16;
    uint256 public constant denominator = 1000;

    uint256 public createFarmPrice = 0.004 ether;
    uint256 public wateringPrice = 0.001 ether;
    uint256 public landBasePrice = 0.002 ether;

    uint256 public wateringShortenFactor = 50;
    uint256 public weedingShortenFactor = 100;
    uint256 public harvestingGainFactor = 100;
    uint256 public landPriceRiseFactor = 300;
    uint256 public landGainRiseFactor = 200;
    uint256 public perLandWateringRoundLimit = 3;

    IShop public shop;
    ICutaverse public cutaverse;
    address public feeTo;
    uint256 public farmerCount;

    mapping(address => uint256) public accountLandCount;
    mapping(address => mapping(uint256 => Land)) public accountPidLand;
    mapping(address => uint256) public accountLevel;

    mapping(address => mapping(uint256 => Overrun.Limit)) public accountWaterLimit;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IFarm.sol";
import "./utils/ExponentMath.sol";
import "./utils/Overrun.sol";
import "./storage/SeedStorage.sol";

contract Farm is IFarm,Ownable,Pausable,ReentrancyGuard{
    using SafeMath for uint256;
    using Overrun for Overrun.Limit;
    using ExponentMath for uint256;

    constructor (address _feeTo,ICutaverse _cutaverse, IShop _shop) {
        require(_feeTo != address(0),"_feeTo is the zero address");
        require(address(_cutaverse) != address(0),"_cutaverse is the zero address");
        require(address(_shop) != address(0),"_shop is the zero address");

        feeTo = _feeTo;
        cutaverse = _cutaverse;
        shop = _shop;
    }

    function resetFeeTo(address payable _feeTo) external onlyOwner{
        require(_feeTo != address(0), "_feeTo is the zero address");
        address oldFeeTo = feeTo;
        feeTo = _feeTo;

        emit ResetFeeTo(oldFeeTo, _feeTo);
    }

    function resetCutaverse(ICutaverse _cutaverse) external onlyOwner{
        require(address(_cutaverse) != address(0), "_cutaverse is the zero address");
        address oldCutaverse = address(cutaverse);
        cutaverse = _cutaverse;

        emit ResetCutaverse(oldCutaverse, address(_cutaverse));
    }

    function resetShop(IShop _shop) external onlyOwner{
        require(address(_shop) != address(0), "_shop is the zero address");
        address oldShop = address(shop);
        shop = _shop;

        emit ResetShop(oldShop, address(_shop));
    }

    function resetCreateFarmPrice(uint256 _createFarmPrice) external onlyOwner{
        uint256 oldCreateFarmPrice = createFarmPrice;
        createFarmPrice = _createFarmPrice;

        emit ResetCreateFarmPrice(oldCreateFarmPrice, _createFarmPrice);
    }

    function resetWeedShortenFactor(uint256 _weedingShortenFactor) external onlyOwner{
        uint256 oldWeedingShortenFactor = weedingShortenFactor;
        weedingShortenFactor = _weedingShortenFactor;

        emit ResetWeedShortenFactor(oldWeedingShortenFactor, _weedingShortenFactor);
    }

    function resetHarvestingGainFactor(uint256 _harvestingGainFactor) external onlyOwner{
        uint256 oldHarvestingGainFactor = harvestingGainFactor;
        harvestingGainFactor = _harvestingGainFactor;

        emit ResetHarvestGainFactor(oldHarvestingGainFactor, _harvestingGainFactor);
    }

    function resetLandBasePrice(uint256 _landBasePrice) external onlyOwner{
        uint256 oldLandBasePrice = landBasePrice;
        landBasePrice = _landBasePrice;

        emit ResetLandBasePrice(oldLandBasePrice, _landBasePrice);
    }

    function resetWateringShortenFactor(uint256 _wateringShortenFactor) external onlyOwner{
        require(_wateringShortenFactor > 0 && _wateringShortenFactor < 5000, "wateringShortenFactor is invalid");

        uint256 oldWateringShortenFactor = wateringShortenFactor;
        wateringShortenFactor = _wateringShortenFactor;

        emit ResetWateringShortenFactor(oldWateringShortenFactor, wateringShortenFactor);
    }

    function resetPerLandWateringRoundLimit(uint256 _perLandWateringRoundLimit) external onlyOwner{
        require(_perLandWateringRoundLimit > 0 && _perLandWateringRoundLimit < 5, "perLandWateringRoundLimit is invalid");

        uint256 oldPerLandWateringRoundLimit = perLandWateringRoundLimit;
        perLandWateringRoundLimit = _perLandWateringRoundLimit;

        emit ResetPerLandWateringRoundLimit(oldPerLandWateringRoundLimit, perLandWateringRoundLimit);
    }

    function createFarm() public payable nonReentrant whenNotPaused{
        require(accountLandCount[msg.sender] == 0,"You already own a farm");
        require(msg.value >= createFarmPrice, "The ether value sent is not correct");

        payable(feeTo).transfer(msg.value);

        uint256 ownedCount = accountLandCount[msg.sender];
        increasingLand(initialLandCount);
        uint256 toHaveCount = accountLandCount[msg.sender];

        farmerCount = farmerCount.add(1);
        accountLevel[msg.sender] = 1;

        emit IncreasingLand(msg.sender,ownedCount,toHaveCount);
    }

    function planting(PlantAct[] memory plantAct) public nonReentrant whenNotPaused{
        uint256 len = plantAct.length;
        require(len > 0 && len <= accountLandCount[msg.sender], "farmer or land is invalid");

        for(uint i =0 ;i < len;i++){
            PlantAct memory act = plantAct[i];
            _planting(act);
        }
    }


    function planting(PlantAct[] memory plantAct,SeedStorage.SeedPermitData[] memory permitData,SeedStorage.SeedSig[] memory sig) public nonReentrant whenNotPaused{
        uint256 len = plantAct.length;
        require(len > 0 && len <= accountLandCount[msg.sender], "farmer or land is invalid");

        for(uint i =0 ;i < len;i++){
            PlantAct memory act = plantAct[i];
            _planting(act,permitData[i],sig[i]);
        }
    }

    function _planting(PlantAct memory plantAct) internal{
        uint256 pid = plantAct.pid;
        ISeed seed = plantAct.seed;

        require(pid > 0 && pid <= accountLandCount[msg.sender],"An invalid pid");
        require(shop.isShopSeed(address(seed)),"An invalid seed");

        Land storage land = accountPidLand[msg.sender][pid];
        require(address(land.seed) == address(0),"The land is already planted");

        land.seed = seed;
        land.harvestTime = seed.matureTime().add(block.timestamp);
        land.gain = calculateLanGain(pid);

        seed.burnFrom(msg.sender,1*10**seed.decimals());

        emit Planting(msg.sender,address(seed),pid);
    }


    function _planting(PlantAct memory plantAct,SeedStorage.SeedPermitData memory permitData,SeedStorage.SeedSig memory sig) internal{
        uint256 pid = plantAct.pid;
        ISeed seed = plantAct.seed;

        require(pid > 0 && pid <= accountLandCount[msg.sender],"An invalid pid");
        require(shop.isShopSeed(address(seed)),"An invalid seed");

        Land storage land = accountPidLand[msg.sender][pid];
        require(address(land.seed) == address(0),"The land is already planted");

        land.seed = seed;
        land.harvestTime = seed.matureTime().add(block.timestamp);
        land.gain = calculateLanGain(pid);

        seed.permit(permitData.owner,permitData.spender,permitData.value,permitData.nonce,permitData.deadline,sig.v,sig.r,sig.s);
        seed.burnFrom(msg.sender,1*10**seed.decimals());

        emit Planting(msg.sender,address(seed),pid);
    }

    function watering(address farmer, uint256[] calldata pids) public payable nonReentrant whenNotPaused{
        uint256 len = pids.length;
        require(len > 0 && len <= accountLandCount[farmer], "The lands count sent is not correct");
        require(msg.value >= wateringPrice.mul(len), "The ether value sent is not correct");

        uint256 successTimes = 0;
        for(uint i =0 ;i < len;i++){
            uint pid = pids[i];
            Land storage land = accountPidLand[farmer][pid];
            if(address(land.seed) == address(0)){
                continue;
            }

            if(land.harvestTime < block.timestamp){
                continue;
            }

            (bool isOverrun,bool isOvertime) = isWateringOverrun(farmer,pid);
            if(isOverrun){
                continue;
            }

            Overrun.Limit storage waterLimit = accountWaterLimit[farmer][pid];
            if(isOvertime){
                waterLimit.times = 1;
                waterLimit.timeline = block.timestamp;
            }else{
                waterLimit.times += 1;
            }

            uint256 surplusTime= land.harvestTime.sub(block.timestamp);
            surplusTime = ExponentMath.exponentDecrease(surplusTime,wateringShortenFactor,denominator,1);
            land.harvestTime = block.timestamp.add(surplusTime);
            successTimes += 1;

            emit Watering(msg.sender, farmer, address(land.seed), pid);
        }

        //TODO 待测试，未成功的是否留在合约
        payable(feeTo).transfer(wateringPrice.mul(successTimes));
    }

    function isWateringOverrun(address _user, uint256 _pid) public view returns(bool,bool){
        Overrun.Limit storage limit = accountWaterLimit[_user][_pid];
        return Overrun.isOverrun(limit, 1, 24*60*60, perLandWateringRoundLimit);
    }

    function harvesting(address farmer) public nonReentrant{
        uint len = accountLandCount[farmer];
        require(len >0 ,"The farmer does not yet own the land");

        for(uint i = 1;i <= len; i++){
            _harvesting(farmer,i);
        }
    }

    function harvesting(address farmer, uint256 pid) public nonReentrant{
        uint len = accountLandCount[farmer];
        require(len >0 ,"The farmer does not yet own the land");

        _harvesting(farmer,pid);
    }

    function _harvesting(address farmer, uint256 pid) internal{
        require(pid > 0 && pid <= accountLandCount[farmer],"An invalid pid");

        Land storage land = accountPidLand[farmer][pid];
        if(address(land.seed) == address(0)){
            return;
        }

        if(block.timestamp < land.harvestTime){
            return;
        }

        if(msg.sender != farmer && block.timestamp < land.harvestTime.add(24*60*60)){
            return;
        }

        uint256 reaperGain = 0;
        uint256 farmerGain = land.gain;

        if(msg.sender != farmer){
            reaperGain = farmerGain.mul(harvestingGainFactor).div(denominator);
            farmerGain = farmerGain.sub(reaperGain);
        }

        if(reaperGain >0){
            cutaverse.mint(msg.sender,reaperGain);
            emit Harvesting(msg.sender, farmer, address(land.seed), pid, reaperGain);
        }

        if(farmerGain >0){
            cutaverse.mint(farmer,farmerGain);
            emit Harvesting(msg.sender, farmer, address(land.seed), pid, farmerGain);
        }

        land.seed = ISeed(address(0));
        land.gain = 0;
        land.harvestTime = 0;
    }

    function buyLand(uint256 _count) public payable{
        require(accountLevel[msg.sender] > 1,"No land upgrades are allowed");

        uint256 ownedCount = accountLandCount[msg.sender];
        uint256 toHaveCount = ownedCount.add(_count);

        uint256 cost = calculateBuyLandCost(_count);
        require(msg.value >= cost, "The ether value sent is not correct");

        payable(feeTo).transfer(msg.value);

        increasingLand(_count);

        emit IncreasingLand(msg.sender,ownedCount,toHaveCount);
    }

    function increasingLand(uint256 _count) internal{
        Land memory empty = Land({
            seed: ISeed(address(0)),
            gain: 0,
            harvestTime: 0
            });

        uint256 ownedCount = accountLandCount[msg.sender];
        uint256 toHaveCount = ownedCount.add(_count);

        for (uint j= ownedCount.add(1); j <= toHaveCount; j ++) {
            accountPidLand[msg.sender][j] = empty;
        }

        accountLandCount[msg.sender] = toHaveCount;
    }

    function calculateLanGain(uint256 _pid) public view returns(uint256){
        require(_pid > 0 && _pid <= accountLandCount[msg.sender],"An invalid pid");

        Land storage land = accountPidLand[msg.sender][_pid];
        uint256 yield = land.seed.yield();

        if(_pid <= initialLandCount){
            return yield;
        }

        uint256 exponent = _pid.sub(initialLandCount);
        return ExponentMath.exponentIncrease(yield,landGainRiseFactor,denominator,exponent);
    }

    function calculateBuyLandCost(uint256 _count) public view returns(uint256){
        require(_count > 0,"An invalid _count");

        uint256 ownedCount = accountLandCount[msg.sender];
        require(ownedCount >= initialLandCount,"Please create the farm first");

        uint256 toHaveCount = ownedCount.add(_count);
        uint256 curLeveMaxLandCount = calculateCurLeveMaxLandCount();
        require(toHaveCount <= curLeveMaxLandCount,"More than the current land class allows");
        require(toHaveCount <= maxLandCount,"The maximum amount of land cannot be exceeded");

        uint256 totalCost = 0;
        for(uint256 i = toHaveCount; i > ownedCount; i--){
            uint256 exponent = i.sub(initialLandCount);
            uint256 curCost = ExponentMath.exponentIncrease(landBasePrice,landPriceRiseFactor,denominator,exponent);
            totalCost = totalCost.add(curCost);
        }

        return totalCost;
    }

    function calculateCurLeveMaxLandCount() public view returns(uint256){
        uint256 level = accountLevel[msg.sender];
        return level.mul(initialLandCount);
    }

    //    function weeding(Land[] memory land) public{
    //        //需要质押 hoe（直到成熟解开质押）
    //        for(uint i =0 ;i < lands.length;i++){
    //            Land _land = lands[i];
    //            uint index = _land.index;
    //
    //            Land storage land = accountPidLand[msg.sender][index];
    //            require(land.seed == address(0) && land.harvestTime.add(1-wateringRate) < block.timestamp,"");
    //            land.harvestTime = land.harvestTime.add(1-wateringRate);
    //        }
    //    }

    //    function steal(address account, Land land) public{
    //        //需要花费 x eth (每块土地每天只能偷盗3次)
    //        //30% 偷盗者胜，成功 x*20% 给到管理员，x*80% 返还，收成归偷盗者
    //        //10% 双方都失败，x 都给到管理员，收成无
    //        //60% 农场主胜, x*20% 给到管理员，x*80% 给到农民
    //    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../storage/FarmStorage.sol";

abstract contract IFarm is FarmStorage{

    event ResetFeeTo(address indexed oldFeeTo, address indexed newFeeTo);
    event ResetCutaverse(address indexed oldCutaverse, address indexed newCutaverse);
    event ResetShop(address indexed oldShop, address indexed newShop);
    event ResetCreateFarmPrice(uint256 oldCreateFarmPrice, uint256 newCreateFarmPrice);
    event ResetWeedShortenFactor(uint256 oldWeedShortenFactor, uint256 newWeedShortenFactor);
    event ResetHarvestGainFactor(uint256 oldHarvestGainFactor, uint256 newHarvestGainFactor);
    event ResetLandBasePrice(uint256 oldLandBasePrice, uint256 newLandBasePrice);
    event ResetWateringShortenFactor(uint256 oldWateringShortenFactor, uint256 newWateringShortenFactor);
    event ResetPerLandWateringRoundLimit(uint256 oldPerLandWateringRoundLimit, uint256 newPerLandWateringRoundLimit);

    event IncreasingLand(address indexed farmer,uint256 ownedCount,uint256 toHaveCount);
    event Planting(address indexed farmer,address indexed seed,uint256 pid);
    event Watering(address indexed operator,address indexed farmer,address indexed seed,uint256 pid);
    event Harvesting(address indexed operator,address indexed farmer,address indexed seed,uint256 pid, uint256 gain);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library ExponentMath {

    using SafeMath for uint256;

    function exponentIncrease(uint256 base, uint256 numerator, uint256 denominator, uint exponent) internal pure returns(uint256){
        require(denominator > 0 && numerator <= denominator,"Illegal numerator and denominator");
        require(exponent > 0,"Exponent is greater than zero");

        uint256 a = numerator.add(denominator);
        uint256 b = a**exponent;

        return base.mul(b).div(denominator**exponent);
    }

    function exponentDecrease(uint256 base, uint256 numerator, uint256 denominator, uint exponent) internal pure returns(uint256){
        require(denominator > 0 && numerator <= denominator,"Illegal numerator and denominator");
        require(exponent > 0,"Exponent is greater than zero");

        uint256 a = SafeMath.sub(denominator,numerator);
        uint256 b = a**exponent;

        return base.mul(b).div(denominator**exponent);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Farm.sol";
import "./Shop.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CutaverseLens {

    struct FarmBasicMetadata{
        bool paused;
        uint256 farmerCount;
    }

    function getFarmBasicInfo(Farm farm) public view returns(FarmBasicMetadata memory){
        return FarmBasicMetadata({
            paused: farm.paused(),
            farmerCount: farm.farmerCount()
        });
    }

    struct FarmerMetadata{
        LandMetadata[] landInfos;
        uint256 landCount;
        uint256 blockTime;
    }

    struct LandMetadata{
        uint256 pid;
        uint256 gain;
        uint256 harvestTime;
        ISeed seed;
    }

    function getFarmerInfo(Farm farm, address farmer) public view returns(FarmerMetadata memory){
        uint256 _landCount = farm.accountLandCount(farmer);
        LandMetadata[] memory _landInfos = new LandMetadata[](_landCount);

        for(uint i=0; i<_landCount;i++){
            uint pid = i+1;
            (ISeed _seed,uint256 _gain, uint256 _harvestTime) = farm.accountPidLand(farmer,pid);
            LandMetadata memory landInfo = LandMetadata(pid,_gain,_harvestTime,_seed);
            _landInfos[i] = landInfo;
        }

        return FarmerMetadata({
            landInfos: _landInfos,
            landCount: _landCount,
            blockTime: block.timestamp
        });
    }

    struct FarmerPackageMetadata{
        SeedBalanceMetadata[] seedBalances;
    }

    struct SeedBalanceMetadata{
        address seed;
        uint256 balance;
    }

    function getFarmerPackage(address farmer,Shop shop) public view returns(FarmerPackageMetadata memory){
        uint256 _seedCount = shop.seedContainersLength();
        SeedBalanceMetadata[] memory _seedBalances = new SeedBalanceMetadata[](_seedCount);

        for(uint i=0; i<_seedCount;i++){
            (ISeed _seed,bool _onSale,uint256 _price,uint256 _shopBuyRoundLimit, uint256 _userBuyRoundLimit) = shop.seedContainers(i);
            uint256 balance = IERC20(address(_seed)).balanceOf(farmer);
            SeedBalanceMetadata memory seedBalance = SeedBalanceMetadata(address(_seed),balance);
            _seedBalances[i] = seedBalance;
        }

        return FarmerPackageMetadata({
            seedBalances: _seedBalances
        });
    }

    struct ShopBasicMetadata{
        bool paused;
        uint256 seedCount;
    }

    function getShopBasicInfo(Shop shop) public view returns(ShopBasicMetadata memory){
        return ShopBasicMetadata({
            paused: shop.paused(),
            seedCount: shop.seedContainersLength()
        });
    }

    struct ShopSeedMetadata{
        SeedMetadata[] seeds;
        uint256 seedCount;
    }

    struct SeedMetadata{
        ISeed seed;
        bool onSale;
        uint256 price;
    }

    function getShopSeedsInfo(Shop shop) public view returns(ShopSeedMetadata memory){
        uint256 _seedCount = shop.seedContainersLength();
        SeedMetadata[] memory _seeds = new SeedMetadata[](_seedCount);

        for(uint i=0; i<_seedCount;i++){
            (ISeed _seed,bool _onSale,uint256 _price,,) = shop.seedContainers(i);
            SeedMetadata memory shopSeed = SeedMetadata(_seed,_onSale,_price);
            _seeds[i] = shopSeed;
        }

        return ShopSeedMetadata({
            seeds: _seeds,
            seedCount: _seedCount
        });
    }

    struct SeedBuyDetailMetadata{
        uint256 yield;
        uint256 matureTime;
        uint256 price;
        uint256 shopTimeline;
        uint256 shopSold;
        uint256 shopBuyRoundLimit;
        uint256 userTimeline;
        uint256 userPurchased;
        uint256 userBuyRoundLimit;
    }

    function getSeedBuyDetailInfo(Shop shop, ISeed seed, address user) public view returns(SeedBuyDetailMetadata memory){
        uint256 _yield = seed.yield();
        uint256 _matureTime = seed.matureTime();
        (uint256 _shopTimeline, uint256 _shopSold) = shop.seedShopBuyLimit(address(seed));
        (uint256 _userTimeline, uint256 _userPurchased) = shop.seedUserBuyLimit(address(seed),user);

        uint256 pid = shop.seedContainersOfPid(address(seed));
        (,,uint256 _price,uint256 _shopBuyRoundLimit, uint256 _userBuyRoundLimit) = shop.seedContainers(pid-1);

        return SeedBuyDetailMetadata({
            yield: _yield,
            matureTime: _matureTime,
            price: _price,
            shopTimeline: _shopTimeline,
            shopSold: _shopSold,
            shopBuyRoundLimit: _shopBuyRoundLimit,
            userTimeline: _userTimeline,
            userPurchased: _userPurchased,
            userBuyRoundLimit: _userBuyRoundLimit
        });
    }

    struct WateringLimitInfoMetadata{
        WateringLimitMetadata[] wateringLimits;
        uint256 wateringRoundLimit;
    }

    struct WateringLimitMetadata{
        bool isOverrun;
        uint pid;
        uint256 watered;
    }

    function getWateringLimitInfo(Farm farm, address farmer, uint256[] calldata pids) public view returns(WateringLimitInfoMetadata memory){
        uint256 _wateringRoundLimit = farm.perLandWateringRoundLimit();
        WateringLimitMetadata[] memory _wateringLimits = new WateringLimitMetadata[](pids.length);

        for(uint256 i=0; i<pids.length; i++){
            uint256 _pid = pids[i];
            (bool _isOverrun,) = farm.isWateringOverrun(farmer, _pid);
            (,uint256 _watered) = farm.accountWaterLimit(farmer,_pid);
            WateringLimitMetadata memory wateringLimit = WateringLimitMetadata(_isOverrun,_pid,_watered);
            _wateringLimits[i] = wateringLimit;
        }

        return WateringLimitInfoMetadata({
            wateringLimits: _wateringLimits,
            wateringRoundLimit: _wateringRoundLimit
        });
    }
}