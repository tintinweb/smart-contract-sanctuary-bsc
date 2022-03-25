// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Burnable.sol)

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
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
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

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IDataStorage {
    function getPandoBoxCreatingProbability() external view returns (uint256[] memory);
    function getDroidBotCreatingProbability(uint256) external view returns (uint256[] memory);
    function getDroidBotUpgradingProbability(uint256, uint256) external view returns(uint256[] memory);
    function getDroidBotPower(uint256) external view returns(uint256);
    function getJDroidBotCreating(uint256) external view returns(uint256, uint256);
    function getJDroidBotUpgrading(uint256) view external returns(uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "../libraries/NFTLib.sol";

interface IDroidBot is IERC721{
    function create(address, uint256, uint256) external returns(uint256);
    function upgrade(uint256, uint256, uint256) external;
    function burn(uint256) external;
    function info(uint256) external view returns(NFTLib.Info memory);
    function power(uint256) external view returns(uint256);
    function level(uint256) external view returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
pragma experimental ABIEncoderV2;

interface IOracle {
    function consult() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "../libraries/NFTLib.sol";

interface IPandoBox is IERC721 {
    function create(address receiver, uint256 level) external returns(uint256);
    function burn(uint256 tokenId) external;
    function info(uint256 id) external view returns(NFTLib.Info memory);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IPandoPot {
    function enter(address, uint256, uint256, uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface ISwapRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function pairFor(address, address) external view returns(address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity = 0.8.4;
pragma experimental ABIEncoderV2;

import './ISwapRouter01.sol';

interface ISwapRouter02 is ISwapRouter01 {
    function tradingPool() external pure returns (address);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IUserLevel {
    function getBonus(address, address) external view returns(uint256, uint256);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;
import "../interfaces/IDroidBot.sol";

library NFTLib {
    struct Info {
        uint256 level;
        uint256 power;
    }

    function max(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) {
            return b;
        }
        return a;
    }

    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function optimizeEachLevel(NFTLib.Info[] memory info, uint256 level, uint256 m,  uint256 n) internal pure returns (uint256){
        // calculate m maximum values after remove n values
        uint256 l = 1;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].level == level) {
                l++;
            }
        }
        uint256[] memory tmp = new uint256[](l);
        require(l > n + m, 'Lib: not enough droidBot');
        uint256 j = 0;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].level == level) {
                tmp[j++] = info[i].power;
            }
        }
        for (uint256 i = 0; i < l; i++) {
            for (j = i + 1; j < l; j++) {
                if (tmp[i] < tmp[j]) {
                    uint256 a = tmp[i];
                    tmp[i] = tmp[j];
                    tmp[j] = a;
                }
            }
        }

        uint256 res = 0;
        for (uint256 i = n; i < n + m; i++) {
            res += tmp[i];
        }
        return res;
    }

    function getPower(uint256[] memory tokenIds, IDroidBot droidBot) external view returns (uint256) {
        NFTLib.Info[] memory info = new NFTLib.Info[](tokenIds.length);
        uint256[9] memory count;
        uint256[9] memory old_count;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            info[i] = droidBot.info(tokenIds[i]);
            count[info[i].level]++;
        }
        uint256 res = 0;
        uint256 c9 = count[0];
        for (uint256 i = 1; i < 9; i++) {
            c9 = min(c9, count[i]);
        }
        if (c9 > 0) {
            uint256 tmp = 0;
            for (uint256 i = 0; i < 9; i++) {
                tmp += optimizeEachLevel(info, i, c9, 0);
            }
            if (c9 >= 3) {
                res += tmp * 5; // 5x
            } else {
                res += tmp * 2; // 2x
            }
        }

        for (uint256 i = 0; i < 9; i++) {
            count[i] -= c9;
            old_count[i] = count[i];
        }

        for (uint256 i = 8; i >= 5; i--) {
            uint256 fi = count[i];
            for (uint256 j = i; j >= i - 5; j--) {
                fi = min(fi, count[j]);
                if (j == 0) {
                    break;
                }
            }
            if (fi > 0) {
                uint tmp = 0;
                for (uint256 j = i; j >= i - 5; j--) {
                    tmp += optimizeEachLevel(info, j, fi, old_count[j] - count[j]);
                    count[j] -= fi;
                    if (j == 0) {
                        break;
                    }
                }
                res += tmp * 14 * fi / 10; // 1.4x
            }
        }

        for (uint256 i = 8; i >= 2; i--) {
            uint256 fi = count[i];
            for (uint256 j = i; j >= i - 2; j--) {
                fi = min(fi, count[j]);
                if (j == 0) {
                    break;
                }
            }
            if (fi > 0) {
                uint tmp = 0;
                for (uint256 j = i; j >= i - 2; j--) {
                    tmp += optimizeEachLevel(info, j, fi, old_count[j] - count[j]);
                    count[j] -= fi;
                    if (j == 0) {
                        break;
                    }
                }
                res += tmp * 115 * fi / 100; //1.15 x
            }
        }

        for (uint256 i = 0; i < 9; i++) {
            if (count[i] > 0) {
                res += optimizeEachLevel(info, i, count[i], old_count[i] - count[i]); // normal
            }
        }
        return res;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library Random {
    address constant BNB = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // mainnet 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
    address constant BTC = 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf; // mainnet 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
    address constant ETH = 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e; // mainnet 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e

    uint256 constant PRECISION = 1e20;

    function getLatestPrice(address _addr) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_addr);
        (, int256 _price, , , ) = priceFeed.latestRoundData();
        return uint256(_price);
    }

    function computerSeed(uint256 salt) internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp)
                    + block.gaslimit
                    + uint256(keccak256(abi.encodePacked(blockhash(block.number)))) / (block.timestamp)
                    + uint256(keccak256(abi.encodePacked(block.coinbase))) / (block.timestamp)
                    + (uint256(keccak256(abi.encodePacked(tx.origin)))) / (block.timestamp)
                    + block.number * block.timestamp
                )
            )
        );
        seed = (seed % PRECISION) * getLatestPrice(BNB);
        seed = (seed % PRECISION) * getLatestPrice(ETH);
        seed = (seed % PRECISION) * getLatestPrice(BTC);
        if (salt > 0) {
            seed = seed % PRECISION * salt;
        }
        return seed;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "../libraries/NFTLib.sol";
