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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

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
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
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
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
     * @dev Returns the number of values in the set. O(1).
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

pragma solidity ^0.8.4;

abstract contract Contextq {
    function _msgSender1() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData1() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Adminable is Contextq {
    mapping(address => bool) private _admins;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ModificationAdmin(address indexed admin, bool oldState, bool newState);

    constructor() {
        _transferOwnership(_msgSender1());
    }

    modifier onlyOwner() {
        require(owner() == _msgSender1(), "Adminable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender1()), "Adminable: caller is not the admin");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function isAdmin(address account) public view virtual returns (bool) {
        return _admins[account];
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        _admins[newOwner] = true;
        _admins[oldOwner] = false;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function modificationAdmin(address admin, bool state) public virtual onlyOwner {
        emit ModificationAdmin(admin,  _admins[admin], state);
        _admins[admin] = state;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMill is IERC721{
    function mintWithWhiteList(address to) external;
    function index() external view returns (uint256);
    function getDefaultAttribute() external view returns (uint256 attribute, uint256 quality, uint256 grade, uint256 initDurability);
    function getNftAttribute(uint256 attributeID, uint256 tokenID) external view returns (uint256);

    function setNftAttribute(uint256 attributeID, uint256 tokenID, uint256 value) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IMineral {
    function mintTokenIdWithWitelist(address to, uint256[] memory ids, uint256[] memory amounts) external;
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../Adminable.sol";

contract Mill is ERC721,Adminable{

    enum Attribute {
        ATTRIBUTE,//属性
        QUALITY,//质量
        GRADE,//等级
        DURABILITY//耐久度
    }

    uint constant INIT_DURABILITY = 10000;
    uint256 public index = 1;
    //attribute=>tokenId=>value
    mapping(uint256 => mapping(uint256 => uint256)) private _nftAttribute;

    constructor() ERC721("Mill", "MILL"){}

    function mintWithWhiteList(address to) public onlyAdmin{
        _mint(to, index);
        index++;
    }

    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,1,2,3
    function mint(address to, uint256 attribute, uint256 quality, uint256 grade) public onlyAdmin {
        uint256 tokenId = index;
        _mint(to, tokenId);
        index++;
        setNftAttribute(uint256(Attribute.ATTRIBUTE), tokenId, attribute);
        setNftAttribute(uint256(Attribute.QUALITY), tokenId, quality);
        setNftAttribute(uint256(Attribute.GRADE), tokenId, grade);
        setNftAttribute(uint256(Attribute.DURABILITY), tokenId, INIT_DURABILITY);
    }

    function getNftAttribute(uint256 attributeId, uint256 tokenId) public view returns (uint256) {
        return _nftAttribute[attributeId][tokenId];
    }

    function getDefaultAttribute() public view returns (uint256 attribute, uint256 quality, uint256 grade, uint256 initDurability){
        attribute = _nftAttribute[uint256(Attribute.ATTRIBUTE)][1];
        quality = _nftAttribute[uint256(Attribute.QUALITY)][1];
        grade = _nftAttribute[uint256(Attribute.GRADE)][1];
        initDurability = INIT_DURABILITY;
    }

    function setNftAttribute(uint256 attributeID, uint256 tokenID, uint256 value) public virtual onlyAdmin {
        _nftAttribute[attributeID][tokenID] = value;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../Adminable.sol";

contract Mineral is ERC1155Supply,Adminable{
    using EnumerableSet for EnumerableSet.Set;

    enum Id {
        OIL,//燃油合成剂
        AIRSHIP,//飞船合成剂
        COMPOUND,//矿机合成剂
        MILL_MAINTAIN,//矿机维修剂
        AIRSHIP_MAINTAIN,//飞船维修剂
        STONE//精炼石
    }

    EnumerableSet.UintSet private idSet;//矿产集合

    constructor(string memory _uri) ERC1155(_uri){
    }

    function addId(uint256 _id) external onlyOwner{
        EnumerableSet.add(idSet,_id);
    }

    function removeId(uint256 _id) external onlyOwner{
        EnumerableSet.remove(idSet,_id);
    }

    function getIdLength() public view returns (uint256){
        return EnumerableSet.length(idSet);
    }

    function getId(uint256 _index) public view returns (uint256){
        require(_index <= getIdLength() - 1, "idSet: index out of bounds");
        return EnumerableSet.at(idSet, _index);
    }

    function mintTokenIdWithWitelist(address to, uint256[] memory ids, uint256[] memory amounts) public onlyAdmin{
        for(uint256 i = 0; i< ids.length; i++){
            uint256 _id = ids[i];
            require(EnumerableSet.contains(idSet,_id),"Illegal id");
        }
        _mintBatch(to, ids, amounts, "");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../storage/MillFactoryStorage.sol";

abstract contract IMillFactory is MillFactoryStorage{

    event ResetFeeTo(address oldFeeTo, address newFeeTo);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../storage/MineEctypePoolStorage.sol";

abstract contract IMineEctypePool is MineEctypePoolStorage{
    event ResetFeeTo(address oldFeeTo, address newFeeTo);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../storage/MineTemplatePoolStorage.sol";

abstract contract IMineTemplatePool is MineTemplatePoolStorage{

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./asset/interfaces/IMill.sol";
import "./interfaces/IMillFactory.sol";
import "./utils/AssetTransfer.sol";

contract MillFactory is IMillFactory,ERC721Holder,ERC1155Holder,Ownable,Pausable,ReentrancyGuard{

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AssetTransfer for address;

    constructor (address _feeTo) {
        require(_feeTo != address(0),"Constructor: _feeTo the zero address");
        feeTo = _feeTo;
    }

    modifier isMill(address _mill) {
        require(millSet.contains(_mill),"Illegal mill");
        _;
    }

    function resetFeeTo(address payable _feeTo) external onlyOwner{
        require(_feeTo != address(0), "ResetFeeTo: _feeTo the zero address");
        address oldFeeTo = feeTo;
        feeTo = _feeTo;

        emit ResetFeeTo(oldFeeTo, _feeTo);
    }

    function addMills(address[] memory _mills) public onlyOwner{
        for(uint256 i=0; i<_mills.length; i++){
            addMill(_mills[i]);
        }
    }

    //0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8,[0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8,[0x4b6b9f3695205c8468ddf9ab4025ec2a09bdff1a,2000],[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,[[1,3,1],[2,4,1]]]],[5,[0x4b6b9f3695205c8468ddf9ab4025ec2a09bdff1a,2000],[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,[[1,3,1],[2,4,1]]]]
    function addMill(address _mill) internal{
        require(_mill != address(0),"AddMill: _mill the zero address");
        EnumerableSet.add(millSet,_mill);
    }

    function removeMill(address _mill) public onlyOwner{
        EnumerableSet.remove(millSet,_mill);
    }

    function getMillLength() public view returns (uint256){
        return EnumerableSet.length(millSet);
    }

    function getMill(uint256 _index) public view returns (address){
        require(_index <= getMillLength() - 1, "millSet: index out of bounds");
        return EnumerableSet.at(millSet, _index);
    }

    //0xd9145CCE52D386f254917e481eB44e9943F39138,[2,0xd9145CCE52D386f254917e481eB44e9943F39138,[0x0000000000000000000000000000000000000000,2000],[0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8,[[0,3,1],[1,4,1]]]]
    function restCompositionConfig(address _mill, CompositionConfig memory _compositionConfig) external onlyOwner{
        require(EnumerableSet.contains(millSet,_mill) && EnumerableSet.contains(millSet,_compositionConfig.compositionMill),"Illegal _mill");
        delete compositionConfigMapping[_mill];

        _initCompositionConfig(_mill, _compositionConfig);
    }

    //0xd9145CCE52D386f254917e481eB44e9943F39138,[5,[0x0000000000000000000000000000000000000000,3000],[0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8,[[1,3,1],[2,4,1]]]]
    function restRepairConfig(address _mill, RepairConfig memory _repairConfig) external onlyOwner{
        require(EnumerableSet.contains(millSet,_mill),"Illegal _mill");
        delete repairConfigMapping[_mill];

        _initRepairConfig(_mill,_repairConfig);
    }

    //合成
    //[0xd9145CCE52D386f254917e481eB44e9943F39138,[1,2]],true,[1,"0x666f6f0000000000000000000000000000000000000000000000000000000000","0x666f6f0000000000000000000000000000000000000000000000000000000000"]
    function composition(MillInfos memory _millInfos, bool _success, Signature memory _signature) public payable isMill(_millInfos.mill) nonReentrant whenNotPaused{
        address _mill = _millInfos.mill;
        uint256[] memory _tokenIds = _millInfos.tokenIds;

        CompositionConfig storage compositionConfig = compositionConfigMapping[_mill];
        CoinValue storage compositionCoin = compositionConfig.compositionCoin;
        address compositionMill = compositionConfig.compositionMill;
        address mineral = compositionConfig.mineralCost.mineral;
        require(_millInfos.tokenIds.length == compositionConfig.consumeMillAmount, "Lack of mill");

        //支付代币
        AssetTransfer.coinCost(feeTo, compositionCoin.coin, compositionCoin.value);
        //消耗矿产
        MineralIdDebt[] memory _mineralIdDebt = getCompositionDebts(_mill);
        AssetTransfer.mineralCost(feeTo, mineral, _mineralIdDebt);
        //质押矿机
        for(uint256 i=0; i<_tokenIds.length; i++){
            uint256 _tokenId = _tokenIds[i];
            uint256 durability = IMill(_mill).getNftAttribute(uint(Attribute.DURABILITY),_tokenId);
            //初始耐久度
            (,,,uint256 initDurability) = IMill(_mill).getDefaultAttribute();
            require(durability == initDurability, "Lack of durability");
            IMill(_mill).safeTransferFrom(msg.sender, address(this), _tokenId);
        }

        if(_success){
            //创建合成矿机
            uint256 tokenId = IMill(compositionMill).index();
            IMill(compositionMill).mintWithWhiteList(msg.sender);
        }
    }

    //分解
//    function decomposition(MillInfo memory _millInfo,  bool success, Signature memory signature) public payable isMill(_millInfo.mill) nonReentrant whenNotPaused{
//
//    }

    //维修
    //[0xd9145CCE52D386f254917e481eB44e9943F39138,3],true,[1,"0x666f6f0000000000000000000000000000000000000000000000000000000000","0x666f6f0000000000000000000000000000000000000000000000000000000000"]
    function repair(MillInfo memory _millInfo, bool _success, Signature memory _signature) public payable isMill(_millInfo.mill) nonReentrant whenNotPaused{
        address _mill = _millInfo.mill;
        uint256 _tokenId = _millInfo.tokenId;

        RepairConfig storage repairConfig = repairConfigMapping[_mill];
        CoinValue storage repairCoin = repairConfig.repairCoin;
        address mineral = repairConfig.mineralCost.mineral;
        uint256 times = repairTimesMapping[_mill][_tokenId];

        require(times < repairConfig.maxRepairTimes, "The number of repairs has exceeded");
        uint256 durability = IMill(_mill).getNftAttribute(uint(Attribute.DURABILITY),_tokenId);
        (,,,uint256 initDurability) = IMill(_mill).getDefaultAttribute();
        require(durability < initDurability, "");

        //支付代币
        AssetTransfer.coinCost(feeTo, repairCoin.coin, repairCoin.value);
        //消耗矿产
        MineralIdDebt[] memory _mineralIdDebt = getRepairDebts(_mill, _tokenId);
        AssetTransfer.mineralCost(feeTo, mineral, _mineralIdDebt);

        repairTimesMapping[_mill][_tokenId] = times.add(1);
        if(_success){
            //获取耐久度

            //重置耐久度
            IMill(_mill).setNftAttribute(uint256(Attribute.DURABILITY), _tokenId, initDurability);
        }
    }

    function _initCompositionConfig(address _mill, CompositionConfig memory _compositionConfig) internal{
        CompositionConfig storage compositionConfig = compositionConfigMapping[_mill];
        CoinValue storage compositionCoin = compositionConfig.compositionCoin;
        MineralCost storage mineralCost = compositionConfig.mineralCost;
        MineralIdCost[] storage mineralIdCosts = mineralCost.mineralIdCost;

        CoinValue memory _compositionCoin = _compositionConfig.compositionCoin;
        MineralCost memory _mineralCost = _compositionConfig.mineralCost;
        MineralIdCost[] memory _mineralIdCosts = _mineralCost.mineralIdCost;

        compositionConfig.consumeMillAmount = _compositionConfig.consumeMillAmount;
        compositionConfig.compositionMill = _compositionConfig.compositionMill;
        compositionCoin.coin = _compositionCoin.coin;
        compositionCoin.value = _compositionCoin.value;
        mineralCost.mineral = _mineralCost.mineral;

        _pushMineralIdCosts(mineralIdCosts, _mineralIdCosts);
    }

    function _initRepairConfig(address _mill, RepairConfig memory _repairConfig) internal{
        RepairConfig storage repairConfig = repairConfigMapping[_mill];
        CoinValue storage repairCoin = repairConfig.repairCoin;
        MineralCost storage mineralCost = repairConfig.mineralCost;
        MineralIdCost[] storage mineralIdCosts = mineralCost.mineralIdCost;

        CoinValue memory _repairCoin = _repairConfig.repairCoin;
        MineralCost memory _mineralCost = _repairConfig.mineralCost;
        MineralIdCost[] memory _mineralIdCosts = _mineralCost.mineralIdCost;

        repairConfig.maxRepairTimes = _repairConfig.maxRepairTimes;
        repairCoin.coin = _repairCoin.coin;
        repairCoin.value = _repairCoin.value;
        mineralCost.mineral = _mineralCost.mineral;

        _pushMineralIdCosts(mineralIdCosts, _mineralIdCosts);
    }

    function getCompositionDebts(address _mill) public view returns(MineralIdDebt[] memory){
        CompositionConfig storage compositionConfig = compositionConfigMapping[_mill];
        MineralCost storage mineralCost = compositionConfig.mineralCost;
        MineralIdCost[] storage mineralIdCosts = mineralCost.mineralIdCost;
        uint256 _len = mineralIdCosts.length;

        MineralIdDebt[] memory mineralIdDebts = new MineralIdDebt[](_len);
        for(uint256 i= 0; i< _len; i++){
            MineralIdCost memory mineralIdCost = mineralIdCosts[i];
            MineralIdDebt memory _mineralIdDebt = MineralIdDebt(mineralIdCost.id, 0, mineralIdCost.firstCost);
            mineralIdDebts[i] = _mineralIdDebt;
        }

        return mineralIdDebts;
    }

    function getRepairDebts(address _mill,uint256 _tokenId) public view returns(MineralIdDebt[] memory){
        RepairConfig storage repairConfig = repairConfigMapping[_mill];
        MineralCost storage mineralCost = repairConfig.mineralCost;
        MineralIdCost[] storage mineralIdCosts = mineralCost.mineralIdCost;
        uint256 _len = mineralIdCosts.length;

        MineralIdDebt[] memory mineralIdDebts = new MineralIdDebt[](_len);
        uint256 times = repairTimesMapping[_mill][_tokenId];
        if(times >= repairConfig.maxRepairTimes){
            return mineralIdDebts;
        }

        for(uint256 i= 0; i< _len; i++){
            MineralIdCost memory mineralIdCost = mineralIdCosts[i];

            uint256 stepTotalCost = times.mul(mineralIdCost.stepCost);
            uint256 totalCost =  mineralIdCost.firstCost.add(stepTotalCost);

            MineralIdDebt memory _mineralIdDebt = MineralIdDebt(mineralIdCost.id, 0, totalCost);
            mineralIdDebts[i] = _mineralIdDebt;
        }

        return mineralIdDebts;
    }

    //重置挖出的矿产集合
    function _pushMineralIdCosts(MineralIdCost[] storage mineralIdCosts, MineralIdCost[] memory _mineralIdCosts) internal{
        uint256 _len = _mineralIdCosts.length;
        for(uint256 i=0; i< _len; i++){
            MineralIdCost memory _mineralIdCost = _mineralIdCosts[i];
            mineralIdCosts.push(_mineralIdCost);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./asset/interfaces/IMill.sol";
import "./interfaces/IMineEctypePool.sol";
import "./utils/AssetTransfer.sol";
import "./utils/StructSet.sol";
import "./MineTemplatePool.sol";
//import "hardhat/console.sol";

contract MineEctypePool is IMineEctypePool,ERC721Holder,ERC1155Holder,Ownable,Pausable,ReentrancyGuard{
    using Math for uint256;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AssetTransfer for address;
    using StructSet for BaseType.MineralIdReward[];

    MineTemplatePool public mineTemplatePool;

    constructor (address _mineTemplatePool, address _feeTo, uint256 _expectedBlockDelta) {
        require(_mineTemplatePool != address(0),"Constructor: _mineTemplatePool the zero address");
        require(_feeTo != address(0),"Constructor: _feeTo the zero address");
        mineTemplatePool = MineTemplatePool(_mineTemplatePool);
        feeTo = _feeTo;
        expectedBlockDelta = _expectedBlockDelta;
    }

    modifier isMineFieldPid(uint256 _pid) {
        require(_pid <= mineFieldLength() - 1, "not find this mineField");
        _;
    }

    function mineFieldLength() public view returns (uint256) {
        return mineTemplatePool.mineFieldLength();
    }

    function resetFeeTo(address payable _feeTo) external onlyOwner{
        require(_feeTo != address(0), "ResetFeeTo: _feeTo the zero address");
        address oldFeeTo = feeTo;
        feeTo = _feeTo;

        emit ResetFeeTo(oldFeeTo, _feeTo);
    }

    function addMills(address[] memory _mills) public onlyOwner{
        for(uint256 i=0; i<_mills.length; i++){
            addMill(_mills[i]);
        }
    }

    function addMill(address _mill) internal{
        require(_mill != address(0),"AddMill: _mill the zero address");
        EnumerableSet.add(millSet,_mill);
    }

    function removeMill(address _mill) public onlyOwner{
        EnumerableSet.remove(millSet,_mill);
    }

    function getMillLength() public view returns (uint256){
        return EnumerableSet.length(millSet);
    }

    function getMill(uint256 _index) public view returns (address){
        require(_index <= getMillLength() - 1, "millSet: index out of bounds");
        return EnumerableSet.at(millSet, _index);
    }

    //解锁用户矿坑
    function unlockUserMineField(uint256 _pid, address _user) public payable isMineFieldPid(_pid) nonReentrant whenNotPaused{
        MineField memory mineField = mineTemplatePool.getMineField(_pid);
        CoinValue memory unlockCoin = mineField.unlockCoin;
        require(userMineFieldStateMapping[_user][_pid] == State.UNCULTIVATED, "CULTIVATED");

        if(!mineField.unlock && unlockCoin.value != 0){
            AssetTransfer.coinCost(feeTo, unlockCoin.coin, unlockCoin.value);
        }

        userMineFieldStateMapping[_user][_pid] = State.CULTIVATED;
    }

    //挖矿 0,[0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8,0]
    function mining(uint256 _pid, MillInfo memory _millInfo) public isMineFieldPid(_pid) nonReentrant whenNotPaused{
        address mill = _millInfo.mill;
        uint256 tokenId = _millInfo.tokenId;

        require(EnumerableSet.contains(millSet, mill),"Illegal _millInfo");
        uint256 durability = IMill(mill).getNftAttribute(uint(Attribute.DURABILITY),tokenId);
        require(durability >0, "Lack of durability");

        MineField memory mineField = mineTemplatePool.getMineField(_pid);
        CoinValue memory unlockCoin = mineField.unlockCoin;
        State state = userMineFieldStateMapping[msg.sender][_pid];
        require(mineField.unlock
            || unlockCoin.value == 0
            || state == State.CULTIVATED,"You need to be unlocked!");
        require(state != State.MING, "It is currently being mined!");
        require(millSet.contains(mill),"Illegal mill");

        //矿机质押
        IMill(mill).safeTransferFrom(msg.sender, address(this), tokenId);//质押矿机
        _mining(_pid, _millInfo);
    }

    //查看债务
    function getDebts(uint256 _pid, address _user, uint256 _expectedBlock) external view isMineFieldPid(_pid) returns (UserMineFieldMing memory _userMineFieldMing, CoinDebt memory _coinDebtCost, CoinDebt memory _coinDebtReward, MineralIdDebt[] memory _mineralIdDebts) {
        MineField storage userMineField = userMineFieldMapping[_user][_pid];
        CoinValue storage costCoin = userMineField.costCoin;
        CoinValue storage rewardCoin = userMineField.rewardCoin;
        MineralReward storage mineralReward = userMineField.mineralReward;
        MineralIdReward[] storage mineralIdRewards = mineralReward.mineralIdRewards;

        //用户矿坑与挖矿信息
        _userMineFieldMing = userMineFieldMingMapping[_user][_pid];
        //消耗的代币
        _coinDebtCost = CoinDebt(costCoin.coin, costCoin.value, 0);
        //奖励的代币
        _coinDebtReward = CoinDebt(rewardCoin.coin, rewardCoin.value, 0);
        //奖励的矿产
        _mineralIdDebts = new MineralIdDebt[](mineralIdRewards.length);

        if(userMineFieldStateMapping[_user][_pid] != State.MING){ //未挖矿状态
            return (_userMineFieldMing, _coinDebtCost, _coinDebtReward, _mineralIdDebts); //TODO 修改结构
        }

        //挖矿的开始区块
        uint256 startBlock = _userMineFieldMing.startAt;
        //计算当前区块时有效的可获取收益的区块数
        uint256 validBlock = getValidBlock(_pid, _user);
        //基于有效的区块数算出挖矿结束的区块（最大不会大于当前区块）
        uint256 entBlock = startBlock.add(validBlock);

        //当_expectedBlock = 0时，需要计算的是实际区块债务；当_expectedBlock > 0时，需要计算的是期望区块的债务
        //如果期望区块小于当前区块实际结束区块，有效区块应该等于期望区块减去开始区块，同时期望区块应该要大于挖矿的开始区块并且期望区块只能小于实际区块expectedBlockDelta值
        if(_expectedBlock !=0 && _expectedBlock < entBlock){
            require(_expectedBlock >= startBlock && entBlock.sub(_expectedBlock) <= expectedBlockDelta,"Illegal _expectedBlock");
            validBlock = _expectedBlock.sub(startBlock);
        }

        _coinDebtReward.debt = validBlock.mul(_coinDebtReward.convertRate);
        _coinDebtCost.debt = validBlock.mul(_coinDebtCost.convertRate);
        _userMineFieldMing.endAt = entBlock;

        for(uint256 i = 0; i< mineralIdRewards.length; i++){
            MineralIdReward storage mineralIdReward = mineralIdRewards[i];
            MineralIdDebt memory _mineralIdDebt = MineralIdDebt(mineralIdReward.id
                , mineralIdReward.convertRate
                , validBlock.div(mineralIdReward.convertRate));
            _mineralIdDebts[i] = _mineralIdDebt;
        }

        return (_userMineFieldMing, _coinDebtCost, _coinDebtReward, _mineralIdDebts);
    }

    //返回用户挖矿时，矿机已耗损的耐久度以及剩余耐久度
    function getMillDurability(uint256 _pid, address _user) public view returns(uint256, uint256){
        MineField storage userMineField = userMineFieldMapping[_user][_pid];
        UserMineFieldMing storage userMineFieldMing = userMineFieldMingMapping[_user][_pid];
        MillInfo storage millInfo = userMineFieldMing.millInfo;
        address mill = millInfo.mill;
        uint256 tokenId = millInfo.tokenId;

        uint256 durability = IMill(mill).getNftAttribute(uint(Attribute.DURABILITY),tokenId);
        if(userMineFieldStateMapping[_user][_pid] != State.MING){//未挖矿状态
            return (0, durability);
        }

        uint256 deltaBlock = block.number.sub(userMineFieldMing.startAt);
        uint256 usedDurability = deltaBlock.ceilDiv(userMineField.durabilityRate);//向上取整

        if(durability >= usedDurability){
            return (usedDurability, durability.sub(usedDurability));
        }else{
            return (durability, 0);
        }
    }

    //取消挖矿
    function noMining(uint256 _pid, uint256 _expectedBlock) public payable isMineFieldPid(_pid) nonReentrant{
        require(userMineFieldStateMapping[msg.sender][_pid] == State.MING, "Not Ming");

        UserMineFieldMing storage userMineFieldMing = userMineFieldMingMapping[msg.sender][_pid];
        address mill = userMineFieldMing.millInfo.mill;
        uint256 tokenId = userMineFieldMing.millInfo.tokenId;

        //提取奖励并
        _withdrawRewardsAndRest(_pid,_expectedBlock);
        //解压押矿机
        IMill(mill).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawRewards(uint256 _pid, uint256 _expectedBlock) public payable isMineFieldPid(_pid) nonReentrant{
        require(userMineFieldStateMapping[msg.sender][_pid] == State.MING, "Not Ming");

        UserMineFieldMing storage userMineFieldMing = userMineFieldMingMapping[msg.sender][_pid];
        MillInfo storage millInfo = userMineFieldMing.millInfo;
        address mill = millInfo.mill;
        uint256 tokenId = millInfo.tokenId;

        _withdrawRewardsAndRest(_pid,_expectedBlock);

        MillInfo memory _millInfo = MillInfo(mill,tokenId);
        _mining(_pid, _millInfo);
    }

    function _mining(uint256 _pid, MillInfo memory _millInfo) internal {
        address mill = _millInfo.mill;
        uint256 tokenId = _millInfo.tokenId;
        //创建用户矿坑副本
        _createEctype(_pid, msg.sender);
        MineField storage userMineField = userMineFieldMapping[msg.sender][_pid];
        MillConfig storage millConfig = userMineField.millConfig;

        require(IMill(mill).getNftAttribute(uint(Attribute.GRADE),tokenId) == millConfig.millGradeId
            || IMill(mill).getNftAttribute(uint(Attribute.QUALITY),tokenId) == millConfig.millQualityId
            || IMill(mill).getNftAttribute(uint(Attribute.ATTRIBUTE),tokenId) == millConfig.millAttributeId,"The mill do not match");

        userMineFieldStateMapping[msg.sender][_pid] = State.MING;
        UserMineFieldMing storage userMineFieldMing =  userMineFieldMingMapping[msg.sender][_pid];
        userMineFieldMing.startAt = block.number;
        userMineFieldMing.millInfo = _millInfo;
    }

    //领取奖励并重置相关属性
    function _withdrawRewardsAndRest(uint256 _pid, uint256 _expectedBlock) internal{
        UserMineFieldMing storage userMineFieldMing = userMineFieldMingMapping[msg.sender][_pid];
        MillInfo storage millInfo = userMineFieldMing.millInfo;
        address mill = millInfo.mill;
        uint256 tokenId = millInfo.tokenId;

        //提取奖励
        _withdrawRewards(_pid, _expectedBlock);

        //重置耐久度
        (, uint256 surplusDurability) = getMillDurability(_pid, msg.sender);
        IMill(mill).setNftAttribute(uint256(Attribute.DURABILITY), tokenId, surplusDurability);

        //重新初始化
        delete userMineFieldMapping[msg.sender][_pid];
        delete userMineFieldMingMapping[msg.sender][_pid];
        userMineFieldStateMapping[msg.sender][_pid] = State.CULTIVATED;
    }

    //领取奖励
    function _withdrawRewards(uint256 _pid, uint256 _expectedBlock) internal{
        require(userMineFieldStateMapping[msg.sender][_pid] == State.MING, "Not Ming");

        //计算所有债务
        (,CoinDebt memory coinDebtCost
        , CoinDebt memory coinDebtReward
        , MineralIdDebt[] memory mineralIdDebts) = this.getDebts(_pid, msg.sender,_expectedBlock);

        //消耗电力代币
        AssetTransfer.coinCost(feeTo, coinDebtCost.coin, coinDebtCost.debt);
        //奖励代币
        AssetTransfer.coinReward(msg.sender, coinDebtReward.coin, coinDebtReward.debt);
        //奖励矿产
        MineField storage userMineField = userMineFieldMapping[msg.sender][_pid];
        MineralReward storage mineralReward = userMineField.mineralReward;
        AssetTransfer.mineralReward(msg.sender, address(mineralReward.mineral), mineralIdDebts);
    }

    function withdrawAsset(address _asset, address _to) public{
        require(_to != address(0),"WithdrawAsset: _to the zero address");
        uint256 amount = _asset == address(0) ? _asset.balance : IERC20(_asset).balanceOf(address(this));
        if(amount >0){
            AssetTransfer.coinReward(_to, _asset, amount);
        }
    }

    //创建用户矿坑副本
    function _createEctype(uint256 _pid, address _user) internal {
        //清空用户矿坑副本
        delete userMineFieldMapping[_user][_pid];

        MineField storage userMineField = userMineFieldMapping[_user][_pid];
        CoinValue storage costCoin = userMineField.costCoin;
        CoinValue storage rewardCoin = userMineField.rewardCoin;
        MillConfig storage millConfig = userMineField.millConfig;
        MineralReward storage mineralReward = userMineField.mineralReward;
        MineralIdReward[] storage mineralIdRewards = mineralReward.mineralIdRewards;

        MineField memory _mineField = mineTemplatePool.getMineField(_pid);
        MillConfig memory _millConfig = _mineField.millConfig;
        CoinValue memory _costCoin = _mineField.costCoin;
        CoinValue memory _rewardCoin = _mineField.rewardCoin;

        userMineField.mineId = _mineField.mineId;
        userMineField.durabilityRate = _mineField.durabilityRate;

        costCoin.coin = _costCoin.coin;
        costCoin.value = _costCoin.value;
        rewardCoin.coin = _rewardCoin.coin;
        rewardCoin.value = _rewardCoin.value;
        millConfig.millAttributeId = _millConfig.millAttributeId;
        millConfig.millQualityId = _millConfig.millQualityId;
        millConfig.millGradeId = _millConfig.millGradeId;

        MineralReward memory _mineralReward = _mineField.mineralReward;
        MineralIdReward[] memory _mineralIdRewards = _mineralReward.mineralIdRewards;
        //重置矿产地址
        mineralReward.mineral = _mineralReward.mineral;
        //重置挖出的矿产集合
        StructSet.pushMineralIdRewards(mineralIdRewards,_mineralIdRewards);
    }

    //计算当前区块时有效的可获取收益的区块数
    function getValidBlock(uint256 _pid, address _user) public view returns(uint256){
        State state = userMineFieldStateMapping[_user][_pid];
        if(State.MING != state){
            return 0;
        }

        MineField storage userMineField = userMineFieldMapping[_user][_pid];
        UserMineFieldMing storage userMineFieldMing = userMineFieldMingMapping[_user][_pid];

        (uint256 usedDurability, ) = getMillDurability(_pid,_user);
        uint256 effectiveBlock = userMineField.durabilityRate.mul(usedDurability);
        uint256 deltaBlock = block.number.sub(userMineFieldMing.startAt);
        return deltaBlock > effectiveBlock ? effectiveBlock : deltaBlock;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MineEctypePool.sol";
import "./asset/interfaces/IMill.sol";
import "./asset/interfaces/IMineral.sol";

contract MineLens {

    struct MinePoolBaseInfo{
        bool paused;
        uint256 mineFieldLength;
    }

    function getMinePoolBaseInfo(MineEctypePool _pool) public view returns(MinePoolBaseInfo memory){
       uint256 len =  _pool.mineFieldLength();
        return MinePoolBaseInfo({
            paused: _pool.paused(),
            mineFieldLength: len
        });
    }

    struct UserMineFieldBaseInfo {
        uint256 mineId;//矿场ID
        uint256 durabilityRate;//耐久度损耗率 eg:200个区块消耗1个耐久度
        uint256 state;//状态：0：未开垦、1：已开垦、2：挖矿中
        BaseType.CoinValue costCoin;//消耗代币，value值为单位区块消耗代币数量，eg:每个区块消耗5个电力代币
        BaseType.CoinValue rewardCoin;//奖励代币，value值为单位区块奖励代币数量，eg：每个区块奖励5个代币
        BaseType.MillConfig millConfig;//矿机配置
    }

    function getUserMineFieldBaseInfo(MineEctypePool _pool, uint256 _pid, address _user) public view returns(UserMineFieldBaseInfo memory ){
        (uint256 _mineId
        , uint256 _durabilityRate
        ,
        ,
        , BaseType.CoinValue memory _costCoin
        , BaseType.CoinValue memory _rewardCoin
        , BaseType.MillConfig memory _millConfig
        ,) = _pool.userMineFieldMapping(_user,_pid);

        return UserMineFieldBaseInfo({
            mineId: _mineId,
            durabilityRate: _durabilityRate,
            state: uint256(_pool.userMineFieldStateMapping(_user,_pid)),
            costCoin: _costCoin,
            rewardCoin: _rewardCoin,
            millConfig: _millConfig
        });
    }

    struct UserMineFieldMingInfo{
        uint256 startAt;//开始区块
        uint256 endAt;//结束区块
        MillInfo millInfo;
    }

    struct MillInfo{
        IMill mill;//矿机
        uint256 tokenId;//矿机ID
        uint256 usedDurability;//已使用耐久度
        uint256 surplusDurability;//剩余耐久度
    }

//    function getUserMineFieldMingInfo(MinePool _pool, uint256 _pid, address _user) public view returns(UserMineFieldMingInfo memory, MinePool.CoinDebt memory, MinePool.CoinDebt memory, MinePool.MineralIdDebt[] memory){
//        (MinePool.UserMineFieldMing memory _userMineFieldMing
//        , MinePool.CoinDebt memory _coinDebtConsumer
//        , MinePool.CoinDebt memory _coinDebtOutput
//        , MinePool.MineralIdDebt[] memory _mineralDebts) = _pool.getDebts(_pid,_user,0);
//
//        (uint256 _usedDurability, uint256 _surplusDurability) = _pool.getMillDurability(_pid,_user);
////        MillInfo memory _millInfo = MillInfo(_userMineFieldMing.millInfo.mill, _userMineFieldMing.millInfo.tokenId, _usedDurability, _surplusDurability);
//        UserMineFieldMingInfo memory _userMineFieldMingInfo = UserMineFieldMingInfo(_userMineFieldMing.startAt, _userMineFieldMing.endAt, MillInfo(_userMineFieldMing.millInfo.mill, _userMineFieldMing.millInfo.tokenId, _usedDurability, _surplusDurability));
//
//        return (_userMineFieldMingInfo, _coinDebtConsumer, _coinDebtOutput, _mineralDebts);
//    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IMineTemplatePool.sol";
import "./utils/StructSet.sol";
//import "hardhat/console.sol";

contract MineTemplatePool is IMineTemplatePool,Ownable,ReentrancyGuard{

    using StructSet for BaseType.MineralIdReward[];

    modifier isMineFieldPid(uint256 _pid) {
        require(_pid <= mineFieldLength() - 1, "not find this mineField");
        _;
    }

    function mineFieldLength() public view returns (uint256) {
        return mineFields.length;
    }

    function getMineField(uint256 _pid) public view isMineFieldPid(_pid) returns(MineField memory){
        return mineFields[_pid];
    }

    //管理员增加矿坑
    //[11,21,true,[0x0000000000000000000000000000000000000000,2001],[0x0000000000000000000000000000000000000000,2001],[0x0000000000000000000000000000000000000000,2001],[11,21,31],[0x0000000000000000000000000000000000000000,[[11,31],[21,51]]]]
    function addMineField(MineField memory _mineField)  public onlyOwner nonReentrant returns(uint256){
        MineField storage mineField = mineFields.push();
        uint256 _pid = mineFieldLength()-1;
        _resetMineField(mineField, _mineField);
        return _pid;
    }

    //每个区块消耗2001个电力代币、每个区块产生301个奖励代币、每3个区块消耗一个耐久度、---每4个区块奖励矿产a 1个，每6个区块奖励矿产b 1个
    //0,[1,2,false,[0x4b6b9f3695205c8468ddf9ab4025ec2a09bdff1a,2000],[0x4b6b9f3695205c8468ddf9ab4025ec2a09bdff1a,2000],[0x4b6b9f3695205c8468ddf9ab4025ec2a09bdff1a,2000],[1,2,3],[0x4b6b9f3695205c8468ddf9ab4025ec2a09bdff1a,[[1,3],[2,5]]]]
    function updateMineField(uint256 _pid, MineField memory _mineField) public isMineFieldPid(_pid) onlyOwner nonReentrant{
        delete mineFields[_pid];
        MineField storage mineField = mineFields[_pid];
        _resetMineField(mineField, _mineField);
    }

    //重置矿产坑位
    function _resetMineField(MineField storage mineField, MineField memory _mineField) internal{
        mineField.mineId = _mineField.mineId;
        mineField.unlock = _mineField.unlock;
        mineField.durabilityRate = _mineField.durabilityRate;

        CoinValue storage unlockCoin = mineField.unlockCoin;
        CoinValue storage costCoin = mineField.costCoin;
        CoinValue storage rewardCoin = mineField.rewardCoin;
        MillConfig storage millConfig = mineField.millConfig;
        MineralReward storage mineralReward = mineField.mineralReward;
        MineralIdReward[] storage mineralIdRewards = mineralReward.mineralIdRewards;

        CoinValue memory _unlockCoin = _mineField.unlockCoin;
        CoinValue memory _costCoin = _mineField.costCoin;
        CoinValue memory _rewardCoin = _mineField.rewardCoin;
        MillConfig memory _millConfig = _mineField.millConfig;
        MineralReward memory _mineralReward = _mineField.mineralReward;
        MineralIdReward[] memory _mineralIdRewards = _mineralReward.mineralIdRewards;

        unlockCoin.coin = _unlockCoin.coin;
        unlockCoin.value = _unlockCoin.value;
        costCoin.coin = _costCoin.coin;
        costCoin.value = _costCoin.value;
        rewardCoin.coin = _rewardCoin.coin;
        rewardCoin.value = _rewardCoin.value;
        millConfig.millAttributeId = _millConfig.millAttributeId;
        millConfig.millQualityId = _millConfig.millQualityId;
        millConfig.millGradeId = _millConfig.millGradeId;
        //重置挖出的矿产集合
        mineralReward.mineral = _mineralReward.mineral;
        StructSet.pushMineralIdRewards(mineralIdRewards, _mineralIdRewards);
    }
}

pragma solidity ^0.8.4;


contract MyNFT{


    address public a = address(0x3Ac38Be76a80980cd64F84dFCacF035dC6909129);

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function checkOrder(string memory value,Sig memory sig) public view returns(bool){
        bytes32 hash = getEthSignedMessageHash(getMessageHash(value));
        address admin = recover(hash,sig.v,sig.r,sig.s);
        bool result = false;
        if(admin == a ){
            result  = true;
        }

    }


    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }
    //进行两次hash 运算是因为在今天的数学界，进行一次hash运算的结果已经有可能被破解
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                _messageHash
            ));
    }

    function recover(bytes32 _ethSignedMessageHash, uint8 v,bytes32 r,bytes32 s)
    public pure returns (address)
    {
        //ecrecover 是solidity自带函数，会反回还原之后的地址
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../types/MillFactoryType.sol";

contract MillFactoryStorage is MillFactoryType{

    address public feeTo;//手续费地址

    //mill=>CompositionConfig
    mapping(address =>CompositionConfig) public compositionConfigMapping;//合成配置
    //mill=>RepairConfig
    mapping(address =>RepairConfig) public repairConfigMapping;//维修配置
    //mill=>tokenId=>repairTimes
    mapping(address =>mapping(uint256 => uint256)) public repairTimesMapping;//维修次数

    EnumerableSet.AddressSet internal millSet;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../types/MineEctypePoolType.sol";

contract MineEctypePoolStorage is MineEctypePoolType{

    address public feeTo;//手续费地址
    uint256 public expectedBlockDelta;//期望区块差，解除质押时，实际区块减去期望区块的差值

    mapping(address => mapping(uint256 => MineField)) public userMineFieldMapping;//用户与矿坑映射
    mapping(address => mapping(uint256 => State)) public userMineFieldStateMapping;//用户矿坑与状态映射
    mapping(address => mapping(uint256 => UserMineFieldMing)) public userMineFieldMingMapping;//用户矿坑与挖矿信息映射

    MineField[] public mineFields;//矿场坑位集合
    EnumerableSet.AddressSet internal millSet;//矿机集合
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../types/MineTemplatePoolType.sol";

contract MineTemplatePoolStorage is MineTemplatePoolType{
    MineField[] public mineFields;//矿场坑位集合
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../asset/interfaces/IMineral.sol";
import "../asset/interfaces/IMill.sol";

contract BaseType {

    struct Signature {
        uint256 v;
        bytes32 r;
        bytes32 s;
    }

    struct MillConfig{
        uint256 millAttributeId;//矿机属性ID
        uint256 millQualityId;//矿机品质ID
        uint256 millGradeId;//矿机级别ID
    }

    struct CoinValue{
        address coin;
        uint256 value;
    }

    struct MineralReward {//矿产产出结构体
        IMineral mineral;
        MineralIdReward[] mineralIdRewards;
    }

    struct MineralIdReward {//矿产产出结构体
        uint256 id;//矿产Id信息
        uint256 convertRate;//产出速率 eg:每个区块奖励5个矿产
    }

    struct CoinDebt {//代币债务结构体
        address coin;//奖励代币地址
        uint256 convertRate;//转化率
        uint256 debt;//待处理债务
    }

    struct MineralDebt {//矿产债务结构体
        IMineral mineral;//矿产
        MineralIdDebt[] mineralIdDebts;
    }

    struct MineralIdDebt {//矿产债务结构体
        uint256 id;//矿产Id信息
        uint256 convertRate;//转化率
        uint256 debt;//待处理债务
    }

    enum Attribute {
        ATTRIBUTE,//属性
        QUALITY,//质量
        GRADE,//等级
        DURABILITY,//耐久度
        INIT_DURABILITY//初始耐久度
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BaseType.sol";

contract MillFactoryType is BaseType{

    struct MillInfo{//矿机信息结构体
        address mill;//矿机
        uint256 tokenId;//矿机ID集合
    }

    struct MillInfos{//矿机信息结构体
        address mill;//矿机
        uint256[] tokenIds;//矿机ID集合
    }

    struct RepairConfig{
        uint256 maxRepairTimes;
        CoinValue repairCoin;
        MineralCost mineralCost;
    }

    struct CompositionConfig{
        uint256 consumeMillAmount;
        address compositionMill;
        CoinValue compositionCoin;
        MineralCost mineralCost;
    }

    struct MineralCost {//矿产消耗结构体
        address mineral;//矿产地址
        MineralIdCost[] mineralIdCost;//矿产Id
    }

    struct MineralIdCost {//矿产Id消耗结构体
        uint256 id;//矿产ID
        uint256 firstCost;//初始消耗 eg:消耗5个矿产
        uint256 stepCost;//步长消耗，每增加一次维修则增加 N*stepCost，即最终消耗 = firstCost+N*stepCost
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseType.sol";
import "./MineTemplatePoolType.sol";

contract MineEctypePoolType is MineTemplatePoolType{

    struct MillInfo{//矿机信息结构体
        address mill;//矿机
        uint256 tokenId;//矿机ID
    }

    struct UserMineFieldMing {//用户坑位挖矿结构体
        uint256 startAt;//开始区块
        uint256 endAt;//结束区块
        MillInfo millInfo;//矿机信息
    }

    enum State {
        UNCULTIVATED,//未开垦的
        CULTIVATED,//已开垦的(已初始化/已初始化并解锁)
        MING//挖矿中
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseType.sol";

contract MineTemplatePoolType is BaseType{

    struct MineField{//矿场坑位结构体
        uint256 mineId;//矿场ID
        uint256 durabilityRate;//耐久度损耗率 eg:200个区块消耗1个耐久度
        bool unlock;//开启状态

        CoinValue unlockCoin;//解锁代币，value值为数量，
        CoinValue costCoin;//消耗代币，value值为单位区块消耗代币数量，eg:每个区块消耗5个电力代币
        CoinValue rewardCoin;//奖励代币，value值为单位区块奖励代币数量，eg：每个区块奖励5个代币
        MillConfig millConfig;//矿机配置
        MineralReward mineralReward;//挖出的矿产
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../asset/interfaces/IMineral.sol";
import "../types/BaseType.sol";

library AssetTransfer {

    function coinCost(address to, address coin, uint256 amount) internal{
        if(amount == 0 ){
            return;
        }
        if(coin == address(0)){//平台币
            require(msg.value >= amount, "The ether value sent is not correct");
            payable(to).transfer(msg.value);
        }else{
            IERC20(coin).transferFrom(msg.sender, to, amount);
        }
    }

    function coinReward(address to,address coin, uint256 amount) internal{
        if(amount == 0 ){
            return;
        }
        if(coin == address(0)){//平台币
            payable(to).transfer(amount);
        }else{
            IERC20(coin).transfer(to, amount);
        }
    }

    function mineralCost(address to, address mineral, BaseType.MineralIdDebt[] memory mineralIdDebts) internal{
        (uint256[] memory ids, uint256[] memory amounts) = parseMineralIdDebts(mineralIdDebts);
        IMineral(mineral).safeBatchTransferFrom(msg.sender,to ,ids,amounts,"");
    }

    function mineralReward(address to, address mineral, BaseType.MineralIdDebt[] memory mineralIdDebts) internal{
        (uint256[] memory ids, uint256[] memory amounts) = parseMineralIdDebts(mineralIdDebts);
        IMineral(mineral).mintTokenIdWithWitelist(to, ids, amounts); //铸造矿产
    }

    function parseMineralIdDebts(BaseType.MineralIdDebt[] memory mineralIdDebts) private pure returns(uint256[] memory,uint256[] memory){
        uint256 len = mineralIdDebts.length;
        uint256[] memory ids = new uint256[](len);
        uint256[] memory amounts = new uint256[](len);
        for(uint256 i= 0; i < len; i++){
            BaseType.MineralIdDebt memory mineralIdDebt = mineralIdDebts[i];
            uint256 id = mineralIdDebt.id;
            uint256 amount = mineralIdDebt.debt;
            if(amount == 0){
                continue;
            }
            ids[i] = id;
            amounts[i] = amount;
        }

        return (ids, amounts);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../types/BaseType.sol";

library StructSet {

    function pushMineralIdRewards(BaseType.MineralIdReward[] storage mineralIdRewards, BaseType.MineralIdReward[] memory _mineralIdRewards) internal{
        uint256 _len = _mineralIdRewards.length;
        for(uint256 i=0; i< _len; i++){
            BaseType.MineralIdReward memory _mineralIdReward = _mineralIdRewards[i];
            mineralIdRewards.push(BaseType.MineralIdReward({
                id: _mineralIdReward.id,
                convertRate: _mineralIdReward.convertRate
            }));
        }
    }
}