/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// File: node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol

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

// File: @openzeppelin\contracts\token\ERC1155\IERC1155.sol



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
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

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

// File: node_modules\@openzeppelin\contracts\token\ERC1155\IERC1155Receiver.sol



/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol



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

// File: @openzeppelin\contracts\token\ERC1155\utils\ERC1155Receiver.sol



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol



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

// File: node_modules\@openzeppelin\contracts\utils\Context.sol



/*
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

// File: @openzeppelin\contracts\access\Ownable.sol



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

// File: @openzeppelin\contracts\utils\structs\EnumerableSet.sol



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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
}

// File: contracts\interfaces\IMysteryBoxStaking.sol



interface IMysteryBoxStaking {
    function depositRewards(uint256 rewards) external;
}

// File: contracts\tavern\MysteryBoxStaking.sol



contract MysteryBoxStaking is Ownable, ERC1155Receiver, IMysteryBoxStaking {
    using EnumerableSet for EnumerableSet.UintSet;

    event PoolAdded(address account, uint256 tokenId, uint256 allocPoint);
    event WithdrawPendingToken(address indexed account, uint256[] tokenIds, uint256 ag);
    event DepositRewards(address indexed operator, uint256 amount);

    uint256 private constant acc1e12 = 1e12;
    address private constant zeroAddress = address(0x0);
    address public constant mainnetTokenAddress = zeroAddress;

    // Info of each pool.
    struct StakingPool {
        uint16 allocPoint; // alloc Point for the pool
        uint240 accTokenPerShare; // Accumulated token per share, times 1e12.
    }

    // Info of each pool.
    struct UserInfo {
        uint32 amount; // user staked count
        uint224 rewardDebt; // Accumulated rewards
    }

    // account => tokenId => info
    mapping(address => mapping(uint256 => UserInfo)) public userInfo;

    // user total withdraws
    mapping(address => uint256) public userTotalWithdraws;

    // tokenId => pool
    mapping(uint256 => StakingPool) public stakingPools;
    // unstarted tokenPoolId => allocPoints
    mapping(uint256 => uint256) private _allocPoints;
    // supported TokenIds
    EnumerableSet.UintSet private _supportedTokenIds;

    // total diposited rewards
    uint256 public totalRewards;
    // sum of alloc points
    uint256 public totalAllocPoint;
    // the account can deposite rewards
    address public rewardInjector;

    // Ancient Gold
    IERC20 private immutable _ancientGold;
    // Mystery Boxes
    address private immutable _godGadget;

    constructor(address ag_, address godGadget_) {
        _ancientGold = IERC20(ag_);
        _godGadget = godGadget_;
        rewardInjector = owner();

        addSupportedToken(110, 10);
        addSupportedToken(111, 40);
        addSupportedToken(112, 50);
    }

    /**
     * @dev add a supported token(if needs)
     * @param tokenId the tokenId in GodGadget
     * @param allocPoint the alloc point of this tokenId
     */
    function addSupportedToken(uint256 tokenId, uint256 allocPoint) public onlyOwner {
        require(_supportedTokenIds.add(tokenId), "token already added");
        _allocPoints[tokenId] = allocPoint;
    }

    /**
     * @dev set reward depositor
     * @param rewardInjector_ the one who can deposit rewards
     */
    function setRewardInjector(address rewardInjector_) external onlyOwner {
        rewardInjector = rewardInjector_;
    }

    /**
     * @dev Add a pool, each tokenId can be only added once
     * @param account who opend this pool
     * @param tokenId the tokenId to open
     */
    function _addPool(address account, uint256 tokenId) private {
        // get alloc points
        uint256 allocPoint = _allocPoints[tokenId];
        // clear storaged allocPoint
        delete _allocPoints[tokenId];
        // set alloc point
        stakingPools[tokenId].allocPoint = uint16(allocPoint);
        // accumulate total alloc point
        totalAllocPoint += allocPoint;
        emit PoolAdded(account, tokenId, allocPoint);
    }

    /**
     * @dev deposit token into pool
     * @param account the one deposit token
     * @param tokenId the tokenId to deposit
     * @param amount the amount to deposit
     */
    function _deposit(
        address account,
        uint256 tokenId,
        uint256 amount
    ) private {
        // if the pool is not existe(_allocPoints in storage is not 0), then add the pool
        if (_allocPoints[tokenId] != 0) _addPool(account, tokenId);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;
        // withdraw pending tokens
        _withdrawPendingToken(account, tokenIds);
        // calculate staked amount and its rewardDebt
        uint256 stakedAmount = userInfo[account][tokenId].amount;
        stakedAmount += amount;
        userInfo[account][tokenId].amount = uint32(stakedAmount);
        userInfo[account][tokenId].rewardDebt = uint224((stakedAmount * stakingPools[tokenId].accTokenPerShare) / acc1e12);
    }

    /**
     * @dev deposit reward tokens into pool
     * @param rewards the amount to deposit
     */
    function depositRewards(uint256 rewards) external override onlyRewardInjector {
        // collect tokens
        _ancientGold.transferFrom(msg.sender, address(this), rewards);
        // add total token rewards
        totalRewards += rewards;
        // gas saves
        uint256 count = _supportedTokenIds.length();
        uint256 _totalAllocPoint = totalAllocPoint;
        IERC1155 godGadget = IERC1155(_godGadget);
        for (uint256 index = 0; index < count; ++index) {
            // tokenId of the pool
            uint256 tokenId = _supportedTokenIds.at(index);
            // get allocPoint
            uint256 allocPoint = stakingPools[tokenId].allocPoint;
            // if allocPoint is not 0 (means that the pool is opened)
            if (allocPoint != 0) {
                // calculate income shares per pool
                uint256 income = (rewards * allocPoint) / _totalAllocPoint;
                // calculate tokens deposited
                uint256 balance = godGadget.balanceOf(address(this), tokenId);
                // if there any token deposited, calculate accumulate tokens per share
                if (balance > 0) stakingPools[tokenId].accTokenPerShare += uint240((income * acc1e12) / balance);
            }
        }
        emit DepositRewards(msg.sender, rewards);
    }

    /**
     * @dev update alloc points, not used in prod env
     */
    function _updateAllocPoint(uint256[] calldata tokenIds, uint256[] calldata allocPoints) private {
        uint256 _totalAllocPoint = totalAllocPoint;
        require(tokenIds.length == allocPoints.length, "input array length not equals");
        for (uint256 index = 0; index < tokenIds.length; ++index) {
            uint256 tokenId = tokenIds[index];
            require(_supportedTokenIds.contains(tokenId), "token not supported");
            if (_allocPoints[tokenId] != 0) _allocPoints[tokenId] = allocPoints[index];
            else {
                uint256 newAllocPoint = allocPoints[index];
                _totalAllocPoint = _totalAllocPoint + newAllocPoint - stakingPools[tokenId].allocPoint;
                stakingPools[tokenId].allocPoint = uint16(newAllocPoint);
            }
        }
        totalAllocPoint = _totalAllocPoint;
    }

    /**
     * @dev withdraw staking token from pool
     * @param tokenIds the tokenIds to withdraw
     * @param amounts the amounts to withdraw
     */
    function withdraw(uint256[] calldata tokenIds, uint256[] calldata amounts) external {
        // collect pending tokens
        _withdrawPendingToken(msg.sender, tokenIds);
        for (uint256 index = 0; index < tokenIds.length; ++index) {
            uint256 tokenId = tokenIds[index];
            uint256 withdrawAmount = amounts[index];
            uint256 stakedAmount = userInfo[msg.sender][tokenId].amount;
            // check if user can withdraw the token with his desired amount
            require(withdrawAmount <= stakedAmount, "not enought to withdraw");
            stakedAmount -= withdrawAmount;
            userInfo[msg.sender][tokenId].amount = uint16(stakedAmount);
            // update rewardDebt
            userInfo[msg.sender][tokenId].rewardDebt = uint224((stakedAmount * stakingPools[tokenId].accTokenPerShare) / acc1e12);
        }
        // transfer out tokens
        IERC1155(_godGadget).safeBatchTransferFrom(address(this), msg.sender, tokenIds, amounts, "");
    }

    /**
     * @dev withdraw pending token
     * @param tokenIds the tokenIds to withdraw pendings
     */
    function withdrawPendingToken(uint256[] calldata tokenIds) external {
        _withdrawPendingToken(msg.sender, tokenIds);
    }

    /**
     * @dev implemtation of withdraw pending tokens
     * @param account the token holder
     * @param tokenIds the tokenIds to withdraw pendings
     */
    function _withdrawPendingToken(address account, uint256[] memory tokenIds) private {
        uint256 profits;
        for (uint256 index = 0; index < tokenIds.length; ++index) {
            uint256 tokenId = tokenIds[index];
            uint256 amount = userInfo[account][tokenId].amount;
            // calculate new rewardDebt
            uint256 newRewardDebt = (amount * stakingPools[tokenId].accTokenPerShare) / acc1e12;
            // accumulate profits using new rewardDebt - old rewardDebt
            profits += newRewardDebt - userInfo[account][tokenId].rewardDebt;
            // update reward debt
            userInfo[account][tokenId].rewardDebt = uint224(newRewardDebt);
        }
        // if there is any profts
        if (profits > 0) {
            // transfer tokens
            _ancientGold.transfer(account, profits);
            // accumulate withdraws
            userTotalWithdraws[account] += profits;
            emit WithdrawPendingToken(account, tokenIds, profits);
        }
    }

    /**
     * @dev pending token of a account
     * @param account the token holder
     * @param tokenIds the tokenIds to withdraw pendings
     */
    function pendingTokens(address account, uint256[] calldata tokenIds) external view returns (uint256[] memory tokenAmounts, uint256[] memory pending) {
        pending = new uint256[](tokenIds.length);
        tokenAmounts = new uint256[](tokenIds.length);
        for (uint256 index = 0; index < tokenIds.length; ++index) {
            uint256 tokenId = tokenIds[index];
            uint256 amount = userInfo[account][tokenId].amount;
            uint256 rewardDebt = userInfo[account][tokenId].rewardDebt;
            pending[index] = (amount * stakingPools[tokenId].accTokenPerShare) / acc1e12 - rewardDebt;
            tokenAmounts[index] = amount;
        }
    }

    function supportedTokenIds() external view returns (uint256[] memory tokenIds) {
        uint256 count = _supportedTokenIds.length();
        tokenIds = new uint256[](count);
        for (uint256 index = 0; index < count; ++index) tokenIds[index] = _supportedTokenIds.at(index);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata
    ) public virtual override returns (bytes4) {
        require(msg.sender == _godGadget, "must send from GodGadget");
        require(tx.origin == operator && operator == from, "must send from owner");
        require(_supportedTokenIds.contains(id), "token not supported");
        if (value > 0) _deposit(from, id, value);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) public virtual override returns (bytes4) {
        revert("not supported");
    }

    modifier onlyRewardInjector() {
        require(msg.sender == rewardInjector, "require reward injector");
        _;
    }
}