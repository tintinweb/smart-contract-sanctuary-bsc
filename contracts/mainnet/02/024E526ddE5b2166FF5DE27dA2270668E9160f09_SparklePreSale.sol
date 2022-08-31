// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interface/ISparkle.sol";

/**
 * @title SparklePreSale
 * @author Sparkle
 */
contract SparklePreSale is Ownable, ReentrancyGuard, Pausable {
    event WhitelistSaleConfigChanged(WhitelistSaleConfig config);

    address public sparkle;
    address public community = address(this);
    uint256[3] public mintPrice; 
    uint256[3] public mintCount; 
    uint256[3] public maxCount;
    uint256 public saleStage;
    uint256 public airDropCount;
    struct WhitelistSaleConfig {
        bytes32 merkleRoot;
        uint256 startTime;
        uint256 endTime; 
    }
    WhitelistSaleConfig public whitelistSaleConfig;
    mapping(address => bool) public whitelistClaimed;

    /**
     * @notice setSparkle is used to set Sparkle contranct address . 
     * @param addr specify which address will be set.
     */
    function setSparkle(address addr) public onlyOwner {
        sparkle = addr;
    }

    /**
     * @notice setCommunity is used to set community address . 
     * @param addr specify which address will be set.
     */
    function setCommunity(address addr) public onlyOwner {
        community = addr;
    }

    /**
     * @notice setMintPrice is used to set sale stage mint price. 
     * @param a specify 1 sale stage mint price.
     * @param b specify 2 sale stage mint price.
     * @param c specify 3 sale stage mint price.
     */
    function setMintPrice(uint256 a, uint256 b, uint256 c) public onlyOwner {
        mintPrice[0] = a;
        mintPrice[1] = b;
        mintPrice[2] = c;
    }

    /**
     * @notice setMaxCount is used to set max mint count with stage. 
     * @param a specify 1 sale stage max count.
     * @param b specify 2 sale stage max count.
     * @param c specify 3 sale stage max count.
     */
    function setMaxCount(uint256 a, uint256 b, uint256 c) public onlyOwner {
        maxCount[0] = a;
        maxCount[1] = b;
        maxCount[2] = c;
    }

    /**
     * @notice setSaleStage is used to set now sale stage. 
     * @param s specify which sale stage.
     */
    function setSaleStage(uint256 s) public onlyOwner {
        saleStage = s;
    }

    /**
     * @notice airDrop is used to drop nfts to address. 
     * @param addrs specify receive address list.
     */
    function airDrop(address[] memory addrs) public onlyOwner {
        require(airDropCount <= 500, "max airDrop");
        for (uint i = 0; i < addrs.length; ++i) {
            ISparkle(sparkle).mint(addrs[i]);
            airDropCount += 1;
        }
    }

    /**
     * @notice setWhitelistSaleConfig is used to set the configuration related to whitelist sale.
     * This process is under the supervision of the community.
     * @param config_ config
     */
    function setWhitelistSaleConfig(WhitelistSaleConfig calldata config_) external onlyOwner {
        whitelistSaleConfig = config_;
        emit WhitelistSaleConfigChanged(config_);
    }

    /**
     * @notice isWhitelistSaleEnabled is used for check whitelist sale.
     */
    function isWhitelistSaleEnabled() public view returns (bool) {
        if (whitelistSaleConfig.endTime > 0 && block.timestamp > whitelistSaleConfig.endTime) {
            return false;
        }
        return whitelistSaleConfig.startTime > 0 && 
            block.timestamp > whitelistSaleConfig.startTime &&
            mintPrice[0] > 0 &&
            whitelistSaleConfig.merkleRoot != "";
    }

    /**
     * @notice isWhitelistAddress is used to verify whether the sender address and signature_ belong to merkleRoot.
     * @param signature_ merkle proof
     */
    function isWhitelistAddress(bytes32[] calldata signature_) public view returns (bool) {
        if (whitelistSaleConfig.merkleRoot == "") {
            return false;
        }
        return MerkleProof.verify(
                signature_,
                whitelistSaleConfig.merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            );
    }

    /**
     * @notice whitelistSale is used for whitelist sale.
     * @param signature_ merkel proof
     */
    function whitelistSale(bytes32[] calldata signature_) external payable callerIsUser nonReentrant {
        require(isWhitelistSaleEnabled(), "whitelist sale has not enabled");
        require(isWhitelistAddress(signature_), "caller is not in whitelist or invalid signature");
        require(whitelistClaimed[msg.sender] == false, "Already Mint");
        require(mintPrice[0] == msg.value, "errorAmount");
        require(mintCount[0] <= maxCount[0], "");
        ISparkle(sparkle).mint(msg.sender);
        whitelistClaimed[msg.sender] = true;
        mintCount[0] += 1;
        if (community != address(this)) {
            (bool success, ) = community.call{value: msg.value}("");
            require(success, "FailedToSend");
        }
    }

    /**
     * @notice presale is used for nft pre-sale.
     * @param num buy count
     */
    function presale(uint256 num) external payable callerIsUser nonReentrant {
        require(saleStage > 0, "presale not start");
        require(num > 0, "error mint number");
        uint256 amount = mintPrice[saleStage] * num;
        require(amount == msg.value, "errorAmount");
        require(mintCount[saleStage] <= maxCount[saleStage], "over max mint count");

        ISparkle(sparkle).batchMint(msg.sender, num);
        if (community != address(this)) {
            (bool success, ) = community.call{value: msg.value}("");
            require(success, "FailedToSend");
        }
        mintCount[saleStage] += 1;
    }

    modifier callerIsUser() {
        require(tx.origin == _msgSender(), "caller is another contract");
        _;
    }

    /**
     * @notice withdraw is used to withdraw token.
     */
    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "FailedToSend");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISparkle {
    function mint(address _addr) external;
    function batchMint(address _addr, uint256 n) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
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
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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