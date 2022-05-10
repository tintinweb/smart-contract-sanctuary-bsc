// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interface/ICyclingBox.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract CyclingBoxEvent is ReentrancyGuard, Ownable {
    bytes32 public root;

    ICyclingBox public boxContract;
    address public recipientAddress;
    mapping(uint8 => PurchaseRound) private _purchaseRounds;
    mapping(uint8 => bool) private _purchaseRoundExist;
    mapping(uint8 => bool) public roundIsPrivate;
    uint8 public whitelistLimit;
    mapping(uint8 => mapping(address => bool)) public backupWhiteList;
    mapping(uint8 => uint256) public roundBackupWhiteListCount;
    mapping(uint8 => uint16) public roundLimitBox;
    mapping(uint8 => mapping(address => uint16))
        private _roundToNumberBoxOfUser;

    struct PurchaseRound {
        uint8 boxType;
        uint16 supply;
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        uint16 minted;
    }

    event OpenPurchaseRound(
        uint8 id,
        uint8 boxType,
        uint16 supply,
        uint256 startTime,
        uint256 endTime,
        uint256 price,
        bool isPrivate
    );
    event PurchasedBox(
        uint8 roundId,
        uint8 boxType,
        uint256 price,
        address buyer
    );

    constructor(
        address _boxContract,
        address _recipientAddress,
        bytes32 merkleroot
    ) {
        require(
            _recipientAddress != address(0),
            "_recipientAddress cannot be 0"
        );
        recipientAddress = _recipientAddress;
        root = merkleroot;
        boxContract = ICyclingBox(_boxContract);
        whitelistLimit = 10;
    }

    modifier roundNotExist(uint8 _roundId) {
        require(
            _purchaseRoundExist[_roundId] == false,
            "Purchase round already exists"
        );
        _;
    }

    modifier roundAvailable(uint8 _roundId) {
        require(
            _purchaseRoundExist[_roundId] == true,
            "Purchase round does not exist"
        );
        PurchaseRound memory purchaseRound = _purchaseRounds[_roundId];
        require(
            purchaseRound.startTime <= block.timestamp &&
                purchaseRound.endTime >= block.timestamp,
            "Purchase round is not active"
        );
        require(
            purchaseRound.minted < purchaseRound.supply,
            "Purchase round is sold out"
        );
        _;
    }

    /**
     * @dev Open an event with box type, time duration and price, supply, ...
     * @param _id uint8: id of the event
     * @param _boxType uint8: type of the box
     * @param _startTime uint256: start time of the event
     * @param _endTime uint256: end time of the event
     * @param _price uint256: price of the box
     * @param _supply uint256: supply of the box
     * @param _isPrivate bool: is the event private
     * @param _limitBox uint16: limit quantity of the box
     * Emit OpenPurchaseRound event
     */
    function openPurchaseRound(
        uint8 _id,
        uint8 _boxType,
        uint16 _supply,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _price,
        bool _isPrivate,
        uint16 _limitBox
    ) public onlyOwner roundNotExist(_id) {
        require(_endTime > _startTime, "End time must be after start time");
        require(_price > 0, "Price must be greater than 0");
        require(_supply > 0, "Supply must be greater than 0");
        require(
            _boxType > 0 && _boxType <= 4,
            "Box type must be between 1 and 4"
        );
        _purchaseRounds[_id] = PurchaseRound(
            _boxType,
            _supply,
            _startTime,
            _endTime,
            _price,
            0
        );

        _purchaseRoundExist[_id] = true;
        roundIsPrivate[_id] = _isPrivate;
        roundLimitBox[_id] = _limitBox;

        emit OpenPurchaseRound(
            _id,
            _boxType,
            _supply,
            _startTime,
            _endTime,
            _price,
            _isPrivate
        );
    }

    /**
     * @dev Buy event box
     * @param _roundId uint8: id of the event
     * @param _amount uint8: amount of box to buy
     * Emit PurchasedBox event
     */
    function buyBox(
        uint8 _roundId,
        uint8 _amount,
        bytes32[] calldata proof
    ) public payable nonReentrant roundAvailable(_roundId) {
        require(tx.origin == msg.sender);
        address buyer = _msgSender();
        require(buyer != address(0), "Buyer cannot be the null address");

        PurchaseRound storage purchaseRound = _purchaseRounds[_roundId];

        if (roundIsPrivate[_roundId]) {
            if (!_verify(_leaf(buyer), proof)) {
                if (!backupWhiteList[_roundId][buyer]) {
                require(
                    _roundToNumberBoxOfUser[_roundId][buyer] + _amount <=
                        whitelistLimit,
                    "You cannot buy more box"
                );
                }
            } else {
                require(
                    _roundToNumberBoxOfUser[_roundId][buyer] + _amount <=
                        roundLimitBox[_roundId],
                    "You cannot buy more box"
                );
            }
        }

        uint256 payWei = _amount * purchaseRound.price;
        require(msg.value >= payWei, "Not enough token");
        purchaseRound.minted += _amount;
        _roundToNumberBoxOfUser[_roundId][buyer] += _amount;
        boxContract.mint(buyer, purchaseRound.boxType, _amount);
        emit PurchasedBox(_roundId, purchaseRound.boxType, payWei, buyer);
    }

    /**
     * @dev getRoundInfo
     * @param _roundId uint8: id of the event
     */
    function getRoundInfo(uint8 _roundId)
        public
        view
        returns (PurchaseRound memory purchaseRound)
    {
        require(
            _purchaseRoundExist[_roundId] == true,
            "Purchase round does not exist"
        );
        purchaseRound = _purchaseRounds[_roundId];
    }

    function setRoundPrice(uint8 _roundId, uint256 _price)
        public
        onlyOwner
        roundAvailable(_roundId)
    {
        require(_price > 0, "Price must be greater than 0");

        PurchaseRound storage purchaseRound = _purchaseRounds[_roundId];

        require(
            purchaseRound.minted == 0,
            "Cannot change price of a round after boxes have been minted"
        );
        purchaseRound.price = _price;
    }

    function setRoundStartime(uint8 _roundId, uint256 _startTime)
        public
        onlyOwner
    {
        require(
            _purchaseRoundExist[_roundId] == true,
            "Purchase round does not exist"
        );
        require(_startTime >= block.timestamp, "Start time must be after now");
        PurchaseRound storage purchaseRound = _purchaseRounds[_roundId];
        require(
            purchaseRound.startTime > block.timestamp,
            "Cannot update starTime of a round after it has started"
        );
        purchaseRound.startTime = _startTime;
    }

    function setRoundEndtime(uint8 _roundId, uint256 _endTime)
        public
        onlyOwner
    {
        require(
            _purchaseRoundExist[_roundId] == true,
            "Purchase round does not exist"
        );
        require(_endTime >= block.timestamp, "End time must be after now");
        PurchaseRound storage purchaseRound = _purchaseRounds[_roundId];
        require(
            purchaseRound.endTime > block.timestamp,
            "Cannot update endTime of a round after it has ended"
        );
        purchaseRound.endTime = _endTime;
    }

    function addRoundBackupWhitelist(
        uint8 _roundId,
        address[] memory _addressWhitelist
    ) public onlyOwner {
        require(
            _purchaseRoundExist[_roundId] == true,
            "Purchase round does not exist"
        );
        for (uint256 i; i < _addressWhitelist.length; i++) {
            require(
                _addressWhitelist[i] != address(0),
                "Address whitelist cannot be the null address"
            );
            if (backupWhiteList[_roundId][_addressWhitelist[i]] == false) {
                backupWhiteList[_roundId][_addressWhitelist[i]] = true;
                roundBackupWhiteListCount[_roundId] += 1;
            }
        }
    }

    function removeRoundBackupWhitelist(
        uint8 _roundId,
        address[] memory _addressBlacklist
    ) public onlyOwner {
        require(
            _purchaseRoundExist[_roundId] == true,
            "Purchase round does not exist"
        );
        for (uint256 i; i < _addressBlacklist.length; i++) {
            require(
                backupWhiteList[_roundId][_addressBlacklist[i]] = true,
                "Address is not in whitelist"
            );
            backupWhiteList[_roundId][_addressBlacklist[i]] = false;
            roundBackupWhiteListCount[_roundId] -= 1;
        }
    }

    function setRoundSupply(uint8 _roundId, uint16 _supply)
        public
        onlyOwner
        roundAvailable(_roundId)
    {
        require(_supply > 0, "Supply must be greater than 0");

        PurchaseRound storage purchaseRound = _purchaseRounds[_roundId];
        require(
            _supply >= purchaseRound.minted,
            "Supply must be greater than minted"
        );
        purchaseRound.supply = _supply;
    }

    function setRoundLimitBox(uint8 _roundId, uint16 _limitBox)
        public
        onlyOwner
    {
        require(
            _purchaseRoundExist[_roundId] == true,
            "Purchase round does not exist"
        );
        // PurchaseRound memory purchaseRound = _purchaseRounds[_roundId];
        // require(
        //     purchaseRound.minted == 0,
        //     "Cannot change limit box after boxes have been minted"
        // );
        roundLimitBox[_roundId] = _limitBox;
    }

    function setRecepientAddress(address _recipientAddress) public onlyOwner {
        require(
            _recipientAddress != address(0),
            "recepientAddress cannot be 0"
        );
        recipientAddress = _recipientAddress;
    }

    function withdrawAll() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function updateRoot(bytes32 _merkleroot) external onlyOwner {
        root = _merkleroot;
    }

    function _verify(bytes32 leaf, bytes32[] memory proof)
        private
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }

    function _leaf(address account) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(account));
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ICyclingBox is IERC1155 {
    function mint(
        address _to,
        uint256 _boxType,
        uint256 _amount
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

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