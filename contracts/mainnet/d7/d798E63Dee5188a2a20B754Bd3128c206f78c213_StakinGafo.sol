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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "./WithdrawableOwnable.sol";

// @dev Custom errors
error DefaultPairUpdated();
error AccountAlreadyExcluded();
error AccountAlreadyIncluded();
error SettingZeroAddress();
error AddressAlreadySet();
error TransferError();
error TransferFromZeroAddress();
error TransferToZeroAddress();
error NoAmount();
error MaxSellAmountExceeded(uint256 amount);
error MaxBuyFeeExceeded(uint256 amount);
error MaxSellFeeExceeded(uint256 amount);
error MaxSellAmountTooLow(uint256 amount);

contract MafaCoin is ERC20, WithdrawableOwnable {
    // @dev the fee the development takes on buy txs.
    uint256 public developmentBuyFee = 1 * 10**16; // 1%

    // @dev the fee the development takes on sell txs.
    uint256 public developmentSellFee = 1 * 10**16; // 1%

    // @dev which wallet will receive the development fee
    address public developmentAddress = 0x056f3E1B30797a122447581d0F34CD69E9A26690;

    // @dev the fee the liquidity takes on buy txs.
    uint256 public liquidityBuyFee = 1 * 10**16; // 1%

    // @dev the fee the liquidity takes on sell txs.
    uint256 public liquiditySellFee = 1 * 10**16; // 1%

    // @dev which wallet will receive the cake tokens from liquidity.
    address public liquidityAddress = 0xc76280a36743E1266dC73F114bB1c9950ee37E7c;

    // @dev the fee the marketing takes on buy txs.
    uint256 public marketingBuyFee = 2 * 10**16; // 2%

    // @dev the fee the marketing takes on sell txs.
    uint256 public marketingSellFee = 2 * 10**16; // 2%

    // @dev which wallet will receive the marketing fee
    address public marketingAddress = 0x272C14981F2Ff4fF06F5EF326940E7F067b4b5D6;

    // @dev maximum amount that buy fees added together can be raised to
    uint256 public constant MAX_BUY_FEE = 10 * 10**16; // 10%;

    // @dev maximum amount that sell fees added together can be raised to
    uint256 public constant MAX_SELL_FEE = 10 * 10**16; // 10%;

    // @dev minimum amount of tokens acumulated in the contract to take fee on sell txs
    uint256 public constant MIN_TAKE_FEE = 20000 * 10**18;

    // @dev maximum amount of tokens a user can sell on a single transaction (antidump mechanism)
    uint256 public maxSellAmount = 100000 * 10**18;

    // @dev minimum value that can be set for antidump mechanism
    uint256 public constant MIN_ANTI_DUMP_LIMIT = 10000 * 10**18;

    // @dev the defauld dex router
    IUniswapV2Router02 public immutable dexRouter;

    // @dev the default dex pair
    address public immutable dexPair;

    // @dev mapping of excluded from fees elements
    mapping(address => bool) public isExcludedFromFees;

    // @dev what pairs are allowed to work in the token
    mapping(address => bool) public automatedMarketMakerPairs;

    constructor(
        string memory name,
        string memory symbol,
        uint256 tSupply // totalSupply
    ) ERC20(name, symbol) {
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[owner()] = true;

        _mint(owner(), tSupply);

        // Create a uniswap pair for this new token
        dexRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        dexPair = IUniswapV2Factory(dexRouter.factory()).createPair(address(this), dexRouter.WETH());
        _setAutomatedMarketMakerPair(dexPair, true);
    }

    receive() external payable {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // @dev sets an AMM pair to check fees upon
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        if (pair == dexPair) revert DefaultPairUpdated();

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    // @dev exclude an account from fees
    function excludeFromFees(address account) public onlyOwner {
        if (isExcludedFromFees[account]) revert AccountAlreadyExcluded();

        isExcludedFromFees[account] = true;
        emit ExcludeFromFees(account);
    }

    // @dev include an account in fees
    function includeInFees(address account) public onlyOwner {
        if (!isExcludedFromFees[account]) revert AccountAlreadyIncluded();

        isExcludedFromFees[account] = false;
        emit IncludeInFees(account);
    }

    function setDevelopmentAddress(address newAddress) external onlyOwner {
        if (newAddress == address(0)) revert SettingZeroAddress();
        if (developmentAddress == newAddress) revert AddressAlreadySet();

        developmentAddress = newAddress;
        emit DevelopmentAddressUpdated(newAddress);
    }

    function setDevelopmentBuyFee(uint256 newFee) external onlyOwner {
        checkBuyFeesChanged(newFee, developmentBuyFee);

        developmentBuyFee = newFee;
        emit DevelopmentFeeUpdated(newFee);
    }

    function setDevelopmentSellFee(uint256 newFee) external onlyOwner {
        checkSellFeesChanged(newFee, developmentSellFee);

        developmentSellFee = newFee;
        emit DevelopmentFeeUpdated(newFee);
    }

    function setMarketingAddress(address newAddress) external onlyOwner {
        if (newAddress == address(0)) revert SettingZeroAddress();
        if (marketingAddress == newAddress) revert AddressAlreadySet();

        marketingAddress = newAddress;
        emit MarketingAddressUpdated(newAddress);
    }

    function setMarketingBuyFee(uint256 newFee) external onlyOwner {
        checkBuyFeesChanged(newFee, marketingBuyFee);

        marketingBuyFee = newFee;
        emit MarketingFeeUpdated(newFee);
    }

    function setMarketingSellFee(uint256 newFee) external onlyOwner {
        checkSellFeesChanged(newFee, marketingSellFee);

        marketingSellFee = newFee;
        emit MarketingFeeUpdated(newFee);
    }

    function setLiquidityAddress(address newAddress) external onlyOwner {
        if (newAddress == address(0)) revert SettingZeroAddress();
        if (liquidityAddress == newAddress) revert AddressAlreadySet();

        liquidityAddress = newAddress;
        emit LiquidityAddressUpdated(newAddress);
    }

    function setLiquidityBuyFee(uint256 newFee) external onlyOwner {
        checkBuyFeesChanged(newFee, liquidityBuyFee);

        liquidityBuyFee = newFee;
        emit LiquidityFeeUpdated(newFee);
    }

    function setLiquiditySellFee(uint256 newFee) external onlyOwner {
        checkSellFeesChanged(newFee, liquiditySellFee);

        liquiditySellFee = newFee;
        emit LiquidityFeeUpdated(newFee);
    }

    function checkBuyFeesChanged(uint256 newFee, uint256 oldFee) internal view {
        uint256 fees = totalBuyFees() + newFee - oldFee;

        if (fees > MAX_BUY_FEE) revert MaxBuyFeeExceeded(fees);
    }

    function checkSellFeesChanged(uint256 newFee, uint256 oldFee) internal view {
        uint256 fees = totalSellFees() + newFee - oldFee;

        if (fees > MAX_SELL_FEE) revert MaxSellFeeExceeded(fees);
    }

    // @dev just to simplify to the user, the total fees on buy
    function totalBuyFees() public view returns (uint256) {
        return developmentBuyFee + liquidityBuyFee + marketingBuyFee;
    }

    // @dev just to simplify to the user, the total fees on sell
    function totalSellFees() public view returns (uint256) {
        return developmentSellFee + liquiditySellFee + marketingSellFee;
    }

    function setMaxSellAmount(uint256 amount) external onlyOwner {
        if (amount < MIN_ANTI_DUMP_LIMIT) revert MaxSellAmountTooLow(amount);

        maxSellAmount = amount;
        emit MaxSellAmountUpdated(amount);
    }

    function _takeFeeInBNB() internal {
        uint256 amount = balanceOf(address(this));

        uint256 developmentFee = developmentSellFee;
        uint256 liquidityFee = liquiditySellFee;
        uint256 marketingFee = marketingSellFee;

        if (amount == 0 || (developmentFee == 0 && liquidityFee == 0 && marketingFee == 0)) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), amount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp);

        uint256 bnbAmount = address(this).balance - balanceBefore;

        (bool success, ) = payable(developmentAddress).call{
            value: (bnbAmount * developmentFee) / (developmentFee + liquidityFee + marketingFee)
        }("");
        if (!success) revert TransferError();

        (success, ) = payable(liquidityAddress).call{
            value: (bnbAmount * liquidityFee) / (developmentFee + liquidityFee + marketingFee)
        }("");
        if (!success) revert TransferError();

        (success, ) = payable(marketingAddress).call{
            value: (bnbAmount * marketingFee) / (developmentFee + liquidityFee + marketingFee)
        }("");
        if (!success) revert TransferError();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(0)) revert TransferFromZeroAddress();
        if (to == address(0)) revert TransferToZeroAddress();
        if (amount == 0) revert NoAmount();

        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
        } else {
            uint256 tokensToDevelopment = 0;
            uint256 tokensToLiquidity = 0;
            uint256 tokensToMarketing = 0;
            uint256 finalAmount = 0;

            // automatedMarketMakerPairs[from] -> buy tokens on dex
            // automatedMarketMakerPairs[to]   -> sell tokens on dex
            if (automatedMarketMakerPairs[to]) {
                if (amount > maxSellAmount) revert MaxSellAmountExceeded(amount);

                uint256 developmentFee = developmentSellFee;
                uint256 liquidityFee = liquiditySellFee;
                uint256 marketingFee = marketingSellFee;
                uint256 tokensToContract = (amount * (developmentSellFee + liquiditySellFee + marketingSellFee)) /
                    10**decimals();

                if (tokensToContract > 0) super._transfer(from, address(this), tokensToContract);
                if (developmentFee > 0) tokensToDevelopment = (amount * developmentFee) / 10**decimals();
                if (liquidityFee > 0) tokensToLiquidity = (amount * liquidityFee) / 10**decimals();
                if (marketingFee > 0) tokensToMarketing = (amount * marketingFee) / 10**decimals();

                if (balanceOf(address(this)) >= MIN_TAKE_FEE) {
                    _takeFeeInBNB();
                }
            } else if (automatedMarketMakerPairs[from]) {
                uint256 developmentFee = developmentBuyFee;
                if (developmentFee > 0) {
                    tokensToDevelopment = (amount * developmentFee) / 10**decimals();
                    super._transfer(from, developmentAddress, tokensToDevelopment);
                }

                uint256 liquidityFee = liquidityBuyFee;
                if (liquidityFee > 0) {
                    tokensToLiquidity = (amount * liquidityFee) / 10**decimals();
                    super._transfer(from, liquidityAddress, tokensToLiquidity);
                }

                uint256 marketingFee = marketingBuyFee;
                if (marketingFee > 0) {
                    tokensToMarketing = (amount * marketingFee) / 10**decimals();
                    super._transfer(from, marketingAddress, tokensToMarketing);
                }
            }

            finalAmount = amount - tokensToDevelopment - tokensToLiquidity - tokensToMarketing;
            super._transfer(from, to, finalAmount);
        }
    }

    event ExcludeFromFees(address indexed account);
    event IncludeInFees(address indexed account);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event DevelopmentAddressUpdated(address indexed developmentAddress);
    event DevelopmentFeeUpdated(uint256 indexed fee);
    event LiquidityAddressUpdated(address indexed liquidityAddress);
    event LiquidityFeeUpdated(uint256 indexed fee);
    event MarketingAddressUpdated(address indexed marketingAddress);
    event MarketingFeeUpdated(uint256 indexed fee);
    event MaxSellAmountUpdated(uint256 indexed amount);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./mafacoin.sol";