import "../libraries/Random.sol";
import "../interfaces/IPandoBox.sol";
import "../interfaces/IDroidBot.sol";
import "../interfaces/IPandoPot.sol";
import "../interfaces/IDataStorage.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/ISwapRouter02.sol";
import "../interfaces/IUserLevel.sol";


contract NFTRouter is Ownable {
    using SafeERC20 for IERC20;

    mapping (uint256 => uint256) private pandoBoxCreated;

    uint256 constant PRECISION = 10000000000;
    uint256 constant ONE_HUNDRED_PERCENT = 10000;
    IDroidBot public droidBot;
    IPandoBox public pandoBox;
    IPandoPot public pandoPot;
    IDataStorage public dataStorage;
    IERC20 public PAN;
    IERC20 public PSR;
    IOracle public PANOracle;
    IOracle public PSROracle;
    ISwapRouter02 public swapRouter;
    IUserLevel public userLevel;

    uint256 public startTime;
    uint256 public pandoBoxPerDay;
    uint256 public createPandoBoxFee;
    uint256 public upgradeBaseFee;
    uint256 public PSRRatio = 8000;
    uint256 public slippage = 8000000000;
    address[] public PANToPSR;

    /*----------------------------INITIALIZE----------------------------*/

    constructor (
        address _pandoBox,
        address _droidBot,
        address _PAN,
        address _PSR,
        address _pandoPot,
        address _dataStorage,
        address _PANOracle,
        address _PSROracle,
        address _swapRouter,
        uint256 _startTime
    ) {
        pandoBox = IPandoBox(_pandoBox);
        droidBot = IDroidBot(_droidBot);
        PAN = IERC20(_PAN);
        PSR = IERC20(_PSR);
        pandoPot = IPandoPot(_pandoPot);
        dataStorage = IDataStorage(_dataStorage);
        startTime = _startTime;
        PANOracle = IOracle(_PANOracle);
        PSROracle = IOracle(_PSROracle);
        swapRouter = ISwapRouter02(_swapRouter);
    }

    /*----------------------------INTERNAL FUNCTIONS----------------------------*/

    function getPandoBoxLv() internal view returns(uint256) {
        uint256[] memory _creatingProbability = IDataStorage(dataStorage).getPandoBoxCreatingProbability();
        uint256 _randSeed = Random.computerSeed(0) % PRECISION + 1;
        uint256 _cur = 0;
        for (uint256 i = 0; i < _creatingProbability.length; i++) {
            _cur += _creatingProbability[i];
            if (_cur >= _randSeed) {
                return i;
            }
        }
        return 0;
    }

    function getNewBotLv(uint256 _boxLv) internal view returns(uint256, uint256) {
        uint256[] memory _creatingProbability = IDataStorage(dataStorage).getDroidBotCreatingProbability(_boxLv);
        uint256 _randSeed = Random.computerSeed(0) % PRECISION + 1;
        uint256 _cur = 0;
        for (uint256 i = 0; i < _creatingProbability.length; i++) {
            _cur += _creatingProbability[i];
            if (_cur >= _randSeed) {
                uint256 _power = IDataStorage(dataStorage).getDroidBotPower(i);
                return (i, _power);
            }
        }
        return (0, 0);
    }

    function getUpgradeBotLv(uint256 _bot0Lv, uint256 _bot1Lv) internal view returns (uint256, uint256){
        uint256[] memory _evolvingProbability = IDataStorage(dataStorage).getDroidBotUpgradingProbability(_bot0Lv, _bot1Lv);
        uint256 _randSeed = Random.computerSeed(0) % PRECISION + 1;
        uint256 _cur = 0;
        for (uint256 i = 0; i < _evolvingProbability.length; i++) {
            _cur += _evolvingProbability[i];
            if (_cur >= _randSeed) {
                uint256 _power = IDataStorage(dataStorage).getDroidBotPower(i);
                return (i, _power);
            }
        }
        return (0, 0);
    }

    function getBonus(uint256 _value) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(msg.sender, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/
    
    function createPandoBox(uint256 _option) external {
        require(block.timestamp >= startTime, 'Router: not started');
        uint256 _ndays = (block.timestamp - startTime) / 1 days;
        uint256 _createPandoBoxFee = createPandoBoxFee - getBonus(createPandoBoxFee);
        if (pandoBoxCreated[_ndays] < pandoBoxPerDay) {
            if (_createPandoBoxFee > 0) {
                if (_option == 0) { // only PAN
                    PAN.safeTransferFrom(msg.sender, address(this), _createPandoBoxFee);
                    uint256 _amountSwap = _createPandoBoxFee * (ONE_HUNDRED_PERCENT - PSRRatio) / ONE_HUNDRED_PERCENT;
                    uint256[] memory _amounts = swapRouter.getAmountsOut(_amountSwap, PANToPSR);
                    uint256 _minAmount = _amounts[_amounts.length - 1] * slippage / PRECISION;
                    IERC20(PAN).safeApprove(address(swapRouter), _amountSwap);
                    swapRouter.swapExactTokensForTokens(_amountSwap, _minAmount, PANToPSR, address(this), block.timestamp + 300);
                    ERC20Burnable(address(PAN)).burn(PAN.balanceOf(address(this)));
                    ERC20Burnable(address(PSR)).burn(PSR.balanceOf(address(this)));
                } else {
                    uint256 _price_PAN = PANOracle.consult();
                    uint256 _price_PSR = PSROracle.consult();

                    uint256 _amount_PSR = _createPandoBoxFee * (ONE_HUNDRED_PERCENT - PSRRatio) / ONE_HUNDRED_PERCENT * _price_PAN / _price_PSR;
                    ERC20Burnable(address(PAN)).burnFrom(msg.sender, _createPandoBoxFee * PSRRatio / ONE_HUNDRED_PERCENT);
                    ERC20Burnable(address(PSR)).burnFrom(msg.sender, _amount_PSR);
                }
            }
            pandoBoxCreated[_ndays]++;
            uint256 _lv = getPandoBoxLv();
            uint256 _boxId = pandoBox.create(msg.sender, _lv);
            emit BoxCreated(msg.sender, _lv, _option, _boxId);
        }
    }

    function createDroidBot(uint256 _pandoBoxId) external {
        if (pandoBox.ownerOf(_pandoBoxId) == msg.sender) {
            pandoBox.burn(_pandoBoxId);
            NFTLib.Info memory _info = pandoBox.info(_pandoBoxId);
            (uint256 _lv, uint256 _power) = getNewBotLv(_info.level);
            uint256 _newBotId = droidBot.create(msg.sender, _lv, _power);

            (uint256 _megaNum, uint256 _minorNum) = dataStorage.getJDroidBotCreating(_info.level);
            pandoPot.enter(msg.sender, _megaNum, _minorNum, PANOracle.consult());
            emit BotCreated(msg.sender, _pandoBoxId, _newBotId);
        }
    }

    function upgradeDroidBot(uint256 _droidBot0Id, uint256 _droidBot1Id) external{
        require(droidBot.ownerOf(_droidBot0Id) == msg.sender && droidBot.ownerOf(_droidBot1Id) == msg.sender, 'NFTRouter : not owner of bot');
        uint256 _l0 = droidBot.level(_droidBot0Id);
        uint256 _l1 = droidBot.level(_droidBot1Id);
        uint256 _id0 = _droidBot0Id;
        uint256 _id1 = _droidBot1Id;
        if (_l0 < _l1) {
            _id0 = _droidBot1Id;
            _id1 = _droidBot0Id;
        }
        NFTLib.Info memory _info0 = droidBot.info(_id0);
        NFTLib.Info memory _info1 = droidBot.info(_id1);

        uint256 _upgradeFee = upgradeBaseFee * (15 ** _info1.level) / (10 ** _info1.level);
        _upgradeFee -= getBonus(_upgradeFee);
        if (_upgradeFee > 0) {
            ERC20Burnable(address(PSR)).burnFrom(msg.sender, _upgradeFee);
        }

        (uint256 _lv, uint256 _power) = getUpgradeBotLv(_info0.level, _info1.level);
        droidBot.burn(_id1);
        if (_lv > _info0.level) {
            droidBot.upgrade(_id0, _lv, _power);
        } else {
            _power = _info0.power;
        }
        (uint256 _megaNum, uint256 _minorNum) = dataStorage.getJDroidBotUpgrading(_info1.level);
        pandoPot.enter(msg.sender, _megaNum, _minorNum, PSROracle.consult());
        emit BotUpgraded(msg.sender, _id0, _id1);
    }


    function pandoBoxRemain() external view returns (uint256) {
        uint256 _ndays = (block.timestamp - startTime) / 1 days;
        return pandoBoxPerDay - pandoBoxCreated[_ndays];
    }

    /*----------------------------RESTRICT FUNCTIONS----------------------------*/

    function setPandoBoxPerDay(uint256 _value) external onlyOwner {
        uint256 oldPandoBoxPerDay = pandoBoxPerDay;
        pandoBoxPerDay = _value;
        emit PandoBoxPerDayChanged(oldPandoBoxPerDay, _value);
    }

    function setCreatePandoBoxFee(uint256 _newFee) external onlyOwner {
        uint256 oldCreatePandoBoxFee = createPandoBoxFee;
        createPandoBoxFee = _newFee;
        emit CreateFeeChanged(oldCreatePandoBoxFee, _newFee);
    }

    function setUpgradeBaseFee(uint256 _newFee) external onlyOwner {
        uint256 oldUpgradeBaseFee = upgradeBaseFee;
        upgradeBaseFee = _newFee;
        emit UpgradeFeeChanged(oldUpgradeBaseFee, _newFee);
    }

    function setPandoPotAddress(address _addr) external onlyOwner {
        address oldPandoPot = address(pandoPot);
        pandoPot = IPandoPot(_addr);
        emit PandoPotChanged(oldPandoPot, _addr);
    }

    function setDataStorageAddress(address _addr) external onlyOwner {
        address oldDataStorage = address(dataStorage);
        dataStorage = IDataStorage(_addr);
        emit DataStorageChanged(oldDataStorage, _addr);
    }

    function setPANOracle(address _addr) external onlyOwner {
        address oldPANOracle = address(PANOracle);
        PANOracle = IOracle(_addr);
        emit PANOracleChanged(oldPANOracle, _addr);
    }

    function setPSROracle(address _addr) external onlyOwner {
        address oldPSROracle = address(PSROracle);
        PSROracle = IOracle(_addr);
        emit PSROracleChanged(oldPSROracle, _addr);
    }

    function setPath(address[] memory _path) external onlyOwner {
        address[] memory oldPath = PANToPSR;
        PANToPSR = _path;
        emit PANtoPSRChanged(oldPath, _path);
    }

    function setPSRRatio(uint256 _ratio) external onlyOwner { 
        uint256 oldPSRRatio = PSRRatio;
        PSRRatio = _ratio;
        emit PSRRatioChanged(oldPSRRatio, _ratio);
    }

    function setNftAddress(address _droidBot, address _pandoBox) external onlyOwner {
        address oldDroidBot = address(droidBot);
        address oldPandoBox = address(pandoBox);
        droidBot = IDroidBot(_droidBot);
        pandoBox = IPandoBox(_pandoBox);
        emit DroidBotChanged(oldDroidBot, _droidBot);
        emit PandoBoxChanged(oldPandoBox, _pandoBox);
    }

    function setTokenAddress(address _PSR, address _PAN) external onlyOwner {
        address oldPSR = address(PSR);
        address oldPAN = address(PAN);
        PSR = IERC20(_PSR);
        PAN = IERC20(_PAN);
        emit PSRChanged(oldPSR, _PSR);
        emit PANChanged(oldPAN, _PAN);
    }

    function setSwapRouter(address _swapRouter) external onlyOwner {
        address oldSwapRouter = address(swapRouter);
        swapRouter = ISwapRouter02(_swapRouter);
        emit SwapRouterChanged(oldSwapRouter, _swapRouter);
    }

    function setSlippage(uint256 _value) external onlyOwner {
        require(_value <= PRECISION, 'NFT Router: > precision');
        uint256 oldSlippage = slippage;
        slippage = _value;
        emit SlippageChanged(oldSlippage, _value);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }
    /*----------------------------EVENTS----------------------------*/

    event BoxCreated(address indexed receiver, uint256 level, uint256 option, uint256 indexed newBoxId);
    event BotCreated(address indexed receiver, uint256 indexed boxId, uint256 indexed newBotId);
    event BotUpgraded(address indexed user, uint256 indexed bot0Id, uint256 indexed bot1Id);
    event PandoBoxPerDayChanged(uint256 oldPandoBoxPerDay, uint256 newPandoBoxPerDay);
    event CreateFeeChanged(uint256 oldFee, uint256 newFee);
    event UpgradeFeeChanged(uint256 oldFee, uint256 newFee);
    event PandoPotChanged(address indexed oldPandoPot, address indexed newPandoPot);
    event DataStorageChanged(address indexed oldDataStorate, address indexed newDataStorate);
    event PANOracleChanged(address indexed oldPANOracle, address indexed newPANOracle);
    event PSROracleChanged(address indexed oldPSROracle, address indexed newPSROracle);
    event PANtoPSRChanged(address[] oldPath, address[] newPath);
    event PSRRatioChanged(uint256 oldRatio, uint256 newRatio);
    event PandoBoxChanged(address indexed oldPandoBox, address indexed newPandoBox);
    event DroidBotChanged(address indexed oldDroidBot, address indexed newDroidBot);
    event PSRChanged(address indexed oldPSR, address indexed newPSR);
    event PANChanged(address indexed oldPAN, address indexed newPAN);
    event SwapRouterChanged(address indexed oldSwapRouter, address indexed newSwapRouter);
    event SlippageChanged(uint256 oldSlippage, uint256 newSlippage);
    event UserLevelChanged(address indexed userLevel);

}