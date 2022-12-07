// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/access/IAccessControlEnumerableUpgradeable.sol";

import "oz-custom/contracts/internal-upgradeable/interfaces/IBlacklistableUpgradeable.sol";

interface IAuthority is
    IBlacklistableUpgradeable,
    IAccessControlEnumerableUpgradeable
{
    event ProxyAccessGranted(address indexed proxy);

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;

    function pause() external;

    function unpause() external;

    function paused() external view returns (bool isPaused);

    function requestAccess(bytes32 role) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/interfaces/IWithdrawableUpgradeable.sol";

interface ITreasury {
    error Treasury__Expired();
    error Treasury__LengthMismatch();
    error Treasury__InvalidSignature();

    event PaymentsUpdated(address[] indexed tokens);
    event PricesUpdated(address[] indexed tokens, uint256[] indexed prices);
    event PriceUpdated(
        IERC20Upgradeable indexed token,
        uint256 indexed from,
        uint256 indexed to
    );
    event PaymentRemoved(address indexed token);
    event PaymentsRemoved();

    function supportedPayment(address token_) external view returns (bool);

    function priceOf(address token_) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IVerifier {
    function verifyProof(
        bytes memory proof,
        uint256[] memory pubSignals
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IVerifier.sol";
import "./ITreasury.sol";

interface IZKBridge {
    error ZKBridge__InvalidProof();
    error ZKBridge__LengthMismatch();
    error ZKBridge__NonZeroAddress();
    error ZKBridge__UnknownRoot(uint256);
    error ZKBridge__AlreadySpent(uint256);
    error ZKBridge__UsedCommitment(uint256);
    error ZKBridge__WrappedTokenNotSupported(address);

    struct Input {
        uint256 root;
        uint256 value;
        address token;
        uint256 nullifierHash;
        address relayer;
        address recipient;
    }

    event NewBridgeState(uint256 indexed stateRoot);

    event VerifierUpdated(
        IVerifier indexed currentAddr,
        IVerifier indexed newAddr
    );

    event Deposited(
        address indexed token,
        address indexed account,
        uint256 indexed value,
        uint256 root,
        uint256 leafIdx,
        uint256 commitment
    );

    event Withdrawn(
        address indexed token,
        address indexed to,
        uint256 indexed value,
        uint256 nullifierHash,
        address relayer,
        uint256 fee
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../interfaces/IAuthority.sol";

import "../libraries/Roles.sol";

error Base__Paused();
error Base__NotPaused();
error Base__AlreadySet();
error Base__Blacklisted();
error Base__Unauthorized();

abstract contract Base {
    bytes32 private _authority;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    modifier onlyWhitelisted() {
        _checkBlacklist(msg.sender);
        _;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    event AuthorityUpdated(IAuthority indexed from, IAuthority indexed to);

    constructor(IAuthority authority_, bytes32 role_) payable {
        authority_.requestAccess(role_);
        __updateAuthority(authority_);
    }

    function updateAuthority(
        IAuthority authority_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        IAuthority old = authority();
        if (old == authority_) revert Base__AlreadySet();
        __updateAuthority(authority_);
        emit AuthorityUpdated(old, authority_);
    }

    function authority() public view returns (IAuthority authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(_authority.slot)
        }
    }

    function _checkBlacklist(address account_) internal view {
        if (authority().isBlacklisted(account_)) revert Base__Blacklisted();
    }

    function _checkRole(bytes32 role_, address account_) internal view {
        if (!authority().hasRole(role_, account_)) revert Base__Unauthorized();
    }

    function __updateAuthority(IAuthority authority_) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_authority.slot, authority_)
        }
    }

    function _requirePaused() internal view {
        if (!authority().paused()) revert Base__NotPaused();
    }

    function _requireNotPaused() internal view {
        if (authority().paused()) revert Base__Paused();
    }

    function _hasRole(
        bytes32 role_,
        address account_
    ) internal view returns (bool) {
        return authority().hasRole(role_, account_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz/utils/structs/BitMaps.sol";

library PoseidonT3 {
    function poseidon(uint256[2] memory) public pure returns (uint256) {}
}

// Each incremental tree has certain properties and data that will
// be used to add new leaves.
struct IncrementalTreeData {
    uint256 depth; // Depth of the tree (levels - 1).
    uint256 root; // Root hash of the tree.
    uint256 numberOfLeaves; // Number of leaves of the tree.
    BitMaps.BitMap knownRoots;
    mapping(uint256 => uint256) zeroes; // Zero hashes used for empty nodes (level -> zero hash).
    // The nodes of the subtrees used in the last addition of a leaf (level -> [left node, right node]).
    mapping(uint256 => uint256[2]) lastSubtrees; // Caching these values is essential to efficient appends.
}

error IncrementalMerkleTree__OutOfField();
error IncrementalMerkleTree__OutOfDepth();
error IncrementalMerkleTree__OutOfRange();
error IncrementalMerkleTree__LengthMismatch();
error IncrementalMerkleTree__AllocationExceeded();

/// @title Incremental binary Merkle tree.
/// @dev The incremental tree allows to calculate the root hash each time a leaf is added, ensuring
/// the integrity of the tree.
library IncrementalMerkleTree {
    using BitMaps for BitMaps.BitMap;

    uint256 internal constant MAX_DEPTH = 32;
    uint256 internal constant SNARK_SCALAR_FIELD =
        0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;

    /// @dev Initializes a tree.
    /// @param self: Tree data.
    /// @param depth: Depth of the tree.
    /// @param zero: Zero value to be used.
    function init(
        IncrementalTreeData storage self,
        uint256 depth,
        uint256 zero
    ) internal {
        if (zero >= SNARK_SCALAR_FIELD)
            revert IncrementalMerkleTree__OutOfField();
        if (depth == 0 || depth > MAX_DEPTH)
            revert IncrementalMerkleTree__OutOfDepth();

        self.depth = depth;

        for (uint256 i; i < depth; ) {
            self.zeroes[i] = zero;
            zero = PoseidonT3.poseidon([zero, zero]);

            unchecked {
                ++i;
            }
        }

        self.root = zero;
        self.knownRoots.set(zero);
    }

    /// @dev Inserts a leaf in the tree.
    /// @param self: Tree data.
    /// @param leaf: Leaf to be inserted.
    function insert(IncrementalTreeData storage self, uint256 leaf) internal {
        uint256 depth = self.depth;
        if (leaf >= SNARK_SCALAR_FIELD)
            revert IncrementalMerkleTree__OutOfField();
        uint256 numberOfLeaves = self.numberOfLeaves;
        if (numberOfLeaves >= 1 << depth)
            revert IncrementalMerkleTree__AllocationExceeded();

        uint256 index = numberOfLeaves;
        uint256 hash = leaf;

        for (uint256 i; i < depth; ) {
            if (index & 1 == 0) self.lastSubtrees[i] = [hash, self.zeroes[i]];
            else self.lastSubtrees[i][1] = hash;

            hash = PoseidonT3.poseidon(self.lastSubtrees[i]);
            index >>= 1;

            unchecked {
                ++i;
            }
        }

        self.root = hash;
        self.knownRoots.set(uint256(hash));
        unchecked {
            self.numberOfLeaves = ++numberOfLeaves;
        }
    }

    function isKnownRoot(
        IncrementalTreeData storage self_,
        uint256 root_
    ) internal view returns (bool) {
        return self_.knownRoots.get(root_);
    }

    /// @dev Updates a leaf in the tree.
    /// @param self: Tree data.
    /// @param leaf: Leaf to be updated.
    /// @param newLeaf: New leaf.
    /// @param proofSiblings: Array of the sibling nodes of the proof of membership.
    /// @param proofPathIndices: Path of the proof of membership.
    function update(
        IncrementalTreeData storage self,
        uint256 leaf,
        uint256 newLeaf,
        uint256[] calldata proofSiblings,
        uint256[] calldata proofPathIndices
    ) internal {
        require(
            verify(self, leaf, proofSiblings, proofPathIndices),
            "IncrementalBinaryTree: leaf is not part of the tree"
        );

        uint256 depth = self.depth;
        uint256 hash = newLeaf;

        uint256 updateIndex;
        uint256 proofPathIndice;
        for (uint256 i; i < depth; ) {
            proofPathIndice = proofPathIndices[i];
            updateIndex |= (proofPathIndice & 1) << i;
            if (proofPathIndice == 0) {
                if (proofPathIndice == self.lastSubtrees[i][1])
                    self.lastSubtrees[i][0] = hash;

                hash = PoseidonT3.poseidon([hash, proofPathIndice]);
            } else {
                if (proofPathIndice == self.lastSubtrees[i][0])
                    self.lastSubtrees[i][1] = hash;

                hash = PoseidonT3.poseidon([proofPathIndice, hash]);
            }

            unchecked {
                ++i;
            }
        }

        if (updateIndex >= self.numberOfLeaves)
            revert IncrementalMerkleTree__OutOfRange();

        self.root = hash;
        self.knownRoots.set(hash);
    }

    /// @dev Removes a leaf from the tree.
    /// @param self: Tree data.
    /// @param leaf: Leaf to be removed.
    /// @param proofSiblings: Array of the sibling nodes of the proof of membership.
    /// @param proofPathIndices: Path of the proof of membership.
    function remove(
        IncrementalTreeData storage self,
        uint256 leaf,
        uint256[] calldata proofSiblings,
        uint256[] calldata proofPathIndices
    ) internal {
        update(self, leaf, self.zeroes[0], proofSiblings, proofPathIndices);
    }

    /// @dev Verify if the path is correct and the leaf is part of the tree.
    /// @param self: Tree data.
    /// @param leaf: Leaf to be removed.
    /// @param proofSiblings: Array of the sibling nodes of the proof of membership.
    /// @param proofPathIndices: Path of the proof of membership.
    /// @return True or false.
    function verify(
        IncrementalTreeData storage self,
        uint256 leaf,
        uint256[] calldata proofSiblings,
        uint256[] calldata proofPathIndices
    ) private view returns (bool) {
        uint256 scalarField = SNARK_SCALAR_FIELD;
        if (leaf >= scalarField) revert IncrementalMerkleTree__OutOfField();

        uint256 depth = self.depth;
        if (proofPathIndices.length != depth || proofSiblings.length != depth)
            revert IncrementalMerkleTree__LengthMismatch();

        uint256 hash = leaf;

        uint256 proofSibling;
        for (uint256 i; i < depth; ) {
            proofSibling = proofSiblings[i];
            if (proofSibling >= scalarField)
                revert IncrementalMerkleTree__OutOfField();

            hash = proofSibling == 0
                ? PoseidonT3.poseidon([hash, proofSibling])
                : PoseidonT3.poseidon([proofSibling, hash]);

            unchecked {
                ++i;
            }
        }

        return hash == self.root;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library Roles {
    bytes32 public constant PROXY_ROLE =
        0x77d72916e966418e6dc58a19999ae9934bef3f749f1547cde0a86e809f19c89b;
    bytes32 public constant SIGNER_ROLE =
        0xe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70;
    bytes32 public constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    bytes32 public constant MINTER_ROLE =
        0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;
    bytes32 public constant OPERATOR_ROLE =
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;
    bytes32 public constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;
    bytes32 public constant TREASURER_ROLE =
        0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07;
    bytes32 public constant FACTORY_ROLE =
        0xdfbefbf47cfe66b701d8cfdbce1de81c821590819cb07e71cb01b6602fb0ee27;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./internal/Base.sol";
import "oz-custom/contracts/internal/FundForwarder.sol";

import "./interfaces/IZKBridge.sol";
import "./interfaces/IAuthority.sol";
import "oz-custom/contracts/internal/interfaces/IWithdrawable.sol";

import {
    BitMaps,
    IncrementalTreeData,
    IncrementalMerkleTree
} from "./libraries/IncrementalMerkleTree.sol";
import "oz-custom/contracts/libraries/Bytes32Address.sol";

contract ZKBridge is Base, IZKBridge, FundForwarder {
    using BitMaps for BitMaps.BitMap;
    using Bytes32Address for address;
    using IncrementalMerkleTree for IncrementalTreeData;

    /// @dev value is equal to keccak256("ZKBridge_v1")
    bytes32 public constant VERSION =
        0xf4bf07e827f4c8c7388905ad771e71f3057b88af67d838d74e682d514b8b35ac;

    IVerifier public verifier;

    BitMaps.BitMap private __supportedTokens;
    mapping(address => address) public wrapped;

    BitMaps.BitMap private __commitments;
    BitMaps.BitMap private __bridgeStates;
    BitMaps.BitMap private __nullifierHashes;
    IncrementalTreeData private __merkleTree;

    constructor(
        uint256 zeroValue_,
        uint256 merkleHeight_,
        ITreasury vault_,
        IAuthority authority_,
        IVerifier verififer_
    )
        payable
        FundForwarder(address(vault_))
        Base(authority_, Roles.TREASURER_ROLE)
    {
        verifier = verififer_;
        __merkleTree.init(merkleHeight_, zeroValue_);
    }

    function updateVerifier(
        IVerifier verifier_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        if (address(verifier_) == address(0)) revert ZKBridge__NonZeroAddress();

        emit VerifierUpdated(verifier, verifier_);

        verifier = verifier_;
    }

    function addWrappedTokens(
        address[] calldata tokens_,
        address[] calldata wrappers_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        uint256 length = tokens_.length;
        if (length != wrappers_.length) revert ZKBridge__LengthMismatch();

        address token;
        for (uint256 i; i < length; ) {
            token = tokens_[i];
            wrapped[token] = wrappers_[i];
            __supportedTokens.set(token.fillLast96Bits());
            unchecked {
                ++i;
            }
        }
    }

    function addBridgeState(
        uint256 stateRoot_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        __bridgeStates.set(stateRoot_);

        emit NewBridgeState(stateRoot_);
    }

    function deposit(
        address account_,
        address token_,
        uint256 value_,
        uint256 commitment_
    ) external onlyRole(Roles.PROXY_ROLE) {
        if (__commitments.get(commitment_))
            revert ZKBridge__UsedCommitment(commitment_);

        uint256 leafIdx = __merkleTree.numberOfLeaves;

        __commitments.set(commitment_);
        __merkleTree.insert(commitment_);

        emit Deposited(
            token_,
            account_,
            value_,
            __merkleTree.root,
            leafIdx,
            commitment_
        );
    }

    function withdraw(
        address,
        address,
        uint256 fee_,
        Input calldata input_,
        bytes calldata proofs_
    ) external onlyRole(Roles.PROXY_ROLE) {
        if (!__supportedTokens.get(input_.token.fillLast96Bits()))
            revert ZKBridge__WrappedTokenNotSupported(input_.token);

        if (!__bridgeStates.get(input_.root))
            revert ZKBridge__UnknownRoot(input_.root);

        if (__nullifierHashes.get(input_.nullifierHash))
            revert ZKBridge__AlreadySpent(input_.nullifierHash);

        __nullifierHashes.set(input_.nullifierHash);

        __verifyProof(fee_, input_, proofs_);

        IWithdrawable(vault).withdraw(
            wrapped[input_.token],
            input_.recipient,
            input_.value
        );

        emit Withdrawn(
            input_.token,
            input_.recipient,
            input_.value,
            input_.nullifierHash,
            input_.relayer,
            fee_
        );
    }

    function __verifyProof(
        uint256 fee_,
        Input calldata input_,
        bytes calldata proofs_
    ) private view {
        uint256[] memory inputs = new uint256[](7);
        inputs[0] = input_.root;
        inputs[1] = input_.value;
        inputs[2] = input_.token.fillLast96Bits();
        inputs[3] = input_.nullifierHash;
        inputs[4] = fee_;
        inputs[5] = input_.relayer.fillLast96Bits();
        inputs[6] = input_.recipient.fillLast96Bits();
        if (!verifier.verifyProof(proofs_, inputs))
            revert ZKBridge__InvalidProof();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBlacklistableUpgradeable {
    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);

    function setUserStatus(address account_, bool status) external;

    function isBlacklisted(address account_) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IWithdrawableUpgradeable {
    event Withdrawn(
        address indexed token,
        address indexed to,
        uint256 indexed value
    );
    event Received(address indexed sender, uint256 indexed value);

    function withdraw(
        address from_,
        address to_,
        uint256 amount_
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/utils/Context.sol";

import "./Transferable.sol";

error FundForwarder__ForwardFailed();

abstract contract FundForwarder is Context, Transferable {
    address public vault;

    event VaultUpdated(address indexed from, address indexed to);
    event Forwarded(address indexed from, uint256 indexed amount);

    constructor(address vault_) payable {
        _changeVault(vault_);
    }

    receive() external payable virtual {
        (bool ok, ) = vault.call{value: msg.value}("");
        if (!ok) revert FundForwarder__ForwardFailed();
        emit Forwarded(_msgSender(), msg.value);
    }

    function recoverERC20(IERC20 token_, uint256 amount_) external {
        _safeERC20Transfer(token_, vault, amount_);
    }

    function recoverNative() external {
        _safeNativeTransfer(vault, address(this).balance);
    }

    function _changeVault(address vault_) internal {
        emit VaultUpdated(vault, vault_);
        vault = vault_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../oz/token/ERC20/IERC20.sol";

interface IWithdrawable {
    event Withdrawn(
        address indexed token,
        address indexed to,
        uint256 indexed value
    );
    event Received(address indexed sender, uint256 indexed value);

    function withdraw(
        address from_,
        address to_,
        uint256 amount_
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/token/ERC20/IERC20.sol";

error Transferable__TransferFailed();
error Transferable__InvalidArguments();

abstract contract Transferable {
    function _safeTransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20TransferFrom(token_, from_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    function _safeTransfer(
        IERC20 token_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20Transfer(token_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    function _safeNativeTransfer(address to_, uint256 amount_)
        internal
        virtual
    {
        __checkValidTransfer(to_, amount_);
        if (!__nativeTransfer(to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20Transfer(
        IERC20 token_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        if (!__ERC20Transfer(token_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20TransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);

        if (!__ERC20TransferFrom(token_, from_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function __nativeTransfer(address to_, uint256 amount_)
        private
        returns (bool success)
    {
        assembly {
            success := call(gas(), to_, amount_, 0, 0, 0, 0)
        }
    }

    function __ERC20Transfer(
        IERC20 token_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to_) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), value_) // Append the "amount" argument.

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
    }

    function __ERC20TransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from_)
            mstore(add(freeMemoryPointer, 36), to_)
            mstore(add(freeMemoryPointer, 68), value_)

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }
    }

    function __checkValidTransfer(address to_, uint256 value_) private pure {
        if (value_ == 0 || to_ == address(0))
            revert Transferable__InvalidArguments();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Bytes32Address {
    function fromFirst20Bytes(bytes32 bytesValue)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := bytesValue
        }
    }

    function fillLast12Bytes(address addressValue)
        internal
        pure
        returns (bytes32 value)
    {
        assembly {
            value := addressValue
        }
    }

    function fromFirst160Bits(uint256 uintValue)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := uintValue
        }
    }

    function fillLast96Bits(address addressValue)
        internal
        pure
        returns (uint256 value)
    {
        assembly {
            value := addressValue
        }
    }

    function fromLast160Bits(uint256 uintValue)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := shr(0x60, uintValue)
        }
    }

    function fillFirst96Bits(address addressValue)
        internal
        pure
        returns (uint256 value)
    {
        assembly {
            value := shl(0x60, addressValue)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index)
        external
        view
        returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getAllRoleMembers(bytes32 role_)
        external
        view
        returns (address[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    error AccessControl__Unauthorized();
    error AccessControl__RoleMissing(bytes32 role, address account);
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

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

    function DEFAULT_ADMIN_ROLE() external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    error ERC20__Expired();
    error ERC20__StringTooLong();
    error ERC20__InvalidSignature();
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    error ERC20__Expired();
    error ERC20__StringTooLong();
    error ERC20__InvalidSignature();
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.17;

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
// OpenZeppelin Contracts v4.4.1 (utils/structs/BitMaps.sol)
pragma solidity ^0.8.17;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) map;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index)
        internal
        view
        returns (bool isSet)
    {
        uint256 value = bitmap.map[index >> 8] & (1 << (index & 0xff));

        assembly {
            isSet := value // Assign isSet to whether the value is non zero.
        }
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool shouldSet
    ) internal {
        uint256 value = bitmap.map[index >> 8];

        assembly {
            // The following sets the bit at `shift` without branching.
            let shift := and(index, 0xff)
            // Isolate the bit at `shift`.
            let x := and(shr(shift, value), 1)
            // Xor it with `shouldSet`. Results in 1 if both are different, else 0.
            x := xor(x, shouldSet)
            // Shifts the bit back. Then, xor with value.
            // Only the bit at `shift` will be flipped if they differ.
            // Every other bit will stay the same, as they are xor'ed with zeroes.
            value := xor(value, shl(shift, x))
        }
        bitmap.map[index >> 8] = value;
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] |= (1 << (index & 0xff));
    }

    function setBatch(BitMap storage bitmap_, uint256[] memory values_)
        internal
    {
        assembly {
            let length := mload(values_)
            let i := add(values_, 0x20)
            mstore(0x20, bitmap_.slot)
            for {
                let end := add(i, mul(length, 0x20))
            } lt(i, end) {
                i := add(i, 0x20)
            } {
                mstore(0x00, shr(8, mload(i)))
                let key := keccak256(0x00, 0x40)
                sstore(key, or(sload(key), shl(and(mload(i), 0xff), 1)))
            }
        }
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] &= ~(1 << (index & 0xff));
    }
}