/**
 * @title StakinGafo
 * @author Sozei / Studio Web3
 * 
 * @notice Coordinates the creation of MafaCoins Staking
 * @dev All Staking focuses on 3 main functions
 * 
 * 1. Staking
 * 1.1 stakingOne
 * 1.2 stakingTwo
 * 2. Claim
 * 2.1 claimOne
 * 2.2 claimTwo
 * 3. Revoke
 * 3.1 revokeOne
 * 3.2 revokeTwo
 * 
 */


contract StakinGafo is Ownable, Pausable, ERC20, ERC20Burnable{

    /**
     * @dev structure with all the characteristics that a stake has
     */

    /// StakingOne structure
    struct StakingOne {
        uint256 id;
        uint256 totalStaked;
        address staker;
        uint256 timeStamp;
        uint256 deadLine;
        bool stakingComplete;
        bool cancelled;
        uint256 lastRewards;
        string teleg;
    }

    /// StakingTwo structure
    struct StakingTwo { 
        uint256 id;
        uint256 totalStaked;
        address staker;
        uint256 timeStamp;
        uint256 deadLine;
        bool stakingComplete;
        bool cancelled;
        uint256 lastRewards;
        string teleg;
    }

    /// StakerHolder structure
    struct StakerHolder { 
        address stakerAdd;
        string telegram;
    }

    /**
     * @dev list of wallets that have staked
     */

    /// list stakingOne
    mapping(address => StakingOne) public vaultOne; 

    /// list stakingTwo
    mapping(address => StakingTwo) public vaultTwo; 

    /// list telegram of StakeHolders
    StakerHolder[] public stakeHolders;

    /// main owner address
    address public _owner;

    /// secondary owner address
    address public _ownerTwo;

    /// mafacoin address
    MafaCoin public mafacoin = MafaCoin(payable(0x6Dd60AFB2586D31Bf390450aDf5E6A9659d48c4A)); 

    /// minimum amount of tokens for StakingOne
    uint256 public tokensOne = 10000; 

    /// minimum tokens for StakingOne with decimals
    uint256 public minTokensOne = tokensOne*10**18; 

    /// minimum amount of tokens for StakingTwo
    uint256 public tokensTwo = 10000; 

    /// minimum tokens for StakingTwo with decimals
    uint256 public minTokensTwo = tokensTwo*10**18; 

    /// monthly yeld in %
    uint256 public yield = 240; 

    /// daily yeld in %
    uint256 public yieldDay = (yield*10**16) / 30;

    /// stakingOne completion time in days
    uint256 public stakingOneDL = 90; 

    /// stakingOne completion time in days
    uint256 public stakingTwoDL = 180; 

    /// minimum time in days for cancellation
    uint256 public minDays = 30; 

    /// penalty in case of cancellation
    uint256 public penalty = 1; 

    /// mafacoins deposit balance for the this contract
    uint256 public rewardsBank = 0; 

    /// maximum limit of tokens in staking
    uint256 public maxTotal = 25000000; 

    /// maximum limit of tokens in staking with decimals
    uint256 public maxStaking = maxTotal*10**18; 

    /// total contract staking balance
    uint256 public totalAmountStaked = 0; 

    /// total balance of mafacoins in the contract
    uint256 public balanceMafa = 0; 
    
    /// total number of users who have staked
    uint256 public totalStakers; 

    /// maximum limit amount withdraw
    uint256 public maxAmountWithdraw = 1000000*10**18;

    /** Events */

    event UpdateMinTokensOne(address indexed _wallet, uint256 _newMinTokens);
    event UpdateMinTokensTwo(address indexed _wallet, uint256 _newMinTokens);
    event UpdateYeld(address indexed _wallet, uint256 _newYeld);
    event UpdateStkOneDL(address indexed _wallet, uint256 _newDeadLineOne);
    event UpdateStkTwoDL(address indexed _wallet, uint256 _newDeadLineTwo);
    event UpdateMinDays(address indexed _wallet, uint256 _newMinDays);
    event UpdatePenalty(address indexed _wallet, uint256 _newPenalty);
    event UpdateMaxStaking(address indexed _wallet, uint256 _newMax);
    event Staking(address indexed _wallet, uint256 _Tokens, string indexed _WalletTelegram);
    event ReStaking(address indexed _wallet, uint256 _Tokens, string indexed _WalletTelegram);
    event Claim(address indexed _wallet, uint256 _Tokens, string indexed _WalletTelegram);
    event Revoke(address indexed _wallet, string indexed _WalletTelegram);
    event DepositBank(uint256 indexed _mafaDeposit);
    event WithDrawBank(address indexed _wallet, uint256 _totalWithDraw);
    event Pause(address indexed _wallet, bool _pause);
    event UnPause(address indexed _wallet, bool _pause);
    event NewOwner(address indexed _wallet, address _newOwner);
    event NewSupport(address indexed _wallet, address _newSupport);

    /** Constructor */
    
    constructor(address ownerTwo, address _mafacoin) payable ERC20("StakinGafoCoin", "STG") {
        _owner = msg.sender;
        _ownerTwo = ownerTwo;
        mafacoin =  MafaCoin(payable(_mafacoin));
    }
    
    /** Staking Functions */

    /**
     * @notice public function that creates the StakingOne for the user
     * @return stakeID returns the staking id
     * @param _tokens amount of token the user will stake (amount with decimals)
     * @param _telegram @ from telegram for registration
     */
    function stakingOne(uint256 _tokens, string memory _telegram) public whenNotPaused returns (uint256 stakeID) {
        require(vaultOne[msg.sender].stakingComplete == false, "You have already claimed your staking");
        require(vaultOne[msg.sender].cancelled == false, "You already canceled your staking");
        require(_tokens + totalAmountStaked <= maxStaking, "The maximum staking amount has been reached"); 
        require(_tokens >= minTokensOne, "Your Staking needs to be at least 10000 MafaCoins");
        require(mafacoin.balanceOf(msg.sender) >= _tokens, "You don't have enough Mafacoin balance");
        require(mafacoin.allowance(msg.sender, address(this)) >= _tokens, "You need to approve the total amount of Mafacoin you want to staking");
        require(mafacoin.transferFrom(msg.sender, address(this), _tokens), "Staking has not been completed");
        totalAmountStaked += _tokens;

        addStakeholder(msg.sender, _telegram);

        if(vaultOne[msg.sender].staker == msg.sender){
            uint256 amount = vaultOne[msg.sender].totalStaked;
            uint256 daysInStaking = (block.timestamp - vaultOne[msg.sender].timeStamp) / 86400; 
            uint256 totalPercent = (daysInStaking * yieldDay) / 100;
            uint256 rewards = (amount * totalPercent) / 10**18;

            vaultOne[msg.sender].timeStamp = block.timestamp;
            vaultOne[msg.sender].lastRewards += rewards;
            vaultOne[msg.sender].totalStaked += _tokens;
            vaultOne[msg.sender].teleg = _telegram;

            emit ReStaking(msg.sender, _tokens, _telegram);
            return  vaultOne[msg.sender].id;
        }

        _mint(msg.sender, 1000000000000000000); ///@dev mint proof staking

        stakeID = totalStakers++;

        StakingOne storage storageStaking = vaultOne[msg.sender];
        storageStaking.id = stakeID;
        storageStaking.staker = msg.sender;
        storageStaking.stakingComplete = false;
        storageStaking.totalStaked = _tokens; ///@dev with decimals
        storageStaking.timeStamp = block.timestamp;
        storageStaking.deadLine = block.timestamp + (86400 * stakingOneDL);
        storageStaking.cancelled = false;
        storageStaking.lastRewards = 0;
        storageStaking.teleg = _telegram;
        
        emit Staking(msg.sender, _tokens, _telegram);
        return stakeID;
    }

    /**
     * @notice public function that creates the StakingTwo for the user
     * @return stakeID returns the staking id
     * @param _tokens amount of token the user will stake (amount with decimals)
     * @param _telegram @ from telegram for registration
     */
    function stakingTwo(uint256 _tokens, string memory _telegram) public whenNotPaused returns (uint256 stakeID) {
        require(vaultTwo[msg.sender].stakingComplete == false, "You have already claimed your staking");
        require(vaultTwo[msg.sender].cancelled == false, "You already canceled your staking");
        require(_tokens + totalAmountStaked <= maxStaking, "The maximum staking amount has been reached"); 
        require(_tokens >= minTokensOne, "Your Staking needs to be at least 10000 MafaCoins");
        require(mafacoin.balanceOf(msg.sender) >= _tokens, "You don't have enough Mafacoin balance");
        require(mafacoin.allowance(msg.sender, address(this)) >= _tokens, "You need to approve the total amount of Mafacoin you want to staking");
        require(mafacoin.transferFrom(msg.sender, payable(address(this)), _tokens), "Staking has not been completed");
        totalAmountStaked += _tokens;

        addStakeholder(msg.sender, _telegram);        

        if(vaultTwo[msg.sender].staker == msg.sender){
            uint256 amount = vaultTwo[msg.sender].totalStaked;
            uint256 daysInStaking = (block.timestamp - vaultTwo[msg.sender].timeStamp) / 86400; 
            uint256 totalPercent = (daysInStaking * yieldDay) / 100;
            uint256 rewards = (amount * totalPercent) / 10**18;

            vaultTwo[msg.sender].timeStamp = block.timestamp;
            vaultTwo[msg.sender].lastRewards += rewards;
            vaultTwo[msg.sender].totalStaked += _tokens;
            vaultTwo[msg.sender].teleg = _telegram;

            emit ReStaking(msg.sender, _tokens, _telegram);
            return vaultTwo[msg.sender].id;
        }

        _mint(msg.sender, 1000000000000000000); ///@dev mint proof staking

        stakeID = totalStakers++;

        StakingTwo storage storageStaking = vaultTwo[msg.sender];
        storageStaking.id = stakeID;
        storageStaking.staker = msg.sender;
        storageStaking.stakingComplete = false;
        storageStaking.totalStaked = _tokens; ///@dev with decimals
        storageStaking.timeStamp = block.timestamp;
        storageStaking.deadLine = block.timestamp + (86400 * stakingTwoDL);
        storageStaking.cancelled = false;
        storageStaking.lastRewards = 0;
        storageStaking.teleg = _telegram;

        emit Staking(msg.sender, _tokens, _telegram);
        return stakeID;
    }
   
    /**
     * @notice public function for the user to be able to withdraw his staking with his rewards in the StakingOne
     */
    function claimRewardsOne() public whenNotPaused {
        require(block.timestamp >= vaultOne[msg.sender].deadLine, "You need to wait for your staking to end");
        require(vaultOne[msg.sender].stakingComplete == false, "You have already claimed your staking");
        require(vaultOne[msg.sender].cancelled == false, "You already canceled your staking");
        
        vaultOne[msg.sender].stakingComplete = true;

        burn(1000000000000000000); ///@dev burn proof staking
        require(balanceOf(msg.sender) <= 0, "You must burn your proof staking");

        uint256 amount = vaultOne[msg.sender].totalStaked;
        uint256 daysInStaking = (vaultOne[msg.sender].deadLine - vaultOne[msg.sender].timeStamp) / 86400;
        uint256 totalPercent = (daysInStaking * yieldDay) / 100;
        uint256 rewards = (amount * totalPercent) / 10**18;
        uint256 totalRewards = rewards + vaultOne[msg.sender].lastRewards;

        uint256 balance = setBalanceMafa(); ///@dev check if the contract has enough balance to pay
        require(balance >= amount + totalRewards, "Withdrawal amount is greater than contract balance");
        
        require(mafacoin.transfer(msg.sender, amount + totalRewards), "Unable to send your reward");
        removeStakeholder(msg.sender);
        emit Claim(msg.sender,  amount + totalRewards, vaultOne[msg.sender].teleg);
    }

    /**
     * @notice public function for the user to be able to withdraw his staking with his rewards in the StakingTwo
     */
    function claimRewardsTwo() public whenNotPaused {
        require(block.timestamp >= vaultTwo[msg.sender].deadLine, "You need to wait for your staking to end");
        require(vaultTwo[msg.sender].stakingComplete == false, "You have already claimed your staking");
        require(vaultTwo[msg.sender].cancelled == false, "You already canceled your staking");
        
        vaultTwo[msg.sender].stakingComplete = true;

        burn(1000000000000000000); ///@dev burn proof staking
        require(balanceOf(msg.sender) <= 0, "You must burn your proof staking");

        uint256 amount = vaultTwo[msg.sender].totalStaked;
        uint256 daysInStaking = (vaultTwo[msg.sender].deadLine - vaultTwo[msg.sender].timeStamp) / 86400;
        uint256 totalPercent = (daysInStaking * yieldDay) / 100;
        uint256 rewards = (amount * totalPercent) / 10**18;
        uint256 totalRewards = rewards + vaultTwo[msg.sender].lastRewards;

        uint256 balance = setBalanceMafa(); ///@dev check if the contract has enough balance to pay
        require(balance >= amount + totalRewards, "Withdrawal amount is greater than contract balance");
        
        require(mafacoin.transfer(msg.sender, amount + totalRewards), "Unable to send your reward");
        removeStakeholder(msg.sender);
        emit Claim(msg.sender,  amount + totalRewards, vaultTwo[msg.sender].teleg);
    }

    
    /**
     * @notice publish function for the user to cancel his StakingOne
     */
    function revokeStakingOne() public whenNotPaused {
        require(block.timestamp >= vaultOne[msg.sender].timeStamp + (86400 * minDays), "You need to wait for the minimum cancellation period");
        require(vaultOne[msg.sender].stakingComplete == false, "You have already claimed your staking");
        require(vaultOne[msg.sender].cancelled == false, "You already canceled your staking");
        
        vaultOne[msg.sender].cancelled = true;

        burn(1000000000000000000); ///@dev burn proof staking
        require(balanceOf(msg.sender) <= 0, "You must burn your proof staking");

        uint256 amount = vaultOne[msg.sender].totalStaked;
        uint256 daysInStaking = (block.timestamp - vaultOne[msg.sender].timeStamp) / 86400; 
        uint256 totalPercent = (daysInStaking * yieldDay) / 100;
        uint256 rewards = (amount * totalPercent) / 10**18;
        uint256 penaltyAmount = (amount * penalty) / 100;
        uint256 liquidAmount = amount - penaltyAmount;
        uint256 totalRewards = rewards + vaultOne[msg.sender].lastRewards;
        
        uint256 balance = setBalanceMafa(); ///@dev check if the contract has enough balance to pay
        require(balance >= liquidAmount + totalRewards, "Withdrawal amount is greater than contract balance");

        require(mafacoin.transfer(msg.sender, liquidAmount + rewards), "Unable to send your tokens");
        removeStakeholder(msg.sender);
        emit Revoke(msg.sender, vaultOne[msg.sender].teleg);
    }

    /**
     * @notice publish function for the user to cancel his StakingTwo
     */
    function revokeStakingTwo() public whenNotPaused {
        require(block.timestamp >= vaultTwo[msg.sender].timeStamp + (86400 * minDays), "You need to wait for the minimum cancellation period");
        require(vaultTwo[msg.sender].stakingComplete == false, "You have already claimed your staking");
        require(vaultTwo[msg.sender].cancelled == false, "You already canceled your staking");

        vaultTwo[msg.sender].cancelled = true;

        burn(1000000000000000000); ///@dev burn proof staking
        require(balanceOf(msg.sender) <= 0, "You must burn your proof staking");

        uint256 amount = vaultTwo[msg.sender].totalStaked;
        uint256 daysInStaking = (block.timestamp - vaultTwo[msg.sender].timeStamp) / 86400; 
        uint256 totalPercent = (daysInStaking * yieldDay) / 100;
        uint256 rewards = (amount * totalPercent) / 10**18;
        uint256 penaltyAmount = (amount * penalty) / 100;
        uint256 liquidAmount = amount - penaltyAmount;
        uint256 totalRewards = rewards + vaultTwo[msg.sender].lastRewards;
        
        uint256 balance = setBalanceMafa(); ///@dev check if the contract has enough balance to pay
        require(balance >= liquidAmount + totalRewards, "Withdrawal amount is greater than contract balance");

        require(mafacoin.transfer(msg.sender, liquidAmount + rewards), "Unable to send your tokens");
        removeStakeholder(msg.sender);
        emit Revoke(msg.sender, vaultTwo[msg.sender].teleg);
    }


    /** Updates Functions */

    /**
     * @notice function where the contract owner can update the minimum amount of tokens for staking
     * @param _minTokens new minimum amount of tokens for StakingOne Ex: 1000 Tokens == 1000
     */
    function setMinTokensOne(uint256 _minTokens) external onlyOwner {
        tokensOne = _minTokens;
        minTokensOne = tokensOne*10**18; 
        emit UpdateMinTokensOne(msg.sender, minTokensOne);
    }

    /**
     * @notice function where the contract owner can update the minimum amount of tokens for staking
     * @param _minTokens new minimum amount of tokens for StakingTwo Ex: 1000 Tokens == 1000
     */
    function setMinTokensTwo(uint256 _minTokens) external onlyOwner {
        tokensTwo = _minTokens;
        minTokensTwo = tokensTwo*10**18; 
        emit UpdateMinTokensOne(msg.sender, minTokensTwo);
    }

    /**
     * @notice function where the contract owner can update the staking yield in %
     * @param _yield new yeld in % Ex: 2,40% == 240
     */
    function setYield(uint256 _yield) external onlyOwner {
        yield = _yield;
        yieldDay = (yield*10**16) / 30; 
        emit UpdateYeld(msg.sender, _yield);
    }

    /**
     * @notice function where the contract owner can update the total staking time in days
     * @param _deadlineOne new staking time in days for StakingOne Ex: 100 days == 100
     */
    function setStkOneDL(uint256 _deadlineOne) external onlyOwner {
        stakingOneDL = _deadlineOne;
        emit UpdateStkOneDL(msg.sender, _deadlineOne);
    }

    /**
     * @notice function where the contract owner can update the total staking time in days
     * @param _deadlineTwo new staking time in days for StakingTwo Ex: 100 days == 100
     */
    function setStkTwoDL(uint256 _deadlineTwo) external onlyOwner {
        stakingTwoDL = _deadlineTwo;
        emit UpdateStkOneDL(msg.sender, _deadlineTwo);
    }

    /**
     * @notice function where the contract owner can update the minimum time in days for canceling the staking
     * @param _minDays new minimum amount of tokens for StakingTwo Ex: 15 days == 15
     */
    function setMinDays(uint256 _minDays) external onlyOwner {
        minDays = _minDays;
        emit UpdateMinDays(msg.sender, _minDays);
    }

    /**
     * @notice function where the owner of the contract can update the penalty percentage for staking cancellation
     * @param _penalty new penalty percentage for cancellation Ex: 1% == 1
     */
    function setPenalty(uint256 _penalty) external onlyOwner {
        penalty = _penalty;
        emit UpdatePenalty(msg.sender, _penalty);
    }
    
    /**
     * @notice function where the contract owner can update the maximum amount of staking tokens
     * @param _max new maximum amount of tokens for staking Ex: 1KK Tokens == 1000000
     */
    function setMaxStaking(uint256 _max) external onlyOwner {
        maxTotal = _max;
        maxStaking = maxTotal*10**18; 
        emit UpdateMaxStaking(msg.sender, maxStaking);
    }

   
    /** Proof Staking Functions*/

    function mint(address _to) external onlyOwner {
        _mint(_to, 1000000000000000000);
    }

    /** Bank Functions */

    /**
     * @notice function where the contract owner can check the MafaCoins balance of the contract
     */
    function setBalanceMafa() internal returns(uint256 mafas) {
        balanceMafa = mafacoin.balanceOf(address(this));
        return balanceMafa;
    }

    /**
     * @notice function where contract owner can deposit mafacoins in this contract
     * @param _amount amount of tokens for deposit (amount with decimals)
     */
    function depositBank(uint256 _amount) external onlyOwner {
        require(mafacoin.balanceOf(msg.sender) >= _amount, "You don't have enough Mafacoin balance");
        require(mafacoin.allowance(msg.sender, address(this)) >= _amount, "You need to approve the total amount of tokens you want to transfer");
        require(mafacoin.transferFrom(msg.sender, payable(address(this)), _amount), "You have not completed the deposit");
        
        rewardsBank += _amount;
        emit DepositBank(_amount);
    }

    /**
     * @notice function where contract owner can withdraw mafacoins bank in this contract
     * @param _amount amount of tokens for deposit (amount with decimals)
     */
    function withdrawBank(uint256 _amount) external onlyOwner{
        require(_amount <= maxAmountWithdraw, "The amount exceeded the withdrawal limit");
        uint256 balance = setBalanceMafa();
        require(balance >= _amount, "Withdrawal amount is greater than contract balance");
        (bool sent) = mafacoin.transfer(msg.sender, _amount);
        require(sent, "Failed to transfer token to Owner");

        rewardsBank -= _amount;
        emit WithDrawBank(msg.sender, _amount);
    }


    /** Modifiers & Checkers */

    /**
     * @notice function where contract owner can temporarily pause some functions
     */
    function pause() public onlyOwner {
        _pause();
        emit Pause(msg.sender, true);
    }   

    /**
     * @notice function where contract owner can unpause functions paused
     */
    function unpause() public onlyOwner {
        _unpause();
        emit UnPause(msg.sender, true);
    }

   
    /** Owner */

    function _checkOwner() internal view override  {
        require(msg.sender == _owner || msg.sender == _ownerTwo, "Ownable: caller is not the owner");
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    function _transferOwnership(address newOwner) internal override  {
        _owner = newOwner;
        emit NewOwner(msg.sender, newOwner);
    }

    /**Telegram StakeHolders Functions */

    /**
     * function where the contract can to check if an address is from a stakeholder
     * @param _address The address to check
     * @return bool, uint256 if the address is of a stakeholder
     * and if so your position in the array of stakeholders
     */
    function isStakeholder(address _address) public view returns(bool, uint256){
        for (uint256 s = 0; s < stakeHolders.length; s += 1){
            if (_address == stakeHolders[s].stakerAdd){ 
                return (true, s);
            }
        }
        return (false, 0);
    }

    /**
     * function where the contract can add an address to stakeholder list
     * @param _stakeholder the stakeholder to add
     */
    function addStakeholder(address _stakeholder, string memory _teleg) internal {
        removeStakeholder(msg.sender);
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder){ 
            stakeHolders.push(StakerHolder(_stakeholder, _teleg));
        }
    }

    /**
     * function where the contract can del an address to stakeholder list
     * @param _stakeholder The stakeholder to del
     */
    function removeStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeHolders[s] = stakeHolders[stakeHolders.length - 1];
            stakeHolders.pop();
        }
    }

    /**
     * function where contract owner can del an address to stakeholder list
     */    
    function getStakerHolders() external view returns (StakerHolder[] memory listStakerHolders){
        listStakerHolders = new StakerHolder[](stakeHolders.length);
        uint256 holder;
        
        for(uint256 i = 0; i < stakeHolders.length; i += 1){
            listStakerHolders[holder] = stakeHolders[i];
            holder ++;         
        }
        return listStakerHolders;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WithdrawableOwnable is Ownable, ReentrancyGuard {
    using Address for address;

    /*
     * @dev Withdraw native token from this contract
     * @param amount the amount of tokens you want to withdraw
     */
    function withdraw(uint256 amount) public virtual onlyOwner nonReentrant {
        uint256 balance = address(this).balance;

        require(amount <= balance, "Withdrawable: you cannot remove this total amount");

        Address.sendValue(payable(_msgSender()), amount);

        emit Withdraw(_msgSender(), amount);
    }

    event Withdraw(address sender, uint256 value);

    /**
     * @dev Withdraw any ERC20 token from this contract
     * @param tokenAddress ERC20 token to withdraw
     * @param amount the amount desired to remove
     */
    function withdrawERC20(address tokenAddress, uint256 amount) external virtual nonReentrant onlyOwner {
        require(tokenAddress.isContract(), "Withdrawable: ERC20 token address must be a contract");

        IERC20 tokenContract = IERC20(tokenAddress);

        uint256 balance = tokenContract.balanceOf(address(this));
        require(amount <= balance, "Withdrawable: you cannot remove this total amount");

        require(tokenContract.transfer(_msgSender(), amount), "Withdrawable: Fail on transfer");

        emit WithdrawERC20(_msgSender(), tokenAddress, amount);
    }

    event WithdrawERC20(address sender, address token, uint256 value);

    /**
     * @dev Withdraw any ERC721 token from this contract
     * @param tokenAddress ERC721 token to withdraw
     * @param tokenIds IDs of the NFTs to withdraw
     */
    function withdrawERC721(address tokenAddress, uint256[] memory tokenIds) external virtual onlyOwner nonReentrant {
        require(tokenAddress.isContract(), "ERC721 token address must be a contract");

        IERC721 tokenContract = IERC721(tokenAddress);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenContract.ownerOf(tokenIds[i]) == address(this),
                "This contract doesn't own the NFT you are trying to withdraw"
            );
            tokenContract.safeTransferFrom(address(this), _msgSender(), tokenIds[i]);
        }
        emit WithdrawERC721(tokenAddress, tokenIds);
    }

    event WithdrawERC721(address tokenAddress, uint256[] tokenIds);

    /**
     * @dev Withdraw any ERC1155 token from this contract
     * @param tokenAddress ERC1155 token to withdraw
     * @param id ID of the token to withdraw
     * @param amount amount to withdraw
     */
    function withdrawERC1155(
        address tokenAddress,
        uint256 id,
        uint256 amount
    ) external virtual onlyOwner nonReentrant {
        require(tokenAddress.isContract(), "ERC1155 token address must be a contract");

        IERC1155 tokenContract = IERC1155(tokenAddress);
        require(
            tokenContract.balanceOf(address(this), id) >= amount,
            "this contract doesn't own the amount of tokens to withdraw"
        );

        tokenContract.safeTransferFrom(address(this), _msgSender(), id, amount, "");
    }

    event WithdrawERC1155(address tokenAddress, uint256 id, uint256 amount);
}