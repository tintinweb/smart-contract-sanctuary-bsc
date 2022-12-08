// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProofUpgradeable {
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
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

contract KyotoLaunchpad is OwnableUpgradeable {
    struct IDO {
        uint256 tokenPrice; // Token price in BNB
        uint256 tokensForDistribution; // Number of tokens to be distributed
        uint256 whitelistOpenTimestamp; // Timestamp at which the whitelist is open
        uint256 winnersOutTimestamp; // Timestamp at which the winners are out
        uint256 publicInvestmentStartTimestamp; // Timestamp at which the public investment starts
        uint256 idoCloseTimestamp; // Timestamp at which the IDO is closed
        uint256 publicSlots; // Number of users that can invest
        uint256 targetAmount; //Funds targeted to be raised for the project
        uint256 minimumInvestment; //Minimum amount of BNB users must invest
        address idoOwner; // Address of the IDO owner
        address tokenAddress; // Address of the token contract
        bool isRewarded; // Whether the IDO tokens have been rewarded ot the investors
    }

    struct IDOInvestment {
        address[] investors; // Array of investors
        uint256 totalInvestment; // Total investment in BNB
        uint256 publicInvestors; // Number of investors
        uint256 publicTierTotalInvestment; // Total amount of investment made by investors
    }

    // Owner of the contract
    address private _owner;
    // Address of the potential owner
    address private _potentialOwner;
    // Percentage of Funds raised to be paid as fee
    uint public feePercentage;

    // IDO ID => IDO
    mapping(string => IDO) private _idos;
    // IDO ID => Its Merkle Root
    mapping(string => bytes32) private _idoMerkleRoots;
    // IDO ID => IDO Investment
    mapping(string => IDOInvestment) private _idoInvestments;
    // IDO ID => User's address => Total investment amount
    mapping(string => mapping(address => uint256))
        private _idoInvestorInvestments;

    event OwnerChanged(address newOwner);
    event NominateOwner(address potentialOwner);
    event IDORewarded(string idoID, address tokenAddress, bool isRewarded);
    event SetMerkleRoot(string idoId, bytes32 merkleRoot);
    event Invest(string idoID, address investor, uint256 investment);
    event IDOAdded(string indexed idoID, address idoOwner, address idoToken);
    event IDOCancelled(string idoID);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {}
    function initialize() 
        public
        initializer
    {
        __Ownable_init();
    }

    receive() external payable {}

    fallback() external {}

    /* Admin Methods Start */

    /**
     * @notice This method is used to set commission percentage for the smart contract
     * @param _feePercentage Percentage from raised funds to be set as fee
     */
    function setFee(uint _feePercentage) 
        external 
        onlyOwner{
        require(
            _feePercentage > 0,
            "KyotoLaunchPad : Smart Contract Fee cannot be zero"
        );
        feePercentage = _feePercentage;
    }

    /**
     * @notice This method is used to nominate a new contract owner
     * @param potentialOwner Address of the New Owner to be nominated
     */
    function addPotentialOwner(address potentialOwner) 
        external
        onlyOwner{
        require(
            potentialOwner != address(0),
            "KyotoLaunchPad: Potential Owner should non-zero!"
        );
        require(
            potentialOwner != _owner,
            "KyotoLaunchPad: Potential Owner should not be owner!"
        );
        _potentialOwner = potentialOwner;
        emit NominateOwner(potentialOwner);
    }

    /**
     * @notice This method is used to add a new IDO project
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO to be added
     * @param ido IDO details
     */
    function addIDO(string calldata idoID, IDO calldata ido) 
        external 
        onlyOwner{
        require(
            _idos[idoID].tokenAddress == address(0),
            "KyotoLaunchPad: IDO already exists!"
        );
        _validateIDOData(ido);

        _idos[idoID] = ido;

        require(
            IERC20Upgradeable(ido.tokenAddress).transferFrom(
            ido.idoOwner,
            address(this),
            ido.tokensForDistribution
                ),
            "KyotoLaunchpad: Failed to transfer project tokens to the Launchpad"
            );
        emit IDOAdded(idoID, ido.idoOwner, ido.tokenAddress);
    }

    /**
     * @notice This method is used to get the investment amount of a project
     * @param idoID ID of the IDO
     */
    function getInvestmentAmount(string calldata idoID) 
        internal 
        onlyOwner{

        uint amountToTransfer = _idoInvestments[idoID].totalInvestment;

        uint amountForContract = (amountToTransfer * feePercentage * 10000) / 1000000;
        uint amountForProjectOwner = amountToTransfer - amountForContract;

        _idoInvestments[idoID].totalInvestment = 0;

        payable(_idos[idoID].idoOwner).transfer(amountForProjectOwner);
        payable(_owner).transfer(amountForContract);
    }

    /**
     * @notice This method is used to set Merkle Root of an IDO
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     * @param merkleRoot Merkle Root of the IDO
     */
    function addMerkleRoot(string calldata idoID, bytes32 merkleRoot) 
        external 
        onlyOwner{
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        // _checkThatIDOIndNotRewarded(idoID);
        require(
            _idoMerkleRoots[idoID] == bytes32(0),
            "KyotoLaunchPad: Merkle Root already exists"
        );
        _idoMerkleRoots[idoID] = merkleRoot;
        emit SetMerkleRoot(idoID, merkleRoot);
    }

    /**
     * @notice This method is used to distribute tokens to investors once the project is closed
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     */
    function distributeTokens(string calldata idoID) 
        external 
        onlyOwner{
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        require(
            _idos[idoID].idoCloseTimestamp <= block.timestamp,
            "KyotoLaunchPad: Close time for IDO not reached yet"
        );
        IDO memory ido = _idos[idoID];
        IDOInvestment memory idoInvestment = _idoInvestments[idoID];
        uint tokenPrice = _idos[idoID].tokenPrice;
        uint totalTokensToDistribute = ido.tokensForDistribution;
        require(
            idoInvestment.investors.length != 0,
            "KyotoLaunchPad: No investments found"
        );

        for (
            uint investorIndex = 0;
            investorIndex < idoInvestment.investors.length;
            investorIndex++
        ) {
            uint tokensToTransfer = (
                _idoInvestorInvestments[idoID][idoInvestment.investors[investorIndex]] * 10000 ) 
                / (tokenPrice * 10000);

            tokensToTransfer *= 10**IERC20MetadataUpgradeable(ido.tokenAddress).decimals();

            totalTokensToDistribute -= tokensToTransfer;
            require(
                IERC20Upgradeable(ido.tokenAddress).transfer(
                    idoInvestment.investors[investorIndex],
                    tokensToTransfer
                    ),
                    "KyotoLaunchpad: Failed to transfer project tokens to Investor"
                );
        }

        if (totalTokensToDistribute > 0) {
            require(
                IERC20Upgradeable(ido.tokenAddress).transfer(
                        ido.idoOwner,
                        totalTokensToDistribute
                    ),
                    "KyotoLaunchpad: Failed to transfer remaining project tokens to Project Owner"
                );
        }
        getInvestmentAmount(idoID);

        _idos[idoID].isRewarded = true;

        emit IDORewarded(idoID, ido.tokenAddress, true);
    }

    /**
     * @notice This method is used to cancel a project and refund the investments to the investors
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     */
    function cancelAndRefundIDO(string calldata idoID) 
        external
        onlyOwner{
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        require(
            _idos[idoID].isRewarded == false,
            "KyotoLaunchPad: IDO has already been rewarded"
        );
        IDO memory _ido = _idos[idoID];
        uint _totalTokensToDistribute = _ido.tokensForDistribution;
        IDOInvestment memory _idoInvestment = _idoInvestments[idoID];

        if(_idoInvestment.investors.length == 0){
            //If there are no investments
            require(
                IERC20Upgradeable(_ido.tokenAddress).transfer(
                        _ido.idoOwner,
                        _totalTokensToDistribute
                    ),
                    "KyotoLaunchpad: Failed to transfer project tokens to Project Owner"
                );
        }
        else{
            for (
                uint investorIndex = 0;
                investorIndex < _idoInvestment.investors.length;
                investorIndex++
            ) {
                uint investmentToTransfer = _idoInvestorInvestments[idoID][_idoInvestment.investors[investorIndex]];

                payable(_idoInvestment.investors[investorIndex]).transfer(investmentToTransfer);
            }
            require(
                IERC20Upgradeable(_ido.tokenAddress).transfer(
                    _ido.idoOwner,
                    _totalTokensToDistribute
                        ),
                    "KyotoLaunchpad: Failed to refund project tokens to Project Owner"    
                );
        }    
        _idos[idoID].isRewarded = true;    
        emit IDOCancelled(idoID);
    }

    /* Admin Methods End */

    /* Potential Owner Methods Start */

    /**
     * @notice This method is used to accept the nomination of a new contract owner
     * @dev This method is called by the nominated contract owner
     */
    function acceptOwnership() external {
        require(
            _potentialOwner == msg.sender,
            "KyotoLaunchPad: Only the potential owner can accept ownership!"
        );
        _owner = _potentialOwner;
        _potentialOwner = address(0);
        emit OwnerChanged(_owner);
    }

    /* Potential Owner Methods End */

    /* User Methods Start */

    /**
     * @notice This method is used to invest in an IDO as a whitelisted user
     * @dev User must send _amount in order to invest
     * @dev User must be whitelisted to invest -- It'll be verified by the MerkleRoot
     * @param idoID ID of the IDO
     * @param merkleProof Merkle Proof of the user for that IDO
     */
    function investInWhitelistPhase(
        string calldata idoID,
        bytes32[] calldata merkleProof,
        uint256 _amount
    ) external payable {
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        require(
            _amount >= _idos[idoID].minimumInvestment,
            "KyotoLaunchpad: Investment amount is less than minimum"
        );
        require(
            _amount > 0,
            "KyotoLaunchPad: Investment amount should be greater than 0"
        );
        require(
            _idos[idoID].winnersOutTimestamp <= block.timestamp,
            "KyotoLaunchPad: Whitelist phase has not started"
        );
        require(
            _idos[idoID].idoCloseTimestamp > block.timestamp,
            "KyotoLaunchPad: Whitelist phase has ended"
        );
        require(
            _isWhitelisted(_idoMerkleRoots[idoID], merkleProof),
            "KyotoLaunchPad: User is not whitelisted"
        );
        _invest(idoID,_amount);
    }

    /* User Methods End */

    /* Private Helper Methods Start */

    /**
     * @dev This helper method is used to validate the IDO's data
     * @param ido IDO to be validated
     */
    function _validateIDOData(IDO calldata ido) private view {
        require(
            ido.tokenAddress != address(0),
            "KyotoLaunchPad: Token address cannot be 0"
        );
        require(
            IERC20Upgradeable(ido.tokenAddress).totalSupply() >= ido.tokensForDistribution,
            "KyotoLaunchPad: Token supply is less than the tokens to be distributed"
        );
        require(
            ido.idoOwner != address(0),
            "KyotoLaunchPad: IDO owner cannot be 0"
        );
        require(ido.tokenPrice != 0, "KyotoLaunchPad: Token price cannot be 0");
        require(
            ido.tokensForDistribution != 0,
            "KyotoLaunchPad: Tokens for distribution cannot be 0"
        );
        require(
            ido.whitelistOpenTimestamp != 0,
            "KyotoLaunchPad: Whitelist open timestamp cannot be 0"
        );
        require(
            ido.whitelistOpenTimestamp >= block.timestamp,
            "KyotoLaunchPad: Whitelist open timestamp cannot be in the past"
        );
        require(
            ido.whitelistOpenTimestamp < ido.winnersOutTimestamp,
            "KyotoLaunchPad: Whitelist open timestamp cannot be greater than winners out timestamp"
        );
        require(
            ido.winnersOutTimestamp <= ido.publicInvestmentStartTimestamp,
            "KyotoLaunchPad: Winners out timestamp cannot be greater than public investment start timestamp"
        );
        require(
            ido.publicInvestmentStartTimestamp < ido.idoCloseTimestamp,
            "KyotoLaunchPad: Public investment start timestamp cannot be greater than IDO close timestamp"
        );
        require(
            ido.publicSlots > 0,
            "KyotoLaunchPad: Number of slots cannot be zero"
        );
        require(
            ido.targetAmount > 0,
            "KyotoLaunchPad: Target amount cannot be zero"
        );
        require(
            ido.minimumInvestment > 0,
            "KyotoLaunchPad: Minimum investment cannot be zero"
        );
        require(
            (ido.targetAmount / ido.tokenPrice) <= ido.tokensForDistribution,
            "KyotoLaunchpad: Number of tokens for distribution would not suffice"
        );
        require(ido.isRewarded == false, "KyotoLaunchPad: IDO cannot be rewarded");
    }

    /**
     * @dev This helper method is used to validate the user whether the address is a whitelisted address or not
     * @param merkleRoot Merkle Root of the IDO
     * @param merkleProof Merkle Proof of the user for that IDO
     */
    function _isWhitelisted(bytes32 merkleRoot, bytes32[] calldata merkleProof)
        private
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProofUpgradeable.verify(merkleProof, merkleRoot, leaf);
    }

    /**
     * @dev This helper method is used to Invest in the IDO
     * @param idoID ID of the IDO to invest in
     */
    function _invest(string calldata idoID, uint256 _amount) private {
        require(
            _amount >= _idos[idoID].tokenPrice,
            "KyotoLaunchPad: Cannont invest less than the token price"
        );

        IDOInvestment memory idoInvestment = _idoInvestments[idoID];

        require(
                _idos[idoID].targetAmount >=
                    idoInvestment.publicTierTotalInvestment + _amount,
                "KyotoLaunchPad: Investment amount would exceed target"
            );

                address[] memory idoInvestors = new address[](
                    idoInvestment.investors.length + 1
                );

                for (
                    uint index = 0;
                    index < idoInvestment.investors.length;
                    index++
                ) {
                    idoInvestors[index] = idoInvestment.investors[index];
                }

                idoInvestors[idoInvestment.investors.length] = msg.sender;

                idoInvestment.investors = idoInvestors;

                require(
                    _idos[idoID].publicSlots > idoInvestment.publicInvestors,
                    "KyotoLaunchPad: Public slots are full"
                );
                idoInvestment.publicInvestors++;

        
            idoInvestment.publicTierTotalInvestment += _amount;

            idoInvestment.totalInvestment += _amount;

            _idoInvestments[idoID] = idoInvestment;

            _idoInvestorInvestments[idoID][msg.sender] += _amount;  

        emit Invest(idoID, msg.sender, _amount);
    }

    /**
     * @dev This helper method is used to Validate that the IDO with given ID is not already rewarded
     * @param idoID ID of the IDO to check
     */
    function _checkThatIDOIndNotRewarded(string calldata idoID) private view {
        require(
            _idos[idoID].isRewarded == false,
            "KyotoLaunchPad: IDO has already been rewarded"
        );
    }

    /* Private Helper Methods End */
}