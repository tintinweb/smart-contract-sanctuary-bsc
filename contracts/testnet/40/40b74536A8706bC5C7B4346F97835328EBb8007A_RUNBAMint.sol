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
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


interface RUNBANFT {
    function mintBatch200(address _to, uint[] calldata _tokenIdList, string[] calldata _tokenUriList, string[] calldata _boxUriList) external;
    function transferOwnership(address newOwner) external;
}

contract RUNBAMint is Ownable {

    constructor(RUNBANFT _run) {
        runC = _run;
    }

    RUNBANFT public runC;
    
    bytes32 public FMMerkleRoot; // free mint
    bytes32 public OGMerkleRoot; // OG mint
    bytes32 public WLMerkleRoot; // whiteList mint

    uint256 public FMPos = 0; // position of claimed of free mint
    uint256 public OGPos = 0; // position of claimed of og mint
    uint256 public WLPos = 0; // position of claimed of whitelist mint
    uint256 public PPos = 0; // position of claimed of whitelist mint

    uint256 public freeMintStart;
    uint256 public freeMintEnd;
    uint256 public ogMintStart;
    uint256 public ogMintEnd;
    uint256 public wlMintStart;
    uint256 public wlMintEnd;
    uint256 public publicMintStart;
    uint256 public publicMintEnd;

    uint256 public maxFreeMint = 2;
    uint256 public maxTotalMint = 5;

    uint256 public ogMintPrice = 0.1 ether;
    uint256 public wlMintPrice = 0.5 ether;

    // three type mapping
    mapping(address => uint256) public freeClaimed;
    mapping(address => uint256) public ogClaimed;
    mapping(address => uint256) public wlClaimed;
    mapping(address => uint256) public publicClaimed;
    // free mint data
    uint256[] public freeTokenIds;
    string[] public freeTokenIdsBoxUri;
    string[] public freeTokenIdsShoeUri;
    // mapping(uint256 => uint256) public freeTokenIds;
    // mapping(uint256 => string) public freeTokenIdsBoxUri;
    // mapping(uint256 => string) public freeTokenIdsShoeUri;
    // og mint data
    uint256[] public ogTokenIds;
    string[] public ogTokenIdsBoxUri;
    string[] public ogTokenIdsShoeUri;
    // mapping(uint256 => uint256) public ogTokenIds;
    // mapping(uint256 => string) public ogTokenIdsBoxUri;
    // mapping(uint256 => string) public ogTokenIdsShoeUri;
    // whitelist mint data
    uint256[] public wlTokenIds;
    string[] public wlTokenIdsBoxUri;
    string[] public wlTokenIdsShoeUri;
    // mapping(uint256 => uint256) public wlTokenIds;
    // mapping(uint256 => string) public wlTokenIdsBoxUri;
    // mapping(uint256 => string) public wlTokenIdsShoeUri;
    // public mint data
    uint256[] public  publicTokenIds;
    string[] public publicTokenIdsBoxUri;
    string[] public publicTokenIdsShoeUri;
    // mapping(uint256 => uint256) public publicTokenIds;
    // mapping(uint256 => string) public publicTokenIdsBoxUri;
    // mapping(uint256 => string) public publicTokenIdsShoeUri;

    function setMaxFreeMint(uint256 _maxMint) external onlyOwner {
        maxFreeMint = _maxMint;
    }
    function setMaxMint(uint256 _maxTotalMint) external onlyOwner {
        maxTotalMint = _maxTotalMint;
    }

    function setFMPos(uint256 _pos) external onlyOwner {
        FMPos = _pos;
    }
    function setOGPos(uint256 _pos) external onlyOwner {
        OGPos = _pos;
    }
    function setWLPos(uint256 _pos) external onlyOwner {
        WLPos = _pos;
    }
    function setPPos(uint256 _pos) external onlyOwner {
        PPos = _pos;
    }

    function setFMMerkleRoot(bytes32 _fm) external onlyOwner {
        FMMerkleRoot = _fm;
    }
    function setOGMerkleRoot(bytes32 _og) external onlyOwner {
        OGMerkleRoot = _og;
    }
    function setWLMerkleRoot(bytes32 _wl) external onlyOwner {
        WLMerkleRoot = _wl;
    }

    function resetOwnership(address _newOwner) external onlyOwner {
        runC.transferOwnership(_newOwner);
    }

    function setFreeMintTime(uint256 _start, uint256 _end) external onlyOwner {
        require(_start < _end, "time illegal");
        freeMintStart = _start;
        freeMintEnd = _end;
    }

    function setOGMintTime(uint256 _start, uint256 _end) external onlyOwner {
        require(_start < _end, "time illegal");
        ogMintStart = _start;
        ogMintEnd = _end;
    }

    function setWhiteListMintTime(uint256 _start, uint256 _end) external onlyOwner {
        require(_start < _end, "time illegal");
        wlMintStart = _start;
        wlMintEnd = _end;
    }

    function setPublicMintTime(uint256 _start, uint256 _end) external onlyOwner {
        require(_start < _end, "time illegal");
        publicMintStart = _start;
        publicMintEnd = _end;
    }

    function addFreeMintData(uint256[] calldata _tokenIds, string[] calldata _boxList, string[] calldata _shoeList) external onlyOwner {
        // 时间限制
        // 格式限制
        for(uint256 i = 0; i < _tokenIds.length; i++) {
            freeTokenIds.push(_tokenIds[i]);
            freeTokenIdsBoxUri.push(_boxList[i]);
            freeTokenIdsShoeUri.push(_shoeList[i]);
        }
    }

    function addOgMintData(uint256[] calldata _tokenIds, string[] calldata _boxList, string[] calldata _shoeList) external onlyOwner {
        // 时间限制
        // 格式限制
        for(uint256 i = 0; i < _tokenIds.length; i++) {
            ogTokenIds.push(_tokenIds[i]);
            ogTokenIdsBoxUri.push(_boxList[i]);
            ogTokenIdsShoeUri.push(_shoeList[i]);
        }
    }

    function addWlMintData(uint256[] calldata _tokenIds, string[] calldata _boxList, string[] calldata _shoeList) external onlyOwner {
        // 时间限制
        // 格式限制
        for(uint256 i = 0; i < _tokenIds.length; i++) {
            wlTokenIds.push(_tokenIds[i]);
            wlTokenIdsBoxUri.push(_boxList[i]);
            wlTokenIdsShoeUri.push(_shoeList[i]);
        }
    }

    function addPublicMintData(uint256[] calldata _tokenIds, string[] calldata _boxList, string[] calldata _shoeList) external onlyOwner {
        // 时间限制
        // 格式限制
        for(uint256 i = 0; i < _tokenIds.length; i++) {
            publicTokenIds.push(_tokenIds[i]);
            publicTokenIdsBoxUri.push(_boxList[i]);
            publicTokenIdsShoeUri.push(_shoeList[i]);
        }
    }

    function freeMint(bytes32[] calldata _merkleProof) external {
        // check pos count
        require(FMPos <= freeTokenIds.length - 1, "exceed Max");
        // check time
        require(block.timestamp > freeMintStart, "not start");
        require(block.timestamp < freeMintEnd, "end");
        // check mint limit
        require(freeClaimed[msg.sender] < maxFreeMint, "mint failed");
        // check merkle tree
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, FMMerkleRoot, leaf), "not in whitelist");

        freeClaimed[msg.sender] += 1;

        // start mint
        uint256[] memory tokenId = new uint256[](1);
        string[] memory boxUri = new string[](1);
        string[] memory shoeUri = new string[](1);

        tokenId[0] = freeTokenIds[FMPos];
        boxUri[0] = freeTokenIdsBoxUri[FMPos];
        shoeUri[0] = freeTokenIdsShoeUri[FMPos];

        runC.mintBatch200(msg.sender, tokenId, boxUri, shoeUri);
        FMPos += 1;
        // end mint
    }


    function ogMint(bytes32[] calldata _merkleProof) external payable {
        // check pos count
        require(OGPos <= ogTokenIds.length - 1, "exceed Max");
        // check time
        require(block.timestamp > ogMintStart, "not start");
        require(block.timestamp < ogMintEnd, "end");
        // check merkle tree
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, OGMerkleRoot, leaf), "not in whitelist");
        // check mint price
        require(msg.value >= ogMintPrice);
        // check mint limit
        if (freeClaimed[msg.sender] > 0) {
            require(ogClaimed[msg.sender] <= maxTotalMint - freeClaimed[msg.sender], "max mint");
        }
        ogClaimed[msg.sender] += 1;
        // start mint 5 modify
        uint256[] memory tokenId = new uint256[](1);
        string[] memory boxUri = new string[](1);
        string[] memory shoeUri = new string[](1);

        tokenId[0] = ogTokenIds[OGPos];
        boxUri[0] = ogTokenIdsBoxUri[OGPos];
        shoeUri[0] = ogTokenIdsShoeUri[OGPos];

        runC.mintBatch200(msg.sender, tokenId, boxUri, shoeUri);
        OGPos++;
        // end mint
    }

    function whiteListMint() external payable {
    }

    function publicMint() external payable {
    }

    // withdraw
    function withdraw() external onlyOwner {
        payable(address(owner())).transfer(address(this).balance);
    }

    function transferToNewOwner(address _new) external onlyOwner {
        runC.transferOwnership(_new);
    }

    fallback() payable external {}

    receive() payable external {}
}