// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import './interfaces/IE8MintableNft.sol';

contract E8MarketPlace is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private batchIdCounter;
    IE8MintableNft private nftE8;
    IERC20 private energyToken;

    struct Lot {
        uint256 limit;
        uint256 supply;
        string tokenUri;
        uint256 price;
        bool active;
    }

    struct BatchLot {
        uint256 limit;
        uint256 supply;
        uint256 price;
        bool active;
        uint256[] ids;
        uint256[] amounts;
    }

    mapping(uint256 => Lot) private tokenIdToLot; //tokenId -> Lot
    mapping(uint256 => BatchLot) private batchIdToBatchLot; //tokenId -> BatchLot

    event Buy(uint256 tokenId, uint256 amount, address buyer);
    event BuyBatch(uint256 batchId, address buyer);
    event CreateLot(uint256 tokenId, uint256 limit, uint256 price, bool active);
    event CreateBatchLot(uint256 batchId, uint256 limit, uint256 price, bool active, uint256[] ids, uint256[] amounts);
    event EditLot(uint256 tokenId, uint256 limit, uint256 price, bool active);
    event EditBatchLot(uint256 batchId, uint256 limit, uint256 price, bool active, uint256[] ids, uint256[] amounts);
    event SetActiveForLot(bool _active, uint256 _tokenId);
    event SetActiveForBatchLot(bool _active, uint256 _batchLotId);

    constructor(IE8MintableNft _nftE8, IERC20 _energyToken) {
        nftE8 = _nftE8;
        energyToken = _energyToken;
    }

    function buy(uint256 _tokenId, uint256 _amount) external returns (bool) {
        Lot storage lot = tokenIdToLot[_tokenId];
        require(lot.active, 'MarketPlaceE8: lot is not active');
        if (lot.limit != 0) require(lot.supply + _amount <= lot.limit, 'MarketPlaceE8: amount more planned supply');
        lot.supply = lot.supply + _amount;
        energyToken.transferFrom(msg.sender, address(this), lot.price);
        nftE8.mintExists(msg.sender, _tokenId, _amount, 'data');
        emit Buy(_tokenId, _amount, msg.sender);
        return true;
    }

    function buyBatch(uint256 batchId) external returns (bool) {
        BatchLot storage batchLot = batchIdToBatchLot[batchId];
        require(batchLot.active, 'MarketPlaceE8: lot is not active');
        if (batchLot.limit != 0) require(batchLot.supply < batchLot.limit, 'MarketPlaceE8: amount more planned supply');
        batchLot.supply = batchLot.supply + 1;
        energyToken.transferFrom(msg.sender, address(this), batchLot.price);
        nftE8.mintExistsBatch(msg.sender, batchLot.ids, batchLot.amounts, 'data');
        emit BuyBatch(batchId, msg.sender);
        return true;
    }

    function createLot(
        uint256 tokenId,
        uint256 limit,
        uint256 price,
        bool active
    ) external onlyOwner returns (bool) {
        require(nftE8.isExists(tokenId), 'E8MarketPlace: token dont exist');
        tokenIdToLot[tokenId] = Lot(limit, 0, nftE8.tokenURI(tokenId), price, active);
        emit CreateLot(tokenId, limit, price, active);
        return true;
    }

    function createBatchLot(
        uint256 limit,
        uint256 price,
        bool active,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyOwner returns (bool) {
        uint256 batchId = batchIdCounter.current();
        for (uint256 i = 0; i < ids.length; i++) {
            require(nftE8.isExists(ids[i]), 'E8MintableNft: one of tokens is not exist');
        }
        batchIdToBatchLot[batchId] = BatchLot(limit, 0, price, active, ids, amounts);
        emit CreateBatchLot(batchId, limit, price, active, ids, amounts);
        batchIdCounter.increment();
        return true;
    }

    function editLot(
        uint256 tokenId,
        uint256 limit,
        uint256 price,
        bool active
    ) external onlyOwner returns (bool) {
        Lot memory lot = tokenIdToLot[tokenId];
        require(!lot.active, 'E8MarketPlace: lot must be not active');
        tokenIdToLot[tokenId] = Lot(limit, lot.supply, nftE8.tokenURI(tokenId), price, active);
        emit EditLot(tokenId, limit, price, active);
        return true;
    }

    function editBatchLot(
        uint256 batchId,
        uint256 limit,
        uint256 price,
        bool active,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyOwner returns (bool) {
        BatchLot memory batchLot = batchIdToBatchLot[batchId];
        require(!batchLot.active, 'E8MarketPlace: batchLot must be not active');
        batchIdToBatchLot[batchId] = BatchLot(limit, batchLot.supply, price, active, ids, amounts);
        emit EditBatchLot(batchId, limit, price, active, ids, amounts);
        return true;
    }

    function setActiveForLot(bool _active, uint256 _tokenId) external onlyOwner returns (bool) {
        tokenIdToLot[_tokenId].active = _active;
        emit SetActiveForLot(_active, _tokenId);
        return true;
    }

    function setActiveForBatchLot(bool _active, uint256 _batchLotId) external onlyOwner returns (bool) {
        batchIdToBatchLot[_batchLotId].active = _active;
        emit SetActiveForBatchLot(_active, _batchLotId);
        return true;
    }

    function getLotInfo(uint256 tokenId) external view returns (Lot memory) {
        return tokenIdToLot[tokenId];
    }

    function getBatchLotInfo(uint256 batchId) external view returns (BatchLot memory) {
        return batchIdToBatchLot[batchId];
    }

    function getAllLots() external view returns (Lot[] memory) {
        uint256 size = nftE8.getCurrentId();
        Lot[] memory arrLots = new Lot[](size);
        for (uint256 i = 0; i < size + 1; i++) {
            arrLots[i] = tokenIdToLot[i];
        }
        return arrLots;
    }

    function getAllBatchLots() external view returns (BatchLot[] memory) {
        uint256 size = batchIdCounter.current();
        BatchLot[] memory arrBatchLots = new BatchLot[](size);
        for (uint256 i = 0; i < size + 1; i++) {
            arrBatchLots[i] = batchIdToBatchLot[i];
        }
        return arrBatchLots;
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

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

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

interface IE8MintableNft is IERC1155 {
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        string memory uri,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        string[] memory uris,
        bytes memory data
    ) external;

    function mintExists(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function mintExistsBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function isExists(uint256 tokenId) external view returns (bool);

    function getCurrentId() external view returns (uint256);
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