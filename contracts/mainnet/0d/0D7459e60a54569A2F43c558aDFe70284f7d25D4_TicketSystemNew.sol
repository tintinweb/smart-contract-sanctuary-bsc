// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BEP20Token is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("BEP20Token", "BEP") {
        uint256 mintAmount = 10000000 * 10 ** decimals();

        _mint(msg.sender, mintAmount);
    }

    event EnabledAutoSwapAndLiquify();
    event DisabledAutoSwapAndLiquify();
    event MinTokensBeforeSwapUpdated(
        uint256 previousMinSwap,
        uint256 currentMinSwap
    );
    event SetRouterAddress(address _routerAddress);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    //to recieve ETH from pancakeSwapV2Router when swaping
    receive() external payable {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function Withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send ETH");
    }
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

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract WarlandsVelastChest is Ownable {
    string public name = "WarlandsChests";
    uint256 public BitorbitChestCost;
    uint256 public totalBitorbitChestMinted;
    uint256 public maxBitorbitChestSupply;

    event BoughtChest(address indexed _from, uint256 cost);
    event Withdrawing(
        address indexed _from,
        address indexed _to,
        uint256 withdrawAmount
    );

    modifier shouldPay(uint256 _cost) {
        require(
            msg.value == BitorbitChestCost,
            "Should Pay: The chest costs more!"
        );
        _;
    }

    constructor() payable {
        setBitorbitChestCost(5 ether);
        setTotalBitorbitChestMinted(0);
        setMaxBitorbitSupply(200);
    }

    function BuyBitorbitChest() external payable shouldPay(BitorbitChestCost) {
        require(
            totalBitorbitChestMinted <= maxBitorbitChestSupply,
            "Maximum Bitorbit Chests minted!"
        );
        totalBitorbitChestMinted++;
        emit BoughtChest(_msgSender(), BitorbitChestCost);
    }

    function getFunds() public view returns (uint256) {
        return address(this).balance;
    }

    /** onlyOwner functions*/

    function Withdraw() public onlyOwner {
        uint256 amount = getFunds();
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send BNB");
        emit Withdrawing(_msgSender(), owner(), amount);
    }

    function setMaxBitorbitSupply(
        uint256 newMaxBitorbitChestSupply
    ) public onlyOwner {
        maxBitorbitChestSupply = newMaxBitorbitChestSupply;
    }

    function setTotalBitorbitChestMinted(
        uint256 newBitorbitChestMintedCount
    ) public onlyOwner {
        totalBitorbitChestMinted = newBitorbitChestMintedCount;
    }

    function setBitorbitChestCost(
        uint256 newBitorbitChestCost
    ) public onlyOwner {
        BitorbitChestCost = newBitorbitChestCost;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error WarlandsBitorbitChest__InsufficientFunds();

contract WarlandsBitorbitChest is Ownable {
    string public name = "WarlandsBitorbitChest";
    uint256 public bitorbitChestCost;
    uint16 public chestCount;
    uint16 public maxSupply;

    IERC20 BITORB;

    // Testnet
    // address public bitorbAddress = 0xf9d2e180697Af80A2bdE9f6C91d071e0f77b492e;

    // Mainnet
    address public bitorbAddress = 0x09bcE7716D46459DF7473982Fd27A96EabD6eE4d;

    event SetMaxBitorbitSupply(uint16 newMaxBitorbitChestSupply);
    event SetTotalBitorbitChestMinted(uint16 newBitorbitChestMintedCount);
    event SetBitorbitChestCost(uint256 newBitorbitChestCost);
    event SetBitorbAddress(address bitorb);
    event BoughtChest(address indexed _from, uint256 cost);
    event Withdrawing(address indexed _to, uint256 withdrawAmount);

    constructor() {
        setBitorbAddress(bitorbAddress);
        setBitorbitChestCost(10000 * 10 ** 18);
        setMaxBitorbitSupply(uint16(200));
    }

    function BuyBitorbitChest() external {
        require(chestCount <= maxSupply, "Maximum Bitorbit Chests minted!");
        bool success = BITORB.transferFrom(
            _msgSender(),
            address(this),
            bitorbitChestCost
        );
        if (!success) {
            revert WarlandsBitorbitChest__InsufficientFunds();
        }
        BITORB.approve(address(this), bitorbitChestCost);

        chestCount++;
        emit BoughtChest(_msgSender(), bitorbitChestCost);
    }

    /** onlyOwner functions*/

    function setBitorbAddress(address bitorb) public onlyOwner {
        BITORB = IERC20(bitorb);
        emit SetBitorbAddress(bitorb);
    }

    /* 
    Need to put Chest Cost in wei, if 1 bitorb then, 
    1000000000000000000 need to be put in the params 
    */
    function setBitorbitChestCost(
        uint256 newBitorbitChestCost
    ) public onlyOwner {
        bitorbitChestCost = newBitorbitChestCost;
        emit SetBitorbitChestCost(newBitorbitChestCost);
    }

    function setMaxBitorbitSupply(
        uint16 newMaxBitorbitChestSupply
    ) public onlyOwner {
        maxSupply = newMaxBitorbitChestSupply;
        emit SetMaxBitorbitSupply(newMaxBitorbitChestSupply);
    }

    function setTotalBitorbitChestMinted(
        uint16 newBitorbitChestMintedCount
    ) public onlyOwner {
        chestCount = newBitorbitChestMintedCount;
        emit SetTotalBitorbitChestMinted(newBitorbitChestMintedCount);
    }

    function Withdraw() external onlyOwner {
        uint256 balance = BITORB.balanceOf(address(this));
        BITORB.transfer(owner(), balance);
        BITORB.approve(owner(), balance);
        emit Withdrawing(_msgSender(), balance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IDIAOracleV2 {
    function getValue(string memory) external view returns (uint128, uint128);
}

error VelasTicketSystem__InsufficientFunds();
error VelasTicketSystem__NumberOfTicketsNeedToBeMoreThanZero();

contract VelasTicketSystem is Ownable, ReentrancyGuard {
    uint256 public ticketPriceInBUSD;
    uint256 public VLXDeposited;
    uint256 public VLXWithdrawn;
    uint256 public ticketsSold;

    uint256 public immutable decimals = 10 ** 18;

    address public oracleAddress = 0x812C365Fe6a44d600dc1B53569c025F3a0aBba26;
    address ORACLE;

    event SetTicketPrice(uint256 ticketPrice_);
    event SetOracleAddress(address oracleAddress_);
    event PurchaseTicket(
        address indexed beneficiary,
        uint256 quantity,
        uint256 pricePerTicketInVLX,
        uint256 totalAmountInVLX
    );

    constructor() {
        setTicketPrice(1);
        setOracleAddress(oracleAddress);
    }

    function purchaseTicket(
        uint256 numberOfTickets
    ) external payable nonReentrant {
        if (numberOfTickets < 1) {
            revert VelasTicketSystem__NumberOfTicketsNeedToBeMoreThanZero();
        }
        uint256 ticketPriceInVLX = ticketPriceInVelas();
        uint256 totalTicketAmountVLX = numberOfTickets * ticketPriceInVLX;

        if (msg.value < totalTicketAmountVLX) {
            revert VelasTicketSystem__InsufficientFunds();
        }

        VLXDeposited += msg.value;
        ticketsSold += numberOfTickets;

        emit PurchaseTicket(
            _msgSender(),
            numberOfTickets,
            ticketPriceInVLX,
            msg.value
        );
    }

    function ticketPriceInVelas() public view returns (uint256) {
        (uint128 latestPrice, ) = IDIAOracleV2(ORACLE).getValue("VLX/USD");
        return (uint256(uint128(ticketPriceInBUSD * 10 ** 8) / (latestPrice)));
    }

    /* Only Owner Functions */
    function Withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        VLXWithdrawn += amount;
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send ETH");
    }

    function setTicketPrice(uint256 ticketPrice_) public onlyOwner {
        ticketPriceInBUSD = ticketPrice_ * decimals;
        emit SetTicketPrice(ticketPrice_ * decimals);
    }

    function setOracleAddress(address oracleAddress_) public onlyOwner {
        ORACLE = oracleAddress_;
        emit SetOracleAddress(oracleAddress_);
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

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error VelasTicketSystem__InsufficientFunds();

contract TicketSystem is Ownable, ReentrancyGuard {
    // Ticket price in BUSD
    uint256 public ticketPriceInBUSD;
    // Total number of tickets sold
    uint256 public ticketsSold;
    // Total BUSD deposited to purchase tickets
    uint256 public BUSDDeposited;
    uint256 public totalAmountWithdrawn;

    uint256 public immutable decimals = 10 ** 18;

    IERC20 private BUSD;
    address public BUSDAddress;

    event PurchaseTicket(
        address indexed beneficiary,
        uint256 quantity,
        uint256 pricePerTicketInBUSD,
        uint256 totalAmountInBUSD
    );
    event SetTicketPrice(uint256 ticketPrice_);
    event SetBUSDAddress(address BUSDAddress_);
    event WithdrawBUSD(address owner, uint256 balance);
    event RewarDistributed(address indexed beneficiary, uint256 amounts_);

    constructor() {
        // Set BUSD address
        setBUSDAddress(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        // Initial ticket price will be $1 worth of LANDS
        setticketPrice(1);
    }

    function purchaseTicket(uint256 numberOfTickets) external nonReentrant {
        require(
            numberOfTickets > 0,
            "Purchase Ticket: Number of tickets has to be greater than zero!"
        );

        uint256 totalTicketAmountBUSD = numberOfTickets * ticketPriceInBUSD;
        bool success = BUSD.transferFrom(
            _msgSender(),
            address(this),
            totalTicketAmountBUSD
        );
        if (!success) {
            revert VelasTicketSystem__InsufficientFunds();
        }
        BUSD.approve(address(this), totalTicketAmountBUSD);

        BUSDDeposited += totalTicketAmountBUSD;
        ticketsSold += numberOfTickets;

        emit PurchaseTicket(
            _msgSender(),
            numberOfTickets,
            ticketPriceInBUSD,
            totalTicketAmountBUSD
        );
    }

    /* Only Owner Functions */
    function Withdraw() public onlyOwner {
        uint256 balance = BUSD.balanceOf(address(this));
        BUSD.transfer(owner(), balance);
        BUSD.approve(owner(), balance);

        emit WithdrawBUSD(owner(), balance);
    }

    function setticketPrice(uint256 ticketPrice_) public onlyOwner {
        ticketPriceInBUSD = ticketPrice_ * decimals;
        emit SetTicketPrice(ticketPrice_ * decimals);
    }

    function setBUSDAddress(address _BUSD) public onlyOwner {
        BUSDAddress = _BUSD;
        BUSD = IERC20(_BUSD);
        emit SetBUSDAddress(_BUSD);
    }

    // To transfer tokens from Contract to the provided list of token holders with respective amount
    function batchTransfer(
        address[] memory tokenHolders,
        uint256[] memory amounts
    ) external onlyOwner {
        require(
            tokenHolders.length == amounts.length,
            "Invalid input parameters"
        );

        uint256 totalAmountToBeWithdrawn = 0;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            totalAmountToBeWithdrawn += amounts[i];
        }

        if (BUSD.balanceOf(address(this)) < totalAmountToBeWithdrawn) {
            revert VelasTicketSystem__InsufficientFunds();
        }

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            BUSD.transfer(tokenHolders[i], amounts[i]);
            BUSD.approve(tokenHolders[i], amounts[i]);
            totalAmountWithdrawn += amounts[i];
            emit RewarDistributed(tokenHolders[i], amounts[i]);
        }
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// so we can draw fees outand send to rewards pool and liquidity pool

/**
 * @title UWMarketplace
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev This Contract will be used to trade Underground Waifus (UW) NFTs.
 * @dev Users will be able to list, purchase, cancel listing, modify listed item,
 * @dev  add bid, remove bid, accept bid for UW NFTs.
 */

import "../Waifus Minting/RoyaltiesV2Impl.sol";

//============== UW Marketplace ==============
error UWMarketplace__AcceptBid_YouAreNotTheRightfulOwner();

contract UWMarketplace is
    ERC721,
    Ownable,
    Pausable,
    ReentrancyGuard,
    RoyaltiesV2Impl
{
    using Counters for Counters.Counter;
    //============== VARIABLES ==============
    Counters.Counter public _itemsListed;
    uint16 listingPercentageBasisPoints = 500;
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    //============== MAPPINGS ==============
    mapping(uint256 => mapping(address => MarketItem)) private marketItems;

    //============== STRUCTS ==============
    struct BidDetail {
        bool ifBidIsThere;
        address bidder;
        uint256 bid;
        uint256 fees;
        address tokenAddress;
    }
    struct MarketItem {
        bool listed;
        uint256 tokenId;
        address contractAdd;
        address owner;
        address seller;
        uint256 price;
        bool sold;
        address royaltyReceiver;
        uint256 royaltyValue;
        uint256 timestamp;
        address tokenAddress;
        mapping(address => BidDetail) userBid;
    }

    //============== EVENTS ==============

    event Offered(
        uint256 tokenId,
        address indexed conAdd,
        address owner,
        address indexed seller,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyValue,
        address tokenAddress,
        uint256 timestamp
    );
    event Modified(
        uint256 tokenId,
        address indexed conAdd,
        address owner,
        address indexed seller,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyValue,
        address tokenAddress,
        uint256 timestamp
    );
    event Bought(
        uint256 tokenId,
        address contractAdd,
        address indexed buyer,
        address indexed seller,
        uint256 price,
        uint256 feesPaid,
        address royaltyReceiver,
        uint256 royaltyPaid,
        address tokenAddress,
        uint256 timestamp
    );
    event CancelListing(
        uint256 indexed tokenId,
        address contractAdd,
        address indexed owner,
        address seller,
        uint256 price,
        uint256 timestamp
    );
    event AddBid(
        uint256 indexed tokenId,
        address contractAdd,
        uint256 bid,
        uint256 fees,
        address bidder,
        address tokenAddress,
        uint256 timestamp
    );
    event CancelBid(
        address contractAdd,
        uint256 tokenId,
        uint256 bid,
        uint256 fees,
        address bidder,
        address tokenAddress,
        uint256 timestamp
    );
    event SetListingPricePercentage(uint16 listingPricePercentage_);

    //============== MODIFIERS ==============

    modifier checkCreateMarketItem(
        uint256 tokenId,
        address conAdd,
        uint256 price
    ) {
        (bool _listed, , , , , , , , , , ) = getMarketItems(tokenId, conAdd);
        IERC721 nft = IERC721(conAdd);
        uint256 NFTBal = nft.balanceOf(_msgSender());
        address ownerOfNFT = nft.ownerOf(tokenId);

        require(!_listed, "Create Item: Item already listed.");
        require(NFTBal > 0, "Create Item: Insufficient Balance.");
        require(ownerOfNFT == _msgSender(), "Create Item: Not an owner.");
        require(price > 0, "Create Item: Price must be more than 0 Wei.");
        _;
    }

    modifier checkModifyMarketItem(
        uint256 tokenId,
        address conAdd,
        uint256 price
    ) {
        (
            bool _listed,
            uint256 _tokenId,
            address _conAdd,
            address _owner,
            address _seller,
            ,
            ,
            ,
            ,
            ,

        ) = getMarketItems(tokenId, conAdd);

        require(price > 0, "Create Item: Price must be more than 0 Wei.");
        require(_listed, "Modify Item: Need to list item first.");
        require(_tokenId == tokenId, "Modify Item: Item doesn't match.");
        require(_conAdd == conAdd, "Modify Item: Contract address not match.");
        require(_owner == address(this), "Modify Item: Item is not listed.");
        require(_seller == _msgSender(), "Modify Item: Not the seller.");
        _;
    }

    modifier checkPurchaseMarketItem(uint256 tokenId, address conAdd) {
        (
            bool _listed,
            uint256 _tokenId,
            address _conAdd,
            address _owner,
            address _seller,
            ,
            bool _sold,
            ,
            ,
            ,

        ) = getMarketItems(tokenId, conAdd);

        require(_seller != _msgSender(), "Purchase Item: Item not listed.");
        require(_listed, "Purchase Item: Item not listed.");
        require(!_sold, "Purchase Item: Item already sold.");
        require(_tokenId == tokenId, "Purchase Item: TokenId mismatch.");
        require(_conAdd == conAdd, "Purchase Item: Contract address mismatch.");
        require(_owner == address(this), "Purchase Item: Item already sold.");
        _;
    }

    modifier checkCancelListing(uint256 tokenId, address conAdd) {
        (
            bool _listed,
            uint256 _tokenId,
            ,
            address _owner,
            address _seller,
            ,
            ,
            ,
            ,
            ,

        ) = getMarketItems(tokenId, conAdd);

        require(_listed, "Cancel Listing: Item not listed.");
        require(_tokenId == tokenId, "Cancel Listing: Incorrect Token Id.");
        require(_owner == address(this), "Cancel Listing: Item not listed.");
        require(_seller == _msgSender(), "Cancel Listing: Not an owner.");
        _;
    }

    modifier checkAddBid(
        uint256 tokenId,
        address conAdd,
        uint256 price,
        address tokenAddress
    ) {
        BidDetail memory bid = marketItems[tokenId][conAdd].userBid[
            _msgSender()
        ];
        (bool _listed, , , , address _seller, , , , , , ) = getMarketItems(
            tokenId,
            conAdd
        );
        require(price > 0, "Add Bid: Price must be more than 0 Wei.");

        if (_listed) {
            require(_seller != _msgSender(), "Add Bid: Owner cannot Bid.");
        } else {
            IERC721 nft = IERC721(conAdd);
            address owner = nft.ownerOf(tokenId);
            require(owner != _msgSender(), "Add Bid: Owner cannot Bid.");
        }

        if (bid.ifBidIsThere) {
            require(bid.bidder == _msgSender(), "Add Bid: Bidder mismatch.");
            require(
                bid.tokenAddress == tokenAddress,
                "Add Bid: Token Address need to be same."
            );
        }
        _;
    }

    modifier checkAcceptBid(
        uint256 tokenId,
        address conAdd,
        address chosenBidder,
        address tokenAddress
    ) {
        MarketItem storage cItem = marketItems[tokenId][conAdd];
        BidDetail memory bid = cItem.userBid[chosenBidder];

        require(bid.ifBidIsThere, "Accept Bid: Bid does not exist.");
        require(bid.bidder == chosenBidder, "Accept Bid: Bidder mismatch.");
        require(
            bid.tokenAddress == tokenAddress,
            "Accept Bid: Incorrect token address."
        );
        _;
    }

    //============== CONSTRUCTOR ==============
    constructor() ERC721("NFT Marketplace", "NFTT") {}

    //============== EXTERNAL FUNCTIONS ==============
    /**
     * @notice Lists the NFT to the marketplace and sends it to this contract
     * @dev setApprovalForAll need to be true for this operator
     * @param conAdd contract address of the NFT that will be listed/transferred
     * @param tokenId tokenId of the NFT that will be listed/transferred
     * @param price Price at which user wants to list NFT
     * @param tokenAddress ERC20 token address which they want in exchange of this NFT
     */
    function createMarketItem(
        uint256 tokenId,
        address conAdd,
        uint256 price,
        address tokenAddress
    )
        external
        checkCreateMarketItem(tokenId, conAdd, price)
        whenNotPaused
        nonReentrant
    {
        checkIfContract(tokenAddress);
        _createMarketItem(tokenId, conAdd, price, tokenAddress);
    }

    /**
     * @notice Modifies the listed item details like, price, royalty, token, etc
     * @dev put correct price, tokenAddress & other details
     * @param conAdd contract address of the NFT that will be listed/transferred
     * @param tokenId tokenId of the NFT that will be listed/transferred
     * @param price Price at which user wants to list NFT
     * @param tokenAddress ERC20 token address which they want in exchange of this NFT
     */
    function modifyMarketItem(
        uint256 tokenId,
        address conAdd,
        uint256 price,
        address tokenAddress
    ) external checkModifyMarketItem(tokenId, conAdd, price) whenNotPaused {
        checkIfContract(tokenAddress);
        _modifyMarketItem(tokenId, conAdd, price, tokenAddress);
    }

    /**
     * @notice Buyer can purchase NFT with this function
     * @notice Transfers ownership of the item, as well as funds between parties
     * @dev need to have adequate token balance for this func to work
     * @dev need to approve this marketplace to receive ERC20 token
     * @dev uses Token.transferFrom() function
     * @param conAdd contract address of the NFT that will be listed/transferred
     * @param tokenId tokenId of the NFT that will be listed/transferred
     */
    function purchaseMarketItem(
        uint256 tokenId,
        address conAdd
    )
        external
        checkPurchaseMarketItem(tokenId, conAdd)
        whenNotPaused
        nonReentrant
    {
        _purchaseMarketItem(tokenId, conAdd);
    }

    /**
     * @notice allows seller to cancel a listing
     * @dev must be marketItems[tokenId][contractAdd].seller == _msgSender()
     * @param tokenId tokenId of the NFT that will be cancelled from the listing
     * @param contractAdd contract address of the NFT that will be cancelled from the listing
     */
    function cancelListing(
        uint256 tokenId,
        address contractAdd
    ) external checkCancelListing(tokenId, contractAdd) whenNotPaused {
        _cancelListing(tokenId, contractAdd);
    }

    /**
     * @notice allows buyer to cancel bid for a particular token of an NFT
     * @dev need to put correct details in params else it wont match
     * @param conAdd contract address of the NFT for which bid to be added
     * @param tokenId tokenId of the NFT for which bid to be added
     * @param price bid amount of the NFT
     * @param tokenAddress ERC20 token address which they want to bid in
     */
    function addBid(
        uint256 tokenId,
        address conAdd,
        uint256 price,
        address tokenAddress
    )
        external
        checkAddBid(tokenId, conAdd, price, tokenAddress)
        whenNotPaused
        nonReentrant
    {
        _addBid(tokenId, conAdd, price, tokenAddress);
    }

    /**
     * @notice allows seller to accept the bid which they want
     * @dev only seller can acceptBid
     * @dev this function takes high gas
     * @param conAdd contract address of the NFT for which bid to be accepted
     * @param tokenId tokenId of the NFT for which bid to be accepted
     * @param chosenBidder address of the bidder which seller wants to accept
     * @param tokenAddress ERC20 token address which they want to accept bid in
     */
    function acceptBid(
        uint256 tokenId,
        address conAdd,
        address chosenBidder,
        address tokenAddress
    )
        external
        checkAcceptBid(tokenId, conAdd, chosenBidder, tokenAddress)
        whenNotPaused
        nonReentrant
    {
        _acceptBid(tokenId, conAdd, chosenBidder, tokenAddress);
    }

    /**
     * @dev  Sets percentage basis points for fees can be calculated by dividing with 100
     * @dev 250 = 2.5% || 1000 = 10%
     * @param listingPricePercentage_ contract address of the Token
     */
    function setListingPricePercentage(
        uint16 listingPricePercentage_
    ) external onlyOwner {
        require(
            listingPricePercentage_ < 1000,
            "Set Listing Price: Cannot set Listing Price Percentage nore than 10 percent"
        );
        listingPercentageBasisPoints = listingPricePercentage_;
        emit SetListingPricePercentage(listingPricePercentage_);
    }

    /**
     * @notice can see whether an NFT is listed in the market or not
     * @dev can be used from frontend
     * @param contractAdd contract address of the NFT
     * @param tokenId tokenId of the NFT
     * @return listed bool whether an NFT is listed or not
     */
    function checkIfListed(
        address contractAdd,
        uint256 tokenId
    ) external view returns (bool) {
        return marketItems[tokenId][contractAdd].listed;
    }

    /**
     * @notice can view marketItems for a particular NFT
     * @dev can be used from frontend
     * @param tokenId tokenId of the NFT
     * @param contractAdd contract address of the NFT
     * @return bidDetail which is a struct which keeps the bid of a particular address
     */
    function showBid(
        uint256 tokenId,
        address contractAdd,
        address userAddress
    ) external view returns (BidDetail memory) {
        return marketItems[tokenId][contractAdd].userBid[userAddress];
    }

    /**
     * @notice can view marketItems for a particular NFT
     * @dev can be used from frontend
     * @param tokenId tokenId of the NFT
     * @param contractAdd contract address of the NFT
     * @return marketItems which is a struct which keeps marketItems data
     */
    function showMarketItems(
        uint256 tokenId,
        address contractAdd
    )
        external
        view
        returns (
            bool,
            uint256,
            address,
            address,
            address,
            uint256,
            bool,
            address,
            uint256,
            uint256,
            address
        )
    {
        return getMarketItems(tokenId, contractAdd);
    }

    //============== PUBLIC FUNCTIONS ==============

    /**
     * @notice buyer can cancel their bids for NFTs
     * @dev _msgSender() need to be equal to buyers address
     * @param contractAdd contract address of the NFT for which bid to be cancelled
     * @param tokenId tokenId of the NFT for which bid to be cancelled
     */
    function cancelBid(uint256 tokenId, address contractAdd) public {
        BidDetail storage bid = marketItems[tokenId][contractAdd].userBid[
            _msgSender()
        ];
        BidDetail memory _bid = bid;
        uint256 totalBid = _bid.bid + _bid.fees;

        require(
            _bid.bidder == _msgSender(),
            "Cancel Bid: You are not the correct Bidder."
        );

        (bid.ifBidIsThere, bid.bidder, bid.bid, bid.fees, bid.tokenAddress) = (
            false,
            address(0),
            0,
            0,
            address(0)
        );

        ERC20TokenTransfer(_bid.tokenAddress, _bid.bidder, totalBid);

        emit CancelBid(
            contractAdd,
            tokenId,
            _bid.bid,
            _bid.fees,
            _bid.bidder,
            _bid.tokenAddress,
            block.timestamp
        );
    }

    /**
     * @notice can view amount of fees need to paid by the bidder
     * @dev can be used from frontend to calculate the fees
     * @param bidAmount contract address of the NFT for which bid to be cancelled
     * @return fees which is initially 5%
     */
    function getTotalBidFees(uint256 bidAmount) public view returns (uint256) {
        return (bidAmount * listingPercentageBasisPoints) / 10000;
    }

    /**
     * @notice updates the listing price of the particular NFT
     * @dev can be used from frontend and inside the contract
     * @param tokenId tokenId of the NFT
     * @param conAdd contract address of the NFT
     * @return price which is used while listing from the contract or from frontend
     */
    function getTotalPrice(
        uint256 tokenId,
        address conAdd
    ) public view returns (uint256) {
        return
            (marketItems[tokenId][conAdd].price *
                (10000 + listingPercentageBasisPoints)) / 10000;
    }

    //============== INTERNAL FUNCTION =============

    function _createMarketItem(
        uint256 tokenId,
        address conAdd,
        uint256 price,
        address tokenAddress
    ) internal {
        MarketItem storage currentItem = marketItems[tokenId][conAdd];
        address royaltyReceiver;
        uint256 royaltyValue;

        if (checkRoyalties(conAdd)) {
            IERC2981 nftRoyalty = IERC2981(conAdd);
            (royaltyReceiver, royaltyValue) = nftRoyalty.royaltyInfo(
                tokenId,
                price
            );
        } else {
            royaltyReceiver = address(0);
            royaltyValue = 0;
        }

        currentItem.listed = true;
        currentItem.tokenId = tokenId;
        currentItem.contractAdd = conAdd;
        currentItem.owner = address(this);
        currentItem.seller = _msgSender();
        currentItem.price = price;
        currentItem.sold = false;
        currentItem.royaltyReceiver = royaltyReceiver;
        currentItem.royaltyValue = royaltyValue;
        currentItem.timestamp = block.timestamp;
        currentItem.tokenAddress = tokenAddress;

        _itemsListed.increment();
        ERC721TokenTransferFrom(conAdd, _msgSender(), address(this), tokenId);

        emit Offered(
            tokenId,
            conAdd,
            address(this),
            _msgSender(),
            price,
            royaltyReceiver,
            royaltyValue,
            tokenAddress,
            block.timestamp
        );
    }

    function _modifyMarketItem(
        uint256 tokenId,
        address conAdd,
        uint256 price,
        address tokenAddress
    ) internal {
        MarketItem storage cItem = marketItems[tokenId][conAdd];

        address royaltyReceiver;
        uint256 royaltyValue;

        if (checkRoyalties(conAdd)) {
            IERC2981 nftRoyalty = IERC2981(conAdd);
            (royaltyReceiver, royaltyValue) = nftRoyalty.royaltyInfo(
                tokenId,
                price
            );
        } else {
            royaltyReceiver = address(0);
            royaltyValue = 0;
        }

        cItem.price = price;
        cItem.royaltyReceiver = royaltyReceiver;
        cItem.royaltyValue = royaltyValue;
        cItem.timestamp = block.timestamp;
        cItem.tokenAddress = tokenAddress;

        emit Modified(
            tokenId,
            conAdd,
            address(this),
            _msgSender(),
            price,
            royaltyReceiver,
            royaltyValue,
            tokenAddress,
            block.timestamp
        );
    }

    function _purchaseMarketItem(uint256 tokenId, address conAdd) internal {
        (
            ,
            ,
            ,
            ,
            address _seller,
            uint256 _price,
            ,
            address _royRec,
            uint256 _royVal,
            ,
            address _tokenAdd
        ) = getMarketItems(tokenId, conAdd);
        // Check whether tokenAddress is a contract or an EOA
        checkIfContract(_tokenAdd);

        MarketItem storage cItem = marketItems[tokenId][conAdd];
        BidDetail memory bid = cItem.userBid[_msgSender()];

        (cItem.listed, cItem.owner, cItem.sold, cItem.timestamp) = (
            false,
            _msgSender(),
            true,
            block.timestamp
        );

        uint256 totalPrice = getTotalPrice(tokenId, conAdd);
        uint256 marketFees = totalPrice - _price;
        uint256 toSeller = totalPrice - marketFees - _royVal;

        _itemsListed.decrement();
        // If royalty is there
        if (_royVal > 0) {
            ERC20TokenTransferFrom(_tokenAdd, _msgSender(), _royRec, _royVal);
        }
        // Fees paid to Marketplace Owner
        ERC20TokenTransferFrom(_tokenAdd, _msgSender(), owner(), marketFees);
        // To seller
        ERC20TokenTransferFrom(_tokenAdd, _msgSender(), _seller, toSeller);

        ERC721TokenTransferFrom(conAdd, address(this), _msgSender(), tokenId);

        if (bid.ifBidIsThere) {
            cancelBid(tokenId, conAdd);
        }

        emit Bought(
            tokenId,
            conAdd,
            _msgSender(),
            _seller,
            _price,
            marketFees,
            _royRec,
            _royVal,
            _tokenAdd,
            block.timestamp
        );
    }

    function _cancelListing(uint256 tokenId, address conAdd) internal {
        MarketItem storage currentItem = marketItems[tokenId][conAdd];

        currentItem.listed = false;
        currentItem.owner = _msgSender();
        currentItem.seller = address(this);
        currentItem.price = 0;
        currentItem.sold = false;
        currentItem.royaltyReceiver = address(0);
        currentItem.royaltyValue = 0;
        currentItem.timestamp = block.timestamp;
        currentItem.tokenAddress = address(0);

        _itemsListed.decrement();

        ERC721TokenTransferFrom(conAdd, address(this), _msgSender(), tokenId);

        emit CancelListing(
            tokenId,
            conAdd,
            _msgSender(),
            address(this),
            0,
            block.timestamp
        );
    }

    function _addBid(
        uint256 tokenId,
        address conAdd,
        uint256 price,
        address tokenAddress
    ) internal {
        checkIfContract(tokenAddress);
        BidDetail storage bid = marketItems[tokenId][conAdd].userBid[
            _msgSender()
        ];

        uint256 fees = getTotalBidFees(price);
        uint256 totalPrice = price + fees;
        // If the userBid is already there
        if (bid.ifBidIsThere) {
            uint256 oldBid = bid.bid + bid.fees;
            // If new bid is bigger than old bid
            if (totalPrice >= oldBid) {
                ERC20TokenTransferFrom(
                    tokenAddress,
                    _msgSender(),
                    address(this),
                    totalPrice - oldBid
                );
            }
            // If old bid is bigger than new bid
            else {
                ERC20TokenTransfer(
                    tokenAddress,
                    _msgSender(),
                    oldBid - totalPrice
                );
            }
        }
        // If the userBid is not there
        else {
            ERC20TokenTransferFrom(
                tokenAddress,
                _msgSender(),
                address(this),
                totalPrice
            );
            bid.ifBidIsThere = true;
            bid.bidder = _msgSender();
            bid.tokenAddress = tokenAddress;
        }
        bid.bid = price;
        bid.fees = fees;

        emit AddBid(
            tokenId,
            conAdd,
            price,
            fees,
            _msgSender(),
            tokenAddress,
            block.timestamp
        );
    }

    function _acceptBid(
        uint256 tokenId,
        address conAdd,
        address chosenBidder,
        address tokenAddress
    ) internal {
        MarketItem storage cItem = marketItems[tokenId][conAdd];
        BidDetail memory _bid = cItem.userBid[chosenBidder];
        address _owner = IERC721(conAdd).ownerOf(tokenId);
        address from;

        checkIfContract(_bid.tokenAddress);

        // the person who is interacting with the contract is the owner of the NFT
        bool msgSenderIsOwner = _owner == _msgSender();
        // this marketplace is the owner of the NFT
        bool marketplaceIsOwner = _owner == address(this) &&
            cItem.seller == _msgSender();

        if (marketplaceIsOwner) {
            from = address(this);
            cItem.owner = _msgSender();
        } else if (msgSenderIsOwner) {
            from = _msgSender();
            cItem.owner = _msgSender();
        } else {
            revert UWMarketplace__AcceptBid_YouAreNotTheRightfulOwner();
        }

        {
            // scope to avoid stack too deep errors
            BidDetail storage bid = cItem.userBid[chosenBidder];
            bid.ifBidIsThere = false;
            bid.bidder = address(0);
            bid.bid = 0;
            bid.fees = 0;
            bid.tokenAddress = address(0);
        }

        address royRec;
        uint256 royVal;
        if (checkRoyalties(conAdd)) {
            IERC2981 nftRoyalty = IERC2981(conAdd);
            (royRec, royVal) = nftRoyalty.royaltyInfo(tokenId, _bid.bid);
        } else {
            royRec = address(0);
            royVal = 0;
        }

        if (cItem.listed) {
            _itemsListed.decrement();
        } else {
            cItem.tokenId = tokenId;
            cItem.contractAdd = conAdd;
            cItem.seller = _msgSender();
        }
        cItem.listed = false;
        cItem.owner = _bid.bidder;
        cItem.price = _bid.bid;
        cItem.sold = true;
        cItem.royaltyReceiver = royRec;
        cItem.royaltyValue = royVal;
        cItem.timestamp = block.timestamp;
        cItem.tokenAddress = _bid.tokenAddress;

        // If royalty is there
        if (royVal > 0) {
            ERC20TokenTransfer(tokenAddress, royRec, royVal);
        }
        // Marketfees to owner
        ERC20TokenTransfer(tokenAddress, owner(), _bid.fees);
        // Fees paid to Marketplace Owner
        ERC20TokenTransfer(tokenAddress, _msgSender(), _bid.bid - royVal);
        // NFT transferred to buyer
        ERC721TokenTransferFrom(conAdd, from, _bid.bidder, tokenId);

        emit Bought(
            tokenId,
            conAdd,
            _bid.bidder,
            _msgSender(),
            _bid.bid,
            _bid.fees,
            royRec,
            royVal,
            _bid.tokenAddress,
            block.timestamp
        );
    }

    function getMarketItems(
        uint256 tokenId,
        address conAdd
    )
        internal
        view
        returns (
            bool,
            uint256,
            address,
            address,
            address,
            uint256,
            bool,
            address,
            uint256,
            uint256,
            address
        )
    {
        MarketItem storage cItem = marketItems[tokenId][conAdd];
        return (
            cItem.listed,
            cItem.tokenId,
            cItem.contractAdd,
            cItem.owner,
            cItem.seller,
            cItem.price,
            cItem.sold,
            cItem.royaltyReceiver,
            cItem.royaltyValue,
            cItem.timestamp,
            cItem.tokenAddress
        );
    }

    /**
     * @dev  Address.isContract() Returns true if `account` is a contract
     * @dev throws error if the address is an EOA
     * @param tokenAddress contract address of the Token
     */
    function checkIfContract(address tokenAddress) internal view {
        require(
            Address.isContract(tokenAddress),
            "Create Item: Cannot be an EOA."
        );
    }

    /**
     * @dev this func checks whether NFT contract supports EIP2981
     * @dev it returns bol
     * @param  contractAdd contract address for the NFT
     * @return success it returns true = yes & false = no
     */
    function checkRoyalties(address contractAdd) internal view returns (bool) {
        bool success = IERC165(contractAdd).supportsInterface(
            _INTERFACE_ID_ERC2981
        );
        return success;
    }

    function ERC20TokenTransfer(
        address tokenAddress,
        address to,
        uint256 amount
    ) internal {
        IERC20 token = IERC20(tokenAddress);
        bool success = token.transfer(to, amount);
        require(success, "ERC20TokenTransfer: Unable to transfer ERC20 token.");
        // token.approve(to, amount);
    }

    function ERC20TokenTransferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) internal {
        IERC20 token = IERC20(tokenAddress);
        bool success = token.transferFrom(from, to, amount);
        require(
            success,
            "ERC20TokenTransferFrom: Unable to transfer ERC20 token."
        );
        // token.approve(to, amount);
    }

    function ERC721TokenTransferFrom(
        address conAdd,
        address from,
        address to,
        uint256 tokenId
    ) internal {
        IERC721 token = IERC721(conAdd);
        token.transferFrom(from, to, tokenId);
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
pragma solidity 0.8.17;

interface IERC2981 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}

library LibPart {
    bytes32 public constant TYPE_HASH =
        keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

library LibRoyaltiesV2 {
    /*
        bytes4(keccak256('getRaribleV2Royalties(uint256)')) == 0xcad96cca
     */
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
}

interface RoyaltiesV2 {
    event RoyaltiesSet(uint256 tokenId, LibPart.Part[] royalties);

    function getRaribleV2Royalties(
        uint256 id
    ) external view returns (LibPart.Part[] memory);
}

abstract contract AbstractRoyalties {
    mapping(uint256 => LibPart.Part[]) internal royalties;

    function _saveRoyalties(
        uint256 id,
        LibPart.Part[] memory _royalties
    ) internal {
        uint256 totalValue;
        for (uint256 i = 0; i < _royalties.length; i++) {
            require(
                _royalties[i].account != address(0x0),
                "Recipient should be present"
            );
            require(
                _royalties[i].value != 0,
                "Royalty value should be positive"
            );
            totalValue += _royalties[i].value;
            royalties[id].push(_royalties[i]);
        }
        require(totalValue < 10000, "Royalty total value should be < 10000");
        _onRoyaltiesSet(id, _royalties);
    }

    function _updateAccount(uint256 _id, address _from, address _to) internal {
        uint256 length = royalties[_id].length;
        for (uint256 i = 0; i < length; i++) {
            if (royalties[_id][i].account == _from) {
                royalties[_id][i].account = payable(address(uint160(_to)));
            }
        }
    }

    function _onRoyaltiesSet(
        uint256 id,
        LibPart.Part[] memory _royalties
    ) internal virtual;
}

contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2, IERC2981 {
    function getRaribleV2Royalties(
        uint256 id
    ) external view override returns (LibPart.Part[] memory) {
        return royalties[id];
    }

    function _onRoyaltiesSet(
        uint256 id,
        LibPart.Part[] memory _royalties
    ) internal override {
        emit RoyaltiesSet(id, _royalties);
    }

    /*
     *Token (ERC721, ERC721Minimal, ERC721MinimalMeta, ERC1155 ) can have a number of different royalties beneficiaries
     *calculate sum all royalties, but royalties beneficiary will be only one royalties[0].account, according to rules of IERC2981
     */

    function royaltyInfo(
        uint256 id,
        uint256 _salePrice
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        if (royalties[id].length == 0) {
            receiver = address(0);
            royaltyAmount = 0;
            return (receiver, royaltyAmount);
        }
        LibPart.Part[] memory _royalties = royalties[id];
        receiver = _royalties[0].account;
        uint256 percent;
        for (uint256 i = 0; i < _royalties.length; i++) {
            percent += _royalties[i].value;
        }
        //don`t need require(percent < 10000, "Token royalty > 100%"); here, because check later in calculateRoyalties
        royaltyAmount = (percent * _salePrice) / 10000;
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

//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "./WaifusTiers.sol";
import "./WaifusDetails.sol";
import "./RoyaltiesV2Impl.sol";

/**
 * @title Underground Waifus
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev This Contract will be used to mint Underground Waifus (UW) NFTs.
 * @dev Users will be able to purchase packs of Underground Waifus (UW) NFTs,
 * @dev This Contract use Chainlink VRF for minting random NFT's.
 */

pragma solidity 0.8.17;

//============== Underground Waifus ==============
error Waifus__RandomWordAlreadyRequested();
error Waifus__RequestRandomWordFirst();
error Waifus__InsufficientFunds();

contract Waifus is
    ERC721URIStorage,
    RoyaltiesV2Impl,
    VRFConsumerBaseV2,
    WaifusDetails,
    WaifusTiers
{
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    //============== VARIABLES ==============
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    string public baseURI;
    bool public paused;

    /* Mainnet */
    // address public TokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    /* TESTNET */
    address public marketplaceAddress =
        0x5BC23C7fDd7D5BBbb548DC9d1067b35aC414E5d3;
    address public TokenAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    /* Uniswap Variables */
    IUniswapV2Router02 internal uniswapRouter;
    address public uniswapRouterAddress =
        0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    /* VRF Variables */
    address public linkTokenAddress =
        0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    bytes32 keyHash =
        0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    uint256 public LINKToSubscription;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint64 public s_subscriptionId;
    uint256 public s_requestId;

    LinkTokenInterface LINKTOKEN;
    VRFCoordinatorV2Interface COORDINATOR;
    IERC20 internal TOKEN;

    //============== STRUCTS ==============
    struct EachCard {
        uint16 total;
        uint24 minted;
    }

    struct chestDetails {
        uint256 cost;
        uint16 TotalChest;
        uint16 TotalPurchasedChest;
        uint256[] TokenIds;
        uint8 Nums;
    }

    //============== MAPPINGS ==============
    mapping(string => chestDetails) public packDetails;
    mapping(string => mapping(string => EachCard)) public cardDetails;
    mapping(string => uint24) private tokenIdStart;
    mapping(address => string) private packToMint;
    mapping(address => mapping(string => bool)) public whitelisted;
    ///@dev Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;
    ///@dev Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;
    ///@dev Array with all token ids, used for enumeration
    uint256[] private _allTokens;
    ///@dev Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(address => bool) public s_ifRequestedRandomWords;
    mapping(uint256 => uint256[]) public s_requestIdToRandomWords;
    mapping(address => uint256) public s_requestIdToAddress;

    //============== CONSTRUCTOR ==============
    constructor() VRFConsumerBaseV2(vrfCoordinator) ERC721("Wafius", "UF") {
        setBaseURI("https://api.undergroundwaifus.com/metadata/");
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(linkTokenAddress);
        createNewSubscription();
        setLINKToTransfer((4 * 10 ** LINKTOKEN.decimals()) / 10);
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
        setTokenAddress(TokenAddress);
        setMarketplaceAddress(marketplaceAddress);
        {
            string[6] memory _unityName = [
                "common",
                "rare",
                "epic",
                "legendary",
                "mythic",
                "founder"
            ];
            uint256[6] memory _cost = [
                uint256(8000000000000000000),
                20000000000000000000,
                35000000000000000000,
                75000000000000000000,
                155000000000000000000,
                210000000000000000000
            ];

            uint16[6] memory _TotalChest = [6001, 5000, 3001, 2701, 751, 226];
            uint8[6] memory _nums = [8, 8, 8, 8, 16, 24];

            uint8[6] memory DiscPercentTier1 = [66, 66, 66, 66, 66, 100];
            uint8[6] memory DiscPercentTier2 = [50, 50, 50, 50, 50, 25];
            uint8[6] memory DiscPercentTier3 = [40, 40, 40, 40, 40, 10];
            for (uint256 i = 0; i < _unityName.length; i++) {
                setUnityDetails(
                    _unityName[i],
                    _cost[i],
                    _TotalChest[i],
                    0,
                    _nums[i]
                );

                SetDiscount(
                    1,
                    _unityName[i],
                    (_cost[i] * DiscPercentTier1[i]) / 100
                );
                SetDiscount(
                    2,
                    _unityName[i],
                    (_cost[i] * DiscPercentTier2[i]) / 100
                );
                SetDiscount(
                    3,
                    _unityName[i],
                    (_cost[i] * DiscPercentTier3[i]) / 100
                );
            }

            SetDiscount(1, "seedfounders", (_cost[5] * 10) / 100);

            for (uint256 i = 0; i < names.length; i++) {
                tokenIdStart[names[i]] = tokenIds[i];
                setCardDetails(_unityName[0], names[i], totalCommon[i], 0);
                setCardDetails(_unityName[1], names[i], totalRare[i], 0);
                setCardDetails(_unityName[2], names[i], totalEpic[i], 0);
                setCardDetails(_unityName[3], names[i], totalLegendary[i], 0);
                setCardDetails(_unityName[4], names[i], totalMythic[i], 0);
                setCardDetails(_unityName[5], names[i], totalFounder[i], 0);
            }
        }
    }

    //============== EVENTS ==============
    event SetUnityDetails(
        string _unityName,
        uint256 _cost,
        uint16 _TotalChest,
        uint16 _TotalPurchasedChest
    );
    event SetBaseURI(string URI);
    event ChestBought(address minter, string unityName, string[] cardNames);
    event RandomWordsRequested(address requester, uint256 paid);
    event SetLINKToTransfer(uint256 amount);
    event SetTokenAddress(address tokenAddress);
    event SetMarketplaceAddress(address _marketplaceAddress);
    event SetWhiteList(address user, string[] packs);

    //============== MODIFIERS ==============
    /**
     * @notice Modifier that checks the validity of the input Pack Name.
     * @param unityName The name of the NFT pack to check.
     * @dev The modifier checks that:
     *     - The `unityName` is a valid NFT pack name (e.g., "common", "rare", etc.).
     *     - The contract is not paused.
     *     - The maximum number of NFTs in the `unityName` pack has not been reached.
     * @dev If any of these conditions is not met, the modifier will revert the transaction.
     */
    modifier check(string memory unityName) {
        // chestDetails memory chestDetails = packDetails[unityName];
        require(
            hashed(unityName) == hashed("common") ||
                hashed(unityName) == hashed("rare") ||
                hashed(unityName) == hashed("epic") ||
                hashed(unityName) == hashed("legendary") ||
                hashed(unityName) == hashed("mythic") ||
                hashed(unityName) == hashed("founder"),
            "Not a Pack!"
        );
        require(!paused, "Paused!");
        require(
            packDetails[unityName].TotalPurchasedChest <
                packDetails[unityName].TotalChest,
            "Max minted!"
        );
        _;
    }

    //============== EXTERNAL FUNCTIONS ==============
    /**
     * @notice Requests random number from the vrf Chainlink oracle that will be use to mint random NFT's.
     * @param unityName The name of the pack to mint.
     * @dev The cost of the request is determined by whether the caller is whitelisted, an investor, or neither.
     * @dev Chainlink subscription should be funded sufficiently.
     * @dev If the cost is greater than 0, the function will also swap ETH for tokens and top up the Chainlink subscription.
     * @dev If the caller has already requested random words, the function will revert.
     * @dev Emits the `RandomWordsRequested` event on success.
     */

    function requestRandomWords(
        string memory unityName
    ) external check(unityName) {
        if (s_ifRequestedRandomWords[_msgSender()]) {
            revert Waifus__RandomWordAlreadyRequested();
        }

        bool success = false;
        uint256 cost;

        if (whitelisted[_msgSender()][unityName]) {
            cost = 0;
            whitelisted[_msgSender()][unityName] = false;
        } else if (investers[_msgSender()].Checkinvester) {
            cost = CalDisc(unityName, packDetails[unityName].cost);

            investers[_msgSender()].Checkinvester =
                investers[_msgSender()].max["common"] > 0 ||
                investers[_msgSender()].max["rare"] > 0 ||
                investers[_msgSender()].max["epic"] > 0 ||
                investers[_msgSender()].max["legendary"] > 0 ||
                investers[_msgSender()].max["mythic"] > 0 ||
                investers[_msgSender()].max["founder"] > 0 ||
                investers[_msgSender()].max["seedfounders"] > 0;
        } else {
            cost = packDetails[unityName].cost;
        }

        success = TOKEN.transferFrom(_msgSender(), address(this), cost);
        TOKEN.approve(address(this), cost);

        if (!success) {
            revert Waifus__InsufficientFunds();
        }

        if (cost > 0) {
            swapTokensForTokens();
            topUpSubscription();
        }

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        packToMint[_msgSender()] = unityName;
        s_ifRequestedRandomWords[_msgSender()] = true;
        s_requestIdToAddress[_msgSender()] = requestId;
        s_requestId = requestId;

        emit RandomWordsRequested(_msgSender(), cost);
    }

    /**
     *@notice BuyChest mints new NFTs for the caller based on Pack and random number they requested using requestRandomWords function.
     *@dev The caller must have previously requested random words.
     *@dev The function will revert if the caller has not previously requested random words.
     *@dev The function will mint new NFTs for the caller, set their royalties, and update the `cardDetails`, `packDetails` mappings.
     *@dev The function will emit the `ChestBought` event on success.
     */
    function BuyChest() external {
        string[] memory nameOfCard = names;
        string memory packName = packToMint[_msgSender()];
        uint8 nums = packDetails[packName].Nums;
        string[] memory mintedCards = new string[](nums);

        if (!s_ifRequestedRandomWords[_msgSender()]) {
            revert Waifus__RequestRandomWordFirst();
        }

        uint256 reqId = s_requestIdToAddress[_msgSender()];
        uint256[] memory randNum = s_requestIdToRandomWords[reqId];

        delete s_requestIdToRandomWords[reqId];
        delete s_requestIdToAddress[_msgSender()];
        s_ifRequestedRandomWords[_msgSender()] = false;

        string[] memory pack = getPack(packName, nums, nameOfCard);
        IERC721 NFT = IERC721(marketplaceAddress);

        for (uint8 i = 0; i < nums; i++) {
            uint256 lengthofPack = pack.length;
            uint256 randWord = randNum[0] % (lengthofPack - i);
            uint256 newItemId = ++tokenIdStart[pack[randWord]];

            ++cardDetails[packName][pack[randWord]].minted;

            _mint(_msgSender(), newItemId);
            NFT.setApprovalForAll(marketplaceAddress, true);
            setRoyalties(newItemId);

            packDetails[packName].TokenIds.push(newItemId);

            mintedCards[i] = (pack[randWord]);
            pack[randWord] = pack[(lengthofPack - 1) - i];
        }

        packDetails[packName].TotalPurchasedChest++;
        emit ChestBought(_msgSender(), packName, mintedCards);
    }

    /**
     * @notice Adds a consumer contract to the chainlink vrf subscription.
     * @param consumerAddress The address of the consumer contract to add.
     * @dev This function can only be called by the contract owner.
     */
    function addConsumer(address consumerAddress) external onlyOwner {
        // Add a consumer contract to the subscription.
        COORDINATOR.addConsumer(s_subscriptionId, consumerAddress);
    }

    /**
     * @notice Removes a consumer contract from the chainlink vrf subscription.
     * @param consumerAddress The address of the consumer contract to remove.
     * @dev This function can only be called by the contract owner.
     */
    function removeConsumer(address consumerAddress) external onlyOwner {
        COORDINATOR.removeConsumer(s_subscriptionId, consumerAddress);
    }

    /**
     * @notice Cancels the chainlink vrf subscription and sends the remaining LINK to a wallet address.
     * @dev This function can only be called by the contract owner.
     */
    function cancelSubscription() external onlyOwner {
        COORDINATOR.cancelSubscription(s_subscriptionId, _msgSender());
        s_subscriptionId = 0;
    }

    /**
     * @notice Pauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function pause() external onlyOwner {
        paused = true;
    }

    /**
     * @notice Unpauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function unPause() external onlyOwner {
        paused = false;
    }

    /**
     * @notice Receives and processes incoming eth payments.
     */
    receive() external payable {}

    //============== PUBLIC FUNCTIONS ==============

    /**
     * @dev Returns the set of random numbers requested by the caller.
     */
    function checkRandomWord() public view returns (uint256[] memory) {
        return (s_requestIdToRandomWords[s_requestIdToAddress[_msgSender()]]);
    }

    /**
     * @notice Determines if the contract supports a given interface.
     * @param interfaceId The ID of the interface to check.
     * @dev This function returns true if the interface is either the ERC-2981 or royalties interface.
     * @return True if the contract supports the interface, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721) returns (bool) {
        if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }
        if (interfaceId == _INTERFACE_ID_ERC2981) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Returns the URI of a given token.
     * @param tokenId The ID of the token.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        // string memory _tokenURI = _tokenURIs[tokenId];
        string memory baseUri = _baseURI();
        return
            bytes(baseUri).length > 0
                ? string(abi.encodePacked(baseUri, tokenId.toString()))
                : "";
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view virtual returns (uint256) {
        require(index < ERC721.balanceOf(owner), "Owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        require(index < Waifus.totalSupply(), "Global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @notice Sets the address of the marketplace contract.
     * @param _marketplaceAddress The address of the marketplace contract.
     * @dev The function sets the `marketplaceAddress` variable and emits the `SetMarketplaceAddress` event.
     */
    function setMarketplaceAddress(
        address _marketplaceAddress
    ) public onlyOwner {
        marketplaceAddress = _marketplaceAddress;
        emit SetMarketplaceAddress(_marketplaceAddress);
    }

    /**
     * @notice Sets the address of the ERC20 token contract.
     * @param tokenAddress The address of the ERC20 token contract.
     * @dev The function sets the `TokenAddress` variable, creates an instance of the `IERC20`
     * interface for the token contract, and emits the `SetTokenAddress` event.
     */
    function setTokenAddress(address tokenAddress) public onlyOwner {
        TokenAddress = tokenAddress;
        TOKEN = IERC20(tokenAddress);
        emit SetTokenAddress(tokenAddress);
    }

    /**
     * @notice Sets the amount of LINK to transfer to the subscription.
     * @param amount The amount of LINK to transfer to the subscription.
     * @dev The function sets the `LINKToSubscription` variable and emits the `SetLINKToTransfer` event.
     */
    function setLINKToTransfer(uint256 amount) public onlyOwner {
        uint256 linkToSubscription = amount;
        LINKToSubscription = linkToSubscription;
        emit SetLINKToTransfer(linkToSubscription);
    }

    /**
     * @notice Withdraws all ERC20 tokens from the contract.
     * @dev The function transfers all ERC20 tokens from the contract to the contract owner.
     */
    function Withdraw() public onlyOwner {
        uint256 amount = TOKEN.balanceOf(address(this));
        TOKEN.transfer(owner(), amount);
        TOKEN.approve(owner(), amount);
    }

    /**
     * @notice Sets the details for an NFT pack.
     * @param _packName The name of the NFT pack.
     * @param _cost The cost of the NFT pack.
     * @param _TotalChest The total number of NFT pack.
     * @param _TotalPurchasedChest The number of NFT packs that have been purchased.
     * @param _nums The number of NFTs that are included in a pack.
     * @dev The function sets the values of the `cost`, `TotalChest`, `TotalPurchasedChest`,
     * and `Nums` properties of the `packDetails[_packName]` mapping and emits the `SetUnityDetails` event.
     */
    function setUnityDetails(
        string memory _packName,
        uint256 _cost,
        uint16 _TotalChest,
        uint16 _TotalPurchasedChest,
        uint8 _nums
    ) public onlyOwner {
        packDetails[_packName].cost = _cost;
        packDetails[_packName].TotalChest = _TotalChest;
        packDetails[_packName].TotalPurchasedChest = _TotalPurchasedChest;
        packDetails[_packName].Nums = _nums;

        emit SetUnityDetails(
            _packName,
            _cost,
            _TotalChest,
            _TotalPurchasedChest
        );
    }

    /**
     * @notice Sets the details for an NFT.
     * @param _PackName The name of the NFT pack that the NFT belongs to.
     * @param _Cardname The name of the NFT.
     * @param _Total The total number of the NFT's that will be minted.
     * @param _Minted The number of the NFT's that have been minted.
     * @dev The function sets the values of the `total` and `minted` properties of the `cardDetails[_PackName][_Cardname]` mapping.
     */
    function setCardDetails(
        string memory _PackName,
        string memory _Cardname,
        uint16 _Total,
        uint16 _Minted
    ) public onlyOwner {
        cardDetails[_PackName][_Cardname].total = _Total;
        cardDetails[_PackName][_Cardname].minted = _Minted;
    }

    /**
     * @notice Adds a user to the whitelist.
     * @param user The address of the user to be added to the whitelist.
     * @param packs An array of packs name that the user should be whitelisted for.
     * @dev The function sets the value of the `whitelisted[user][pack]` mapping to `true`
     * for each pack in the `packs` array and emits the `SetWhiteList` event.
     */
    function setWhitelist(
        address user,
        string[] memory packs
    ) public onlyAdmin {
        for (uint256 i = 0; i < packs.length; i++) {
            whitelisted[user][packs[i]] = true;
        }
        emit SetWhiteList(user, packs);
    }

    /**
     * @notice Sets the base URI for the NFT's.
     * @param _newBaseURI The new base URI to be set.
     * @dev The function sets the value of the `baseURI` variable to `_newBaseURI` and emits the `SetBaseURI` event.
     */
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
        emit SetBaseURI(_newBaseURI);
    }

    /**
     * @notice Burns an NFT.
     * @param tokenId The ID of the NFT to be burned.
     * @dev The function calls the `_burn`.
     */
    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    //============== INTERNAL FUNCTION =============

    /**
     * @notice returns the base URI of the NFT's.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @notice fulfillRandomWords stores random number for the given request ID in `s_requestIdToRandomWords` mapping.
     * @param requestId the request ID to fulfill.
     * @param randomWords the array of random numbers.
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        s_requestIdToRandomWords[requestId] = randomWords;
    }

    /**
     * @notice getPack function returns array of cards by the given pack name, number of cards, and name of cards.
     * @dev It will first check if there are enough cards available in the pack to satisfy the number of cards requested.
     * @dev If there are enough cards available, it will create a array of cards with the specified number of cards.
     * @dev If not, it will continue to loop until it has found enough cards.
     * @param packName the name of the pack from which to retrieve cards.
     * @param nums the number of cards to retrieve.
     * @param nameOfCard the names of the cards in the pack.
     * @return string[] the array of cards as a string array.
     */
    function getPack(
        string memory packName,
        uint8 nums,
        string[] memory nameOfCard
    ) internal view returns (string[] memory) {
        uint8 count = 0;
        while (count < nums) {
            for (uint256 i = 0; i < nameOfCard.length; i++) {
                if (
                    cardDetails[packName][nameOfCard[i]].minted <
                    cardDetails[packName][nameOfCard[i]].total
                ) {
                    count++;
                }
            }
        }

        string[] memory newPack = new string[](count);
        uint8 newCount = 0;
        while (newCount < nums) {
            for (uint256 i = 0; i < nameOfCard.length; i++) {
                if (
                    cardDetails[packName][nameOfCard[i]].minted <
                    cardDetails[packName][nameOfCard[i]].total
                ) {
                    newPack[newCount] = nameOfCard[i];
                    newCount++;
                }
            }
        }
        return (newPack);
    }

    /**
     * @dev function to set royalties for a given token id
     * @param _tokenId the token id for which royalties are to be set
     */
    function setRoyalties(uint256 _tokenId) internal {
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        // Royalty taken by the NFT contract
        _royalties[0].value = 500;
        _royalties[0].account = payable(owner());
        _saveRoyalties(_tokenId, _royalties);
    }

    /**
     * @dev getTokenRequired function returns the required number of tokens to be sent to Uniswap for an amount of Link to be received.
     * @return uint256 - Required number of Link tokens.
     */
    function getTokenRequired() internal view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = TokenAddress;
        path[1] = uniswapRouter.WETH();
        path[2] = linkTokenAddress;
        uint256[] memory amountsOut = uniswapRouter.getAmountsIn(
            LINKToSubscription,
            path
        );
        return amountsOut[0];
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert("consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    //============== PRIVATE FUNCTIONS =============

    /**
    * @notice Swap tokens for tokens using uniswapRouter. 
    * @dev The TokenAddress(BUSD or LICK) and Linktoken
    are swapped for an equivalent amount of 0.2 LINK TOKEN.
    */
    function swapTokensForTokens() private {
        address[] memory path = new address[](3);
        path[0] = TokenAddress;
        path[1] = uniswapRouter.WETH();
        path[2] = linkTokenAddress;

        TOKEN.approve(uniswapRouterAddress, getTokenRequired());

        uniswapRouter.swapTokensForExactTokens(
            LINKToSubscription, //amountout
            getTokenRequired(), //amountin
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @notice creates new subscription of Chainlink VRF.
     * @dev Create a new subscription when the contract is initially deployed.
     */
    function createNewSubscription() private onlyOwner {
        s_subscriptionId = COORDINATOR.createSubscription();
        // Add this contract as a consumer of its own subscription.
        COORDINATOR.addConsumer(s_subscriptionId, address(this));
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(
        address from,
        uint256 tokenId
    ) private {
        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    /**
     * @dev This function calls transferAndCall function on the LINK token contract to top up the vrf chainlink subscription.
     */
    function topUpSubscription() private {
        LINKTOKEN.transferAndCall(
            address(COORDINATOR),
            LINKTOKEN.balanceOf(address(this)),
            abi.encode(s_subscriptionId)
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WaifusTiers
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev WaifusTiers contract is used to define investors and their discounts
 * @dev Only the owner of the contract can set the discount and change the admin
 * @dev The admin can set investors.
 */

contract WaifusTiers is Ownable {
    //============== VARIABLES ==============
    uint256 dicount;
    address public admin = 0x7B1599fd58dA00DC505157F783Ef4d4D39145b81;

    //============== STRUCT ==============
    /**
     * @dev Struct to store investors data
     */
    struct tiers {
        bool Checkinvester;
        uint8 tiertype;
        mapping(string => uint32) max;
    }
    //============== MAPPINGS ==============
    mapping(address => tiers) public investers;
    mapping(uint8 => mapping(string => uint256)) public InvestrorsDisc;

    //============== EVENTS ==============
    event SetInvester(address user, uint8 _tiertype);

    //============== MODIFIER ==============
    /**
     * @dev Modifier to ensure only the admin can call the function
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    //============== PUBLIC FUNCTIONS ==============
    /**
     * @dev Function to set the admin address
     * @param newadmin The new address to set as the admin
     */
    function SetAdmin(address newadmin) public onlyOwner {
        admin = newadmin;
    }

    /**
     * @dev Function to set the discount for a specific tier and pack
     * @param _tiertype The tier type to set the discount for
     * @param unityname The pack to set the discount for
     * @param cost The cost of the pack
     */

    function SetDiscount(
        uint8 _tiertype,
        string memory unityname,
        uint256 cost
    ) public onlyOwner {
        InvestrorsDisc[_tiertype][unityname] = cost;
    }

    /**
     * @notice sets the investment tier for the given user
     * @param user- the address of the user to set the investment tier for
     * @param investment- the amount of the user's investment
     * @dev  if investement amount is greater than 1000, it should be write it in only multiples of 1000 for seed founder calculation
     * @dev for private investers investement is set to be 0.
     */
    function setInvester(address user, uint32 investment) public onlyAdmin {
        investers[user].Checkinvester = true;
        string[7] memory pack = [
            "common",
            "rare",
            "epic",
            "legendary",
            "mythic",
            "seedfounders",
            "founder"
        ];
        if (investment >= 1000) {
            uint32 cal = investment / 1000;
            investers[user].tiertype = 1;
            investers[user].max[pack[6]] = 1;
            for (uint256 i = 0; i < 6; i++) {
                investers[user].max[pack[i]] = 4 * cal;
            }
        }

        if (investment < 1000 && investment > 499) {
            investers[user].tiertype = 2;
            investers[user].max[pack[6]] = 1;
            for (uint256 i = 0; i < 5; i++) {
                investers[user].max[pack[i]] = 2;
            }
        }

        if (investment == 0) {
            investers[user].tiertype = 3;
            investers[user].max[pack[6]] = 1;
            for (uint256 i = 0; i < 5; i++) {
                investers[user].max[pack[i]] = 1;
            }
        }

        emit SetInvester(user, investers[user].tiertype);
    }

    /**
     * @dev retrieves the maximum number of packs available for purchase at discounted cost for the given user
     * @param user -the address of the user to retrieve maximum packs available.
     * @return max - an array of maximum pack quantities for each pack.
     */

    function checkMaxAvailable(
        address user
    ) public view returns (uint32[7] memory max) {
        string[7] memory pack = [
            "common",
            "rare",
            "epic",
            "legendary",
            "mythic",
            "founder",
            "seedfounders"
        ];
        for (uint256 i = 0; i < pack.length; i++) {
            max[i] = investers[user].max[pack[i]];
        }
        return max;
    }

    //============== INTERNAL FUNCTIONS ==============
    /**
     * @dev Internal function to calculate the discount for an investor
     * @param unityName The pack to calculate the discount for
     * @param _cost The cost of the pack
     * @return cal discounted cost for the investor
     */
    function CalDisc(
        string memory unityName,
        uint256 _cost
    ) internal returns (uint256 cal) {
        if (hashed(unityName) == hashed("founder")) {
            if (investers[_msgSender()].max["founder"] > 0) {
                cal =
                    _cost -
                    InvestrorsDisc[investers[_msgSender()].tiertype]["founder"];
                investers[_msgSender()].max["founder"]--;
            } else if (investers[_msgSender()].max["seedfounders"] > 0) {
                cal =
                    _cost -
                    InvestrorsDisc[investers[_msgSender()].tiertype][
                        "seedfounders"
                    ];
                investers[_msgSender()].max["seedfounders"]--;
            } else {
                cal = _cost;
            }
        } else {
            if (investers[_msgSender()].max[unityName] > 0) {
                cal =
                    _cost -
                    InvestrorsDisc[investers[_msgSender()].tiertype][unityName];
                investers[_msgSender()].max[unityName]--;
            } else {
                cal = _cost;
            }
        }

        return cal;
    }

    /**
    @dev creates a unique hash for the given string
    @param unityName - the string to create a hash for
    @return - the unique hash of the string
    */
    function hashed(string memory unityName) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(unityName));
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Waifus Details
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev This contract holds the names and token IDs for the "Waifus" NFTs.
 * @dev It also holds information about the total supply of "Waifus" NFTs.
 */

contract WaifusDetails {
    string[] public names = [
        "Akane", "Annie", "Elfit", "Hari", "Kowasu", "Lucy", "Megumi", "Mei", "Onobiki", "Yumehime", 
        "Aomigaka", "Archa", "Gaitoro", "Gosuto", "Homure", "Koucho", "Liafa", "Lin", "Niniel", "Raion", "Reini", "Sairen", "Sasu", "Takeku", "Tsuki", 
        "Agnes", "Danmichi", "Kumoko", "Kuno", "Kyatto", "Kylie", "Midori", "Mizu", "Moyasu", "Narumi", "Rantan", "Shama", "Yakedo", "Yamicho", "Yurei", 
        "Celesne", "Fubuki", "Gekkome", "Hikigane", "Hiko", "Hyonoko", "Jukyo", "Kohaku", "Koneko", "Kumona", "OsoreKen", "Sariour", "Seimiko", "Senshina", "Subarochi", "Tenken", 
        "Dezato", "Elentari", "Kokoro", "Kyochiko", "Kyodaina", "Mesura", "Ongaku", "Osore", "Sharutira", "Shimo", "Tatsume", "Tenojo", "Yumigami", 
        "Akaratsuki", "Aoiyari", "Doraida", "Futago", "Kayori", "Kenshira", "Kirokami", "Megamin", "Ophedia", "Senpu", "Shirokami", "Tsugeiru"
        ];

    uint24[] public tokenIds = [
        0, 3968, 7936, 11904, 15872, 19840, 23808, 27776, 31744, 35712, 
        39680, 42244, 44808, 47372, 49936, 52500, 55064, 57628, 60192, 62756, 65320, 67884, 70448, 73012, 75576, 
        78140, 80315, 82490, 84665, 86840, 89015, 91190, 93365, 95540, 97715, 99890, 102065, 104240, 106415, 108590, 
        110765, 112692, 114619, 116546, 118473, 120400, 122327, 124254, 126181, 128108, 130035, 131962, 133889, 135816, 137743, 139670, 
        141597, 142208, 142819, 143430, 144041, 144652, 145263, 145874, 146485, 147096, 147707, 148318, 148929, 
        149540, 149867, 150194, 150521, 150848, 151175, 151502, 151829, 152156, 152483, 152810, 153137
    ];

    uint16[] public totalCommon =  [
        2880, 2880, 2880, 2880, 2880, 2880, 2880, 2880, 2880, 2880, 
        640, 640, 640, 640, 640, 640, 640, 640, 640, 640, 640, 640, 640, 640, 640, 
        449, 449, 449, 449, 449, 449, 449, 449, 449, 449, 449, 449, 449, 449, 449, 
        147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 
        29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 
        12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
    ];

    uint16[] public totalRare =  [
        800, 800, 800, 800, 800, 800, 800, 800, 800, 800, 
        1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 1067, 
        667, 667, 667, 667, 667, 667, 667, 667, 667, 667, 667, 667, 667, 667, 667, 
        338, 338, 338, 338, 338, 338, 338, 338, 338, 338, 338, 338, 338, 338, 338, 338, 
        30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 
        16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
    ];

    uint16[] public totalEpic = [
        264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 
        704, 704, 704, 704, 704, 704, 704, 704, 704, 704, 704, 704, 704, 704, 704, 
        440, 440, 440, 440, 440, 440, 440, 440, 440, 440, 440, 440, 440, 440, 440, 
        364, 364, 364, 364, 364, 364, 364, 364, 364, 364, 364, 364, 364, 364, 364, 364, 
        40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22
    ];

    uint16[] public totalLegendary = [
        21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 144, 144, 144, 144, 144, 144, 144,
        144, 144, 144, 144, 144, 144, 144, 144, 576, 576, 576, 576, 576, 576, 576,
        576, 576, 576, 576, 576, 576, 576, 576, 568, 568, 568, 568, 568, 568, 568,
        568, 568, 568, 568, 568, 568, 568, 568, 568, 82, 82, 82, 82, 82, 82, 82, 82,
        82, 82, 82, 82, 82, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37
    ];

    uint16[] public totalMythic = [
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 
        412, 412, 412, 412, 412, 412, 412, 412, 412, 412, 412, 412, 412, 412, 412, 412, 
        222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 
        149, 149, 149, 149, 149, 149, 149, 149, 149, 149, 149, 149
    ];

    uint16[] public totalFounder = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 
        98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 
        208, 208, 208, 208, 208, 208, 208, 208, 208, 208, 208, 208, 208, 
        91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
    ];
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

//SPDX-License-Identifier: MIT

/**
 * https://goerli.etherscan.io/address/0x6E74688585a25351D3365e3e135627a653b5075f#code
 * Yellow (Common):      [276-500] (225)
 * Purple (Uncommon):    [126-275] (150)
 * White (Rare):         [051-125] (75)
 * Red (Epic):           [016-050] (35)
 * Yellow (Legendary):   [001-015] (15)
 */

/**
 * Change OWNER address
 * Batch lock NFT feature
 * Ask to check the owner address
 * Check who can lock / unlock / add to whitelist, etc
 * Change msg.value in front end for requestRandomWords
 */

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

interface IERC2981 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

library LibPart {
    bytes32 public constant TYPE_HASH =
        keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

library LibRoyaltiesV2 {
    /*
        bytes4(keccak256('getRaribleV2Royalties(uint256)')) == 0xcad96cca
     */
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
}

interface RoyaltiesV2 {
    event RoyaltiesSet(uint256 tokenId, LibPart.Part[] royalties);

    function getRaribleV2Royalties(uint256 id)
        external
        view
        returns (LibPart.Part[] memory);
}

abstract contract AbstractRoyalties {
    mapping(uint256 => LibPart.Part[]) internal royalties;

    function _saveRoyalties(uint256 id, LibPart.Part[] memory _royalties)
        internal
    {
        uint256 totalValue;
        for (uint256 i = 0; i < _royalties.length; i++) {
            require(
                _royalties[i].account != address(0x0),
                "Recipient should be present"
            );
            require(
                _royalties[i].value != 0,
                "Royalty value should be positive"
            );
            totalValue += _royalties[i].value;
            royalties[id].push(_royalties[i]);
        }
        require(totalValue < 10000, "Royalty total value should be < 10000");
        _onRoyaltiesSet(id, _royalties);
    }

    function _updateAccount(
        uint256 _id,
        address _from,
        address _to
    ) internal {
        uint256 length = royalties[_id].length;
        for (uint256 i = 0; i < length; i++) {
            if (royalties[_id][i].account == _from) {
                royalties[_id][i].account = payable(address(uint160(_to)));
            }
        }
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties)
        internal
        virtual;
}

contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2, IERC2981 {
    function getRaribleV2Royalties(uint256 id)
        external
        view
        override
        returns (LibPart.Part[] memory)
    {
        return royalties[id];
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties)
        internal
        override
    {
        emit RoyaltiesSet(id, _royalties);
    }

    /*
     *Token (ERC721, ERC721Minimal, ERC721MinimalMeta, ERC1155 ) can have a number of different royalties beneficiaries
     *calculate sum all royalties, but royalties beneficiary will be only one royalties[0].account, according to rules of IERC2981
     */

    function royaltyInfo(uint256 id, uint256 _salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        if (royalties[id].length == 0) {
            receiver = address(0);
            royaltyAmount = 0;
            return (receiver, royaltyAmount);
        }
        LibPart.Part[] memory _royalties = royalties[id];
        receiver = _royalties[0].account;
        uint256 percent;
        for (uint256 i = 0; i < _royalties.length; i++) {
            percent += _royalties[i].value;
        }
        //don`t need require(percent < 10000, "Token royalty > 100%"); here, because check later in calculateRoyalties
        royaltyAmount = (percent * _salePrice) / 10000;
    }
}

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

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    mapping(uint256 => bool) internal locked;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: address zero is not a valid owner"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

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
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer();
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer();
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            !locked[tokenId],
            "Transfer: Your NFT is locked, need talk with support!"
        );
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer();
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

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
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    // Check this because it
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(), //Operator
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer() internal virtual {
        return;
    }
}

abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) internal _tokenURIs;

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

error Nakashi__RandomWordAlreadyRequested();
error Nakashi__RequestRandomWordFirst();
error Nakashi__InsufficientFunds();

contract Nakashi is
    ERC721URIStorage,
    RoyaltiesV2Impl,
    VRFConsumerBaseV2,
    Ownable
{
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCount;
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    // https://nakashibackend.herokuapp.com/api/metadata/
    string public baseURI;
    uint16 public maxMintSupply = 500;
    // Max item one that one wallet can mint
    uint256 public maxMintAmount = 500;
    // Can pause and unpause minting
    bool public paused = false;

    mapping(string => PackDetail) public unityDetails;
    mapping(address => bool) public whitelisted;

    struct PackDetail {
        uint16 maxSupplyOfNFT;
        uint16 itemsMinted;
        uint256[] tokenIds;
        uint16 tokenId;
    }
    uint256 public cost = 0.1 ether;
    uint256 public whiteListCost = 0.05 ether;
    uint256 public returnCost = 0.01 ether;
    uint256 LINKToSubscription;

    // Uniswap Variables
    IUniswapV2Router02 internal uniswapRouter;
    // Change values for mainnet
    address public uniswapRouterAddress =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    // VRF Variables
    LinkTokenInterface LINKTOKEN;
    VRFCoordinatorV2Interface COORDINATOR;

    address public linkToken = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint64 public s_subscriptionId;

    mapping(address => bool) public s_ifRequestedRandomWords;
    mapping(uint256 => uint256[]) public s_requestIdToRandomWords;
    mapping(address => uint256) public s_requestIdToAddress;
    uint256 public s_requestId;

    // https://api.nakashi.world/api/metadata/
    constructor(string memory _initBaseURI)
        VRFConsumerBaseV2(vrfCoordinator)
        ERC721("Nakashi Manga", "NM")
    {
        string[5] memory packs = [
            "common",
            "uncommon",
            "rare",
            "epic",
            "legendary"
        ];
        uint8[5] memory packMaxMintAmount = [225, 150, 75, 35, 15];
        uint16[5] memory packTokenIdStart = [275, 125, 50, 15, 0];
        setBaseURI(_initBaseURI);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(linkToken);
        createNewSubscription();
        setLINKToTransfer(1);

        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);

        for (uint8 i = 0; i < packs.length; i++) {
            setUnityDetails(
                packs[i],
                packMaxMintAmount[i],
                packTokenIdStart[i]
            );

            _tokenIdCount.increment();
            uint16 newItemId = ++unityDetails[packs[i]].tokenId;
            _mint(_msgSender(), newItemId);
            setRoyalties(newItemId);
            unityDetails[packs[i]].itemsMinted++;
            unityDetails[packs[i]].tokenIds.push(newItemId);
            emit NFTMinted(_msgSender(), newItemId, packs[i]);
        }
    }

    event SetUnityDetails(
        string _unityName,
        uint16 _maxSupplyOfNFT,
        uint16 _tokenId
    );
    event SetCost(uint256 cost_);
    event LockNFT(uint256 _tokenId);
    event UnlockNFT(uint256 _tokenId);
    event IsPaused(bool _yesOrNo);
    event SetBaseURI(string URI);
    event SetMaxMintSupply(uint16 _maxMintSupply);
    event NFTMinted(address minter, uint256 tokenId, string unityName);
    event SetReturnCost(uint256 _cost);
    event ReturnComic(address _user);
    event SetWhiteList(address user, bool yesNo);
    event RandomWordsRequested(address requester, uint256 paid);
    event SetLINKToTransfer(uint256 amount);

    /* Will check all the conditions */
    modifier check(string memory unityName) {
        PackDetail memory packDetail = unityDetails[unityName];
        require(
            keccak256(abi.encodePacked(unityName)) ==
                keccak256(abi.encodePacked("common")) ||
                keccak256(abi.encodePacked(unityName)) ==
                keccak256(abi.encodePacked("uncommon")) ||
                keccak256(abi.encodePacked(unityName)) ==
                keccak256(abi.encodePacked("rare")) ||
                keccak256(abi.encodePacked(unityName)) ==
                keccak256(abi.encodePacked("epic")) ||
                keccak256(abi.encodePacked(unityName)) ==
                keccak256(abi.encodePacked("legendary")),
            "Check: Unrecognized Unity name!"
        );
        require(
            packDetail.itemsMinted < packDetail.maxSupplyOfNFT,
            "Check: Max supply minted of the particular NFT reached!"
        );
        _;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721)
        returns (bool)
    {
        if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }
        if (interfaceId == _INTERFACE_ID_ERC2981) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external payable {
        uint256 currentBalanceOfNFTs = IERC721(address(this)).balanceOf(
            _msgSender()
        );
        // If random number is already requested then it will revert
        if (s_ifRequestedRandomWords[_msgSender()]) {
            revert Nakashi__RandomWordAlreadyRequested();
        }
        require(
            _tokenIdCount.current() < maxMintSupply,
            "Check: Maximum NFTs minted!"
        );

        require(
            currentBalanceOfNFTs < maxMintAmount,
            "Check: Cannot mint more NFTs than MaxMintAmount"
        );
        require(!paused, "Check: NFT contract is paused");

        bool success = false;

        if (whitelisted[_msgSender()]) {
            (success, ) = payable(address(this)).call{value: whiteListCost}("");
            require(
                msg.value == whiteListCost,
                "Request Random Words: Try Sending WhitelistCost."
            );
        }
        if (!whitelisted[_msgSender()]) {
            (success, ) = payable(address(this)).call{value: cost}("");
            require(
                msg.value == cost,
                "Request Random Words: Try Sending Normal Cost."
            );
        }
        if (!success) {
            revert Nakashi__InsufficientFunds();
        }

        // Swapping ETH to LINK
        swapETHForTokens();
        topUpSubscription();

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_ifRequestedRandomWords[_msgSender()] = true;
        s_requestIdToAddress[_msgSender()] = requestId;
        s_requestId = requestId;
        emit RandomWordsRequested(_msgSender(), msg.value);
    }

    function checkRandomWord() public view returns (uint256[] memory) {
        return (s_requestIdToRandomWords[s_requestIdToAddress[_msgSender()]]);
    }

    // function checkRandomWord(address user)
    //     public
    //     view
    //     returns (uint256[] memory)
    // {
    //     return (s_requestIdToRandomWords[s_requestIdToAddress[user]]);
    // }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        s_requestIdToRandomWords[requestId] = randomWords;
    }

    function getPacks() internal view returns (string[] memory) {
        string[5] memory packs = [
            "common",
            "uncommon",
            "rare",
            "epic",
            "legendary"
        ];
        uint8 count = 0;
        for (uint i = 0; i < packs.length; i++) {
            if (
                unityDetails[packs[i]].itemsMinted <=
                unityDetails[packs[i]].maxSupplyOfNFT
            ) {
                count++;
            }
        }
        string[] memory newPacks = new string[](count);
        for (uint i = 0; i < packs.length; i++) {
            if (
                unityDetails[packs[i]].itemsMinted <=
                unityDetails[packs[i]].maxSupplyOfNFT
            ) {
                newPacks[i] = packs[i];
            }
        }
        return newPacks;
    }

    function _Newmint(string memory unityName) internal check(unityName) {
        _tokenIdCount.increment();
        uint16 newItemId = ++unityDetails[unityName].tokenId;
        _mint(_msgSender(), newItemId);

        setRoyalties(newItemId);

        unityDetails[unityName].itemsMinted++;
        unityDetails[unityName].tokenIds.push(newItemId);

        emit NFTMinted(_msgSender(), newItemId, unityName);
    }

    function mint() external {
        // If random number is not requested then it will revert
        if (!s_ifRequestedRandomWords[_msgSender()]) {
            revert Nakashi__RequestRandomWordFirst();
        }
        string[] memory packs = getPacks();
        uint256 reqId = s_requestIdToAddress[_msgSender()];
        uint256[] memory randNum = s_requestIdToRandomWords[reqId];
        uint256 randomNumber = randNum[0] % packs.length;

        delete s_requestIdToRandomWords[reqId];
        delete s_requestIdToAddress[_msgSender()];
        s_ifRequestedRandomWords[_msgSender()] = false;

        // If the user is whitelisted then set it to false
        if (whitelisted[_msgSender()]) {
            whitelisted[_msgSender()] = false;
            emit SetWhiteList(_msgSender(), false);
        }

        // mint an NFT
        _Newmint(packs[randomNumber]);
    }

    function setRoyalties(uint256 _tokenId) internal {
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        // Royalty taken by the NFT contract
        _royalties[0].value = 900;
        _royalties[0].account = payable(
            address(0x11159a7d3F8a8cd35305dAF5751828Cb9C3c8E4a)
        );
        _saveRoyalties(_tokenId, _royalties);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory currentBaseURI = _baseURI();

        //  If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(currentBaseURI).length > 0) {
            return
                string(
                    abi.encodePacked(
                        //"https://api.nakashi.world/api/metadata/"
                        currentBaseURI,
                        // 95
                        tokenId.toString()
                        // baseExtension
                    )
                );
        }
        //  If there is no base URI, return the token URI.
        if (bytes(currentBaseURI).length == 0) {
            return _tokenURI;
        }

        return super.tokenURI(tokenId);
    }

    function checkIfLocked(uint256 tokenId) public view returns (bool) {
        require(
            _exists(tokenId),
            "Check Locked: URI query for nonexistent token"
        );
        return locked[tokenId];
    }

    function returnComic() external payable {
        if (msg.value != returnCost) {
            revert Nakashi__InsufficientFunds();
        }

        emit ReturnComic(_msgSender());
    }

    // Assumes this contract owns link.
    // 1000000000000000000 = 1 LINK
    function topUpSubscription() public {
        LINKTOKEN.transferAndCall(
            address(COORDINATOR),
            LINKTOKEN.balanceOf(address(this)),
            abi.encode(s_subscriptionId)
        );
    }

    function swapETHForTokens() public {
        address[] memory path = new address[](2);

        path[0] = uniswapRouter.WETH();
        path[1] = linkToken;

        // Swap tokens to ETH
        uniswapRouter.swapETHForExactTokens{value: address(this).balance}(
            LINKToSubscription,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    /** ONLY OWNER FUNCTIONS */

    function setLINKToTransfer(uint256 amount) public onlyOwner {
        uint256 linkToSubscription = amount * 10**LINKTOKEN.decimals();
        LINKToSubscription = linkToSubscription;
        emit SetLINKToTransfer(linkToSubscription);
    }

    // Create a new subscription when the contract is initially deployed.
    function createNewSubscription() private onlyOwner {
        s_subscriptionId = COORDINATOR.createSubscription();
        // Add this contract as a consumer of its own subscription.
        COORDINATOR.addConsumer(s_subscriptionId, address(this));
    }

    function addConsumer(address consumerAddress) external onlyOwner {
        // Add a consumer contract to the subscription.
        COORDINATOR.addConsumer(s_subscriptionId, consumerAddress);
    }

    function removeConsumer(address consumerAddress) external onlyOwner {
        // Remove a consumer contract from the subscription.
        COORDINATOR.removeConsumer(s_subscriptionId, consumerAddress);
    }

    function cancelSubscription() external onlyOwner {
        // Cancel the subscription and send the remaining LINK to a wallet address.
        COORDINATOR.cancelSubscription(s_subscriptionId, _msgSender());
        s_subscriptionId = 0;
    }

    function setWhitelist(address[] memory users) public onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelisted[users[i]] = true;
            emit SetWhiteList(users[i], true);
        }
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
        emit SetBaseURI(_newBaseURI);
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
        emit IsPaused(_state);
    }

    function burn(uint256 tokenId) public {
        require(
            !checkIfLocked(tokenId),
            "Burn: Your asset is locked, cannot burn!"
        );
        _burn(tokenId);
    }

    function Withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send ETH");
    }

    function unlockNFT(uint256 tokenId) public onlyOwner {
        locked[tokenId] = false;
        emit UnlockNFT(tokenId);
    }

    function lockNFT(uint256 tokenId) public onlyOwner {
        locked[tokenId] = true;
        emit LockNFT(tokenId);
    }

    function batchLockNFT(uint256[] memory _tokenIds) public onlyOwner {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            locked[_tokenIds[i]] = true;
            emit LockNFT(_tokenIds[i]);
        }
    }

    function batchUnlockNFT(uint256[] memory _tokenIds) public onlyOwner {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            locked[_tokenIds[i]] = false;
            emit UnlockNFT(_tokenIds[i]);
        }
    }

    function setUnityDetails(
        string memory _unityName,
        uint16 _maxSupplyOfNFT,
        uint16 _tokenId
    ) public onlyOwner {
        require(
            keccak256(abi.encodePacked(_unityName)) ==
                keccak256(abi.encodePacked("common")) ||
                keccak256(abi.encodePacked(_unityName)) ==
                keccak256(abi.encodePacked("uncommon")) ||
                keccak256(abi.encodePacked(_unityName)) ==
                keccak256(abi.encodePacked("rare")) ||
                keccak256(abi.encodePacked(_unityName)) ==
                keccak256(abi.encodePacked("epic")) ||
                keccak256(abi.encodePacked(_unityName)) ==
                keccak256(abi.encodePacked("legendary")),
            "Check: Unrecognized Unity name!"
        );

        unityDetails[_unityName].maxSupplyOfNFT = _maxSupplyOfNFT;

        // If the Id is being set on deployement
        // Only works on deployement
        if (unityDetails[_unityName].tokenId == 0) {
            unityDetails[_unityName].tokenId = _tokenId;
        }

        emit SetUnityDetails(
            _unityName,
            _maxSupplyOfNFT,
            unityDetails[_unityName].tokenId
        );
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
        emit SetCost(_cost);
    }

    function setReturnCost(uint256 _cost) external onlyOwner {
        returnCost = _cost;
        emit SetReturnCost(_cost);
    }

    function setMaxMintSupply(uint16 _maxMintSupply) public onlyOwner {
        maxMintSupply = _maxMintSupply;
        emit SetMaxMintSupply(_maxMintSupply);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721Receiver.sol";

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @title LICK (ERC20 Token)
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev This is an ERC20 token contract for LICK mintable, pausable, burnable, ownable
 * @dev This contract also acts as a liquidity pool
 * @dev  which swaps LICK <-> BNB and puts it into LP which is in PancakeSwap
 * @dev  owner must create a liquidity pool for LICK & BNB right after deployement
 * so it can automatically swap LICK and put to liquidity pool
 * else it will throw an error and users will face problem in transfers
 */

//============== LICK (ERC20) ==============
contract LICK is ERC20, ERC20Burnable, Pausable, Ownable {
    IUniswapV2Router02 public pancakeRouter;

    //============== VARIABLES ==============
    address public pancakeRouterAddress =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public pancakePair;
    address public liquidityReceiver = owner(); //need to change it owner address later.
    bool public autoSwapAndLiquifyEnabled;
    bool isSwapAndLiquify;
    uint256 public minTokensBeforeSwap = 500000 * 10**decimals();

    //============== EVENTS ==============
    event EnabledAutoSwapAndLiquify();
    event DisabledAutoSwapAndLiquify();
    event MinTokensBeforeSwapUpdated(
        uint256 previousMinSwap,
        uint256 currentMinSwap
    );
    event SetRouterAddress(address _routerAddress);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    //============== MODIFIERS ==============
    modifier lockTheSwap() {
        isSwapAndLiquify = true;
        _;
        isSwapAndLiquify = false;
    }

    //============== CONSTRUCTOR ==============
    constructor() ERC20("LICK", "LICK") {
        uint256 mintAmount = 100000000 * 10**decimals();
        _mint(msg.sender, mintAmount);
        enableAutoSwapAndLiquify();
    }

    //============== EXTERNAL FUNCTIONS ==============
    //to receive ETH from pancakeSwapV2Router when swaping
    receive() external payable {}

    //============== onlyOwner FUNCTIONS =============
    /**
     * @notice disables autoswap and liquify
     * @dev must be false to put tokens into liquidity pool
     */
    function disableAutoSwapAndLiquify() external onlyOwner {
        require(
            autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature is already disabled."
        );
        autoSwapAndLiquifyEnabled = false;
        emit DisabledAutoSwapAndLiquify();
    }

    /**
     * @notice minimum LICK required for the swap
     * @dev need to be in wei
     * @param _minTokensBeforeSwap minimum wei amount required for the swap
     */
    function setMinTokensBeforeSwap(uint256 _minTokensBeforeSwap)
        external
        onlyOwner
    {
        uint256 previousMinTokensBeforeSwap = minTokensBeforeSwap;
        minTokensBeforeSwap = _minTokensBeforeSwap;
        emit MinTokensBeforeSwapUpdated(
            previousMinTokensBeforeSwap,
            _minTokensBeforeSwap
        );
    }

    /**
     * @notice will set the router address
     * @param _routerAddress pancake router address
     */
    function setRouterAddress(address _routerAddress) external onlyOwner {
        require(_routerAddress != address(0), "Invalid router address");
        pancakeRouterAddress = _routerAddress;
        pancakeRouter = IUniswapV2Router02(_routerAddress);
        emit SetRouterAddress(_routerAddress);
    }

    /**
     * @notice set _pause to true
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice set _pause to false
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice owner can mint tokens
     * @param to address of the owner
     * @param amount total amount in wei to be minted
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @notice enables autoswap and liquify
     * @dev must be true to put tokens into liquidity pool
     */
    function enableAutoSwapAndLiquify() public onlyOwner {
        require(
            !autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature is already enabled."
        );

        IUniswapV2Router02 _pancakeRouter = IUniswapV2Router02(
            pancakeRouterAddress
        );
        pancakePair = IUniswapV2Factory(_pancakeRouter.factory()).createPair(
            address(this),
            _pancakeRouter.WETH()
        );
        pancakeRouter = _pancakeRouter;
        autoSwapAndLiquifyEnabled = true;
        emit EnabledAutoSwapAndLiquify();
    }

    //============== INTERNAL FUNCTION =============
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @notice this functions automatically puts LICK received,
     * by this contract to liquidity pool
     * @dev autoSwapAndLiquifyEnabled need to be enable for this function to swap
     */
    function _afterTokenTransfer(
        address,
        address,
        uint256
    ) internal override whenNotPaused {
        if (autoSwapAndLiquifyEnabled) {
            uint256 contractBalance = balanceOf(address(this));

            // whether the current contract balances makes the threshold to swap and liquify.
            bool overMinTokensBeforeSwap = contractBalance >=
                minTokensBeforeSwap;

            if (
                overMinTokensBeforeSwap &&
                !isSwapAndLiquify &&
                _msgSender() != pancakePair &&
                autoSwapAndLiquifyEnabled
            ) {
                contractBalance = minTokensBeforeSwap;
                swapAndLiquify(contractBalance);
                contractBalance = 0;
            }
        }
    }

    //============== PRIVATE FUNCTIONS =============
    /**
     * @notice swaps half LICK to BNB and put both BNB LICK to the liquidity pool
     * @param contractBalance total contractBalance that need to be swapped
     */
    function swapAndLiquify(uint256 contractBalance) private lockTheSwap {
        uint256 tokensToSwap = (contractBalance * 5000) / 10000;
        uint256 tokensAddToLiquidity = contractBalance - tokensToSwap;

        swapTokensForEth(tokensToSwap);
        uint256 ethAddToLiquify = address(this).balance;
        addLiquidity(ethAddToLiquify, tokensAddToLiquidity);

        emit SwapAndLiquify(
            tokensToSwap,
            ethAddToLiquify,
            tokensAddToLiquidity
        );
    }

    /**
     * @notice swaps dedicated amount from LICK -> BNB
     * @param amount total LICK amount that need to be swapped to BNB
     */
    function swapTokensForEth(uint256 amount) private {
        // Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        _approve(address(this), address(pancakeRouter), amount);

        pancakeRouter.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this), // this contract will receive the eth that were swapped from the token
            block.timestamp
        );
    }

    /**
     * @notice puts tokens into liquidity pool
     * @param ethAmount BNB amount that is needed
     * @param tokenAmount LICK amount that is needed
     */
    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private {
        _approve(address(this), address(pancakeRouter), tokenAmount);

        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityReceiver, // the LP is sent to burnAccount.
            block.timestamp
        );
    }
}

//SPDX-License-Identifier:MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./IERC20.sol";

/**
 * @title TicketSystemCD
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev The TicketSystemCD contract is used for purchasing tickets for CryptoDuels.
 */

contract TicketSystemNew is Ownable, ReentrancyGuard, Pausable {
    IUniswapV2Router02 public pancakeRouter;

    //============== VARIABLES ==============
    IERC20 public GQToken;
    uint256 public ticketPrice;
    uint256 public teamPercentage;
    uint256 public rewardPoolPercentage;
    uint256 public burnPercentage;
    uint256 public withdrawLimit;
    uint256 public OZFees;
    address public pancakeRouterAddress;

    address public teamAddress;
    address public rewardPool;
    address public admin;
    uint256 decimals;

    address private GQ_BUSD_pair;

    struct UserInfo {
        uint256 ticketBalance;
        uint256 lastWithdrawalTime;
    }

    //============== MAPPINGS ==============
    mapping(address => UserInfo) public userInfo;

    //============== EVENTS ==============
    event TicketPurchased(
        address indexed buyer,
        uint256 numofTicket,
        uint256 amountPaid
    );
    event TicketWithdrawn(
        address indexed user,
        uint256 numOfTicket,
        uint256 amountRefund
    );
    event FeesTransfered(
        uint256 teamAmount,
        uint256 rewardPoolAmount,
        uint256 burnAmount
    );
    event TokenWithdrawn(address indexed owner, uint256 amount);
    event SetUserBalance(address indexed user, uint256 amount);
    event SetTokenAddress(address tokenAddr);
    event SetPairAddress(address pairAddr);
    event SetTicketprice(uint256 price);
    event SetTeamPercentage(uint256 teamPercent);
    event SetRewardPoolPercentage(uint256 rewardPoolPercent);
    event SetBurnPercentage(uint256 burnPercent);
    event SetWithdrawLimit(uint256 withdrawLimit);
    event SetOZFees(uint256 OZFees);
    event SetTeamAddress(address teamAddr);
    event SetRewardAddress(address rewardPoolAddr);
    event SetAdmin(address newAdmin);
    event SetRouterAddress(address _routerAddress);

    //============== CONSTRUCTOR ==============
    constructor() {
        decimals = 10 ** 18;
        ticketPrice = 1 * decimals;
        teamPercentage = (ticketPrice * 1000) / 10000;
        rewardPoolPercentage = (ticketPrice * 250) / 10000;
        burnPercentage = (ticketPrice * 250) / 10000;
        withdrawLimit = 500 * decimals;
        OZFees = (2500 * decimals) / 10000;

        // testnet
        pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        pancakeRouter = IUniswapV2Router02(pancakeRouterAddress);
        GQToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        teamAddress = 0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769;
        rewardPool = 0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769;
        admin = payable(0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769);
        GQ_BUSD_pair = 0x209eBd953FA5e3fE1375f7Dd0a848A9621e9eaFc;

        // mainnet
        // pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // pancakeRouter = IUniswapV2Router02(pancakeRouterAddress);
        // GQToken = IERC20(0xF700D4c708C2be1463E355F337603183D20E0808);
        // GQ_BUSD_pair = 0x72121d60b0e2F01c0FB7FE32cA24021b42165A40;
        // admin = payable(0xbb1220Eb122f85aE0FAf61D89e0727C4962b4506);
        // teamAddress = 0x81319B34e571d8aE7725bD611bcB8c0b3556bF01;
        // rewardPool = 0x81319B34e571d8aE7725bD611bcB8c0b3556bF01;
    }

    //============== MODIFIER ==============
    /**
     * @dev Modifier to ensure only the admin can call the function
     */
    modifier onlyAdmin() {
        require(_msgSender() == admin, "Only admin");
        _;
    }

    //============== VIEW FUNCTIONS ==============
    /**
     * @dev Function to get GQ price from Pancackeswap
     */
    function getPrice() public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(GQ_BUSD_pair)
            .getReserves();
        return (uint256(reserve1) * 1e18) / uint256(reserve0);
    }

    //============== EXTERNAL FUNCTIONS ==============
    /**
     * @dev Function to Purchase Tickets
     * @param numOfTicket to select quantity of tickets to purchase
     */
    function purchaseTicket(
        uint256 numOfTicket
    ) external payable whenNotPaused nonReentrant {
        require(
            numOfTicket > 0,
            "Purchase Ticket: Number of Ticket should be greater than Zero"
        );
        uint256 amount;
        uint256 ticketAmount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;
        uint256 ozFees = (OZFees * getPrice()) / decimals;

        amount =
            ticketAmount +
            teamAmount +
            rewardPoolAmount +
            burnAmount +
            ozFees;

        bool success = GQToken.transferFrom(
            _msgSender(),
            address(this),
            amount
        );
        require(success, "Purchase Ticket: GQ transfer failed.");
        feesTransfer(teamAmount, rewardPoolAmount, burnAmount);

        swapTokensForEth(ozFees);
        uint256 BNBBalance = address(this).balance;
        (bool BNBSuccess, ) = admin.call{value: BNBBalance}("");
        require(BNBSuccess, "Purchase Ticket: BNB transfer failed.");

        userInfo[_msgSender()].ticketBalance += numOfTicket;

        emit TicketPurchased(_msgSender(), numOfTicket, amount);
    }

    function getFees(
        uint256 numOfTicket
    ) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 ticketAmount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;
        // need to do get
        uint256 ozFees = (OZFees * getPrice()) / decimals;
        return (ticketAmount, teamAmount, rewardPoolAmount, burnAmount, ozFees);
    }

    /**
     * @dev Function to Withdraw Tickets
     * @param numOfTicket to select quantity of tickets to withdraw
     */
    function withdrawTicket(
        uint256 numOfTicket
    ) external whenNotPaused nonReentrant {
        require(
            userInfo[_msgSender()].ticketBalance >= numOfTicket,
            "Withdraw Ticket: Insufficient Balance"
        );
        require(
            numOfTicket >= 1,
            "Withdraw Ticket: Amount should be greater than Zero"
        );
        if (userInfo[_msgSender()].lastWithdrawalTime != 0) {
            require(
                userInfo[_msgSender()].lastWithdrawalTime + 24 hours <=
                    block.timestamp,
                "Withdraw Ticket: Withdrawal is only allowed once every 24 hours"
            );
        }

        uint256 amount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;

        uint256 balance = GQToken.balanceOf(address(this));
        require(
            balance >= amount,
            "Withdraw Ticket: Not enough balance in the contract"
        );
        require(
            amount <= (withdrawLimit * getPrice()) / decimals,
            "Withdraw Ticket: Withdrawal amount exceeds Limit"
        );

        uint256 ticketAmount = amount -
            (teamAmount + rewardPoolAmount + burnAmount);

        userInfo[_msgSender()].lastWithdrawalTime = block.timestamp;
        userInfo[_msgSender()].ticketBalance -= numOfTicket;

        bool success = GQToken.transfer(_msgSender(), ticketAmount);
        require(success, "Withdraw Ticket: Return Failed");

        feesTransfer(teamAmount, rewardPoolAmount, burnAmount);

        emit TicketWithdrawn(_msgSender(), numOfTicket, ticketAmount);
    }

    /**
     * @notice swaps dedicated amount from GQ -> BNB
     * @param amount total GQ amount that need to be swapped to BNB
     */
    function swapTokensForEth(uint256 amount) private {
        // Generate the uniswap pair path of GQToken -> weth
        address[] memory path = new address[](2);
        path[0] = address(GQToken);
        path[1] = pancakeRouter.WETH();

        GQToken.approve(address(pancakeRouter), amount);

        pancakeRouter.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this), // this contract will receive the eth that were swapped from the GQToken
            block.timestamp
        );
    }

    /**
     * @notice will set the router address
     * @param _routerAddress pancake router address
     */
    function setRouterAddress(address _routerAddress) external onlyOwner {
        require(
            _routerAddress != address(0),
            "Set Router Address: Invalid router address"
        );
        pancakeRouterAddress = _routerAddress;
        pancakeRouter = IUniswapV2Router02(_routerAddress);
        emit SetRouterAddress(_routerAddress);
    }

    /**
     * @dev Function to Withdraw funds
     */
    function withdraw() external onlyOwner {
        uint256 balance = GQToken.balanceOf(address(this));
        require(balance > 0, "Withdraw: Not enough balance in the contract");
        bool success;
        success = GQToken.transfer(owner(), balance);
        require(success, "Withdraw: Withdraw Failed");
        emit TokenWithdrawn(owner(), balance);
    }

    /**
     * @dev Function to set the user's ticket balance
     * @param user address of user whose balance is to be set
     * @param amount The balance change amount to be set
     */
    function setUserBalance(
        address user,
        uint256 amount
    ) external onlyAdmin whenNotPaused nonReentrant {
        require(user != address(0), "Set User Balance: Invalid user address");
        userInfo[user].ticketBalance = amount;
        emit SetUserBalance(user, amount);
    }

    /**
     * @dev Function to set the admin address
     * @param newAdmin The new address to set as the admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "Set Admin: Invalid address");
        admin = newAdmin;
        emit SetAdmin(admin);
    }

    /**
     * @dev Function to set the new GQToken address that is used Purchasing tickets
     * @param tokenAdd The new GQToken address
     */
    function setTokenAddress(address tokenAdd) external onlyOwner {
        require(tokenAdd != address(0), "Set Token Address: Invalid address");
        GQToken = IERC20(tokenAdd);
        emit SetTokenAddress(tokenAdd);
    }

    /**
     * @dev Function to set the new Pair address of GQToken pool
     * @param pairAdd The new pair address
     */
    function setPairAddress(address pairAdd) external onlyOwner {
        require(pairAdd != address(0), "Set Pair Address: Invalid address");
        GQ_BUSD_pair = pairAdd;
        emit SetPairAddress(pairAdd);
    }

    /**
     * @dev Function to set the Ticket Price
     * @param newPrice The new tick price in wei for 1 ticket.
     */
    function setTicketPrice(uint256 newPrice) external onlyOwner {
        require(
            newPrice > 0,
            "Set Ticket Price: New Price should be greater than Zero"
        );
        ticketPrice = newPrice;
        emit SetTicketprice(newPrice);
    }

    /**
     * @dev Function to set the Ticket OpenZepellin Fees.
     * @param amount The new limit amount in wei.
     */
    function setOZFees(uint256 amount) external onlyOwner {
        require(amount > 0, "Set OZ Fees: OZ Fees be greater than Zero");
        OZFees = amount;
        emit SetOZFees(amount);
    }

    /**
     * @dev Function to set the Ticket withdraw limit.
     * @param amount The new limit amount in wei.
     */
    function setWithdrawLimit(uint256 amount) external onlyOwner {
        require(
            amount > 0,
            "Set Withdraw limit: Withdraw limit be greater than Zero"
        );
        withdrawLimit = amount;
        emit SetWithdrawLimit(amount);
    }

    /**
     * @dev Function to set amount that will be transfered to Team
     * @param amount The new team share amount in wei for 1 ticket price
     */
    function setTeamPercentage(uint256 amount) external onlyOwner {
        teamPercentage = amount;
        emit SetTeamPercentage(amount);
    }

    /**
     * @dev Function to set amount that will be transfered to Reward pool
     * @param amount The new reward pool share amount in wei for 1 ticket price
     */
    function setRewardPoolPercentage(uint256 amount) external onlyOwner {
        rewardPoolPercentage = amount;
        emit SetRewardPoolPercentage(amount);
    }

    /**
     * @dev Function to set GQToken amount that will be burned.
     * @param amount The new burn share amount in wei for 1 ticket price
     */
    function setBurnPercentage(uint256 amount) external onlyOwner {
        burnPercentage = amount;
        emit SetBurnPercentage(amount);
    }

    /**
     * @dev Function to set the Team address
     * @param newTeamAddress The new address to set as the Team address
     */
    function setTeamAddress(address newTeamAddress) external onlyOwner {
        require(
            newTeamAddress != address(0),
            "Set Team Address: Invalid address"
        );
        teamAddress = newTeamAddress;
        emit SetTeamAddress(teamAddress);
    }

    /**
     * @dev Function to set the admin address
     * @param newRewardPoolAddress The new address to set as the Rewardpool address
     */
    function setRewardAddress(address newRewardPoolAddress) external onlyOwner {
        require(
            newRewardPoolAddress != address(0),
            "Set Reward Address: Invalid address"
        );
        rewardPool = newRewardPoolAddress;
        emit SetRewardAddress(rewardPool);
    }

    /**
     * @notice Pauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function unPause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Internal function to transfer the fees.
     * @param teamAmnt amount to transfer to team.
     * @param rewardPoolAmnt amount to transfer to reward pool.
     * @param burnAmnt amount to burn tokens.
     */
    function feesTransfer(
        uint256 teamAmnt,
        uint256 rewardPoolAmnt,
        uint256 burnAmnt
    ) internal {
        bool teamTransfer = GQToken.transfer(teamAddress, teamAmnt);
        require(teamTransfer, "Fees Tramsfer: Team transfer failed");

        bool rewardPoolTransfer = GQToken.transfer(rewardPool, rewardPoolAmnt);
        require(
            rewardPoolTransfer,
            "Fees Transfer: RewardPool Transfer failed"
        );

        bool burnTransfer = GQToken.burn(burnAmnt);
        require(burnTransfer, "Fees Transfer: Burn failed");

        emit FeesTransfered(teamAmnt, rewardPoolAmnt, burnAmnt);
    }

    receive() external payable {}
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
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) external returns (bool);

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

//SPDX-License-Identifier:MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./IERC20.sol";

/**
 * @title TicketSystemCD
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev The TicketSystemCD contract is used for purchasing tickets for CryptoDuels.
 */

contract TicketSystemCD is Ownable, ReentrancyGuard, Pausable {
    //============== VARIABLES ==============
    IERC20 public GQToken;
    uint256 public ticketPrice;
    uint256 public teamPercentage;
    uint256 public rewardPoolPercentage;
    uint256 public burnPercentage;
    uint256 public withdrawLimit;
    uint256 public OZFees;

    address public teamAddress;
    address public rewardPool;
    address public admin;
    uint256 decimals;

    address private PairAddress;

    struct UserInfo {
        uint256 ticketBalance;
        uint256 lastWithdrawalTime;
    }

    //============== MAPPINGS ==============
    mapping(address => UserInfo) public userInfo;

    //============== EVENTS ==============
    event TicketPurchased(
        address indexed buyer,
        uint256 numofTicket,
        uint256 amountPaid
    );
    event TicketWithdrawn(
        address indexed user,
        uint256 numOfTicket,
        uint256 amountRefund
    );
    event FeesTransfered(
        uint256 teamAmount,
        uint256 rewardPoolAmount,
        uint256 burnAmount
    );
    event TokenWithdrawn(address indexed owner, uint256 amount);
    event SetUserBalance(address indexed user, uint256 amount);
    event SetTokenAddress(address tokenAddr);
    event SetPairAddress(address pairAddr);
    event SetTicketprice(uint256 price);
    event SetTeamPercentage(uint256 teamPercent);
    event SetRewardPoolPercentage(uint256 rewardPoolPercent);
    event SetBurnPercentage(uint256 burnPercent);
    event SetWithdrawLimit(uint256 withdrawLimit);
    event SetOZFees(uint256 OZFees);
    event SetTeamAddress(address teamAddr);
    event SetRewardAddress(address rewardPoolAddr);
    event SetAdmin(address newAdmin);
    event SetRouterAddress(address _routerAddress);

    //============== CONSTRUCTOR ==============
    constructor() {
        decimals = 10 ** 18;
        ticketPrice = 1 * decimals;
        teamPercentage = (ticketPrice * 1000) / 10000;
        rewardPoolPercentage = (ticketPrice * 250) / 10000;
        burnPercentage = (ticketPrice * 250) / 10000;
        withdrawLimit = 500 * decimals;
        OZFees = 787280000000000;

        GQToken = IERC20(0xF700D4c708C2be1463E355F337603183D20E0808);
        PairAddress = 0x72121d60b0e2F01c0FB7FE32cA24021b42165A40;
        admin = 0xbb1220Eb122f85aE0FAf61D89e0727C4962b4506;
        teamAddress = 0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769;
        rewardPool = 0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769;
    }

    //============== MODIFIER ==============
    /**
     * @dev Modifier to ensure only the admin can call the function
     */
    modifier onlyAdmin() {
        require(_msgSender() == admin, "Only admin");
        _;
    }

    //============== VIEW FUNCTIONS ==============
    /**
     * @dev Function to get GQ price from Pancackeswap
     */
    function getPrice() public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(PairAddress)
            .getReserves();
        return (uint256(reserve1) * 1e18) / uint256(reserve0);
    }

    //============== EXTERNAL FUNCTIONS ==============
    /**
     * @dev Function to Purchase Tickets
     * @param numOfTicket to select quantity of tickets to purchase
     */
    function purchaseTicket(
        uint256 numOfTicket
    ) external payable whenNotPaused nonReentrant {
        require(
            numOfTicket > 0,
            "Purchase Ticket: Number of Ticket should be greater than Zero"
        );
        require(msg.value >= OZFees, "Purchase Ticket: Invalid OZ Fees");
        uint256 ticketAmount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;

        bool success = GQToken.transferFrom(
            _msgSender(),
            address(this),
            ticketAmount
        );
        require(success, "Purchase Ticket: GQ transfer failed.");
        feesTransfer(teamAmount, rewardPoolAmount, burnAmount);

        (bool BNBSuccess, ) = admin.call{value: OZFees}("");
        require(BNBSuccess, "Purchase Ticket: BNB transfer failed.");

        userInfo[_msgSender()].ticketBalance += numOfTicket;

        emit TicketPurchased(
            _msgSender(),
            numOfTicket,
            ticketAmount + teamAmount + rewardPoolAmount + burnAmount
        );
    }

    /**
     * @dev Function to Withdraw Tickets
     * @param numOfTicket to select quantity of tickets to withdraw
     */
    function withdrawTicket(
        uint256 numOfTicket
    ) external whenNotPaused nonReentrant {
        require(
            userInfo[_msgSender()].ticketBalance >= numOfTicket,
            "Withdraw Ticket: Insufficient Balance"
        );
        require(
            numOfTicket >= 1,
            "Withdraw Ticket: Amount should be greater than Zero"
        );
        if (userInfo[_msgSender()].lastWithdrawalTime != 0) {
            require(
                userInfo[_msgSender()].lastWithdrawalTime + 24 hours <=
                    block.timestamp,
                "Withdraw Ticket: Withdrawal is only allowed once every 24 hours"
            );
        }

        uint256 amount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;

        uint256 balance = GQToken.balanceOf(address(this));
        require(
            balance >= amount,
            "Withdraw Ticket: Not enough balance in the contract"
        );
        require(
            amount <= (withdrawLimit * getPrice()) / decimals,
            "Withdraw Ticket: Withdrawal amount exceeds Limit"
        );

        userInfo[_msgSender()].lastWithdrawalTime = block.timestamp;
        userInfo[_msgSender()].ticketBalance -= numOfTicket;

        bool success = GQToken.transfer(_msgSender(), amount);
        require(success, "Withdraw Ticket: Return Failed");

        feesTransfer(teamAmount, rewardPoolAmount, burnAmount);

        emit TicketWithdrawn(
            _msgSender(),
            numOfTicket,
            amount + teamAmount + rewardPoolAmount + burnAmount
        );
    }

    /**
     * @dev Function to Withdraw funds
     */
    function withdraw() external onlyOwner {
        uint256 balance = GQToken.balanceOf(address(this));
        require(balance > 0, "Withdraw: Not enough balance in the contract");
        bool success;
        success = GQToken.transfer(owner(), balance);
        require(success, "Withdraw: Withdraw Failed");
        emit TokenWithdrawn(owner(), balance);
    }

    /**
     * @dev Function to set the user's ticket balance
     * @param user address of user whose balance is to be set
     * @param amount The balance change amount to be set
     */
    function setUserBalance(
        address user,
        uint256 amount
    ) external onlyAdmin whenNotPaused nonReentrant {
        require(user != address(0), "Set User Balance: Invalid user address");
        userInfo[user].ticketBalance = amount;
        emit SetUserBalance(user, amount);
    }

    /**
     * @dev Function to set the admin address
     * @param newAdmin The new address to set as the admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "Set Admin: Invalid address");
        admin = newAdmin;
        emit SetAdmin(admin);
    }

    /**
     * @dev Function to set the new GQToken address that is used Purchasing tickets
     * @param tokenAdd The new GQToken address
     */
    function setTokenAddress(address tokenAdd) external onlyOwner {
        require(tokenAdd != address(0), "Set Token Address: Invalid address");
        GQToken = IERC20(tokenAdd);
        emit SetTokenAddress(tokenAdd);
    }

    /**
     * @dev Function to set the new Pair address of GQToken pool
     * @param pairAdd The new pair address
     */
    function setPairAddress(address pairAdd) external onlyOwner {
        require(pairAdd != address(0), "Set Pair Address: Invalid address");
        PairAddress = pairAdd;
        emit SetPairAddress(pairAdd);
    }

    /**
     * @dev Function to set the Ticket Price
     * @param newPrice The new tick price in wei for 1 ticket.
     */
    function setTicketPrice(uint256 newPrice) external onlyOwner {
        require(
            newPrice > 0,
            "Set Ticket Price: New Price should be greater than Zero"
        );
        ticketPrice = newPrice;
        emit SetTicketprice(newPrice);
    }

    /**
     * @dev Function to set the Ticket OpenZepellin Fees.
     * @param amount The new limit amount in wei.
     */
    function setOZFees(uint256 amount) external onlyOwner {
        require(amount > 0, "Set OZ Fees: OZ Fees be greater than Zero");
        OZFees = amount;
        emit SetOZFees(amount);
    }

    /**
     * @dev Function to set the Ticket withdraw limit.
     * @param amount The new limit amount in wei.
     */
    function setWithdrawLimit(uint256 amount) external onlyOwner {
        require(
            amount > 0,
            "Set Withdraw limit: Withdraw limit be greater than Zero"
        );
        withdrawLimit = amount;
        emit SetWithdrawLimit(amount);
    }

    /**
     * @dev Function to set amount that will be transfered to Team
     * @param amount The new team share amount in wei for 1 ticket price
     */
    function setTeamPercentage(uint256 amount) external onlyOwner {
        teamPercentage = amount;
        emit SetTeamPercentage(amount);
    }

    /**
     * @dev Function to set amount that will be transfered to Reward pool
     * @param amount The new reward pool share amount in wei for 1 ticket price
     */
    function setRewardPoolPercentage(uint256 amount) external onlyOwner {
        rewardPoolPercentage = amount;
        emit SetRewardPoolPercentage(amount);
    }

    /**
     * @dev Function to set GQToken amount that will be burned.
     * @param amount The new burn share amount in wei for 1 ticket price
     */
    function setBurnPercentage(uint256 amount) external onlyOwner {
        burnPercentage = amount;
        emit SetBurnPercentage(amount);
    }

    /**
     * @dev Function to set the Team address
     * @param newTeamAddress The new address to set as the Team address
     */
    function setTeamAddress(address newTeamAddress) external onlyOwner {
        require(
            newTeamAddress != address(0),
            "Set Team Address: Invalid address"
        );
        teamAddress = newTeamAddress;
        emit SetTeamAddress(teamAddress);
    }

    /**
     * @dev Function to set the admin address
     * @param newRewardPoolAddress The new address to set as the Rewardpool address
     */
    function setRewardAddress(address newRewardPoolAddress) external onlyOwner {
        require(
            newRewardPoolAddress != address(0),
            "Set Reward Address: Invalid address"
        );
        rewardPool = newRewardPoolAddress;
        emit SetRewardAddress(rewardPool);
    }

    /**
     * @notice Pauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function unPause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Internal function to transfer the fees.
     * @param teamAmnt amount to transfer to team.
     * @param rewardPoolAmnt amount to transfer to reward pool.
     * @param burnAmnt amount to burn tokens.
     */
    function feesTransfer(
        uint256 teamAmnt,
        uint256 rewardPoolAmnt,
        uint256 burnAmnt
    ) internal {
        bool teamTransfer = GQToken.transferFrom(
            _msgSender(),
            teamAddress,
            teamAmnt
        );
        require(teamTransfer, "Fees Tramsfer: Team transfer failed");

        bool rewardPoolTransfer = GQToken.transferFrom(
            _msgSender(),
            rewardPool,
            rewardPoolAmnt
        );
        require(
            rewardPoolTransfer,
            "Fees Transfer: RewardPool Transfer failed"
        );

        bool burnTransfer = GQToken.burn(burnAmnt);
        require(burnTransfer, "Fees Transfer: Burn failed");

        emit FeesTransfered(teamAmnt, rewardPoolAmnt, burnAmnt);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title RewardPoolWaifus
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev  The RewardPoolWaifus contract is used for distributing rewards.
 */

contract RewardPoolWaifus is Ownable, ReentrancyGuard, Pausable {
    //============== VARIABLES ==============
    address public admin = 0xa0BD24F30218c5D431319e57d0580dd992879007;
    uint256 public totalRewardDistributed;
    IERC20 public rewardToken =
        IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    //============== MAPPINGS ==============
    mapping(address => uint256) public rewardsCollected;

    //============== EVENTS ==============
    event RewardDistributed(address indexed beneficiary, uint256 amounts);
    event TotalRewardDistributed(uint256 amounts);
    event WithdrawToken(address indexed owner, uint256 amounts);
    event SetTokenAddress(address newRewardToken);
    event SetAdmin(address newAdmin);

    //============== MODIFIER ==============
    /**
     * @dev Modifier to ensure only the admin can call the function
     */
    modifier onlyAdmin() {
        require(_msgSender() == admin, "Only admin");
        _;
    }

    //============== EXTERNAL FUNCTIONS ==============
    /**
    @dev Function to allow the contract owner to withdraw their balance
    @notice There must be a balance greater than 0 in the contract for the owner to withdraw
    */
    function withdraw() external onlyOwner {
        uint256 balances = rewardToken.balanceOf(address(this));
        require(balances > 0, "Not enough balance in the contract");
        bool success = rewardToken.transfer(owner(), balances);
        require(success, "Transfer failed.");
        emit WithdrawToken(owner(), balances);
    }

    /**
     * @dev Function to set the Reward token address
     * @param newToken The new address to set as the reward token
     */
    function setTokenAddress(address newToken) external onlyOwner {
        require(newToken != address(0), "Invalid address");
        rewardToken = IERC20(newToken);
        emit SetTokenAddress(newToken);
    }

    /**
     * @dev Function to set the admin address
     * @param newAdmin The new address to set as the admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
        emit SetAdmin(admin);
    }

    /**
     * @dev Function to distribute rewards to a specific address
     * @param recipient The address to send the rewards to
     * @param amount The amount of rewards to send
     * @notice Only the admin can call this function
     * @notice The contract must be unpaused to call this function
     */
    function distributeReward(address recipient, uint256 amount)
        external
        onlyAdmin
        whenNotPaused
        nonReentrant
    {
        require(recipient != address(0), "Invalid recipient address");
        uint256 balances = rewardToken.balanceOf(address(this));
        require(balances >= amount, "Not enough balance in the contract");
        rewardsCollected[recipient] += amount;
        totalRewardDistributed += amount;

        bool success = rewardToken.transfer(recipient, amount);
        require(success, "Transfer failed.");

        emit RewardDistributed(recipient, amount);
        emit TotalRewardDistributed(totalRewardDistributed);
    }

    /**
     * @notice Pauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function unPause() external onlyOwner {
        _unpause();
    }
}

//SPDX-License-Identifier:MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title RewardPoolCD
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev The RewardPoolCD contract is used for purchasing tickets for CryptoDuels.
 */

contract RewardPoolCD is Ownable, ReentrancyGuard, Pausable {
    //============== VARIABLES ==============
    address public admin;
    uint256 public totalRewardDistributed;
    IERC20 public rewardToken;

    //============== MAPPINGS ==============
    mapping(address => uint256) public rewardsCollected;

    //============== EVENTS ==============
    event RewardDistributed(address indexed beneficiary, uint256 amounts);
    event TotalRewardDistributed(uint256 amounts);
    event WithdrawToken(address indexed owner, uint256 amounts);
    event SetTokenAddress(address newRewardToken);
    event SetAdmin(address newAdmin);

    //============== CONSTRUCTOR ==============
    constructor() {
        admin = 0xa0BD24F30218c5D431319e57d0580dd992879007;
        rewardToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    }

    //============== MODIFIER ==============
    /**
     * @dev Modifier to ensure only the admin can call the function
     */
    modifier onlyAdmin() {
        require(_msgSender() == admin, "Only admin");
        _;
    }

    //============== EXTERNAL FUNCTIONS ==============
    /**
    @dev Function to allow the contract owner to withdraw their balance
    @notice There must be a balance greater than 0 in the contract for the owner to withdraw
    */
    function withdraw() external onlyOwner {
        uint256 balances = rewardToken.balanceOf(address(this));
        require(balances > 0, "Not enough balance in the contract");
        bool success = rewardToken.transfer(owner(), balances);
        require(success, "Transfer failed.");
        emit WithdrawToken(owner(), balances);
    }

    /**
     * @dev Function to set the Reward token address
     * @param newToken The new address to set as the reward token
     */
    function setTokenAddress(address newToken) external onlyOwner {
        require(newToken != address(0), "Invalid address");
        rewardToken = IERC20(newToken);
        emit SetTokenAddress(newToken);
    }

    /**
     * @dev Function to set the admin address
     * @param newAdmin The new address to set as the admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
        emit SetAdmin(admin);
    }

    /**
     * @dev Function to distribute rewards to a specific address
     * @param recipient The address to send the rewards to
     * @param amount The amount of rewards to send
     * @notice Only the admin can call this function
     * @notice The contract must be unpaused to call this function
     */
    function distributeReward(
        address recipient,
        uint256 amount
    ) external onlyAdmin whenNotPaused nonReentrant {
        require(recipient != address(0), "Invalid recipient address");
        uint256 balances = rewardToken.balanceOf(address(this));
        require(balances >= amount, "Not enough balance in the contract");
        rewardsCollected[recipient] += amount;
        totalRewardDistributed += amount;

        bool success = rewardToken.transfer(recipient, amount);
        require(success, "Transfer failed.");

        emit RewardDistributed(recipient, amount);
        emit TotalRewardDistributed(totalRewardDistributed);
    }

    /**
     * @notice Pauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function unPause() external onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT

/* git rm --cached ignored-folder
    While deploying on mainnet change the following things-
    => Ask and change Rewards/Team/Liquidity fees
    => Change Router Address
    => Ask and change _minTokensBeforeSwap, liquidityreceiver to burnaddress for token lock
    => Change marketing receiver address
    => Check compiler version
 */

/*
    #LANDS features:
    6% fee auto add to the liquidity pool 
    6% fee auto distribute to all holders
    6% fee auto will be sent back to the team for further developments
 */

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IPancake.sol";

contract LANDS is Context, IERC20, Ownable {
    using Address for address;

    // ERC20 Token Standard
    string private _name = "LANDS Token";

    // ERC20 Token Standard
    string private _symbol = "LANDS";

    // ERC20 Token Standard
    uint256 private _decimals = 18;

    // Keeps track of balances for address that are included in receiving reward.
    mapping(address => uint256) private _reflectionBalances;

    // Keeps track of balances for address that are excluded from receiving reward.
    mapping(address => uint256) private _tokenBalances;

    // ERC20 Token Standard
    mapping(address => mapping(address => uint256)) private _allowances;

    // Keeps track of which address are excluded from fee.
    mapping(address => bool) private _isExcludedFromFee;

    // Keeps track of which address are excluded from reward.
    mapping(address => bool) private _isExcludedFromReward;

    // Keeps track of txLimitExempt
    mapping(address => bool) isTxLimitExempt;

    // An array of addresses that are excluded from reward.
    address[] private _excluded;

    // A number that helps distributing fees to all holders respectively.
    uint256 private _reflectionTotal;

    // ERC20 Token Standard
    uint256 private _totalSupply = 100 * (10**6) * (10**_decimals);

    // Total amount of tokens rewarded / distributing.
    uint256 private _totalRewarded;

    // This percent of a transaction will be redistribute to all holders.
    uint8 public _taxReward = 6;

    /* This percent of a transaction will be added to the liquidity pool. 
    More details at https://github.com/Sheldenshi/ERC20Deflationary.*/
    uint8 public _taxLiquify = 6;

    // This percent of a transaction will be added for further developments
    uint8 public _devTax = 6;

    // A threshold for swap and liquify.
    uint256 public _minTokensBeforeSwap = 5 * (10**5) * (10**_decimals);

    // Max Tx Amount~
    uint256 public _maxTxAmount = 2 * (10**5) * (10**_decimals);

    // Liquidity pool provider router
    IPancakeRouter02 internal _pancakeRouter;

    // This Token and WETH pair contract address.
    address internal _pancakePair;

    // Total amount of tokens locked in the LP (this token and WETH pair).
    uint256 public _totalTokensLockedInLiquidity;

    // Total amount of ETH locked in the LP (this token and WETH pair).
    uint256 public _totalETHLockedInLiquidity;

    // Whether a previous call of SwapAndLiquify process is still in process.
    bool _inSwapAndLiquify;

    // To check if autoSwapAndLiquify is enabled
    bool public _autoSwapAndLiquifyEnabled;

    // To check if reward is enabled
    bool public _rewardEnabled;

    // To check if dev fee is enabled
    bool public _devFeeEnabled;

    // Prevent reentrancy.
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    // Return values of _getValues function.
    struct ValuesFromAmount {
        // Amount of tokens for to transfer.
        uint256 amount;
        // Amount tokens charged for development.
        uint256 tDevFee;
        // Amount tokens charged to reward.
        uint256 tRewardFee;
        // Amount tokens charged to add to liquidity.
        uint256 tLiquifyFee;
        // Amount tokens after fees.
        uint256 tTransferAmount;
        // Reflection of amount.
        uint256 rAmount;
        // Reflection of dev fee.
        uint256 rDevFee;
        // Reflection of reward fee.
        uint256 rRewardFee;
        // Reflection of liquify fee.
        uint256 rLiquifyFee;
        // Reflection of transfer amount.
        uint256 rTransferAmount;
    }

    /*
        Events
    */
    event MinTokensBeforeSwapUpdated(
        uint256 previousMinTokensBeforeSwap,
        uint256 minTokensBeforeSwap_
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event ExcludeAccountFromFee(address account);
    event IncludeAccountInFee(address account);
    event ExcludeAccountFromReward(address account);
    event IncludeAccountInReward(address account);
    event EnabledDevFee();
    event EnabledReward();
    event EnabledAutoSwapAndLiquify();
    event DevFeeUpdate(uint8 previousTax, uint8 currentTax);
    event TaxRewardUpdate(uint8 previousTax, uint8 currentTax);
    event TaxLiquifyUpdate(uint8 previousTax, uint8 currentTax);
    event SetTxnLimit(uint256 maxTxAmount_);
    event DisabledDevFee();
    event DisabledReward();
    event DisabledAutoSwapAndLiquify();
    event FeeDistributedAmongHolders(uint256 rewardFee);
    event DevFeeTransfer(uint256 devFee);
    event IncludeTxLimit(address holder);
    event ExcludeFromTxLimit(address holder);
    event Airdrop(uint256 amount);

    // Liquidity pool provider router
    address _routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    // Where burnt tokens are sent to. This is an address that no one can have accesses to.
    address private constant burnAccount =
        0x000000000000000000000000000000000000dEaD;

    // Where burnt tokens are sent to. This is an address that no one can have accesses to.
    address private constant zeroAddress =
        0x0000000000000000000000000000000000000000;

    // dev fee receiver
    address private constant marketingReceiver =
        0x3442aB0f13361a3a2D7149D6072eF4d94C34c52e;

    // Liquidity Pool tokens receiver => need to be Burn / Zero address
    address private constant liquidityReceiver =
        0x9Dcd3212FD95dA843D4EE2Ec00BfE71D0d201Db9;

    constructor() {
        // Enable dev fee
        enableDevFee(_devTax);

        // Enable holder's reward
        enableReward(_taxReward);

        // Enable AutoSwapAndLiquify
        enableAutoSwapAndLiquify(
            _taxLiquify,
            _routerAddress,
            _minTokensBeforeSwap
        );

        // Excluding burn and zero addresses from reward
        excludeFromReward(burnAccount);
        excludeFromReward(zeroAddress);

        // exclude this contract from fee.
        excludeFromFee(address(this));
        excludeFromTxLimit(address(this));

        _reflectionTotal = (~uint256(0) - (~uint256(0) % _totalSupply));
        _reflectionBalances[_msgSender()] = _reflectionTotal;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns whether an account is excluded from reward.
     */
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }

    /**
     * @dev Returns whether an account is excluded from fee.
     */
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    /**
     Gives total number of tokens rewarded from reward tax
     */
    function totalRewarded() public view returns (uint256) {
        return _totalRewarded;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tokenBalances[account];
        return tokenFromReflection(_reflectionBalances[account]);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        checkTxLimit(sender, recipient, amount);

        /*If sender or the recipient is excluded form fee, the fee is not charged */
        ValuesFromAmount memory values = _getValues(
            amount,
            _isExcludedFromFee[sender] || _isExcludedFromFee[recipient]
        );
        if (
            _isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferFromExcluded(sender, recipient, values);
        } else if (
            !_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferToExcluded(sender, recipient, values);
        } else if (
            !_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferStandard(sender, recipient, values);
        } else if (
            _isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferBothExcluded(sender, recipient, values);
        } else {
            _transferStandard(sender, recipient, values);
        }
        emit Transfer(sender, recipient, values.tTransferAmount);

        if ((!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient])) {
            _afterTokenTransfer(values);
        }
    }

    /**
     * @dev Performs transfer from an excluded account to an included account.
     * (included and excluded from receiving reward.)
     */
    function _transferFromExcluded(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs transfer from an included account to an excluded account.
     * (included and excluded from receiving reward.)
     */
    function _transferToExcluded(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _tokenBalances[recipient] =
            _tokenBalances[recipient] +
            values.tTransferAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs transfer between two accounts that are both included in receiving reward.
     */
    function _transferStandard(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs transfer between two accounts that are both excluded in receiving reward.
     */
    function _transferBothExcluded(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _tokenBalances[recipient] =
            _tokenBalances[recipient] +
            values.tTransferAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs all the functionalities that are enabled.
     */
    function _afterTokenTransfer(ValuesFromAmount memory values)
        internal
        virtual
    {
        // Dev Fee
        if (_devFeeEnabled) {
            // adding fees to the wallets for development
            _tokenBalances[marketingReceiver] += values.tDevFee;
            _reflectionBalances[marketingReceiver] += values.rDevFee;
            emit DevFeeTransfer(values.tDevFee);
        }
        // Reflect
        if (_rewardEnabled) {
            _distributeFee(values.rRewardFee, values.tRewardFee);
        }

        // Add to liquidity pool
        if (_autoSwapAndLiquifyEnabled) {
            // add liquidity fee to this contract.
            _tokenBalances[address(this)] += values.tLiquifyFee;
            _reflectionBalances[address(this)] += values.rLiquifyFee;
            emit Transfer(_msgSender(), address(this), values.tLiquifyFee);

            uint256 contractBalance = balanceOf(address(this));

            // whether the current contract balances makes the threshold to swap and liquify.
            bool overMinTokensBeforeSwap = contractBalance >=
                _minTokensBeforeSwap;

            if (
                overMinTokensBeforeSwap &&
                !_inSwapAndLiquify &&
                _msgSender() != _pancakePair &&
                _autoSwapAndLiquifyEnabled
            ) {
                contractBalance = _minTokensBeforeSwap;
                swapAndLiquify(contractBalance);
                contractBalance = 0;
            }
        }
    }

    /**
     * @dev Returns fees and transfer amount in both tokens and reflections.
     * tXXXX stands for tokenXXXX
     * rXXXX stands for reflectionXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getValues(uint256 amount, bool deductTransferFee)
        private
        view
        returns (ValuesFromAmount memory)
    {
        ValuesFromAmount memory values;
        values.amount = amount;
        _getTValues(values, deductTransferFee);
        _getRValues(values, _getRate(), deductTransferFee);
        return (values);
    }

    /**
     * @dev Adds fees and transfer amount in tokens to `values`.
     * tXXXX stands for tokenXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getTValues(ValuesFromAmount memory values, bool deductTransferFee)
        private
        view
    {
        if (deductTransferFee) {
            values.tTransferAmount = values.amount;
        } else {
            values.tDevFee = calculateDevFee(values.amount);
            values.tRewardFee = calculateTaxFee(values.amount);
            values.tLiquifyFee = calculateLiquidityFee(values.amount);
            values.tTransferAmount =
                values.amount -
                values.tRewardFee -
                values.tLiquifyFee;
        }
    }

    /**
     * @dev Adds fees and transfer amount in reflection to `values`.
     * rXXXX stands for reflectionXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getRValues(
        ValuesFromAmount memory values,
        uint256 currentRate,
        bool deductTransferFee
    ) private pure {
        values.rAmount = values.amount * currentRate;
        if (deductTransferFee) {
            values.rTransferAmount = values.rAmount;
        } else {
            values.rAmount = values.amount * currentRate;
            values.rDevFee = values.tDevFee * currentRate;
            values.rRewardFee = values.tRewardFee * currentRate;
            values.rLiquifyFee = values.tLiquifyFee * currentRate;
            values.rTransferAmount =
                values.rAmount -
                values.rRewardFee -
                values.rLiquifyFee;
        }
    }

    /**
     * @dev Returns the current reflection rate.
     */
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    /**
     * @dev Returns the current reflection supply and token supply.
     */
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _reflectionTotal;
        uint256 tSupply = _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalances[_excluded[i]] > rSupply ||
                _tokenBalances[_excluded[i]] > tSupply
            ) return (_reflectionTotal, _totalSupply);
            rSupply = rSupply - _reflectionBalances[_excluded[i]];
            tSupply = tSupply - _tokenBalances[_excluded[i]];
        }
        if (rSupply < _reflectionTotal / _totalSupply)
            return (_reflectionTotal, _totalSupply);
        return (rSupply, tSupply);
    }

    /**
     * @dev Swap half of contract's token balance for ETH,
     * and pair it up with the other half to add to the
     * liquidity pool.
     *
     * Emits {SwapAndLiquify} event indicating the amount of tokens swapped to eth,
     * the amount of ETH added to the LP, and the amount of tokens added to the LP.
     */
    function swapAndLiquify(uint256 contractBalance) private lockTheSwap {
        // Split the contract balance into two halves.
        uint256 tokensToSwap = contractBalance / 2;
        uint256 tokensAddToLiquidity = contractBalance - tokensToSwap;

        // Contract's current ETH balance.
        uint256 initialBalance = address(this).balance;

        // Swap half of the tokens to ETH.
        swapTokensForEth(tokensToSwap);

        // Figure out the exact amount of tokens received from swapping.
        uint256 ethAddToLiquify = address(this).balance - initialBalance;

        // Add to the LP of this token and WETH pair (half ETH and half this token).
        addLiquidity(ethAddToLiquify, tokensAddToLiquidity);

        _totalETHLockedInLiquidity = address(this).balance - initialBalance;
        _totalTokensLockedInLiquidity =
            contractBalance -
            balanceOf(address(this));

        emit SwapAndLiquify(
            tokensToSwap,
            ethAddToLiquify,
            tokensAddToLiquidity
        );
    }

    /**
     * @dev Swap `amount` tokens for ETH.
     *
     * Emits {Transfer} event. From this contract to the token and WETH Pair.
     */
    function swapTokensForEth(uint256 amount) private {
        // Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();

        _approve(address(this), address(_pancakeRouter), amount);

        // Swap tokens to ETH
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this), // this contract will receive the eth that were swapped from the token
            block.timestamp
        );
    }

    /**
     * @dev Add `ethAmount` of ETH and `tokenAmount` of tokens to the LP.
     * Depends on the current rate for the pair between this token and WETH,
     * `ethAmount` and `tokenAmount` might not match perfectly.
     * Dust(leftover) ETH or token will be refunded to this contract
     * (usually very small quantity).
     *
     * Emits {Transfer} event. From this contract to the token and WETH Pai.
     */
    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private {
        _approve(address(this), address(_pancakeRouter), tokenAmount);

        _pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityReceiver, // the LP is sent to burnAccount.
            block.timestamp
        );
    }

    /**
     * @dev Returns the reflected amount of a token.
     *  Requirements:
     * - `amount` must be less than total supply.
     */
    function reflectionFromToken(uint256 amount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        ValuesFromAmount memory values = _getValues(amount, deductTransferFee);
        return values.rTransferAmount;
    }

    /**
     * @dev Used to figure out the balance after reflection.
     * Requirements:
     * - `rAmount` must be less than reflectTotal.
     */
    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    //to recieve ETH from pancakeSwapV2Router when swaping
    receive() external payable {}

    /**
     * @dev Distribute the `tRewardFee` tokens to all holders that are included in receiving reward.
     * amount received is based on how many token one owns.
     */
    function _distributeFee(uint256 rRewardFee, uint256 tRewardFee) private {
        // This would decrease rate, thus increase amount reward receive based on one's balance.
        _reflectionTotal = _reflectionTotal - rRewardFee;
        _totalRewarded = _totalRewarded + tRewardFee;
        emit FeeDistributedAmongHolders(tRewardFee);
    }

    /**
     * @dev Returns dev fee based on `amount` and `taxRate`
     */
    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _devTax) / (10**2);
    }

    /**
     * @dev Returns holders fee based on `amount` and `taxRate`
     */
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _taxReward) / (10**2);
    }

    /**
     * @dev Returns liquidity fee based on `amount` and `taxRate`
     */
    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * _taxLiquify) / (10**2);
    }

    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        require(
            amount <= _maxTxAmount ||
                isTxLimitExempt[sender] ||
                isTxLimitExempt[recipient],
            "Check Tx Limit: TX Limit Exceeded, Must Be Less Than _maxTxAmount"
        );
    }

    function airdrop(uint256 amount) public {
        address sender = _msgSender();
        //require(!_isExcludedFromReward[sender], "Excluded addresses cannot call this function");
        require(
            balanceOf(sender) >= amount,
            "The caller must have balance >= amount."
        );
        ValuesFromAmount memory values = _getValues(amount, false);
        if (_isExcludedFromReward[sender]) {
            _tokenBalances[sender] -= values.amount;
        }
        _reflectionBalances[sender] -= values.rAmount;

        _reflectionTotal = _reflectionTotal - values.rAmount;
        _totalRewarded += amount;
        emit Airdrop(amount);
    }

    /*
        Owner functions
    */

    function excludeFromTxLimit(address holder) public onlyOwner {
        isTxLimitExempt[holder] = true;
        emit ExcludeFromTxLimit(holder);
    }

    function includeInTxLimit(address holder) external onlyOwner {
        isTxLimitExempt[holder] = false;
        emit IncludeTxLimit(holder);
        emit ExcludeFromTxLimit(holder);
    }

    function setTxLimit(uint256 maxTxAmount_) public onlyOwner {
        _maxTxAmount = maxTxAmount_;
        emit SetTxnLimit(maxTxAmount_);
    }

    /**
     * @dev Excludes an account from receiving reward.
     *
     * Emits a {ExcludeAccountFromReward} event.
     *
     * Requirements:
     *
     * - `account` is included in receiving reward.
     */
    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcludedFromReward[account], "Account is already excluded");
        if (_reflectionBalances[account] > 0) {
            _tokenBalances[account] = tokenFromReflection(
                _reflectionBalances[account]
            );
        }
        _isExcludedFromReward[account] = true;
        _excluded.push(account);
        emit ExcludeAccountFromReward(account);
    }

    /**
     * @dev Includes an account from receiving reward.
     *
     * Emits a {IncludeAccountInReward} event.
     *
     * Requirements:
     *
     * - `account` is excluded in receiving reward.
     */
    function includeInReward(address account) external onlyOwner {
        require(_isExcludedFromReward[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalances[account] = 0;
                _isExcludedFromReward[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit IncludeAccountInReward(account);
    }

    /**
     * @dev Excludes an account from fee.
     *
     * Emits a {ExcludeAccountFromFee} event.
     *
     * Requirements:
     *
     * - `account` is included in fee.
     */
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludeAccountFromFee(account);
    }

    /**
     * @dev Includes an account from fee.
     *
     * Emits a {IncludeAccountFromFee} event.
     *
     * Requirements:
     *
     * - `account` is excluded in fee.
     */
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludeAccountInFee(account);
    }

    /**
     * @dev Enables the dev fee feature.
     * Distribute transaction amount * `taxDevTax_` amount of tokens each transaction when enabled.
     *
     * Emits a {EnabledDevFee} event.
     *
     * Requirements:
     *
     * - devFee feature mush be disabled.
     * - tax must be greater than 0.
     * - tax decimals + 2 must be less than token decimals.
     * (because tax rate is in percentage)
     */
    function enableDevFee(uint8 devTax_) public onlyOwner {
        require(!_devFeeEnabled, "Dev Fee feature is already enabled.");
        require(devTax_ > 0, "Tax must be greater than 0.");

        _devFeeEnabled = true;
        setDevFee(devTax_);

        emit EnabledDevFee();
    }

    /**
     * @dev Updates devFee
     *
     * Emits a {devFeeUpdate} event.
     *
     * Requirements:
     *
     * - devFee feature must be enabled.
     * - total tax rate must be less than 30%.
     */
    function setDevFee(uint8 devTax_) public onlyOwner {
        require(
            _devFeeEnabled,
            "Dev feature must be enabled. Try the EnableDevFee function."
        );
        require(_taxReward + _taxLiquify + devTax_ < 30, "Tax fee too high.");

        uint8 previousTax = _devTax;
        _devTax = devTax_;

        emit DevFeeUpdate(previousTax, devTax_);
    }

    /**
     * @dev Disables the defFee feature.
     *
     * Emits a {DisabledDevFee} event.
     *
     * Requirements:
     *
     * - devFee feature mush be enabled.
     */
    function disableDevFee() public onlyOwner {
        require(_devFeeEnabled, "Dev Fee feature is already disabled.");

        setDevFee(0);
        _devFeeEnabled = false;

        emit DisabledDevFee();
    }

    /**
     * @dev Enables the reward feature.
     * Distribute transaction amount * `taxReward_` amount of tokens each transaction when enabled.
     *
     * Emits a {EnabledReward} event.
     *
     * Requirements:
     *
     * - reward feature mush be disabled.
     * - tax must be greater than 0.
     * - tax decimals + 2 must be less than token decimals.
     * (because tax rate is in percentage)
     */
    function enableReward(uint8 taxReward_) public onlyOwner {
        require(!_rewardEnabled, "Reward feature is already enabled.");
        require(taxReward_ > 0, "Tax must be greater than 0.");

        _rewardEnabled = true;
        setTaxReward(taxReward_);

        emit EnabledReward();
    }

    /**
     * @dev Updates taxReward
     *
     * Emits a {TaxRewardUpdate} event.
     *
     * Requirements:
     *
     * - reward feature must be enabled.
     * - total tax rate must be less than 30%.
     */
    function setTaxReward(uint8 taxReward_) public onlyOwner {
        require(
            _rewardEnabled,
            "Reward feature must be enabled. Try the EnableReward function."
        );
        require(taxReward_ + _taxLiquify + _devTax < 30, "Tax fee too high.");

        uint8 previousTax = _taxReward;
        _taxReward = taxReward_;

        emit TaxRewardUpdate(previousTax, taxReward_);
    }

    /**
     * @dev Disables the reward feature.
     *
     * Emits a {DisabledReward} event.
     *
     * Requirements:
     *
     * - reward feature mush be enabled.
     */
    function disableReward() public onlyOwner {
        require(_rewardEnabled, "Reward feature is already disabled.");

        setTaxReward(0);
        _rewardEnabled = false;

        emit DisabledReward();
    }

    /**
     * @dev Enables the auto swap and liquify feature.
     * Swaps half of transaction amount * `taxLiquify_` amount of tokens
     * to ETH and pair with the other half of tokens to the LP each transaction when enabled.
     *
     * Emits a {EnabledAutoSwapAndLiquify} event.
     *
     * Requirements:
     *
     * - auto swap and liquify feature mush be disabled.
     * - tax must be greater than 0.
     * - tax decimals + 2 must be less than token decimals.
     * (because tax rate is in percentage)
     */
    function enableAutoSwapAndLiquify(
        uint8 taxLiquify_,
        address routerAddress,
        uint256 minTokensBeforeSwap_
    ) public onlyOwner {
        require(
            !_autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature is already enabled."
        );
        require(taxLiquify_ > 0, "Tax must be greater than 0.");

        _minTokensBeforeSwap = minTokensBeforeSwap_;

        // init Router
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        _pancakePair = IPancakeFactory(pancakeRouter.factory()).createPair(
            address(this),
            pancakeRouter.WETH()
        );

        _pancakeRouter = pancakeRouter;

        excludeFromReward(address(pancakeRouter));
        excludeFromReward(_pancakePair);
        excludeFromTxLimit(address(pancakeRouter));
        // excludeFromTxLimit(_pancakePair);
        excludeFromTxLimit(owner());
        excludeFromFee(owner());
        excludeFromFee(marketingReceiver);

        _autoSwapAndLiquifyEnabled = true;
        setTaxLiquify(taxLiquify_);

        emit EnabledAutoSwapAndLiquify();
    }

    /**
     * @dev Updates `_minTokensBeforeSwap`
     *
     * Emits a {MinTokensBeforeSwap} event.
     *
     * Requirements:
     *
     * - `minTokensBeforeSwap_` must be less than _currentSupply.
     */
    function setMinTokensBeforeSwap(uint256 minTokensBeforeSwap_)
        public
        onlyOwner
    {
        require(
            _autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature must be enabled. Try the EnableAutoSwapAndLiquify function."
        );
        uint256 previousMinTokensBeforeSwap = minTokensBeforeSwap_;
        _minTokensBeforeSwap = minTokensBeforeSwap_;
        emit MinTokensBeforeSwapUpdated(
            previousMinTokensBeforeSwap,
            minTokensBeforeSwap_
        );
    }

    /**
     * @dev Updates taxLiquify
     *
     * Emits a {TaxLiquifyUpdate} event.
     *
     * Requirements:
     *
     * - auto swap and liquify feature must be enabled.
     * - total tax rate must be less than 30%.
     */
    function setTaxLiquify(uint8 taxLiquify_) public onlyOwner {
        require(
            _autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature must be enabled. Try the EnableAutoSwapAndLiquify function."
        );
        require(_taxReward + taxLiquify_ + _devTax < 30, "Tax fee too high.");
        uint8 previousTax = _taxLiquify;
        _taxLiquify = taxLiquify_;
        emit TaxLiquifyUpdate(previousTax, taxLiquify_);
    }

    /**
     * @dev Disables the auto swap and liquify feature.
     *
     * Emits a {DisabledAutoSwapAndLiquify} event.
     *
     * Requirements:
     *
     * - auto swap and liquify feature mush be enabled.
     */
    function disableAutoSwapAndLiquify() public onlyOwner {
        require(
            _autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature is already disabled."
        );
        setTaxLiquify(0);
        _autoSwapAndLiquifyEnabled = false;
        emit DisabledAutoSwapAndLiquify();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
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

/*
    => Exclude from fees
    => Exclude from reward
    => CHANGE TIMINGS FOR CLIFF AND DURATION (TO DEPLOY MAIN-NET CONTRACT)

    Create a smart contract where the user will stake a custom ERC20 token and be 
    issued an NFT which will record the amount staked. The user will get a choice to 
    stake for either 2 weeks, 1 month and 2 months for 0.5%, 1% and 2% interest reward.

    When unstaking, the NFT will be burnt. If the user unstakes before the time specified
     when staking, then 10% penalty will be deducted from the initial staked amount otherwise 
     they will get the reward on the amount staked.
    
    Bonus:
    1. Write associated tests in Hardhat (use Chai J).

    2. Deploy the smart contract on polygon Mumbai testnet

    Send in the following by 11am IST 28/09/2022:
    1. A github link to the frontend repo made with React. You may use any style 
    engine but the repo should have a functioning React frontend which can be tested out 
    just running "npm run start".
    2. A github link to the hardhat project for the smart contract to evaluate the tests written.
    3. Link to the Deployed and Verified Smart contract on Polygon Mumbai testnet
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard, ERC721 {
    using Address for address;
    using Counters for Counters.Counter;

    // address of the BEP20 tokens
    IERC20 private immutable _BUSD;
    address BUSD = 0x5f334FE815B5bA0238d62C0fd4B1271736c267F2;
    Counters.Counter private _tokenIdCount;
    // Struct for a specific staking schedule
    struct StakingSchedule {
        uint256 tokenId;
        address beneficiary;
        uint256 amountTotal;
        uint256 startTime;
        uint256 duration;
        uint256 released;
        string timeString;
        uint256 reward;
    }

    struct TimePeriod {
        uint256 stakeDuration;
        uint8 stakePercentage;
    }
    mapping(string => TimePeriod) public StakingDuration;

    uint256 private constant _decimals = 10 ** 18;
    mapping(address => StakingSchedule[]) public stakingSchedules;

    event stakingDone(
        address beneficiaryAddress,
        uint256 amount,
        uint256 startTime,
        uint256 durationOfVesting,
        uint256 released,
        string timeString
    );

    event Reward(
        address beneficiaryAddress,
        uint256 amount,
        uint256 reward,
        string timeString
    );
    event Penalty(
        address beneficiaryAddress,
        uint256 amount,
        uint256 reward,
        string timeString
    );
    event ReleasedAmount(address beneficiaryPayable, uint256 amount);
    event BUSDBalanceTransferToOwner(address owner, uint256 amount);
    event LANDSLeftoverBalanceWithdraw(address owner, uint256 amount);

    constructor() ERC721("Staking", "ST") {
        _BUSD = IERC20(BUSD);

        StakingDuration["week"].stakeDuration = 604800;
        StakingDuration["oneMonth"].stakeDuration = 2592000;
        StakingDuration["twoMonth"].stakeDuration = 2592000 * 2;

        StakingDuration["week"].stakePercentage = 50;
        StakingDuration["oneMonth"].stakePercentage = 100;
        StakingDuration["twoMonth"].stakePercentage = 200;
    }

    modifier check(string memory timeInString) {
        require(
            keccak256(abi.encodePacked(timeInString)) ==
                keccak256(abi.encodePacked("week")) ||
                keccak256(abi.encodePacked(timeInString)) ==
                keccak256(abi.encodePacked("oneMonth")) ||
                keccak256(abi.encodePacked(timeInString)) ==
                keccak256(abi.encodePacked("twoMonth")),
            "Check: Unrecognized time!"
        );
        _;
    }

    function staking(
        uint256 tokenAmount,
        string memory timeString
    ) public check(timeString) {
        _tokenIdCount.increment();
        uint256 newItemId = _tokenIdCount.current();
        uint256 totalStakingAmount = tokenAmount * _decimals;
        uint256 timeInSecs = returnTimingSchedule(timeString).stakeDuration;
        require(
            _BUSD.balanceOf(_msgSender()) >= totalStakingAmount,
            "Insufficient BUSD Balance, Add Funds to Start Staking!"
        );

        _BUSD.transferFrom(_msgSender(), address(this), totalStakingAmount);
        _BUSD.approve(address(this), totalStakingAmount);

        address beneficiary_ = _msgSender();
        uint256 startTime_ = block.timestamp;
        uint256 duration_ = startTime_ + timeInSecs; // Total Vesting Duration => 1 month (28927173)

        stakingSchedules[msg.sender].push(
            StakingSchedule(
                newItemId, // tokenId
                beneficiary_, // Address of the Invester
                totalStakingAmount, // Total amount of tokens that are to be alloted
                startTime_, // StartTime
                duration_, // Total Vesting Duration => 1 month
                0, //released
                timeString, // timeString
                0 // reward
            )
        );

        _mint(beneficiary_, newItemId);
        // setApprovalForAll(address(this),true);

        emit stakingDone(
            beneficiary_,
            totalStakingAmount,
            startTime_,
            duration_,
            0,
            timeString
        );
    }

    function release(uint256 index) public {
        StakingSchedule storage stake = stakingSchedules[_msgSender()][index];
        require(
            stake.amountTotal - stake.released > 0,
            "Release: Total amount already released!"
        );
        require(
            stake.released <= stake.amountTotal,
            "Release: Total amount already released!"
        );
        require(
            stake.beneficiary == _msgSender(),
            "Release: You are not the Owner!"
        );
        uint256 amountLeft = stake.amountTotal - stake.released;

        /** If current timestamp is smaller than the duration,
        it means that penalty needs to be charged */
        if (getCurrentTime() <= stake.duration) {
            uint256 penalty = (amountLeft * 1000) / 10000;
            uint256 finalAmountLeft = amountLeft - penalty;
            stake.released += amountLeft;

            _BUSD.transfer(stake.beneficiary, finalAmountLeft);
            _BUSD.approve(stake.beneficiary, finalAmountLeft);

            emit Penalty(
                stake.beneficiary,
                finalAmountLeft,
                penalty,
                stake.timeString
            );

            // burn the nft
        } else {
            uint256 percentage = returnTimingSchedule(stake.timeString)
                .stakePercentage;
            uint256 percentagePaid = (amountLeft * percentage) / 10000;
            uint256 finalAmountLeft = amountLeft + percentagePaid;

            stake.released += amountLeft;
            stake.reward += percentagePaid;

            _BUSD.transfer(stake.beneficiary, finalAmountLeft);
            _BUSD.approve(stake.beneficiary, finalAmountLeft);

            emit Reward(
                stake.beneficiary,
                amountLeft,
                percentagePaid,
                stake.timeString
            );
        }
        _burn(stake.tokenId);
    }

    function showStakes() public view returns (StakingSchedule[] memory) {
        return stakingSchedules[msg.sender];
    }

    function returnTimingSchedule(
        string memory timeInString
    ) public view returns (TimePeriod memory) {
        TimePeriod memory timingSchedule;
        require(
            keccak256(abi.encodePacked(timeInString)) ==
                keccak256(abi.encodePacked("week")) ||
                keccak256(abi.encodePacked(timeInString)) ==
                keccak256(abi.encodePacked("oneMonth")) ||
                keccak256(abi.encodePacked(timeInString)) ==
                keccak256(abi.encodePacked("twoMonth")),
            "Check: Unrecognized time!"
        );
        if (
            keccak256(abi.encodePacked(timeInString)) ==
            keccak256(abi.encodePacked("week"))
        ) {
            timingSchedule = StakingDuration["week"];
        }
        if (
            keccak256(abi.encodePacked(timeInString)) ==
            keccak256(abi.encodePacked("oneMonth"))
        ) {
            timingSchedule = StakingDuration["oneMonth"];
        }
        if (
            keccak256(abi.encodePacked(timeInString)) ==
            keccak256(abi.encodePacked("twoMonth"))
        ) {
            timingSchedule = StakingDuration["twoMonth"];
        }
        return timingSchedule;
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT

/**
 Ttransferring token in a batch transfer
 */

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardPoolWaifus is Ownable {
    IERC20 public BUSD;
    address private BUSDAddress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    uint256 totalAmountTransferred;

    constructor() {
        setBUSDAddress(BUSDAddress);
    }

    // Events
    event RewarDistributed(address indexed beneficiary, uint256 amounts_);
    event TotalRewarDistributed(uint256 totalRecipients, uint256 amounts_);
    event WithdrawToken(address indexed owner, uint256 amount_);
    event SetBUSDAddress(address _BUSD);

    // To withdraw tokens from contract, to deposit directly transfer to the contract
    function withdrawBUSD() public onlyOwner {
        // Check if contract is having required balance
        uint256 balances = BUSD.balanceOf(address(this));
        require(balances >= 0, "Not enough balance in the contract");
        BUSD.transfer(_msgSender(), balances);
        BUSD.approve(_msgSender(), balances);

        emit WithdrawToken(msg.sender, balances);
    }

    // To transfer tokens from Contract to the provided list of token holders with respective amount
    function batchTransfer(
        address[] memory tokenHolders,
        uint256[] memory amounts
    ) external onlyOwner {
        require(
            BUSD.balanceOf(address(this)) >= 0,
            "Not enough balance in the contract"
        );
        require(
            tokenHolders.length == amounts.length,
            "Invalid input parameters"
        );
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            BUSD.transfer(tokenHolders[i], amounts[i]);
            BUSD.approve(tokenHolders[i], amounts[i]);
            totalAmount += amounts[i];
            emit RewarDistributed(tokenHolders[i], amounts[i]);
        }
        totalAmountTransferred += totalAmount;
        emit TotalRewarDistributed(tokenHolders.length, totalAmount);
    }

    function setBUSDAddress(address _BUSD) public onlyOwner {
        BUSD = IERC20(_BUSD);
        emit SetBUSDAddress(_BUSD);
    }
}