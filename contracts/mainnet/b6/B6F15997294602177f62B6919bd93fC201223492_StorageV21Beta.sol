// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Bolide is Context, IBEP20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 timestampCreated;
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
        _name = "Bolide";
        _symbol = "BLID";
        timestampCreated = block.timestamp;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        require(
            timestampCreated + 1 days > block.timestamp,
            "Mint time was finished"
        );
        _mint(account, amount);
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
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
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        override
        returns (uint256 balance)
    {
        return _balances[account];
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
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
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
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
    function burnFrom(address account, uint256 amount) public {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
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
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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
    function _mint(address account, uint256 amount) internal {
        require(_totalSupply + amount <= _cap, "ERC20Capped: cap exceeded");
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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
        _mint(msg.sender, 100000000000000000000000000000);
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
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
        virtual
        override
        returns (bool)
    {
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Multicall.sol)

pragma solidity ^0.8.0;

import "./Address.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * _Available since v4.1._
 */
abstract contract Multicall {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

interface IStorage {
    function takeToken(uint256 amount, address token) external;

    function returnToken(uint256 amount, address token) external;

    function addEarn(uint256 amount) external;
}

interface IDistribution {
    function enterMarkets(address[] calldata vTokens) external returns (uint256[] memory);

    function markets(address vTokenAddress)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );

    function claimVenus(address holder) external;

    function claimVenus(address holder, address[] memory vTokens) external;
}

interface IMasterChef {
    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function userInfo(uint256 _pid, address account) external view returns (uint256, uint256);
}

interface IVToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function mint() external payable;

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function repayBorrow() external payable;
}

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IPancakeRouter01 {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

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
}

contract LogicV1 is Ownable, Multicall {
    using SafeERC20 for IERC20;

    struct ReserveLiquidity {
        address tokenA;
        address tokenB;
        address vTokenA;
        address vTokenB;
        address swap;
        address swapMaster;
        address lpToken;
        uint256 poolID;
        address[][] path;
    }

    address private _storage;
    address private blid;
    address private admin;
    address private venusController;
    address private pancake;
    address private apeswap;
    address private biswap;
    address private pancakeMaster;
    address private apeswapMaster;
    address private biswapMaster;
    address private expenseAddress;
    address private vBNB;
    mapping(address => bool) private usedVTokens;
    mapping(address => address) private VTokens;

    ReserveLiquidity[] reserves;

    event SetAdmin(address admin);
    event SetBLID(address _blid);
    event SetStorage(address _storage);

    constructor(
        address _expenseAddress,
        address _venusController,
        address _pancakeRouter,
        address _apeswapRouter,
        address _biswapRouter,
        address _pancakeMaster,
        address _apeswapMaster,
        address _biswapMaster
    ) {
        expenseAddress = _expenseAddress;
        venusController = _venusController;

        apeswap = _apeswapRouter;
        pancake = _pancakeRouter;
        biswap = _biswapRouter;
        pancakeMaster = _pancakeMaster;
        apeswapMaster = _apeswapMaster;
        biswapMaster = _biswapMaster;
    }

    fallback() external payable {}

    receive() external payable {}

    modifier onlyOwnerAndAdmin() {
        require(msg.sender == owner() || msg.sender == admin, "E1");
        _;
    }

    modifier onlyStorage() {
        require(msg.sender == _storage, "E1");
        _;
    }

    modifier isUsedVToken(address vToken) {
        require(usedVTokens[vToken], "E2");
        _;
    }

    modifier isUsedSwap(address swap) {
        require(swap == apeswap || swap == pancake || swap == biswap, "E3");
        _;
    }

    modifier isUsedMaster(address swap) {
        require(swap == pancakeMaster || apeswapMaster == swap || biswapMaster == swap, "E4");
        _;
    }

    /**
     * @notice Add VToken in Contract and approve token  for storage, venus,
     * pancakeswap/apeswap router, and pancakeswap/apeswap master(Main Staking contract)
     * @param token Address of Token for deposited
     * @param vToken Address of VToken
     */
    function addVTokens(address token, address vToken) external onlyOwner {
        bool _isUsedVToken;
        (_isUsedVToken, , ) = IDistribution(venusController).markets(vToken);
        require(_isUsedVToken, "E5");
        if ((token) != address(0)) {
            IERC20(token).approve(vToken, type(uint256).max);
            IERC20(token).approve(apeswap, type(uint256).max);
            IERC20(token).approve(pancake, type(uint256).max);
            IERC20(token).approve(biswap, type(uint256).max);
            IERC20(token).approve(_storage, type(uint256).max);
            IERC20(token).approve(pancakeMaster, type(uint256).max);
            IERC20(token).approve(apeswapMaster, type(uint256).max);
            IERC20(token).approve(biswapMaster, type(uint256).max);
            VTokens[token] = vToken;
        } else {
            vBNB = vToken;
        }
        usedVTokens[vToken] = true;
    }

    /**
     * @notice Set blid in contract and approve blid for storage, venus, pancakeswap/apeswap
     * router, and pancakeswap/apeswap master(Main Staking contract), you can call the
     * function once
     * @param blid_ Adrees of BLID
     */
    function setBLID(address blid_) external onlyOwner {
        require(blid == address(0), "E6");
        blid = blid_;
        IERC20(blid).safeApprove(apeswap, type(uint256).max);
        IERC20(blid).safeApprove(pancake, type(uint256).max);
        IERC20(blid).safeApprove(biswap, type(uint256).max);
        IERC20(blid).safeApprove(pancakeMaster, type(uint256).max);
        IERC20(blid).safeApprove(apeswapMaster, type(uint256).max);
        IERC20(blid).safeApprove(biswapMaster, type(uint256).max);
        IERC20(blid).safeApprove(_storage, type(uint256).max);
        emit SetBLID(blid_);
    }

    /**
     * @notice Set storage, you can call the function once
     * @param storage_ Addres of Storage Contract
     */
    function setStorage(address storage_) external onlyOwner {
        require(_storage == address(0), "E7");
        _storage = storage_;
        emit SetStorage(storage_);
    }

    /**
     * @notice Approve token for storage, venus, pancakeswap/apeswap router,
     * and pancakeswap/apeswap master(Main Staking contract)
     * @param token  Address of Token that is approved
     */
    function approveTokenForSwap(address token) external onlyOwner {
        (IERC20(token).approve(apeswap, type(uint256).max));
        (IERC20(token).approve(pancake, type(uint256).max));
        (IERC20(token).approve(biswap, type(uint256).max));
        (IERC20(token).approve(pancakeMaster, type(uint256).max));
        (IERC20(token).approve(apeswapMaster, type(uint256).max));
        (IERC20(token).approve(biswapMaster, type(uint256).max));
    }

    /**
     * @notice Frees up tokens for the user, but Storage doesn't transfer token for the user,
     * only Storage can this function, after calling this function Storage transfer
     * from Logic to user token.
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnToken(uint256 amount, address token) external payable onlyStorage {
        uint256 takeFromVenus = 0;
        uint256 length = reserves.length;
        //check logic balance
        if (IERC20(token).balanceOf(address(this)) >= amount) {
            return;
        }
        //loop by reserves lp token
        for (uint256 i = 0; i < length; i++) {
            address[] memory path = findPath(i, token); // get path for router
            ReserveLiquidity memory reserve = reserves[i];
            uint256 lpAmount = getPriceFromTokenToLp(
                reserve.lpToken,
                amount - takeFromVenus,
                token,
                reserve.swap,
                path
            ); //get amount of lp token that need for reedem liqudity

            //get how many deposited to farming
            (uint256 depositedLp, ) = IMasterChef(reserve.swapMaster).userInfo(reserve.poolID, address(this));
            if (depositedLp == 0) continue;
            // if deposited LP tokens don't enough  for repay borrow and for reedem token then only repay
            // borow and continue loop, else repay borow, reedem token and break loop
            if (lpAmount >= depositedLp) {
                takeFromVenus += getPriceFromLpToToken(
                    reserve.lpToken,
                    depositedLp,
                    token,
                    reserve.swap,
                    path
                );
                withdrawAndRepay(reserve, depositedLp);
            } else {
                withdrawAndRepay(reserve, lpAmount);

                // get supplied token and break loop
                IVToken(VTokens[token]).redeemUnderlying(amount);
                return;
            }
        }
        //try get supplied token
        IVToken(VTokens[token]).redeemUnderlying(amount);
        //if get money
        if (IERC20(token).balanceOf(address(this)) >= amount) {
            return;
        }
        revert("no money");
    }

    /**
     * @notice Set admin
     * @param newAdmin Addres of new admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
        emit SetAdmin(newAdmin);
    }

    /**
     * @notice Transfer amount of token from Storage to Logic contract token - address of the token
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeTokenFromStorage(uint256 amount, address token) external onlyOwnerAndAdmin {
        IStorage(_storage).takeToken(amount, token);
    }

    /**
     * @notice Transfer amount of token from Logic to Storage contract token - address of token
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnTokenToStorage(uint256 amount, address token) external onlyOwnerAndAdmin {
        IStorage(_storage).returnToken(amount, token);
    }

    /**
     * @notice Distribution amount of blid to depositors.
     * @param amount Amount of BLID
     */
    function addEarnToStorage(uint256 amount) external onlyOwnerAndAdmin {
        IERC20(blid).safeTransfer(expenseAddress, (amount * 3) / 100);
        IStorage(_storage).addEarn((amount * 97) / 100);
    }

    /**
     * @notice Enter into a list of markets(address of VTokens) - it is not an
     * error to enter the same market more than once.
     * @param vTokens The addresses of the vToken markets to enter.
     * @return For each market, returns an error code indicating whether or not it was entered.
     * Each is 0 on success, otherwise an Error code
     */
    function enterMarkets(address[] calldata vTokens) external onlyOwnerAndAdmin returns (uint256[] memory) {
        return IDistribution(venusController).enterMarkets(vTokens);
    }

    /**
     * @notice Every Venus user accrues XVS for each block
     * they are supplying to or borrowing from the protocol.
     * @param vTokens The addresses of the vToken markets to enter.
     */
    function claimVenus(address[] calldata vTokens) external onlyOwnerAndAdmin {
        IDistribution(venusController).claimVenus(address(this), vTokens);
    }

    /**
     * @notice Stake token and mint VToken
     * @param vToken: that mint Vtokens to this contract
     * @param mintAmount: The amount of the asset to be supplied, in units of the underlying asset.
     * @return 0 on success, otherwise an Error code
     */
    function mint(address vToken, uint256 mintAmount)
        external
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        if (vToken == vBNB) {
            IVToken(vToken).mint{ value: mintAmount }();
        }
        return IVToken(vToken).mint(mintAmount);
    }

    /**
     * @notice The borrow function transfers an asset from the protocol to the user and creates a
     * borrow balance which begins accumulating interest based on the Borrow Rate for the asset.
     * The amount borrowed must be less than the user's Account Liquidity and the market's
     * available liquidity.
     * @param vToken: that mint Vtokens to this contract
     * @param borrowAmount: The amount of underlying to be borrow.
     * @return 0 on success, otherwise an Error code
     */
    function borrow(address vToken, uint256 borrowAmount)
        external
        payable
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        return IVToken(vToken).borrow(borrowAmount);
    }

    /**
     * @notice The repay function transfers an asset into the protocol, reducing the user's borrow balance.
     * @param vToken: that mint Vtokens to this contract
     * @param repayAmount: The amount of the underlying borrowed asset to be repaid.
     * A value of -1 (i.e. 2256 - 1) can be used to repay the full amount.
     * @return 0 on success, otherwise an Error code
     */
    function repayBorrow(address vToken, uint256 repayAmount)
        external
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        if (vToken == vBNB) {
            IVToken(vToken).repayBorrow{ value: repayAmount }();
            return 0;
        }
        return IVToken(vToken).repayBorrow(repayAmount);
    }

    /**
     * @notice The redeem underlying function converts vTokens into a specified quantity of the
     * underlying asset, and returns them to the user.
     * The amount of vTokens redeemed is equal to the quantity of underlying tokens received,
     * divided by the current Exchange Rate.
     * The amount redeemed must be less than the user's Account Liquidity and the market's
     * available liquidity.
     * @param vToken: that mint Vtokens to this contract
     * @param redeemAmount: The amount of underlying to be redeemed.
     * @return 0 on success, otherwise an Error code
     */
    function redeemUnderlying(address vToken, uint256 redeemAmount)
        external
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        return IVToken(vToken).redeemUnderlying(redeemAmount);
    }

    /**
     * @notice Adds liquidity to a BEP20⇄BEP20 pool.
     * @param swap Address of swap router
     * @param tokenA The contract address of one token from your liquidity pair.
     * @param tokenB The contract address of the other token from your liquidity pair.
     * @param amountADesired The amount of tokenA you'd like to provide as liquidity.
     * @param amountBDesired The amount of tokenA you'd like to provide as liquidity.
     * @param amountAMin The minimum amount of tokenA to provide (slippage impact).
     * @param amountBMin The minimum amount of tokenB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function addLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (amountADesired, amountBDesired, amountAMin) = IPancakeRouter01(swap).addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            address(this),
            deadline
        );

        return (amountADesired, amountBDesired, amountAMin);
    }

    /**
     * @notice Removes liquidity from a BEP20⇄BEP20 pool.
     * @param swap Address of swap router
     * @param tokenA The contract address of one token from your liquidity pair.
     * @param tokenB The contract address of the other token from your liquidity pair.
     * @param liquidity The amount of LP Tokens to remove.
     * @param amountAMin he minimum amount of tokenA to provide (slippage impact).
     * @param amountBMin The minimum amount of tokenB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function removeLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) external onlyOwnerAndAdmin isUsedSwap(swap) returns (uint256 amountA, uint256 amountB) {
        (amountAMin, amountBMin) = IPancakeRouter01(swap).removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            address(this),
            deadline
        );

        return (amountAMin, amountBMin);
    }

    /**
     * @notice Receive an as many output tokens as possible for an exact amount of input tokens.
     * @param swap Address of swap router
     * @param amountIn TPayable amount of input tokens.
     * @param amountOutMin The minimum amount tokens to receive.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactTokensForTokens(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external isUsedSwap(swap) onlyOwnerAndAdmin returns (uint256[] memory amounts) {
        return
            IPancakeRouter01(swap).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as few input tokens as possible.
     * @param swap Address of swap router
     * @param amountOut Payable amount of input tokens.
     * @param amountInMax The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapTokensForExactTokens(
        address swap,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        uint256 deadline
    ) external onlyOwnerAndAdmin isUsedSwap(swap) returns (uint256[] memory amounts) {
        return
            IPancakeRouter01(swap).swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Adds liquidity to a BEP20⇄WBNB pool.
     * @param swap Address of swap router
     * @param token The contract address of one token from your liquidity pair.
     * @param amountTokenDesired The amount of the token you'd like to provide as liquidity.
     * @param amountETHDesired The minimum amount of the token to provide (slippage impact).
     * @param amountTokenMin The minimum amount of token to provide (slippage impact).
     * @param amountETHMin The minimum amount of BNB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function addLiquidityETH(
        address swap,
        address token,
        uint256 amountTokenDesired,
        uint256 amountETHDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (amountETHDesired, amountTokenMin, amountETHMin) = IPancakeRouter01(swap).addLiquidityETH{
            value: amountETHDesired
        }(token, amountTokenDesired, amountTokenMin, amountETHMin, address(this), deadline);

        return (amountETHDesired, amountTokenMin, amountETHMin);
    }

    /**
     * @notice Removes liquidity from a BEP20⇄WBNB pool.
     * @param swap Address of swap router
     * @param token The contract address of one token from your liquidity pair.
     * @param liquidity The amount of LP Tokens to remove.
     * @param amountTokenMin The minimum amount of the token to remove (slippage impact).
     * @param amountETHMin The minimum amount of BNB to remove (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function removeLiquidityETH(
        address swap,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external payable isUsedSwap(swap) onlyOwnerAndAdmin returns (uint256 amountToken, uint256 amountETH) {
        (deadline, amountETHMin) = IPancakeRouter01(swap).removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        return (deadline, amountETHMin);
    }

    /**
     * @notice Receive as many output tokens as possible for an exact amount of BNB.
     * @param swap Address of swap router
     * @param amountETH Payable BNB amount.
     * @param amountOutMin 	The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactETHForTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external isUsedSwap(swap) onlyOwnerAndAdmin returns (uint256[] memory amounts) {
        return
            IPancakeRouter01(swap).swapExactETHForTokens{ value: amountETH }(
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as few input tokens as possible.
     * @param swap Address of swap router
     * @param amountOut Payable BNB amount.
     * @param amountInMax The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapTokensForExactETH(
        address swap,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        uint256 deadline
    ) external payable isUsedSwap(swap) onlyOwnerAndAdmin returns (uint256[] memory amounts) {
        return
            IPancakeRouter01(swap).swapTokensForExactETH(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive as much BNB as possible for an exact amount of input tokens.
     * @param swap Address of swap router
     * @param amountIn Payable amount of input tokens.
     * @param amountOutMin The maximum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactTokensForETH(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external payable isUsedSwap(swap) onlyOwnerAndAdmin returns (uint256[] memory amounts) {
        return
            IPancakeRouter01(swap).swapExactTokensForETH(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as little BNB as possible.
     * @param swap Address of swap router
     * @param amountOut The amount tokens to receive.
     * @param amountETH Payable BNB amount.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapETHForExactTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOut,
        address[] calldata path,
        uint256 deadline
    ) external isUsedSwap(swap) onlyOwnerAndAdmin returns (uint256[] memory amounts) {
        return
            IPancakeRouter01(swap).swapETHForExactTokens{ value: amountETH }(
                amountOut,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Deposit LP tokens to Master
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _pid pool id
     * @param _amount amount of lp token
     */
    function deposit(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external isUsedMaster(swapMaster) onlyOwnerAndAdmin {
        IMasterChef(swapMaster).deposit(_pid, _amount);
    }

    /**
     * @notice Withdraw LP tokens from Master
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _pid pool id
     * @param _amount amount of lp token
     */
    function withdraw(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external isUsedMaster(swapMaster) onlyOwnerAndAdmin {
        IMasterChef(swapMaster).withdraw(_pid, _amount);
    }

    /**
     * @notice Stake BANANA/Cake tokens to STAKING.
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _amount amount of lp token
     */
    function enterStaking(address swapMaster, uint256 _amount)
        external
        isUsedMaster(swapMaster)
        onlyOwnerAndAdmin
    {
        IMasterChef(swapMaster).enterStaking(_amount);
    }

    /**
     * @notice Withdraw BANANA/Cake tokens from STAKING.
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _amount amount of lp token
     */
    function leaveStaking(address swapMaster, uint256 _amount)
        external
        isUsedMaster(swapMaster)
        onlyOwnerAndAdmin
    {
        IMasterChef(swapMaster).leaveStaking(_amount);
    }

    /**
     * @notice Add reserve staked lp token to end list
     * @param reserveLiquidity Data is about staked lp in farm
     */
    function addReserveLiquidity(ReserveLiquidity memory reserveLiquidity) external onlyOwnerAndAdmin {
        reserves.push(reserveLiquidity);
    }

    /**
     * @notice Delete last ReserveLiquidity from list of ReserveLiquidity
     */
    function deleteLastReserveLiquidity() external onlyOwnerAndAdmin {
        reserves.pop();
    }

    /**
     * @notice Return count reserves staked lp tokens for return users their tokens.
     */
    function getReservesCount() external view returns (uint256) {
        return reserves.length;
    }

    /**
     * @notice Return reserves staked lp tokens for return user their tokens. return ReserveLiquidity
     */
    function getReserve(uint256 id) external view returns (ReserveLiquidity memory) {
        return reserves[id];
    }

    /*** Prive Function ***/

    /**
     * @notice Repay borrow when in farms  erc20 and BNB
     */
    function repayBorrowBNBandToken(
        address swap,
        address tokenB,
        address VTokenA,
        address VTokenB,
        uint256 lpAmount
    ) private {
        (uint256 amountToken, uint256 amountETH) = IPancakeRouter01(swap).removeLiquidityETH(
            tokenB,
            lpAmount,
            0,
            0,
            address(this),
            block.timestamp + 1 days
        );
        {
            uint256 totalBorrow = IVToken(VTokenA).borrowBalanceCurrent(address(this));
            if (totalBorrow >= amountETH) {
                IVToken(VTokenA).repayBorrow{ value: amountETH }();
            } else {
                IVToken(VTokenA).repayBorrow{ value: totalBorrow }();
            }

            totalBorrow = IVToken(VTokenB).borrowBalanceCurrent(address(this));
            if (totalBorrow >= amountToken) {
                IVToken(VTokenB).repayBorrow(amountToken);
            } else {
                IVToken(VTokenB).repayBorrow(totalBorrow);
            }
        }
    }

    /**
     * @notice Repay borrow when in farms only erc20
     */
    function repayBorrowOnlyTokens(
        address swap,
        address tokenA,
        address tokenB,
        address VTokenA,
        address VTokenB,
        uint256 lpAmount
    ) private {
        (uint256 amountA, uint256 amountB) = IPancakeRouter01(swap).removeLiquidity(
            tokenA,
            tokenB,
            lpAmount,
            0,
            0,
            address(this),
            block.timestamp + 1 days
        );
        {
            uint256 totalBorrow = IVToken(VTokenA).borrowBalanceCurrent(address(this));
            if (totalBorrow >= amountA) {
                IVToken(VTokenA).repayBorrow(amountA);
            } else {
                IVToken(VTokenA).repayBorrow(totalBorrow);
            }

            totalBorrow = IVToken(VTokenB).borrowBalanceCurrent(address(this));
            if (totalBorrow >= amountB) {
                IVToken(VTokenB).repayBorrow(amountB);
            } else {
                IVToken(VTokenB).repayBorrow(totalBorrow);
            }
        }
    }

    /**
     * @notice Withdraw lp token from farms and repay borrow
     */
    function withdrawAndRepay(ReserveLiquidity memory reserve, uint256 lpAmount) private {
        IMasterChef(reserve.swapMaster).withdraw(reserve.poolID, lpAmount);
        if (reserve.tokenA == address(0) || reserve.tokenB == address(0)) {
            //if tokenA is BNB
            if (reserve.tokenA == address(0)) {
                repayBorrowBNBandToken(
                    reserve.swap,
                    reserve.tokenB,
                    reserve.vTokenA,
                    reserve.vTokenB,
                    lpAmount
                );
            }
            //if tokenB is BNB
            else {
                repayBorrowBNBandToken(
                    reserve.swap,
                    reserve.tokenA,
                    reserve.vTokenB,
                    reserve.vTokenA,
                    lpAmount
                );
            }
        }
        //if token A and B is not BNB
        else {
            repayBorrowOnlyTokens(
                reserve.swap,
                reserve.tokenA,
                reserve.tokenB,
                reserve.vTokenA,
                reserve.vTokenB,
                lpAmount
            );
        }
    }

    /*** Prive View Function ***/
    /**
     * @notice Convert Lp Token To Token
     */
    function getPriceFromLpToToken(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) private view returns (uint256) {
        //make price returned not affected by slippage rate
        uint256 totalSupply = IERC20(lpToken).totalSupply();
        address token0 = IPancakePair(lpToken).token0();
        uint256 totalTokenAmount = IERC20(token0).balanceOf(lpToken) * (2);
        uint256 amountIn = (value * totalTokenAmount) / (totalSupply);

        if (amountIn == 0 || token0 == token) {
            return amountIn;
        }

        uint256[] memory price = IPancakeRouter01(swap).getAmountsOut(amountIn, path);
        return price[price.length - 1];
    }

    /**
     * @notice Convert Token To Lp Token
     */
    function getPriceFromTokenToLp(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) private view returns (uint256) {
        //make price returned not affected by slippage rate
        uint256 totalSupply = IERC20(lpToken).totalSupply();
        address token0 = IPancakePair(lpToken).token0();
        uint256 totalTokenAmount = IERC20(token0).balanceOf(lpToken);

        if (token0 == token) {
            return (value * (totalSupply)) / (totalTokenAmount) / 2;
        }

        uint256[] memory price = IPancakeRouter01(swap).getAmountsOut((1 gwei), path);
        return (value * (totalSupply)) / ((price[price.length - 1] * 2 * totalTokenAmount) / (1 gwei));
    }

    /**
     * @notice FindPath for swap router
     */
    function findPath(uint256 id, address token) private view returns (address[] memory path) {
        ReserveLiquidity memory reserve = reserves[id];
        uint256 length = reserve.path.length;

        for (uint256 i = 0; i < length; i++) {
            if (reserve.path[i][reserve.path[i].length - 1] == token) {
                return reserve.path[i];
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenVesting {
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);

    IERC20 public _token;
    address private _beneficiary;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private _durationCount;
    uint256 private _startTimestamp;
    uint256 private _duration;
    uint256 private _endTimestamp;

    uint256 private _released;

    /**
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
     * beneficiary. By then all
     * of the balance will have vested.
     * @param tokenValue Address of vesting token
     * @param beneficiaryValue Address of beneficiary
     * @param startTimestampValue Timstamp when start vesting
     * @param durationValue Duration one period of vesit
     * @param durationCountValue Count duration one period of vesit
     */
    constructor(
        address tokenValue,
        address beneficiaryValue,
        uint256 startTimestampValue,
        uint256 durationValue,
        uint256 durationCountValue
    ) {
        require(
            beneficiaryValue != address(0),
            "TokenVesting: beneficiary is the zero address"
        );

        _token = IERC20(tokenValue);
        _beneficiary = beneficiaryValue;
        _duration = durationValue;
        _durationCount = durationCountValue;
        _startTimestamp = startTimestampValue;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the end time of the token vesting.
     */
    function end() public view returns (uint256) {
        return _startTimestamp + _duration * _durationCount;
    }

    /**
     * @return the start time of the token vesting.
     */
    function start() public view returns (uint256) {
        return _startTimestamp;
    }

    /**
     * @return the duration of the token vesting.
     */
    function duration() public view returns (uint256) {
        return _duration;
    }

    /**
     * @return the amount of the token released.
     */
    function released() public view returns (uint256) {
        return _released;
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function release() public {
        uint256 unreleased = releasableAmount();

        require(unreleased > 0, "TokenVesting: no tokens are due");

        _released = _released + (unreleased);

        _token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(_token), unreleased);
    }

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function releasableAmount() public view returns (uint256) {
        return _vestedAmount() - (_released);
    }

    /**
     * @dev Calculates the amount that has already vested.
     */
    function _vestedAmount() private view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance + (_released);

        if (block.timestamp < _startTimestamp) {
            return 0;
        } else if (
            block.timestamp >= _startTimestamp + _duration * _durationCount
        ) {
            return totalBalance;
        } else {
            return
                (totalBalance *
                    ((block.timestamp - _startTimestamp) / (_duration))) /
                _durationCount;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVestingGroup is Ownable {
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);

    mapping(address => uint256) _sumUser;
    mapping(address => uint256) _rateToken;
    mapping(address => uint256) _released;
    mapping(address => address) _userToken;
    address[] _tokens;
    IERC20 public _token;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private _durationCount;
    uint256 private _startTimestamp;
    uint256 private _duration;
    uint256 private _endTimestamp;

    /**
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
     * beneficiary. By then all
     * of the balance will have vested.
     */
    constructor(
        address tokenValue,
        uint256 durationValue,
        uint256 durationCountValue,
        address[] memory tokensValue
    ) {
        _token = IERC20(tokenValue);
        _duration = durationValue;
        _durationCount = durationCountValue;
        _tokens = tokensValue;
    }

    /**
     * @notice Set amount of token for user deposited token
     */
    function deposit(
        address user,
        address token,
        uint256 amount
    ) external onlyOwner {
        _userToken[user] = token;
        _sumUser[user] = amount;
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function finishRound(
        uint256 startTimestampValue,
        uint256[] memory tokenRate
    ) external onlyOwner {
        require(_startTimestamp == 0, "Vesting has been started");
        _startTimestamp = startTimestampValue;
        for (uint256 i = 0; i < tokenRate.length; i++) {
            _rateToken[_tokens[i]] = tokenRate[i];
        }
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function claim() external {
        uint256 unreleased = releasableAmount();

        require(unreleased > 0, "TokenVesting: no tokens are due");

        _released[msg.sender] = _released[msg.sender] + (unreleased);

        _token.safeTransfer(msg.sender, unreleased);

        emit TokensReleased(address(_token), unreleased);
    }

    /**
     * @notice Set 0 for user deposited token
     */
    function returnDeposit(address user) external onlyOwner {
        require(_startTimestamp == 0, "Vesting has been started");
        _userToken[user] = address(0);
        _sumUser[user] = 0;
    }

    /**
     * @return the end time of the token vesting.
     */
    function end() public view returns (uint256) {
        return _startTimestamp + _duration * _durationCount;
    }

    /**
     * @return the start time of the token vesting.
     */
    function start() public view returns (uint256) {
        return _startTimestamp;
    }

    /**
     * @return the duration of the token vesting.
     */
    function duration() public view returns (uint256) {
        return _duration;
    }

    /**
     * @return the count of duration  of the token vesting.
     */
    function durationCount() public view returns (uint256) {
        return _durationCount;
    }

    /**
     * @return the amount of the token released.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function releasableAmount() public view returns (uint256) {
        return _vestedAmount(msg.sender) - (_released[msg.sender]);
    }

    /**
     * @dev Calculates the user dollar deposited.
     */
    function getUserShare(address account) public view returns (uint256) {
        return
            (_sumUser[account] * _rateToken[_userToken[account]]) / (1 ether);
    }

    /**
     * @dev Calculates the amount that has already vested.
     */
    function _vestedAmount(address account) public view returns (uint256) {
        require(_startTimestamp != 0, "Vesting has not been started");
        uint256 totalBalance = (_sumUser[account] *
            _rateToken[_userToken[account]]) / (1 ether);
        if (block.timestamp < _startTimestamp) {
            return 0;
        } else if (
            block.timestamp >= _startTimestamp + _duration * _durationCount
        ) {
            return totalBalance;
        } else {
            return
                (totalBalance *
                    ((block.timestamp - _startTimestamp) / (_duration))) /
                (_durationCount);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./TokenVestingGroup.sol";

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256 answer);
}

interface IBurnable {
    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}

contract PrivateSale is Ownable {
    using SafeERC20 for IERC20;

    //*** Structs  ***//

    struct Round {
        mapping(address => bool) whiteList;
        mapping(address => uint256) sums;
        mapping(address => address) depositToken;
        mapping(address => uint256) tokenReserve;
        uint256 totalReserve;
        uint256 tokensSold;
        uint256 tokenRate;
        uint256 maxMoney;
        uint256 sumTokens;
        uint256 minimumSaleAmount;
        uint256 maximumSaleAmount;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 duration;
        uint256 durationCount;
        uint256 lockup;
        TokenVestingGroup vestingContract;
        uint8 percentOnInvestorWallet;
        uint8 typeRound;
        bool finished;
        bool open;
        bool burnable;
    }

    struct InputNewRound {
        uint256 _tokenRate;
        uint256 _maxMoney;
        uint256 _sumTokens;
        uint256 _startTimestamp;
        uint256 _endTimestamp;
        uint256 _minimumSaleAmount;
        uint256 _maximumSaleAmount;
        uint256 _duration;
        uint256 _durationCount;
        uint256 _lockup;
        uint8 _typeRound;
        uint8 _percentOnInvestorWallet;
        bool _burnable;
        bool _open;
    }

    //*** Variable ***//
    mapping(uint256 => Round) rounds;
    address investorWallet;
    uint256 countRound;
    uint256 countTokens;
    mapping(uint256 => address) tokens;
    mapping(address => address) oracles;
    mapping(address => bool) tokensAdd;

    address BLID;
    address expenseAddress;

    //*** Modifiers ***//

    modifier isUsedToken(address _token) {
        require(tokensAdd[_token], "Token is not used ");
        _;
    }

    modifier finishedRound() {
        require(
            countRound == 0 || rounds[countRound - 1].finished,
            "Last round has not been finished"
        );
        _;
    }

    modifier unfinishedRound() {
        require(
            countRound != 0 && !rounds[countRound - 1].finished,
            "Last round has  been finished"
        );
        _;
    }
    modifier existRound(uint256 round) {
        require(round < countRound, "Number round more than Rounds count");
        _;
    }

    /*** User function ***/

    /**
     * @notice User deposit amount of token for
     * @param amount Amount of token
     * @param token Address of token
     */
    function deposit(uint256 amount, address token)
        external
        isUsedToken(token)
        unfinishedRound
    {
        require(
            rounds[countRound - 1].open ||
                rounds[countRound - 1].whiteList[msg.sender],
            "No access"
        );
        require(
            !isParticipatedInTheRound(countRound - 1),
            "You  have already made a deposit"
        );
        require(
            rounds[countRound - 1].startTimestamp < block.timestamp,
            "Round dont start"
        );
        require(
            rounds[countRound - 1].minimumSaleAmount <=
                amount * 10**(18 - AggregatorV3Interface(token).decimals()),
            "Minimum sale amount more than your amount"
        );
        require(
            rounds[countRound - 1].maximumSaleAmount == 0 ||
                rounds[countRound - 1].maximumSaleAmount >=
                amount * 10**(18 - AggregatorV3Interface(token).decimals()),
            "Your amount more than maximum sale amount"
        );
        require(
            rounds[countRound - 1].endTimestamp > block.timestamp ||
                rounds[countRound - 1].endTimestamp == 0,
            "Round is ended, round time expired"
        );
        require(
            rounds[countRound - 1].tokenRate == 0 ||
                rounds[countRound - 1].sumTokens == 0 ||
                rounds[countRound - 1].sumTokens >=
                ((rounds[countRound - 1].totalReserve +
                    amount *
                    10**(18 - AggregatorV3Interface(token).decimals())) *
                    (1 ether)) /
                    rounds[countRound - 1].tokenRate,
            "Round is ended, all tokens sold"
        );
        require(
            rounds[countRound - 1].maxMoney == 0 ||
                rounds[countRound - 1].maxMoney >=
                (rounds[countRound - 1].totalReserve +
                    amount *
                    10**(18 - AggregatorV3Interface(token).decimals())),
            "The round is over, the maximum required value has been reached, or your amount is greater than specified in the conditions of the round"
        );
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        rounds[countRound - 1].tokenReserve[token] +=
            amount *
            10**(18 - AggregatorV3Interface(token).decimals());
        rounds[countRound - 1].sums[msg.sender] +=
            amount *
            10**(18 - AggregatorV3Interface(token).decimals());
        rounds[countRound - 1].depositToken[msg.sender] = token;
        rounds[countRound - 1].totalReserve +=
            amount *
            10**(18 - AggregatorV3Interface(token).decimals());
        rounds[countRound - 1].vestingContract.deposit(
            msg.sender,
            token,
            amount * 10**(18 - AggregatorV3Interface(token).decimals())
        );
    }

    /**
     * @notice User return deposit of round
     * @param round number of round
     */
    function returnDeposit(uint256 round) external {
        require(round < countRound, "Number round more than Rounds count");
        require(
            rounds[round].sums[msg.sender] > 0,
            "You don't have deposit or you return your deposit"
        );
        require(
            !rounds[round].finished || rounds[round].typeRound == 0,
            "round has been finished successfully"
        );
        IERC20(rounds[round].depositToken[msg.sender]).safeTransfer(
            msg.sender,
            rounds[round].sums[msg.sender] /
                10 **
                    (18 -
                        AggregatorV3Interface(
                            rounds[round].depositToken[msg.sender]
                        ).decimals())
        );
        rounds[round].vestingContract.returnDeposit(msg.sender);
        rounds[round].totalReserve -= rounds[round].sums[msg.sender];
        rounds[round].tokenReserve[
            rounds[round].depositToken[msg.sender]
        ] -= rounds[round].sums[msg.sender];
        rounds[round].sums[msg.sender] = 0;
        rounds[round].depositToken[msg.sender] = address(0);
    }

    /**
     * @notice Add token and token's oracle
     * @param _token Address of Token
     * @param _oracles Address of token's oracle(https://docs.chain.link/docs/binance-smart-chain-addresses/
     */
    function addToken(address _token, address _oracles) external onlyOwner {
        require(_token != address(0) && _oracles != address(0));
        require(!tokensAdd[_token], "token was added");
        oracles[_token] = _oracles;
        tokens[countTokens++] = _token;
        tokensAdd[_token] = true;
    }

    /**
     * @notice Set Investor Wallet
     * @param _investorWallet address of InvestorWallet
     */
    function setInvestorWallet(address _investorWallet)
        external
        onlyOwner
        finishedRound
    {
        investorWallet = _investorWallet;
    }

    /**
     * @notice Set Expense Wallet
     * @param _expenseAddress address of Expense Address
     */
    function setExpenseAddress(address _expenseAddress)
        external
        onlyOwner
        finishedRound
    {
        expenseAddress = _expenseAddress;
    }

    /**
     * @notice Set Expense Wallet and Investor Wallet
     * @param _investorWallet address of InvestorWallet
     * @param _expenseAddress address of Expense Address
     */
    function setExpenseAddressAndInvestorWallet(
        address _expenseAddress,
        address _investorWallet
    ) external onlyOwner finishedRound {
        expenseAddress = _expenseAddress;
        investorWallet = _investorWallet;
    }

    /**
     * @notice Set blid in contract
     * @param _BLID address of BLID
     */
    function setBLID(address _BLID) external onlyOwner {
        require(BLID == address(0), "BLID was set");
        BLID = _BLID;
    }

    /**
     * @notice Creat new round with input parameters
     * @param input Data about of new round
     */
    function newRound(InputNewRound memory input)
        external
        onlyOwner
        finishedRound
    {
        require(BLID != address(0), "BLID is not set");
        require(expenseAddress != address(0), "Require set expense address ");
        require(
            investorWallet != address(0) || input._percentOnInvestorWallet == 0,
            "Require set Logic contract"
        );
        require(
            input._endTimestamp == 0 || input._endTimestamp > block.timestamp,
            "_endTimestamp must be unset or more than now timestamp"
        );
        if (input._typeRound == 1) {
            require(
                input._tokenRate > 0,
                "Need set _tokenRate and _tokenRate must be more than 0"
            );
            require(
                IERC20(BLID).balanceOf(address(this)) >= input._sumTokens,
                "_sumTokens more than this smart contract have BLID"
            );
            require(input._sumTokens > 0, "Need set _sumTokens ");
            rounds[countRound].tokenRate = input._tokenRate;
            rounds[countRound].maxMoney = input._maxMoney;
            rounds[countRound].startTimestamp = input._startTimestamp;
            rounds[countRound].sumTokens = input._sumTokens;
            rounds[countRound].endTimestamp = input._endTimestamp;
            rounds[countRound].duration = input._duration;
            rounds[countRound].durationCount = input._durationCount;
            rounds[countRound].minimumSaleAmount = input._minimumSaleAmount;
            rounds[countRound].maximumSaleAmount = input._maximumSaleAmount;
            rounds[countRound].lockup = input._lockup;
            rounds[countRound].percentOnInvestorWallet = input
                ._percentOnInvestorWallet;
            rounds[countRound].burnable = input._burnable;
            rounds[countRound].open = input._open;
            rounds[countRound].typeRound = input._typeRound;
            address[] memory inputTokens = new address[](countTokens);
            for (uint256 i = 0; i < countTokens; i++) {
                inputTokens[i] = tokens[i];
            }
            rounds[countRound].vestingContract = new TokenVestingGroup(
                BLID,
                input._duration,
                input._durationCount,
                inputTokens
            );
            countRound++;
        } else if (input._typeRound == 2) {
            require(input._sumTokens > 0, "Need set _sumTokens");
            require(
                input._tokenRate == 0,
                "Need unset _tokenRate (_tokenRate==0)"
            );
            require(!input._burnable, "Need not burnable round");
            require(
                IERC20(BLID).balanceOf(address(this)) >= input._sumTokens,
                "_sumTokens more than this smart contract have BLID"
            );
            rounds[countRound].tokenRate = input._tokenRate;
            rounds[countRound].maxMoney = input._maxMoney;
            rounds[countRound].startTimestamp = input._startTimestamp;
            rounds[countRound].endTimestamp = input._endTimestamp;
            rounds[countRound].sumTokens = input._sumTokens;
            rounds[countRound].duration = input._duration;
            rounds[countRound].minimumSaleAmount = input._minimumSaleAmount;
            rounds[countRound].maximumSaleAmount = input._maximumSaleAmount;
            rounds[countRound].durationCount = input._durationCount;
            rounds[countRound].lockup = input._lockup;
            rounds[countRound].percentOnInvestorWallet = input
                ._percentOnInvestorWallet;
            rounds[countRound].burnable = input._burnable;
            rounds[countRound].open = input._open;
            rounds[countRound].typeRound = input._typeRound;
            address[] memory inputTokens = new address[](countTokens);
            for (uint256 i = 0; i < countTokens; i++) {
                inputTokens[i] = (tokens[i]);
            }
            rounds[countRound].vestingContract = new TokenVestingGroup(
                BLID,
                input._duration,
                input._durationCount,
                inputTokens
            );
            countRound++;
        }
    }

    /**
     * @notice Set rate of token for last round(only for round that typy is 1)
     * @param rate Rate token  token/usd * 10**18
     */
    function setRateToken(uint256 rate) external onlyOwner unfinishedRound {
        require(
            rounds[countRound - 1].typeRound == 1,
            "This round auto generate rate"
        );
        rounds[countRound - 1].tokenRate = rate;
    }

    /**
     * @notice Set timestamp when end round
     * @param _endTimestamp timesetamp when round is ended
     */
    function setEndTimestamp(uint256 _endTimestamp)
        external
        onlyOwner
        unfinishedRound
    {
        rounds[countRound - 1].endTimestamp = _endTimestamp;
    }

    /**
     * @notice Set Sum Tokens
     * @param _sumTokens Amount of selling BLID. Necessarily with the type of round 2
     */
    function setSumTokens(uint256 _sumTokens)
        external
        onlyOwner
        unfinishedRound
    {
        require(
            IERC20(BLID).balanceOf(address(this)) >= _sumTokens,
            "_sumTokens more than this smart contract have BLID"
        );
        require(
            _sumTokens > rounds[countRound - 1].tokensSold,
            "Token sold more than _sumTokens"
        );
        rounds[countRound - 1].sumTokens = _sumTokens;
    }

    /**
     * @notice Set  Start Timestamp
     * @param _startTimestamp Unix timestamp  Start Round
     */
    function setStartTimestamp(uint256 _startTimestamp)
        external
        onlyOwner
        unfinishedRound
    {
        require(block.timestamp < _startTimestamp, "Round has been started");
        rounds[countRound - 1].startTimestamp = _startTimestamp;
    }

    /**
     * @notice Set Max Money
     * @param _maxMoney Amount USD when close round
     */
    function setMaxMoney(uint256 _maxMoney) external onlyOwner unfinishedRound {
        require(
            rounds[countRound - 1].totalReserve < _maxMoney,
            "Now total reserve more than _maxMoney"
        );
        rounds[countRound - 1].maxMoney = _maxMoney;
    }

    /**
     * @notice Add account in white list
     * @param account Address is added in white list
     */
    function addWhiteList(address account) external onlyOwner unfinishedRound {
        rounds[countRound - 1].whiteList[account] = true;
    }

    /**
     * @notice Add accounts in white list
     * @param accounts Addresses are added in white list
     */
    function addWhiteListByArray(address[] calldata accounts)
        external
        onlyOwner
        unfinishedRound
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            rounds[countRound - 1].whiteList[accounts[i]] = true;
        }
    }

    /**
     * @notice Delete accounts in white list
     * @param account Address is deleted in white list
     */
    function deleteWhiteList(address account)
        external
        onlyOwner
        unfinishedRound
    {
        rounds[countRound - 1].whiteList[account] = false;
    }

    /**
     * @notice Delete accounts in white list
     * @param accounts Addresses are  deleted in white list
     */
    function deleteWhiteListByArray(address[] calldata accounts)
        external
        onlyOwner
        unfinishedRound
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            rounds[countRound - 1].whiteList[accounts[i]] = false;
        }
    }

    /**
     * @notice Finish round, send rate to VestingGroup contracts
     */
    function finishRound() external onlyOwner {
        require(
            countRound != 0 && !rounds[countRound - 1].finished,
            "Last round has been finished"
        );
        uint256[] memory rates = new uint256[](countTokens);
        uint256 sumUSD = 0;
        for (uint256 i = 0; i < countTokens; i++) {
            if (rounds[countRound - 1].tokenReserve[tokens[i]] == 0) continue;
            IERC20(tokens[i]).safeTransfer(
                expenseAddress,
                rounds[countRound - 1].tokenReserve[tokens[i]] /
                    10**(18 - AggregatorV3Interface(tokens[i]).decimals()) -
                    ((rounds[countRound - 1].tokenReserve[tokens[i]] /
                        10 **
                            (18 -
                                AggregatorV3Interface(tokens[i]).decimals())) *
                        (rounds[countRound - 1].percentOnInvestorWallet)) /
                    100
            );
            IERC20(tokens[i]).safeTransfer(
                investorWallet,
                ((rounds[countRound - 1].tokenReserve[tokens[i]] /
                    10**(18 - AggregatorV3Interface(tokens[i]).decimals())) *
                    (rounds[countRound - 1].percentOnInvestorWallet)) / 100
            );
            rates[i] = (uint256(
                AggregatorV3Interface(oracles[tokens[i]]).latestAnswer()
            ) *
                10 **
                    (18 -
                        AggregatorV3Interface(oracles[tokens[i]]).decimals()));

            sumUSD +=
                (rounds[countRound - 1].tokenReserve[tokens[i]] * rates[i]) /
                (1 ether);
            if (rounds[countRound - 1].typeRound == 1)
                rates[i] =
                    (rates[i] * (1 ether)) /
                    rounds[countRound - 1].tokenRate;
            if (rounds[countRound - 1].typeRound == 2)
                rates[i] =
                    (rounds[countRound - 1].sumTokens * rates[i]) /
                    sumUSD;
        }
        if (sumUSD != 0) {
            rounds[countRound - 1].vestingContract.finishRound(
                block.timestamp + rounds[countRound - 1].lockup,
                rates
            );
            if (rounds[countRound - 1].typeRound == 1)
                IERC20(BLID).safeTransfer(
                    address(rounds[countRound - 1].vestingContract),
                    (sumUSD * (1 ether)) / rounds[countRound - 1].tokenRate
                );
        }
        if (rounds[countRound - 1].typeRound == 2)
            IERC20(BLID).safeTransfer(
                address(rounds[countRound - 1].vestingContract),
                rounds[countRound - 1].sumTokens
            );
        if (
            rounds[countRound - 1].burnable &&
            rounds[countRound - 1].sumTokens -
                (sumUSD * (1 ether)) /
                rounds[countRound - 1].tokenRate !=
            0
        ) {
            IBurnable(BLID).burn(
                rounds[countRound - 1].sumTokens -
                    (sumUSD * (1 ether)) /
                    rounds[countRound - 1].tokenRate
            );
        }
        rounds[countRound - 1].finished = true;
    }

    /**
     * @notice Cancel round
     */
    function cancelRound() external onlyOwner {
        require(
            countRound != 0 && !rounds[countRound - 1].finished,
            "Last round has been finished"
        );
        rounds[countRound - 1].finished = true;
        rounds[countRound - 1].typeRound = 0;
    }

    /**
     * @param id Number of round
     * @return InputNewRound - information about round
     */
    function getRoundStateInfromation(uint256 id)
        public
        view
        returns (InputNewRound memory)
    {
        InputNewRound memory out = InputNewRound(
            rounds[id].tokenRate,
            rounds[id].maxMoney,
            rounds[id].sumTokens,
            rounds[id].startTimestamp,
            rounds[id].endTimestamp,
            rounds[id].minimumSaleAmount,
            rounds[id].maximumSaleAmount,
            rounds[id].duration,
            rounds[id].durationCount,
            rounds[id].lockup,
            rounds[id].typeRound,
            rounds[id].percentOnInvestorWallet,
            rounds[id].burnable,
            rounds[id].open
        );
        return out;
    }

    /**
     * @param id Number of round
     * @return  Locked Tokens
     */
    function getLockedTokens(uint256 id) public view returns (uint256) {
        if (rounds[id].tokenRate == 0) return 0;
        return ((rounds[id].totalReserve * (1 ether)) / rounds[id].tokenRate);
    }

    /**
     * @param id Number of round
     * @return  Returns (all deposited money, sold tokens, open or close round)
     */
    function getRoundDynamicInfromation(uint256 id)
        public
        view
        returns (
            uint256,
            uint256,
            bool
        )
    {
        if (rounds[id].typeRound == 1) {
            return (
                rounds[id].totalReserve,
                rounds[id].totalReserve / rounds[id].tokenRate,
                rounds[id].open
            );
        } else {
            return (
                rounds[id].totalReserve,
                rounds[id].sumTokens,
                rounds[id].open
            );
        }
    }

    /**
     * @return  True if `account`  is in white list
     */
    function isInWhiteList(address account) public view returns (bool) {
        return rounds[countRound - 1].whiteList[account];
    }

    /**
     * @return  Count round
     */
    function getCountRound() public view returns (uint256) {
        return countRound;
    }

    /**
     * @param id Number of round
     * @return  Address Vesting contract
     */
    function getVestingAddress(uint256 id)
        public
        view
        existRound(id)
        returns (address)
    {
        return address(rounds[id].vestingContract);
    }

    /**
     * @param id Number of round
     * @param account Address of depositor
     * @return  Investor Deposited Tokens
     */
    function getInvestorDepositedTokens(uint256 id, address account)
        public
        view
        existRound(id)
        returns (uint256)
    {
        return (rounds[id].sums[account]);
    }

    /**
     * @return  Investor Deposited Tokens
     */
    function getInvestorWallet() public view returns (address) {
        return investorWallet;
    }

    /**
     * @param id Number of round
     * @return   True if `id` round is cancelled
     */
    function isCancelled(uint256 id) public view existRound(id) returns (bool) {
        return rounds[id].typeRound == 0;
    }

    /**
     * @param id Number of round
     * @return True if `msg.sender`  is Participated In The Round
     */
    function isParticipatedInTheRound(uint256 id)
        public
        view
        existRound(id)
        returns (bool)
    {
        return rounds[id].depositToken[msg.sender] != address(0);
    }

    /**
     * @param id Number of round
     * @return Deposited token addres of `msg.sender`
     */
    function getUserToken(uint256 id)
        public
        view
        existRound(id)
        returns (address)
    {
        return rounds[id].depositToken[msg.sender];
    }

    /**
     * @param id Number of round
     * @return True if `id` round  is finished
     */
    function isFinished(uint256 id) public view returns (bool) {
        return rounds[id].finished;
    }
}

pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TreasuryVester is Ownable {
    using SafeMath for uint256;

    address public immutable blid;
    address public recipient;

    uint256 public immutable vestingAmount;
    uint256 public immutable vestingBegin;
    uint256 public immutable vestingCliff;
    uint256 public immutable vestingEnd;

    uint256 public lastUpdate;

    constructor(
        address blid_,
        address recipient_,
        uint256 vestingAmount_,
        uint256 vestingBegin_,
        uint256 vestingCliff_,
        uint256 vestingEnd_
    ) {
        require(
            vestingBegin_ >= block.timestamp,
            "TreasuryVester::constructor: vesting begin too early"
        );
        require(
            vestingCliff_ >= vestingBegin_,
            "TreasuryVester::constructor: cliff is too early"
        );
        require(
            vestingEnd_ > vestingCliff_,
            "TreasuryVester::constructor: end is too early"
        );

        blid = blid_;
        recipient = recipient_;

        vestingAmount = vestingAmount_;
        vestingBegin = vestingBegin_;
        vestingCliff = vestingCliff_;
        vestingEnd = vestingEnd_;

        lastUpdate = vestingBegin_;
    }

    function setRecipient(address recipient_) public {
        require(
            msg.sender == owner(),
            "TreasuryVester::setRecipient: unauthorized"
        );
        recipient = recipient_;
    }

    function claim() public {
        require(
            block.timestamp >= vestingCliff,
            "TreasuryVester::claim: not time yet"
        );
        uint256 amount;
        if (block.timestamp >= vestingEnd) {
            amount = IBlid(blid).balanceOf(address(this));
        } else {
            amount = vestingAmount * 10**18;
            amount = amount.mul(block.timestamp - lastUpdate).div(
                vestingEnd - vestingBegin
            );
            lastUpdate = block.timestamp;
        }
        IBlid(blid).transfer(recipient, amount);
    }
}

interface IBlid {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address dst, uint256 rawAmount) external returns (bool);
}

pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PersonalVester {
    using SafeMath for uint256;

    address public immutable blid;
    address public recipient;

    uint256 public immutable vestingAmount;
    uint256 public immutable vestingBegin;
    uint256 public immutable vestingCliff;
    uint256 public immutable vestingEnd;

    uint256 public lastUpdate;

    constructor(
        address blid_,
        address recipient_,
        uint256 vestingAmount_,
        uint256 vestingBegin_,
        uint256 vestingCliff_,
        uint256 vestingEnd_
    ) {
        require(
            vestingBegin_ >= block.timestamp,
            "TreasuryVester::constructor: vesting begin too early"
        );
        require(
            vestingCliff_ >= vestingBegin_,
            "TreasuryVester::constructor: cliff is too early"
        );
        require(
            vestingEnd_ > vestingCliff_,
            "TreasuryVester::constructor: end is too early"
        );

        blid = blid_;
        recipient = recipient_;

        vestingAmount = vestingAmount_;
        vestingBegin = vestingBegin_;
        vestingCliff = vestingCliff_;
        vestingEnd = vestingEnd_;

        lastUpdate = vestingBegin_;
    }

    function setRecipient(address recipient_) public {
        require(
            msg.sender == recipient,
            "TreasuryVester::setRecipient: unauthorized"
        );
        recipient = recipient_;
    }

    function claim() public {
        require(
            block.timestamp >= vestingCliff,
            "TreasuryVester::claim: not time yet"
        );
        uint256 amount;
        if (block.timestamp >= vestingEnd) {
            amount = IBlid(blid).balanceOf(address(this));
        } else {
            amount = vestingAmount * 10**18;
            amount = amount.mul(block.timestamp - lastUpdate).div(
                vestingEnd - vestingBegin
            );
            lastUpdate = block.timestamp;
        }
        IBlid(blid).transfer(recipient, amount);
    }
}

interface IBlid {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address dst, uint256 rawAmount) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interfaces/IStorage.sol";
import "./Interfaces/AggregatorV3Interface.sol";
import "./Interfaces/ILogicContract.sol";
import "./Interfaces/IStrategyContract.sol";
import "./utils/OwnableUpgradeableAdminable.sol";
import "./utils/LogicUpgradeable.sol";

contract MultiLogic is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct singleStrategy {
        address logicContract;
        address strategyContract;
    }

    address private storageContract;
    singleStrategy[] private multiStrategy;
    mapping(address => bool) private approvedTokens;
    mapping(address => bool) private approvedTokensLogic;
    mapping(address => mapping(address => uint256)) private dividePercentage;
    mapping(address => mapping(address => uint256)) private tokenAvailableLogic;
    mapping(address => mapping(address => uint256)) private tokenBalanceLogic;
    uint256 public multiStrategyLength;
    string[] public multiStrategyName;
    mapping(string => singleStrategy) private multiStrategyData;
    event UpdateTokenAvailableLogic(
        uint256 balance,
        address token,
        address logic
    );
    event UpdateTokenBalanceLogic(
        uint256 balance,
        address token,
        address logic
    );
    event TakeToken(address token, address logic, uint256 amount);
    event ReturnToken(address token, uint256 amount);
    event ReleaseToken(address token, uint256 amount);
    event AddStrategy(string name, singleStrategy strategies);
    event InitStrategy(string[] strategiesName, singleStrategy[] strategies);
    event SetLogicTokenAvailable(
        uint256 amount,
        address token,
        uint256 deposit_flag
    );

    function __MultiLogicProxy_init() public initializer {
        LogicUpgradeable.initialize();
        multiStrategyLength = 0;
    }

    receive() external payable {}

    modifier onlyStorage() {
        require(msg.sender == storageContract, "M1");
        _;
    }

    /*** User function ***/

    /**
     * @notice set Storage address
     * @param _storage storage address
     */
    function setStorage(address _storage) external onlyOwner {
        require(storageContract == address(0), "M5");
        storageContract = _storage;
    }

    /**
     * @notice Set the dividing percentage
     * @param _token token address
     * @param _percentages percentage array
     */
    function setPercentages(address _token, uint256[] calldata _percentages)
        external
        onlyOwner
    {
        uint256 _count = multiStrategyLength;
        uint256 sum = 0;
        uint256 sumAvailable = 0;
        uint256 index;
        require(_percentages.length == _count, "M2");
        for (index = 0; index < _count; ) {
            sum += _percentages[index];
            unchecked {
                ++index;
            }
        }
        require(sum == 10000, "M3");
        for (index = 0; index < _count; ) {
            singleStrategy memory _multiStrategy = multiStrategyData[
                multiStrategyName[index]
            ];
            sumAvailable += tokenAvailableLogic[_token][
                _multiStrategy.logicContract
            ];
            dividePercentage[_token][
                _multiStrategy.logicContract
            ] = _percentages[index];
            unchecked {
                ++index;
            }
        }
        if (sumAvailable > 0) {
            for (index = 0; index < _count; ) {
                tokenAvailableLogic[_token][
                    multiStrategyData[multiStrategyName[index]].logicContract
                ] = (sumAvailable * _percentages[index]) / 10000;
                unchecked {
                    ++index;
                }
            }
        }
    }

    /**
     * @notice Init the Logic address into MultiLogicProxy
     * @param _strategyName strategy name array
     * @param _multiStrategy strategy array
     */
    function initStrategies(
        string[] calldata _strategyName,
        singleStrategy[] calldata _multiStrategy
    ) external onlyOwner {
        delete multiStrategyName;
        uint256 count = _multiStrategy.length;
        uint256 nameCount = _strategyName.length;
        require(count == nameCount);

        for (uint256 i = 0; i < count; ) {
            multiStrategyName.push(_strategyName[i]);
            multiStrategyData[_strategyName[i]] = _multiStrategy[i];
            unchecked {
                ++i;
            }
        }
        multiStrategyLength = count;

        emit InitStrategy(_strategyName, _multiStrategy);
    }

    /**
     * @notice Set the Logic address into MultiLogicProxy
     * @param _strategyName strategy name
     * @param _multiStrategy strategy
     * @param _overwrite overwrite flag
     */
    function addStrategy(
        string memory _strategyName,
        singleStrategy memory _multiStrategy,
        bool _overwrite
    ) external onlyOwner {
        bool exist = false;
        for (uint256 i = 0; i < multiStrategyLength; ) {
            if (
                keccak256(abi.encodePacked((multiStrategyName[i]))) ==
                keccak256(abi.encodePacked((_strategyName)))
            ) {
                require(_overwrite, "M9");
                exist = true;
                break;
            }
            unchecked {
                ++i;
            }
        }
        if (!exist) {
            multiStrategyName.push(_strategyName);
            multiStrategyLength++;
        }
        multiStrategyData[_strategyName] = _multiStrategy;
        emit AddStrategy(_strategyName, _multiStrategy);
    }

    /*** Storage function ***/

    /**
     * @notice Set Token balance for each logic
     * @param _amount deposit amount
     * @param _token deposit token
     * @param _deposit_withdraw flag for deposit or withdraw 1 : increase, 0: decrease, 2: set
     */
    function setLogicTokenAvailable(
        uint256 _amount,
        address _token,
        uint256 _deposit_withdraw
    ) external {
        require(msg.sender == owner() || msg.sender == storageContract, "M1");

        uint256 _count = multiStrategyLength;
        uint256 _amount_s = _amount;
        for (uint256 i = 0; i < _count; i++) {
            address logicAddress = multiStrategyData[multiStrategyName[i]]
                .logicContract;
            if (_deposit_withdraw == 1) {
                //deposit
                uint256 newAvailableAmount = ((_amount_s *
                    dividePercentage[_token][logicAddress]) / 10000);
                tokenAvailableLogic[_token][logicAddress] += newAvailableAmount;
            } else if (_deposit_withdraw == 0) {
                //withdraw
                if (tokenAvailableLogic[_token][logicAddress] >= _amount_s) {
                    tokenAvailableLogic[_token][logicAddress] -= _amount_s;
                    _amount_s = 0;
                } else {
                    _amount_s -= tokenAvailableLogic[_token][logicAddress];
                    tokenAvailableLogic[_token][logicAddress] = 0;
                }
                if (_amount_s <= 0) break;
            } else {
                uint256 newAvailableAmount = ((_amount_s *
                    dividePercentage[_token][logicAddress]) / 10000);
                tokenAvailableLogic[_token][logicAddress] = newAvailableAmount;
            }
        }

        emit SetLogicTokenAvailable(_amount, _token, _deposit_withdraw);
    }

    /**
     * @notice Transfer amount of token from Logic to Storage Contract.
     * @param _amount Amount of token
     * @param _token Address of token
     */
    function releaseToken(uint256 _amount, address _token)
        external
        onlyStorage
    {
        uint256 _count = multiStrategyLength;
        uint256 _amount_show = _amount;
        if (_token != address(0) && !approvedTokens[_token]) {
            //if token not approved for storage
            IERC20Upgradeable(_token).approve(
                storageContract,
                type(uint256).max
            );
            approvedTokens[_token] = true;
        }

        for (uint256 i = 0; i < _count; i++) {
            singleStrategy memory sStrategy = multiStrategyData[
                multiStrategyName[i]
            ];

            uint256 releaseAmount = _amount;
            if (
                tokenBalanceLogic[_token][sStrategy.logicContract] <
                releaseAmount
            ) {
                releaseAmount = tokenBalanceLogic[_token][
                    sStrategy.logicContract
                ];
            }

            if (releaseAmount > 0) {
                IStrategyContract(sStrategy.strategyContract).releaseToken(
                    releaseAmount,
                    _token
                );
                tokenBalanceLogic[_token][
                    sStrategy.logicContract
                ] -= releaseAmount;

                if (_token != address(0)) {
                    IERC20Upgradeable(_token).safeTransferFrom(
                        sStrategy.logicContract,
                        address(this),
                        releaseAmount
                    );
                }
            }
            // We don't update tokenAvaliable, because it is updated in Storage

            _amount -= releaseAmount;
            if (_amount <= 0) break;
        }

        if (_token == address(0)) {
            require(address(this).balance >= _amount_show, "M7");
            _send(payable(storageContract), _amount_show);
        }

        emit ReleaseToken(_token, _amount_show);
    }

    /*** Logic function ***/

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param _amount Amount of token
     * @param _token Address of token
     */
    function takeToken(uint256 _amount, address _token) external {
        require(isExistLogic(msg.sender), "M4");
        uint256 tokenAvailable = getTokenAvailable(_token, msg.sender);
        require(_amount <= tokenAvailable, "M6");

        IStorage(storageContract).takeToken(_amount, _token);

        if (_token == address(0)) {
            require(address(this).balance >= _amount, "M7");
            _send(payable(msg.sender), _amount);
        } else {
            IERC20Upgradeable(_token).safeTransfer(msg.sender, _amount);
        }

        tokenAvailableLogic[_token][msg.sender] -= _amount;
        tokenBalanceLogic[_token][msg.sender] += _amount;

        emit UpdateTokenAvailableLogic(
            tokenAvailableLogic[_token][msg.sender],
            _token,
            msg.sender
        );
        emit UpdateTokenBalanceLogic(
            tokenBalanceLogic[_token][msg.sender],
            _token,
            msg.sender
        );
        emit TakeToken(_token, msg.sender, _amount);
    }

    /**
     * @notice Transfer amount of token from Logic to Storage Contract.
     * @param _amount Amount of token
     * @param _token Address of token
     */
    function returnToken(uint256 _amount, address _token) external {
        require(isExistLogic(msg.sender), "M4");
        require(_amount <= tokenBalanceLogic[_token][msg.sender], "M6");

        if (_token == address(0)) {
            require(address(this).balance >= _amount, "M7");
            _send(payable(storageContract), _amount);
        } else {
            if (!approvedTokens[_token]) {
                //if token not approved for storage
                IERC20Upgradeable(_token).approve(
                    storageContract,
                    type(uint256).max
                );
                approvedTokens[_token] = true;
            }

            IERC20Upgradeable(_token).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        IStorage(storageContract).returnToken(_amount, _token);

        tokenAvailableLogic[_token][msg.sender] += _amount;
        tokenBalanceLogic[_token][msg.sender] -= _amount;

        emit UpdateTokenAvailableLogic(
            tokenAvailableLogic[_token][msg.sender],
            _token,
            msg.sender
        );
        emit UpdateTokenBalanceLogic(
            tokenBalanceLogic[_token][msg.sender],
            _token,
            msg.sender
        );
        emit ReturnToken(_token, _amount);
    }

    /**
     * @notice Take amount BLID from Logic contract  and distributes earned BLID
     * @param _amount Amount of distributes earned BLID
     * @param _blidToken blidToken address
     */
    function addEarn(uint256 _amount, address _blidToken) external {
        require(isExistLogic(msg.sender), "M4");

        IERC20Upgradeable(_blidToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (!approvedTokens[_blidToken]) {
            //if token not approved for storage
            IERC20Upgradeable(_blidToken).approve(
                storageContract,
                type(uint256).max
            );
            approvedTokens[_blidToken] = true;
        }

        IStorage(storageContract).addEarn(_amount);
    }

    /*** Public view function ***/

    /**
     * @notice Return deposited usd
     */
    function getTotalDeposit() external view returns (uint256) {
        return IStorage(storageContract).getTotalDeposit();
    }

    /**
     * @notice Returns the available amount of token for the logic
     * @param _token deposit token
     * @param _logicAddress logic Address
     */
    function getTokenAvailable(address _token, address _logicAddress)
        public
        view
        returns (uint256)
    {
        return tokenAvailableLogic[_token][_logicAddress];
    }

    /**
     * @notice Returns the taken amount of token for the logic
     * @param _token deposit token
     * @param _logicAddress logic Address
     */
    function getTokenTaken(address _token, address _logicAddress)
        public
        view
        returns (uint256)
    {
        return tokenBalanceLogic[_token][_logicAddress];
    }

    /**
     * @notice Return percentage value
     * @param _token deposit token
     */
    function getPercentage(address _token)
        external
        view
        returns (uint256[] memory)
    {
        uint256 _count = multiStrategyLength;
        uint256[] memory ret = new uint256[](_count);
        for (uint256 i = 0; i < _count; i++) {
            ret[i] = dividePercentage[_token][
                multiStrategyData[multiStrategyName[i]].logicContract
            ];
        }
        return ret;
    }

    /**
     * @notice Set the Logic address into MultiLogicProxy
     * @param _name strategy name
     */
    function strategyInfo(string memory _name)
        external
        view
        returns (address, address)
    {
        bool exist = false;
        for (uint256 i = 0; i < multiStrategyLength; ) {
            if (
                keccak256(abi.encodePacked((multiStrategyName[i]))) ==
                keccak256(abi.encodePacked((_name)))
            ) {
                exist = true;
                break;
            }
            unchecked {
                ++i;
            }
        }
        require(exist == true, "M10");
        return (
            multiStrategyData[_name].logicContract,
            multiStrategyData[_name].strategyContract
        );
    }

    /**
     * @notice Check if the logic address exist
     * @param _logicAddress logic address for checking
     */
    function isExistLogic(address _logicAddress) public view returns (bool) {
        uint256 _count = multiStrategyLength;
        for (uint256 i; i < _count; ) {
            if (
                multiStrategyData[multiStrategyName[i]].logicContract ==
                _logicAddress
            ) return true;
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /**
     * @notice Get used tokens in storage
     */
    function getUsedTokensStorage() external view returns (address[] memory) {
        return IStorage(storageContract).getUsedTokens();
    }

    /*** Private function ***/

    /**
     * @notice Send ETH to address
     * @param _to target address to receive ETH
     * @param amount ETH amount (wei) to be sent
     */
    function _send(address payable _to, uint256 amount) private {
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "M8");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IStorage {
    function takeToken(uint256 amount, address token) external;

    function returnToken(uint256 amount, address token) external;

    function addEarn(uint256 amount) external;

    function _isUsedToken(address _token) external returns (bool);

    function getTokenDeposit(address account, address token)
        external
        view
        returns (uint256);

    function getTotalDeposit() external view returns (uint256);

    function getTokenBalance(address token) external view returns (uint256);

    function getTokenDeposited(address token) external view returns (uint256);

    function depositOnBehalf(
        uint256 amount,
        address token,
        address accountAddress
    ) external;

    function getUsedTokens() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256 answer);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface ILogicContract {
    function addXTokens(
        address token,
        address xToken,
        uint8 leadingTokenType
    ) external;

    function approveTokenForSwap(address token) external;

    function claim(address[] calldata xTokens, uint8 leadingTokenType) external;

    function mint(address xToken, uint256 mintAmount)
        external
        returns (uint256);

    function borrow(
        address xToken,
        uint256 borrowAmount,
        uint8 leadingTokenType
    ) external returns (uint256);

    function repayBorrow(address xToken, uint256 repayAmount) external;

    function redeemUnderlying(address xToken, uint256 redeemAmount)
        external
        returns (uint256);

    function swapExactTokensForTokens(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function removeLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address swap,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH);

    function addEarnToStorage(uint256 amount) external;

    function enterMarkets(address[] calldata xTokens, uint8 leadingTokenType)
        external
        returns (uint256[] memory);

    function returnTokenToStorage(uint256 amount, address token) external;

    function takeTokenFromStorage(uint256 amount, address token) external;

    function withdraw(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external;

    function returnETHToMultiLogicProxy(uint256 amount) external;

    function returnToken(uint256 amount, address token) external; // for StorageV2 only
}

interface IStrategy {
    function releaseToken(uint256 amount, address token) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IStrategyContract {
    function releaseToken(uint256 amount, address token) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract OwnableUpgradeableAdminable is OwnableUpgradeable {
    address private _admin;

    event SetAdmin(address admin);

    modifier onlyAdmin() {
        require(msg.sender == _admin, "OA1");
        _;
    }

    modifier onlyOwnerAndAdmin() {
        require(msg.sender == owner() || msg.sender == _admin, "OA2");
        _;
    }

    /**
     * @notice Set admin
     * @param newAdmin Addres of new admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        _admin = newAdmin;
        emit SetAdmin(newAdmin);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./OwnableUpgradeableVersionable.sol";
import "./OwnableUpgradeableAdminable.sol";

abstract contract LogicUpgradeable is
    Initializable,
    OwnableUpgradeableVersionable,
    OwnableUpgradeableAdminable,
    UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract OwnableUpgradeableVersionable is OwnableUpgradeable {
    string private _version;
    string private _purpose;

    event UpgradeVersion(string version, string purpose);

    function getVersion() external view returns (string memory) {
        return _version;
    }

    function getPurpose() external view returns (string memory) {
        return _purpose;
    }

    /**
    * @notice Set version and purpose
    * @param version Version string, ex : 1.2.0
    * @param purpose Purpose string
    */
    function upgradeVersion(string memory version, string memory purpose)
        external
        onlyOwner
    {
        require(bytes(version).length != 0, "OV1");

        _version = version;
        _purpose = purpose;

        emit UpgradeVersion(version, purpose);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../Interfaces/ILogicContract.sol";
import "../Interfaces/AggregatorV3Interface.sol";

contract StorageV2 is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    //struct
    struct DepositStruct {
        mapping(address => uint256) amount;
        mapping(address => int256) tokenTime;
        uint256 iterate;
        uint256 balanceBLID;
        mapping(address => uint256) depositIterate;
    }

    struct EarnBLID {
        uint256 allBLID;
        uint256 timestamp;
        uint256 usd;
        uint256 tdt;
        mapping(address => uint256) rates;
    }

    /*** events ***/

    event Deposit(address depositor, address token, uint256 amount);
    event Withdraw(address depositor, address token, uint256 amount);
    event UpdateTokenBalance(uint256 balance, address token);
    event TakeToken(address token, uint256 amount);
    event ReturnToken(address token, uint256 amount);
    event AddEarn(uint256 amount);
    event UpdateBLIDBalance(uint256 balance);
    event InterestFee(address depositor, uint256 amount);
    event SetBLID(address blid);
    event AddToken(address token, address oracle);
    event SetLogic(address logic);

    function initialize(address _logicContract) external initializer {
        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
        logicContract = _logicContract;
    }

    mapping(uint256 => EarnBLID) private earnBLID;
    uint256 private countEarns;
    uint256 private countTokens;
    mapping(uint256 => address) private tokens;
    mapping(address => uint256) private tokenBalance;
    mapping(address => address) private oracles;
    mapping(address => bool) private tokensAdd;
    mapping(address => DepositStruct) private deposits;
    mapping(address => uint256) private tokenDeposited;
    mapping(address => int256) private tokenTime;
    uint256 private reserveBLID;
    address private logicContract;
    address private BLID;
    mapping(address => mapping(uint256 => uint256))
        public accumulatedRewardsPerShare;

    /*** modifiers ***/

    modifier isUsedToken(address _token) {
        require(tokensAdd[_token], "E1");
        _;
    }

    modifier isLogicContract(address account) {
        require(logicContract == account, "E2");
        _;
    }

    /*** User function ***/

    /**
     * @notice Deposit amount of token  to Strategy  and receiving earned tokens.
     * @param amount amount of token
     * @param token address of token
     */
    function deposit(uint256 amount, address token)
        external
        isUsedToken(token)
        whenNotPaused
    {
        require(amount > 0, "E3");
        uint8 decimals = AggregatorV3Interface(token).decimals();
        DepositStruct storage depositor = deposits[msg.sender];
        IERC20Upgradeable(token).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        uint256 amountExp18 = amount * 10**(18 - decimals);
        if (depositor.tokenTime[address(0)] == 0) {
            depositor.iterate = countEarns;
            depositor.depositIterate[token] = countEarns;
            depositor.tokenTime[address(0)] = 1;
            depositor.tokenTime[token] += int256(
                block.timestamp * (amountExp18)
            );
        } else {
            interestFee();
            if (depositor.depositIterate[token] == countEarns) {
                depositor.tokenTime[token] += int256(
                    block.timestamp * (amountExp18)
                );
            } else {
                depositor.tokenTime[token] = int256(
                    depositor.amount[token] *
                        earnBLID[countEarns - 1].timestamp +
                        block.timestamp *
                        (amountExp18)
                );

                depositor.depositIterate[token] = countEarns;
            }
        }
        depositor.amount[token] += amountExp18;

        tokenTime[token] += int256(block.timestamp * (amountExp18));
        tokenBalance[token] += amountExp18;
        tokenDeposited[token] += amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Deposit(msg.sender, token, amountExp18);
    }

    /**
     * @notice Withdraw amount of token  from Strategy and receiving earned tokens.
     * @param amount Amount of token
     * @param token Address of token
     */
    function withdraw(uint256 amount, address token)
        external
        isUsedToken(token)
        whenNotPaused
    {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 countEarns_ = countEarns;
        uint256 amountExp18 = amount * 10**(18 - decimals);
        DepositStruct storage depositor = deposits[msg.sender];
        require(depositor.amount[token] >= amountExp18 && amount > 0, "E4");
        if (amountExp18 > tokenBalance[token]) {
            ILogicContract(logicContract).returnToken(amount, token);
            interestFee();
            IERC20Upgradeable(token).safeTransferFrom(
                logicContract,
                msg.sender,
                amount
            );
            tokenDeposited[token] -= amountExp18;
            tokenTime[token] -= int256(block.timestamp * (amountExp18));
        } else {
            interestFee();
            IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
            tokenTime[token] -= int256(block.timestamp * (amountExp18));

            tokenBalance[token] -= amountExp18;
            tokenDeposited[token] -= amountExp18;
        }
        if (depositor.depositIterate[token] == countEarns_) {
            depositor.tokenTime[token] -= int256(
                block.timestamp * (amountExp18)
            );
        } else {
            depositor.tokenTime[token] =
                int256(
                    depositor.amount[token] *
                        earnBLID[countEarns_ - 1].timestamp
                ) -
                int256(block.timestamp * (amountExp18));
            depositor.depositIterate[token] = countEarns_;
        }
        depositor.amount[token] -= amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Withdraw(msg.sender, token, amountExp18);
    }

    /**
     * @notice Claim BLID to msg.sender
     */
    function interestFee() public {
        uint256 balanceUser = balanceEarnBLID(msg.sender);
        require(reserveBLID >= balanceUser, "E5");
        IERC20Upgradeable(BLID).safeTransfer(msg.sender, balanceUser);
        DepositStruct storage depositor = deposits[msg.sender];
        depositor.balanceBLID = balanceUser;
        depositor.iterate = countEarns;
        //unchecked is used because a check was made in require
        unchecked {
            depositor.balanceBLID = 0;
            reserveBLID -= balanceUser;
        }

        emit UpdateBLIDBalance(reserveBLID);
        emit InterestFee(msg.sender, balanceUser);
    }

    /*** Owner functions ***/

    /**
     * @notice Set blid in contract
     * @param _blid address of BLID
     */
    function setBLID(address _blid) external onlyOwner {
        BLID = _blid;

        emit SetBLID(_blid);
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Update AccumulatedRewardsPerShare for token, using once after update contract
     * @param token Address of token
     */
    function updateAccumulatedRewardsPerShare(address token)
        external
        onlyOwner
    {
        require(accumulatedRewardsPerShare[token][0] == 0, "E7");
        uint256 countEarns_ = countEarns;
        for (uint256 i = 0; i < countEarns_; i++) {
            updateAccumulatedRewardsPerShareById(token, i);
        }
    }

    /**
     * @notice Add token and token's oracle
     * @param _token Address of Token
     * @param _oracles Address of token's oracle(https://docs.chain.link/docs/binance-smart-chain-addresses/
     */
    function addToken(address _token, address _oracles) external onlyOwner {
        require(_token != address(0) && _oracles != address(0));
        require(!tokensAdd[_token], "E6");
        oracles[_token] = _oracles;
        tokens[countTokens++] = _token;
        tokensAdd[_token] = true;

        emit AddToken(_token, _oracles);
    }

    /**
     * @notice Set logic in contract(only for upgradebale contract,use only whith DAO)
     * @param _logic Address of Logic Contract
     */
    function setLogic(address _logic) external onlyOwner {
        logicContract = _logic;

        emit SetLogic(_logic);
    }

    /*** LogicContract function ***/

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeToken(uint256 amount, address token)
        external
        isLogicContract(msg.sender)
        isUsedToken(token)
    {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 amountExp18 = amount * 10**(18 - decimals);
        IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
        tokenBalance[token] = tokenBalance[token] - amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit TakeToken(token, amountExp18);
    }

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnToken(uint256 amount, address token)
        external
        isLogicContract(msg.sender)
        isUsedToken(token)
    {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 amountExp18 = amount * 10**(18 - decimals);
        IERC20Upgradeable(token).safeTransferFrom(
            logicContract,
            address(this),
            amount
        );
        tokenBalance[token] = tokenBalance[token] + amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit ReturnToken(token, amountExp18);
    }

    /**
     * @notice Take amount BLID from Logic contract  and distributes earned BLID
     * @param amount Amount of distributes earned BLID
     */
    function addEarn(uint256 amount) external isLogicContract(msg.sender) {
        IERC20Upgradeable(BLID).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        reserveBLID += amount;
        int256 _dollarTime = 0;
        uint256 countTokens_ = countTokens;
        uint256 countEarns_ = countEarns;
        EarnBLID storage thisEarnBLID = earnBLID[countEarns_];
        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            AggregatorV3Interface oracle = AggregatorV3Interface(
                oracles[token]
            );
            thisEarnBLID.rates[token] = (uint256(oracle.latestAnswer()) *
                10**(18 - oracle.decimals()));

            // count all deposited token in usd
            thisEarnBLID.usd +=
                tokenDeposited[token] *
                thisEarnBLID.rates[token];

            // convert token time to dollar time
            _dollarTime += tokenTime[token] * int256(thisEarnBLID.rates[token]);
        }
        require(_dollarTime != 0);
        thisEarnBLID.allBLID = amount;
        thisEarnBLID.timestamp = block.timestamp;
        thisEarnBLID.tdt = uint256(
            (int256(((block.timestamp) * thisEarnBLID.usd)) - _dollarTime) /
                (1 ether)
        ); // count delta of current token time and all user token time

        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            tokenTime[token] = int256(tokenDeposited[token] * block.timestamp); // count curent token time
            updateAccumulatedRewardsPerShareById(token, countEarns_);
        }
        thisEarnBLID.usd /= (1 ether);
        countEarns++;

        emit AddEarn(amount);
        emit UpdateBLIDBalance(reserveBLID);
    }

    /*** External function ***/

    /**
     * @notice Counts the number of accrued СSR
     * @param account Address of Depositor
     */
    function _upBalance(address account) external {
        deposits[account].balanceBLID = balanceEarnBLID(account);
        deposits[account].iterate = countEarns;
    }

    /***  Public View function ***/

    /**
     * @notice Return earned blid
     * @param account Address of Depositor
     */
    function balanceEarnBLID(address account) public view returns (uint256) {
        DepositStruct storage depositor = deposits[account];
        if (depositor.tokenTime[address(0)] == 0 || countEarns == 0) {
            return 0;
        }
        if (countEarns == depositor.iterate) return depositor.balanceBLID;

        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        uint256 depositorIterate = depositor.iterate;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            //if iterate when user deposited
            if (depositorIterate == depositor.depositIterate[token]) {
                sum += getEarnedInOneDepositedIterate(
                    depositorIterate,
                    token,
                    account
                );
                sum += getEarnedInOneNotDepositedIterate(
                    depositorIterate,
                    token,
                    account
                );
            } else {
                sum += getEarnedInOneNotDepositedIterate(
                    depositorIterate - 1,
                    token,
                    account
                );
            }
        }

        return sum + depositor.balanceBLID;
    }

    /*** External View function ***/

    /**
     * @notice Return usd balance of account
     * @param account Address of Depositor
     */
    function balanceOf(address account) external view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            AggregatorV3Interface oracle = AggregatorV3Interface(
                oracles[token]
            );

            sum += ((deposits[account].amount[token] *
                uint256(oracle.latestAnswer()) *
                10**(18 - oracle.decimals())) / (1 ether));
        }
        return sum;
    }

    /**
     * @notice Return sums of all distribution BLID.
     */
    function getBLIDReserve() external view returns (uint256) {
        return reserveBLID;
    }

    /**
     * @notice Return deposited usd
     */
    function getTotalDeposit() external view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            AggregatorV3Interface oracle = AggregatorV3Interface(
                oracles[token]
            );
            sum +=
                (tokenDeposited[token] *
                    uint256(oracle.latestAnswer()) *
                    10**(18 - oracle.decimals())) /
                (1 ether);
        }
        return sum;
    }

    /**
     * @notice Returns the balance of token on this contract
     */
    function getTokenBalance(address token) external view returns (uint256) {
        return tokenBalance[token];
    }

    /**
     * @notice Return deposited token from account
     */
    function getTokenDeposit(address account, address token)
        external
        view
        returns (uint256)
    {
        return deposits[account].amount[token];
    }

    /**
     * @notice Return true if _token  is in token list
     * @param _token Address of Token
     */
    function _isUsedToken(address _token) external view returns (bool) {
        return tokensAdd[_token];
    }

    /**
     * @notice Return count distribution BLID token.
     */
    function getCountEarns() external view returns (uint256) {
        return countEarns;
    }

    /**
     * @notice Return data on distribution BLID token.
     * First return value is amount of distribution BLID token.
     * Second return value is a timestamp when  distribution BLID token completed.
     * Third return value is an amount of dollar depositedhen  distribution BLID token completed.
     */
    function getEarnsByID(uint256 id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (earnBLID[id].allBLID, earnBLID[id].timestamp, earnBLID[id].usd);
    }

    /**
     * @notice Return amount of all deposited token
     * @param token Address of Token
     */
    function getTokenDeposited(address token) external view returns (uint256) {
        return tokenDeposited[token];
    }

    /*** Prvate Function ***/

    /**
     * @notice Count accumulatedRewardsPerShare
     * @param token Address of Token
     * @param id of accumulatedRewardsPerShare
     */
    function updateAccumulatedRewardsPerShareById(address token, uint256 id)
        private
    {
        EarnBLID storage thisEarnBLID = earnBLID[id];
        //unchecked is used because if id = 0 then  accumulatedRewardsPerShare[token][id-1] equal zero
        unchecked {
            accumulatedRewardsPerShare[token][id] =
                accumulatedRewardsPerShare[token][id - 1] +
                ((thisEarnBLID.allBLID *
                    (thisEarnBLID.timestamp - earnBLID[id - 1].timestamp) *
                    thisEarnBLID.rates[token]) / thisEarnBLID.tdt);
        }
    }

    /**
     * @notice Count user rewards in one iterate, when he  deposited
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        EarnBLID storage thisEarnBLID = earnBLID[depositIterate];
        DepositStruct storage thisDepositor = deposits[account];
        return
            (// all distibution BLID multiply to
            thisEarnBLID.allBLID *
                // delta of  user dollar time and user dollar time if user deposited in at the beginning distibution
                uint256(
                    int256(
                        thisDepositor.amount[token] *
                            thisEarnBLID.rates[token] *
                            thisEarnBLID.timestamp
                    ) -
                        thisDepositor.tokenTime[token] *
                        int256(thisEarnBLID.rates[token])
                )) /
            //div to delta of all users dollar time and all users dollar time if all users deposited in at the beginning distibution
            thisEarnBLID.tdt /
            (1 ether);
    }

    /*** Prvate View Function ***/

    /**
     * @notice Count user rewards in one iterate, when he was not deposit
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneNotDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        return
            ((accumulatedRewardsPerShare[token][countEarns - 1] -
                accumulatedRewardsPerShare[token][depositIterate]) *
                deposits[account].amount[token]) / (1 ether);
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
library SafeMathUpgradeable {
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

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Interfaces/IMultiLogicProxy.sol";
import "./Interfaces/AggregatorV3Interface.sol";

contract StorageV3Beta is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    //struct
    struct DepositStruct {
        mapping(address => uint256) amount;
        mapping(address => int256) tokenTime; // 1: flag, 0: BNB
        uint256 iterate;
        uint256 balanceBLID;
        mapping(address => uint256) depositIterate;
    }

    struct EarnBLID {
        uint256 allBLID;
        uint256 timestamp;
        uint256 usd;
        uint256 tdt;
        mapping(address => uint256) rates;
    }

    struct BoostInfo {
        uint256 blidDeposit;
        uint256 rewardDebt;
        uint256 blidOverDeposit;
    }

    struct LeaveTokenPolicy {
        uint256 limit;
        uint256 leavePercentage;
        uint256 leaveFixed;
    }

    /*** events ***/

    event Deposit(address depositor, address token, uint256 amount);
    event Withdraw(address depositor, address token, uint256 amount);
    event UpdateTokenBalance(uint256 balance, address token);
    event TakeToken(address token, uint256 amount);
    event ReturnToken(address token, uint256 amount);
    event AddEarn(uint256 amount);
    event UpdateBLIDBalance(uint256 balance);
    event InterestFee(address depositor, uint256 amount);
    event SetBLID(address blid);
    event AddToken(address token, address oracle);
    event SetMultiLogicProxy(address multiLogicProxy);
    event SetBoostInfo(uint256 maxBlidPerUSD, uint256 blidPerBlock);
    event DepositBLID(address depositor, uint256 amount);
    event WithdrawBLID(address depositor, uint256 amount);
    event ClaimBoostBLID(address depositor, uint256 amount);
    event SetBoostingAddress(address boostingAddress);
    event SetAdmin(address admin);
    event UpgradeVersion(string version, string purpose);
    event SetLeaveTokenPolicy(
        uint256 limit,
        uint256 leavePerentage,
        uint256 leaveFixed
    );

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
    }

    mapping(uint256 => EarnBLID) private earnBLID;
    uint256 private countEarns;
    uint256 private countTokens;
    mapping(uint256 => address) private tokens;
    mapping(address => uint256) private tokenBalance;
    mapping(address => address) private oracles;
    mapping(address => bool) private tokensAdd;
    mapping(address => DepositStruct) private deposits;
    mapping(address => uint256) private tokenDeposited;
    mapping(address => int256) private tokenTime;
    uint256 private reserveBLID;
    address public logicContract; // MultiLogicProxy : V3
    address private BLID;
    mapping(address => mapping(uint256 => uint256))
        public accumulatedRewardsPerShare;

    // Boost2.0
    mapping(address => BoostInfo) private userBoosts;
    uint256 public maxBlidPerUSD;
    uint256 public blidPerBlock;
    uint256 public initBlidPerBlock;
    uint256 public accBlidPerShare;
    uint256 public lastRewardBlock;
    address public boostingAddress;
    uint256 public totalSupplyBLID;

    // ****** Add from V3 ******
    // Adminable, Versionable
    address private _admin;
    string private _version;
    string private _purpose;

    // Leave Token Policy
    LeaveTokenPolicy private leaveTokenPolicy;

    // Deactivate token
    mapping(address => bool) private tokensActivate;

    // ETH Strategy
    receive() external payable {}

    /*** modifiers ***/

    modifier isUsedToken(address _token) {
        require(tokensAdd[_token], "E1");
        _;
    }

    modifier onlyMultiLogicProxy() {
        require(msg.sender == logicContract, "E8");
        _;
    }

    modifier isBLIDToken(address _token) {
        require(BLID == _token, "E1");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "OA1");
        _;
    }

    modifier onlyOwnerAndAdmin() {
        require(msg.sender == owner() || msg.sender == _admin, "OA2");
        _;
    }

    /*** Adminable/Versionable function ***/

    /**
     * @notice Set admin
     * @param newAdmin Addres of new admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        _admin = newAdmin;
        emit SetAdmin(newAdmin);
    }

    function getVersion() external view returns (string memory) {
        return _version;
    }

    function getPurpose() external view returns (string memory) {
        return _purpose;
    }

    /**
     * @notice Set version and purpose
     * @param version Version string, ex : 1.2.0
     * @param purpose Purpose string
     */
    function upgradeVersion(string memory version, string memory purpose)
        external
        onlyOwner
    {
        require(bytes(version).length != 0, "OV1");

        _version = version;
        _purpose = purpose;

        emit UpgradeVersion(version, purpose);
    }

    /*** Owner functions ***/

    /**
     * @notice Set blid in contract
     * @param _blid address of BLID
     */
    function setBLID(address _blid) external onlyOwner {
        BLID = _blid;

        emit SetBLID(_blid);
    }

    /**
     * @notice Set blid in contract
     * @param _boostingAddress address of expense
     */
    function setBoostingAddress(address _boostingAddress) external onlyOwner {
        boostingAddress = _boostingAddress;

        emit SetBoostingAddress(boostingAddress);
    }

    /**
     * @notice Set boosting parameters
     * @param _maxBlidperUSD max value of BLID per USD
     * @param _blidperBlock blid per Block
     */
    function setBoostingInfo(uint256 _maxBlidperUSD, uint256 _blidperBlock)
        external
        onlyOwner
    {
        _boostingUpdateAccBlidPerShare();

        maxBlidPerUSD = _maxBlidperUSD;
        blidPerBlock = _blidperBlock;
        initBlidPerBlock = _blidperBlock;

        emit SetBoostInfo(_maxBlidperUSD, _blidperBlock);
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Update AccumulatedRewardsPerShare for token, using once after update contract
     * @param token Address of token
     */
    function updateAccumulatedRewardsPerShare(address token)
        external
        onlyOwner
    {
        require(accumulatedRewardsPerShare[token][0] == 0, "E7");
        uint256 countEarns_ = countEarns;
        for (uint256 i = 0; i < countEarns_; i++) {
            updateAccumulatedRewardsPerShareById(token, i);
        }
    }

    /**
     * @notice Add token and token's oracle
     * @param _token Address of Token
     * @param _oracles Address of token's oracle(https://docs.chain.link/docs/binance-smart-chain-addresses/
     */
    function addToken(address _token, address _oracles) external onlyOwner {
        require(_token != address(1) && _oracles != address(1));
        require(!tokensAdd[_token], "E6");
        oracles[_token] = _oracles;
        tokens[countTokens++] = _token;
        tokensAdd[_token] = true;
        tokensActivate[_token] = true;

        emit AddToken(_token, _oracles);
    }

    /**
     * @notice Set token activate / deactivate
     * @param _token Address of Token
     * @param status true : token is activate, false : token is deactivate
     */
    function setTokenActivate(address _token, bool status) external onlyOwner {
        tokensActivate[_token] = status;
    }

    /**
     * @notice Set MultiLogicProxy in contract(only for upgradebale contract,use only whith DAO)
     * @param _multiLogicProxy Address of MultiLogicProxy Contract
     */
    function setMultiLogicProxy(address _multiLogicProxy) external onlyOwner {
        logicContract = _multiLogicProxy;

        emit SetMultiLogicProxy(_multiLogicProxy);
    }

    /**
     * @notice Set LeaveTokenPolicy
     * @param limit Token limit for leavePercentage
     * @param leavePercentage Leave percentage before limit (0 - 9999)
     * @param leaveFixed Leave fixed after limit
     */
    function setLeaveTokenPolicy(
        uint256 limit,
        uint256 leavePercentage,
        uint256 leaveFixed
    ) external onlyOwner {
        require((limit * leavePercentage) / 10000 <= leaveFixed, "E15");

        leaveTokenPolicy.limit = limit;
        leaveTokenPolicy.leavePercentage = leavePercentage;
        leaveTokenPolicy.leaveFixed = leaveFixed;

        emit SetLeaveTokenPolicy(limit, leavePercentage, leaveFixed);
    }

    /*** User functions ***/

    /**
     * @notice Deposit amount of token for msg.sender
     * @param amount amount of token
     * @param token address of token
     */
    function deposit(uint256 amount, address token)
        external
        payable
        isUsedToken(token)
        whenNotPaused
    {
        depositInternal(amount, token, msg.sender);
    }

    /**
     * @notice Deposit amount of token on behalf of depositor wallet
     * @param amount amount of token
     * @param token address of token
     * @param accountAddress Address of depositor
     */
    function depositOnBehalf(
        uint256 amount,
        address token,
        address accountAddress
    ) external payable isUsedToken(token) whenNotPaused {
        depositInternal(amount, token, accountAddress);
    }

    /**
     * @notice Withdraw amount of token  from Strategy and receiving earned tokens.
     * @param amount Amount of token
     * @param token Address of token
     */
    function withdraw(uint256 amount, address token)
        external
        isUsedToken(token)
        whenNotPaused
    {
        uint8 decimals;

        if (token == address(0)) {
            decimals = 18;
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        uint256 countEarns_ = countEarns;
        uint256 amountExp18 = amount * 10**(18 - decimals);
        DepositStruct storage depositor = deposits[msg.sender];
        require(depositor.amount[token] >= amountExp18 && amount > 0, "E4");
        if (amountExp18 > tokenBalance[token]) {
            uint256 requireReturnAmount = amount -
                (tokenBalance[token] / (10**(18 - decimals)));
            IMultiLogicProxy(logicContract).releaseToken(
                requireReturnAmount,
                token
            );
            interestFee(msg.sender);

            if (token == address(0)) {
                require(address(this).balance >= amount, "E9");
                _send(payable(msg.sender), amount);
            } else {
                IERC20Upgradeable(token).safeTransferFrom(
                    logicContract,
                    address(this),
                    requireReturnAmount
                );
                IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
            }

            tokenDeposited[token] -= amountExp18;
            tokenTime[token] -= int256(block.timestamp * (amountExp18));
            tokenBalance[token] = 0;

            // Because balance = 0, set Available to be 0
            IMultiLogicProxy(logicContract).setLogicTokenAvailable(0, token, 2);
        } else {
            interestFee(msg.sender);
            if (token == address(0)) {
                _send(payable(msg.sender), amount);
            } else {
                IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
            }

            // Calculate requiredLeave and set available for strategy
            uint256 requiredLeaveOld = _calcRequiredTokenLeave(
                token,
                tokenDeposited[token]
            );
            uint256 requiredLeaveNow = _calcRequiredTokenLeave(
                token,
                tokenDeposited[token] - amountExp18
            );

            if (requiredLeaveNow > (tokenBalance[token] - amountExp18)) {
                // If withdraw can't reach to requiredLeave, make Avaliable to be zero
                IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                    0,
                    token,
                    2
                );
            } else {
                // if withdraw can reach to requiredLeave
                if (requiredLeaveOld <= requiredLeaveNow + amountExp18) {
                    // In normal case, amount will be decreased the gap between old/new requiredLeave
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        amount -
                            (requiredLeaveOld - requiredLeaveNow) /
                            10**(18 - decimals),
                        token,
                        0
                    );
                } else {
                    // If requiredLeave is decreased too much, available will be increased
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        (requiredLeaveOld - requiredLeaveNow) /
                            10**(18 - decimals) -
                            amount,
                        token,
                        1
                    );
                }
            }

            // Update balance, deposited
            tokenTime[token] -= int256(block.timestamp * (amountExp18));
            tokenBalance[token] -= amountExp18;
            tokenDeposited[token] -= amountExp18;
        }
        if (depositor.depositIterate[token] == countEarns_) {
            depositor.tokenTime[token] -= int256(
                block.timestamp * (amountExp18)
            );
        } else {
            depositor.tokenTime[token] =
                int256(
                    depositor.amount[token] *
                        earnBLID[countEarns_ - 1].timestamp
                ) -
                int256(block.timestamp * (amountExp18));
            depositor.depositIterate[token] = countEarns_;
        }
        depositor.amount[token] -= amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(msg.sender, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Withdraw(msg.sender, token, amountExp18);
    }

    /**
     * @notice Claim BLID to accountAddress
     * @param accountAddress account address for claim
     */
    function interestFee(address accountAddress) public {
        uint256 balanceUser = balanceEarnBLID(accountAddress);
        require(reserveBLID >= balanceUser, "E5");
        IERC20Upgradeable(BLID).safeTransfer(accountAddress, balanceUser);
        DepositStruct storage depositor = deposits[accountAddress];
        depositor.balanceBLID = balanceUser;
        depositor.iterate = countEarns;
        //unchecked is used because a check was made in require
        unchecked {
            depositor.balanceBLID = 0;
            reserveBLID -= balanceUser;
        }

        emit UpdateBLIDBalance(reserveBLID);
        emit InterestFee(accountAddress, balanceUser);
    }

    /*** Boosting User function ***/

    /**
     * @notice Deposit BLID token for boosting.
     * @param amount amount of token
     */
    function depositBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(usdDepositAmount > 0, "E11");

        BoostInfo storage userBoost = userBoosts[msg.sender];

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Adjust blidOverDeposit
        uint256 totalAmount = userBoost.blidDeposit + amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        uint256 depositAmount = amount;
        if (totalAmount > blidDepositLimit) {
            uint256 overAmount = totalAmount - blidDepositLimit;
            userBoost.blidOverDeposit += overAmount;
            depositAmount = amount - overAmount;
        }

        userBoost.blidDeposit += depositAmount;
        totalSupplyBLID += amount;

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit DepositBLID(msg.sender, amount);
    }

    /**
     * @notice WithDraw BLID token for boosting.
     * @param amount amount of token
     */
    function withdrawBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        BoostInfo storage userBoost = userBoosts[msg.sender];
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(
            amount <= userBoost.blidDeposit + userBoost.blidOverDeposit,
            "E12"
        );

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransfer(msg.sender, amount);

        // Adjust blidOverDeposit
        uint256 oldBlidDeposit = userBoost.blidDeposit;
        uint256 totalAmount = oldBlidDeposit +
            userBoost.blidOverDeposit -
            amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        if (totalAmount > blidDepositLimit) {
            userBoost.blidDeposit = blidDepositLimit;
            userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
        } else {
            userBoost.blidDeposit = totalAmount;
            userBoost.blidOverDeposit = 0;
        }

        totalSupplyBLID -= amount;

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit WithdrawBLID(msg.sender, amount);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     */
    function claimBoostingRewardBLID() external {
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice get deposited Boosting BLID amount of user
     * @param _user address of user
     */
    function getBoostingBLIDAmount(address _user)
        public
        view
        returns (uint256)
    {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 amount = userBoost.blidDeposit + userBoost.blidOverDeposit;
        return amount;
    }

    /*** MultiLogicProxy function ***/

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeToken(uint256 amount, address token)
        external
        onlyMultiLogicProxy
        isUsedToken(token)
    {
        uint8 decimals;

        if (token == address(0)) {
            decimals = 18;
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        uint256 amountExp18 = amount * 10**(18 - decimals);

        if (token == address(0)) {
            _send(payable(logicContract), amount);
        } else {
            IERC20Upgradeable(token).safeTransfer(logicContract, amount);
        }
        tokenBalance[token] = tokenBalance[token] - amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit TakeToken(token, amountExp18);
    }

    /**
     * @notice Transfer amount of token from Logic to Storage Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnToken(uint256 amount, address token)
        external
        onlyMultiLogicProxy
        isUsedToken(token)
    {
        uint8 decimals;

        if (token == address(0)) {
            require(address(this).balance >= amount, "E9");
            decimals = 18;
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        uint256 amountExp18 = amount * 10**(18 - decimals);

        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransferFrom(
                logicContract,
                address(this),
                amount
            );
        }

        tokenBalance[token] = tokenBalance[token] + amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit ReturnToken(token, amountExp18);
    }

    /**
     * @notice Claim all BLID(from strategy and boost) for user
     */
    function claimAllRewardBLID() external {
        interestFee(msg.sender);
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice Take amount BLID from Logic contract  and distributes earned BLID
     * @param amount Amount of distributes earned BLID
     */
    function addEarn(uint256 amount) external onlyMultiLogicProxy {
        IERC20Upgradeable(BLID).safeTransferFrom(
            logicContract,
            address(this),
            amount
        );
        reserveBLID += amount;
        int256 _dollarTime = 0;
        uint256 countTokens_ = countTokens;
        uint256 countEarns_ = countEarns;
        EarnBLID storage thisEarnBLID = earnBLID[countEarns_];
        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            AggregatorV3Interface oracle = AggregatorV3Interface(
                oracles[token]
            );
            thisEarnBLID.rates[token] = (uint256(oracle.latestAnswer()) *
                10**(18 - oracle.decimals()));

            // count all deposited token in usd
            thisEarnBLID.usd +=
                tokenDeposited[token] *
                thisEarnBLID.rates[token];

            // convert token time to dollar time
            _dollarTime += tokenTime[token] * int256(thisEarnBLID.rates[token]);
        }
        require(_dollarTime != 0);
        thisEarnBLID.allBLID = amount;
        thisEarnBLID.timestamp = block.timestamp;
        thisEarnBLID.tdt = uint256(
            (int256(((block.timestamp) * thisEarnBLID.usd)) - _dollarTime) /
                (1 ether)
        ); // count delta of current token time and all user token time

        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            tokenTime[token] = int256(tokenDeposited[token] * block.timestamp); // count curent token time
            updateAccumulatedRewardsPerShareById(token, countEarns_);
        }
        thisEarnBLID.usd /= (1 ether);
        countEarns++;

        emit AddEarn(amount);
        emit UpdateBLIDBalance(reserveBLID);
    }

    /*** External function ***/

    /**
     * @notice Counts the number of accrued СSR
     * @param account Address of Depositor
     */
    function _upBalance(address account) external {
        deposits[account].balanceBLID = balanceEarnBLID(account);
        deposits[account].iterate = countEarns;
    }

    /***  Public View function ***/

    /**
     * @notice Return earned blid
     * @param account Address of Depositor
     */
    function balanceEarnBLID(address account) public view returns (uint256) {
        DepositStruct storage depositor = deposits[account];
        if (depositor.tokenTime[address(1)] == 0 || countEarns == 0) {
            return 0;
        }
        if (countEarns == depositor.iterate) return depositor.balanceBLID;

        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        uint256 depositorIterate = depositor.iterate;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            //if iterate when user deposited
            if (depositorIterate == depositor.depositIterate[token]) {
                sum += getEarnedInOneDepositedIterate(
                    depositorIterate,
                    token,
                    account
                );
                sum += getEarnedInOneNotDepositedIterate(
                    depositorIterate,
                    token,
                    account
                );
            } else {
                sum += getEarnedInOneNotDepositedIterate(
                    depositorIterate - 1,
                    token,
                    account
                );
            }
        }

        return sum + depositor.balanceBLID;
    }

    /**
     * @notice Return usd balance of account
     * @param account Address of Depositor
     */
    function balanceOf(address account) public view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            sum += _calcUSDPrice(token, deposits[account].amount[token]);
        }
        return sum;
    }

    /**
     * @notice Return sums of all distribution BLID.
     */
    function getBLIDReserve() external view returns (uint256) {
        return reserveBLID;
    }

    /**
     * @notice Return deposited usd
     */
    function getTotalDeposit() external view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            sum += _calcUSDPrice(token, tokenDeposited[token]);
        }
        return sum;
    }

    /**
     * @notice Returns the balance of token on this contract
     */
    function getTokenBalance(address token) external view returns (uint256) {
        return tokenBalance[token];
    }

    /**
     * @notice Return deposited token from account
     */
    function getTokenDeposit(address account, address token)
        external
        view
        returns (uint256)
    {
        return deposits[account].amount[token];
    }

    /**
     * @notice Return true if _token  is in token list
     * @param _token Address of Token
     */
    function _isUsedToken(address _token) external view returns (bool) {
        return tokensAdd[_token];
    }

    /**
     * @notice Return true if _token  is in activated
     * @param _token Address of Token
     */
    function isActivatedToken(address _token) external view returns (bool) {
        return (tokensAdd[_token] && tokensActivate[_token]);
    }

    /**
     * @notice Return count distribution BLID token.
     */
    function getCountEarns() external view returns (uint256) {
        return countEarns;
    }

    /**
     * @notice Return data on distribution BLID token.
     * First return value is amount of distribution BLID token.
     * Second return value is a timestamp when  distribution BLID token completed.
     * Third return value is an amount of dollar depositedhen  distribution BLID token completed.
     */
    function getEarnsByID(uint256 id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (earnBLID[id].allBLID, earnBLID[id].timestamp, earnBLID[id].usd);
    }

    /**
     * @notice Return amount of all deposited token
     * @param token Address of Token
     */
    function getTokenDeposited(address token) external view returns (uint256) {
        return tokenDeposited[token];
    }

    /**
     * @notice Return all added tokens
     */
    function getUsedTokens() external view returns (address[] memory) {
        uint256 countTokens_ = countTokens;
        address[] memory ret = new address[](countTokens_);
        for (uint256 i = 0; i < countTokens_; i++) {
            ret[i] = tokens[i];
        }
        return ret;
    }

    /**
     * @notice Get LeaveTokenPolicy
     */
    function getLeaveTokenPolicy()
        external
        view
        returns (LeaveTokenPolicy memory)
    {
        return leaveTokenPolicy;
    }

    /**
     * @notice Return pending BLID amount for boost to see on frontend
     * @param _user address of user
     */

    function getBoostingClaimableBLID(address _user)
        external
        view
        returns (uint256)
    {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 _accBLIDpershare = accBlidPerShare;
        if (block.number > lastRewardBlock) {
            uint256 passedblockcount = block.number - lastRewardBlock + 1; // When claim 1 block is added because of mining
            _accBLIDpershare =
                accBlidPerShare +
                (passedblockcount * blidPerBlock);
        }
        uint256 calcAmount = (userBoost.blidDeposit * _accBLIDpershare) / 1e18;
        return
            calcAmount > userBoost.rewardDebt
                ? calcAmount - userBoost.rewardDebt
                : 0;
    }

    /*** Private Function ***/

    /**
     * @notice deposit token
     * @param amount Amount of deposit token
     * @param token Address of token
     * @param accountAddress Address of depositor
     */
    function depositInternal(
        uint256 amount,
        address token,
        address accountAddress
    ) internal {
        require(tokensActivate[token], "E14");
        require(amount > 0, "E3");
        uint8 decimals;

        if (token == address(0)) {
            require(msg.value >= amount, "E9");
            decimals = 18; // For BNB we fix decimals as 18 - chainlink shows 8
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        DepositStruct storage depositor = deposits[accountAddress];

        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
        }

        uint256 amountExp18 = amount * 10**(18 - decimals);
        if (depositor.tokenTime[address(1)] == 0) {
            depositor.iterate = countEarns;
            depositor.depositIterate[token] = countEarns;
            depositor.tokenTime[address(1)] = 1;
            depositor.tokenTime[token] += int256(
                block.timestamp * (amountExp18)
            );
        } else {
            interestFee(accountAddress);
            if (depositor.depositIterate[token] == countEarns) {
                depositor.tokenTime[token] += int256(
                    block.timestamp * (amountExp18)
                );
            } else {
                depositor.tokenTime[token] = int256(
                    depositor.amount[token] *
                        earnBLID[countEarns - 1].timestamp +
                        block.timestamp *
                        (amountExp18)
                );

                depositor.depositIterate[token] = countEarns;
            }
        }
        depositor.amount[token] += amountExp18;

        // Calculate requiredLeave and set available for strategy
        uint256 requiredLeaveOld = _calcRequiredTokenLeave(
            token,
            tokenDeposited[token]
        );

        uint256 requiredLeaveNow = _calcRequiredTokenLeave(
            token,
            tokenDeposited[token] + amountExp18
        );

        if (requiredLeaveNow > (tokenBalance[token] + amountExp18)) {
            // If deposit can't reach to requiredLeave, make Avaliable to be zero
            IMultiLogicProxy(logicContract).setLogicTokenAvailable(0, token, 2);
        } else {
            // if deposit can to reach requiredLeave
            if (tokenBalance[token] >= requiredLeaveOld) {
                // If the previous balance is more then requiredLeave, amount will be decreased the gap between old/new requiredLeave
                if (amountExp18 >= (requiredLeaveNow - requiredLeaveOld)) {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        amount -
                            (requiredLeaveNow - requiredLeaveOld) /
                            10**(18 - decimals),
                        token,
                        1
                    );
                } else {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        (requiredLeaveNow - requiredLeaveOld) /
                            10**(18 - decimals) -
                            amount,
                        token,
                        0
                    );
                }
            } else {
                // If the preivous balance is less than requiredLeave, amount will be decreased to reach to requiredLeaveNew
                if (amountExp18 >= (requiredLeaveNow - tokenBalance[token])) {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        amount -
                            (requiredLeaveNow - tokenBalance[token]) /
                            10**(18 - decimals),
                        token,
                        1
                    );
                } else {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        (requiredLeaveNow - tokenBalance[token]) /
                            10**(18 - decimals) -
                            amount,
                        token,
                        0
                    );
                }
            }
        }

        // Update balance, deposited
        tokenTime[token] += int256(block.timestamp * (amountExp18));
        tokenBalance[token] += amountExp18;
        tokenDeposited[token] += amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(accountAddress, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Deposit(accountAddress, token, amountExp18);
    }

    // Safe blid transfer function, just in case if rounding error causes pool to not have enough BLIDs.
    function safeBlidTransfer(address _to, uint256 _amount) internal {
        IERC20Upgradeable(BLID).safeTransferFrom(boostingAddress, _to, _amount);
    }

    /**
     * @notice Count accumulatedRewardsPerShare
     * @param token Address of Token
     * @param id of accumulatedRewardsPerShare
     */
    function updateAccumulatedRewardsPerShareById(address token, uint256 id)
        private
    {
        EarnBLID storage thisEarnBLID = earnBLID[id];
        //unchecked is used because if id = 0 then  accumulatedRewardsPerShare[token][id-1] equal zero
        unchecked {
            accumulatedRewardsPerShare[token][id] =
                accumulatedRewardsPerShare[token][id - 1] +
                ((thisEarnBLID.allBLID *
                    (thisEarnBLID.timestamp - earnBLID[id - 1].timestamp) *
                    thisEarnBLID.rates[token]) / thisEarnBLID.tdt);
        }
    }

    /**
     * @notice Count user rewards in one iterate, when he  deposited
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        EarnBLID storage thisEarnBLID = earnBLID[depositIterate];
        DepositStruct storage thisDepositor = deposits[account];
        return
            (// all distibution BLID multiply to
            thisEarnBLID.allBLID *
                // delta of  user dollar time and user dollar time if user deposited in at the beginning distibution
                uint256(
                    int256(
                        thisDepositor.amount[token] *
                            thisEarnBLID.rates[token] *
                            thisEarnBLID.timestamp
                    ) -
                        thisDepositor.tokenTime[token] *
                        int256(thisEarnBLID.rates[token])
                )) /
            //div to delta of all users dollar time and all users dollar time if all users deposited in at the beginning distibution
            thisEarnBLID.tdt /
            (1 ether);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     * @param userAccount address of account
     * @param isAdjust true : adjust userBoost.blidDeposit, false : not update userBoost.blidDeposit
     */
    function _claimBoostingRewardBLIDInternal(
        address userAccount,
        bool isAdjust
    ) private {
        _boostingUpdateAccBlidPerShare();
        BoostInfo storage userBoost = userBoosts[userAccount];
        uint256 calcAmount;
        if (userBoost.blidDeposit > 0) {
            calcAmount = (userBoost.blidDeposit * accBlidPerShare) / 1e18;
            if (calcAmount > userBoost.rewardDebt) {
                calcAmount -= userBoost.rewardDebt;
                safeBlidTransfer(userAccount, calcAmount);
            }
        }

        // Adjust blidDeposit
        if (isAdjust) {
            uint256 usdDepositAmount = balanceOf(userAccount);
            uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) /
                1e18;
            uint256 totalAmount = userBoost.blidDeposit +
                userBoost.blidOverDeposit;

            // Update boosting info
            if (totalAmount > blidDepositLimit) {
                userBoost.blidDeposit = blidDepositLimit;
                userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
            } else {
                userBoost.blidDeposit = totalAmount;
                userBoost.blidOverDeposit = 0;
            }

            // Update rewards debt
            userBoost.rewardDebt =
                (userBoost.blidDeposit * accBlidPerShare) /
                1e18;
        }

        emit ClaimBoostBLID(userAccount, calcAmount);
    }

    /**
     * @notice update Accumulated BLID per share
     */
    function _boostingUpdateAccBlidPerShare() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }

        uint256 passedblockcount = block.number - lastRewardBlock;
        accBlidPerShare = accBlidPerShare + (passedblockcount * blidPerBlock);
        lastRewardBlock = block.number;
    }

    /**
     * @notice Send ETH to address
     * @param _to target address to receive ETH
     * @param amount ETH amount (wei) to be sent
     */
    function _send(address payable _to, uint256 amount) private {
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "E10");
    }

    /*** Private View Function ***/

    /**
     * @notice Count user rewards in one iterate, when he was not deposit
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneNotDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        return
            ((accumulatedRewardsPerShare[token][countEarns - 1] -
                accumulatedRewardsPerShare[token][depositIterate]) *
                deposits[account].amount[token]) / (1 ether);
    }

    /**
     * @notice Calculate price in USD
     * returns USD in Exp18 format
     * @param token Address of Token with Exp18 expression
     * @param amountExp18 token amount with Exp18 expression
     */
    function _calcUSDPrice(address token, uint256 amountExp18)
        private
        view
        returns (uint256)
    {
        AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);

        return ((amountExp18 *
            uint256(oracle.latestAnswer()) *
            10**(18 - oracle.decimals())) / (1 ether));
    }

    /**
     * @notice Calculate required leave token base on totalDeposit amount
     * returns requiredTokenLeave balance in Exp18 expression
     * @param token Address of Token
     * @param depositTotalExp18 total token depositedwith Exp18 expression
     */
    function _calcRequiredTokenLeave(address token, uint256 depositTotalExp18)
        private
        view
        returns (uint256)
    {
        AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);

        uint256 limit = (leaveTokenPolicy.limit *
            10**(oracle.decimals()) *
            (1 ether)) / uint256(oracle.latestAnswer());

        // 0 - limit : return leavePerentage %
        if (depositTotalExp18 <= limit)
            return
                (depositTotalExp18 * leaveTokenPolicy.leavePercentage) / 10000;

        // > limit : return leaveFixed
        return
            (leaveTokenPolicy.leaveFixed *
                10**(oracle.decimals()) *
                (1 ether)) / uint256(oracle.latestAnswer());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IMultiLogicProxy {
    function releaseToken(uint256 amount, address token) external;

    function takeToken(uint256 amount, address token) external;

    function addEarn(uint256 amount, address blidToken) external;

    function returnToken(uint256 amount, address token) external;

    function setLogicTokenAvailable(
        uint256 amount,
        address token,
        uint256 deposit_withdraw
    ) external;

    function getTokenAvailable(address _token, address _logicAddress)
        external
        view
        returns (uint256);

    function getTokenTaken(address _token, address _logicAddress)
        external
        view
        returns (uint256);

    function getUsedTokensStorage() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Interfaces/IMultiLogicProxy.sol";
import "./Interfaces/AggregatorV3Interface.sol";

contract StorageV3 is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    //struct
    struct DepositStruct {
        mapping(address => uint256) amount;
        mapping(address => int256) tokenTime; // 1: flag, 0: BNB
        uint256 iterate;
        uint256 balanceBLID;
        mapping(address => uint256) depositIterate;
    }

    struct EarnBLID {
        uint256 allBLID;
        uint256 timestamp;
        uint256 usd;
        uint256 tdt;
        mapping(address => uint256) rates;
    }

    struct BoostInfo {
        uint256 blidDeposit;
        uint256 rewardDebt;
        uint256 blidOverDeposit;
    }

    struct LeaveTokenPolicy {
        uint256 limit;
        uint256 leavePercentage;
        uint256 leaveFixed;
    }

    /*** events ***/

    event Deposit(address depositor, address token, uint256 amount);
    event Withdraw(address depositor, address token, uint256 amount);
    event UpdateTokenBalance(uint256 balance, address token);
    event TakeToken(address token, uint256 amount);
    event ReturnToken(address token, uint256 amount);
    event AddEarn(uint256 amount);
    event UpdateBLIDBalance(uint256 balance);
    event InterestFee(address depositor, uint256 amount);
    event SetBLID(address blid);
    event AddToken(address token, address oracle);
    event SetMultiLogicProxy(address multiLogicProxy);
    event SetBoostInfo(uint256 maxBlidPerUSD, uint256 blidPerBlock);
    event DepositBLID(address depositor, uint256 amount);
    event WithdrawBLID(address depositor, uint256 amount);
    event ClaimBoostBLID(address depositor, uint256 amount);
    event SetBoostingAddress(address boostingAddress);
    event SetAdmin(address admin);
    event UpgradeVersion(string version, string purpose);
    event SetLeaveTokenPolicy(
        uint256 limit,
        uint256 leavePerentage,
        uint256 leaveFixed
    );

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
    }

    mapping(uint256 => EarnBLID) private earnBLID;
    uint256 private countEarns;
    uint256 private countTokens;
    mapping(uint256 => address) private tokens;
    mapping(address => uint256) private tokenBalance;
    mapping(address => address) private oracles;
    mapping(address => bool) private tokensAdd;
    mapping(address => DepositStruct) private deposits;
    mapping(address => uint256) private tokenDeposited;
    mapping(address => int256) private tokenTime;
    uint256 private reserveBLID;
    address public logicContract; // MultiLogicProxy : V3
    address private BLID;
    mapping(address => mapping(uint256 => uint256))
        public accumulatedRewardsPerShare;

    // ****** Add from V21 ******

    // Boost2.0
    mapping(address => BoostInfo) private userBoosts;
    uint256 public maxBlidPerUSD;
    uint256 public blidPerBlock;
    uint256 public initBlidPerBlock;
    uint256 public maxBlidPerBlock; // deprecated  - should be to remove in staging / production
    uint256 public accBlidPerShare;
    uint256 public lastRewardBlock;
    uint256 public totalSupplyBLID; // deprecated  - should be to remove in staging / production
    address public expenseAddress; // deprecated - should be to remove in staging / production
    address private accumulatedDepositor; // CrossChain : deprecated - should be to remove in staging / production
    address public boostingAddress;

    // ****** Add from V3 ******

    // Adminable, Versionable
    address private _admin;
    string private _version;
    string private _purpose;

    // Leave Token Policy
    LeaveTokenPolicy private leaveTokenPolicy;

    // Deactivate token
    mapping(address => bool) private tokensActivate;

    // ETH Strategy
    receive() external payable {}

    /*** modifiers ***/

    modifier isUsedToken(address _token) {
        require(tokensAdd[_token], "E1");
        _;
    }

    modifier onlyMultiLogicProxy() {
        require(msg.sender == logicContract, "E8");
        _;
    }

    modifier isBLIDToken(address _token) {
        require(BLID == _token, "E1");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "OA1");
        _;
    }

    modifier onlyOwnerAndAdmin() {
        require(msg.sender == owner() || msg.sender == _admin, "OA2");
        _;
    }

    /*** Adminable/Versionable function ***/

    /**
     * @notice Set admin
     * @param newAdmin Addres of new admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        _admin = newAdmin;
        emit SetAdmin(newAdmin);
    }

    function getVersion() external view returns (string memory) {
        return _version;
    }

    function getPurpose() external view returns (string memory) {
        return _purpose;
    }

    /**
     * @notice Set version and purpose
     * @param version Version string, ex : 1.2.0
     * @param purpose Purpose string
     */
    function upgradeVersion(string memory version, string memory purpose)
        external
        onlyOwner
    {
        require(bytes(version).length != 0, "OV1");

        _version = version;
        _purpose = purpose;

        emit UpgradeVersion(version, purpose);
    }

    /*** Owner functions ***/

    /**
     * @notice Set blid in contract
     * @param _blid address of BLID
     */
    function setBLID(address _blid) external onlyOwner {
        BLID = _blid;

        emit SetBLID(_blid);
    }

    /**
     * @notice Set blid in contract
     * @param _boostingAddress address of expense
     */
    function setBoostingAddress(address _boostingAddress) external onlyOwner {
        boostingAddress = _boostingAddress;

        emit SetBoostingAddress(boostingAddress);
    }

    /**
     * @notice Set boosting parameters
     * @param _maxBlidperUSD max value of BLID per USD
     * @param _blidperBlock blid per Block
     */
    function setBoostingInfo(uint256 _maxBlidperUSD, uint256 _blidperBlock)
        external
        onlyOwner
    {
        _boostingUpdateAccBlidPerShare();

        maxBlidPerUSD = _maxBlidperUSD;
        blidPerBlock = _blidperBlock;
        initBlidPerBlock = _blidperBlock;

        emit SetBoostInfo(_maxBlidperUSD, _blidperBlock);
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Update AccumulatedRewardsPerShare for token, using once after update contract
     * @param token Address of token
     */
    function updateAccumulatedRewardsPerShare(address token)
        external
        onlyOwner
    {
        require(accumulatedRewardsPerShare[token][0] == 0, "E7");
        uint256 countEarns_ = countEarns;
        for (uint256 i = 0; i < countEarns_; i++) {
            updateAccumulatedRewardsPerShareById(token, i);
        }
    }

    /**
     * @notice Add token and token's oracle
     * @param _token Address of Token
     * @param _oracles Address of token's oracle(https://docs.chain.link/docs/binance-smart-chain-addresses/
     */
    function addToken(address _token, address _oracles) external onlyOwner {
        require(_token != address(1) && _oracles != address(1));
        require(!tokensAdd[_token], "E6");
        oracles[_token] = _oracles;
        tokens[countTokens++] = _token;
        tokensAdd[_token] = true;
        tokensActivate[_token] = true;

        emit AddToken(_token, _oracles);
    }

    /**
     * @notice Set token activate / deactivate
     * @param _token Address of Token
     * @param status true : token is activate, false : token is deactivate
     */
    function setTokenActivate(address _token, bool status) external onlyOwner {
        tokensActivate[_token] = status;
    }

    /**
     * @notice Set MultiLogicProxy in contract(only for upgradebale contract,use only whith DAO)
     * @param _multiLogicProxy Address of MultiLogicProxy Contract
     */
    function setMultiLogicProxy(address _multiLogicProxy) external onlyOwner {
        logicContract = _multiLogicProxy;

        emit SetMultiLogicProxy(_multiLogicProxy);
    }

    /**
     * @notice Set LeaveTokenPolicy
     * @param limit Token limit for leavePercentage
     * @param leavePercentage Leave percentage before limit (0 - 9999)
     * @param leaveFixed Leave fixed after limit
     */
    function setLeaveTokenPolicy(
        uint256 limit,
        uint256 leavePercentage,
        uint256 leaveFixed
    ) external onlyOwner {
        require((limit * leavePercentage) / 10000 <= leaveFixed, "E15");

        leaveTokenPolicy.limit = limit;
        leaveTokenPolicy.leavePercentage = leavePercentage;
        leaveTokenPolicy.leaveFixed = leaveFixed;

        emit SetLeaveTokenPolicy(limit, leavePercentage, leaveFixed);
    }

    /*** User functions ***/

    /**
     * @notice Deposit amount of token for msg.sender
     * @param amount amount of token
     * @param token address of token
     */
    function deposit(uint256 amount, address token)
        external
        payable
        isUsedToken(token)
        whenNotPaused
    {
        depositInternal(amount, token, msg.sender);
    }

    /**
     * @notice Deposit amount of token on behalf of depositor wallet
     * @param amount amount of token
     * @param token address of token
     * @param accountAddress Address of depositor
     */
    function depositOnBehalf(
        uint256 amount,
        address token,
        address accountAddress
    ) external payable isUsedToken(token) whenNotPaused {
        depositInternal(amount, token, accountAddress);
    }

    /**
     * @notice Withdraw amount of token  from Strategy and receiving earned tokens.
     * @param amount Amount of token
     * @param token Address of token
     */
    function withdraw(uint256 amount, address token)
        external
        isUsedToken(token)
        whenNotPaused
    {
        uint8 decimals;

        if (token == address(0)) {
            decimals = 18;
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        uint256 countEarns_ = countEarns;
        uint256 amountExp18 = amount * 10**(18 - decimals);
        DepositStruct storage depositor = deposits[msg.sender];
        require(depositor.amount[token] >= amountExp18 && amount > 0, "E4");
        if (amountExp18 > tokenBalance[token]) {
            uint256 requireReturnAmount = amount -
                (tokenBalance[token] / (10**(18 - decimals)));
            IMultiLogicProxy(logicContract).releaseToken(
                requireReturnAmount,
                token
            );
            interestFee(msg.sender);

            if (token == address(0)) {
                require(address(this).balance >= amount, "E9");
                _send(payable(msg.sender), amount);
            } else {
                IERC20Upgradeable(token).safeTransferFrom(
                    logicContract,
                    address(this),
                    requireReturnAmount
                );
                IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
            }

            tokenDeposited[token] -= amountExp18;
            tokenTime[token] -= int256(block.timestamp * (amountExp18));
            tokenBalance[token] = 0;

            // Because balance = 0, set Available to be 0
            IMultiLogicProxy(logicContract).setLogicTokenAvailable(0, token, 2);
        } else {
            interestFee(msg.sender);
            if (token == address(0)) {
                _send(payable(msg.sender), amount);
            } else {
                IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
            }

            // Calculate requiredLeave and set available for strategy
            uint256 requiredLeaveOld = _calcRequiredTokenLeave(
                token,
                tokenDeposited[token]
            );
            uint256 requiredLeaveNow = _calcRequiredTokenLeave(
                token,
                tokenDeposited[token] - amountExp18
            );

            if (requiredLeaveNow > (tokenBalance[token] - amountExp18)) {
                // If withdraw can't reach to requiredLeave, make Avaliable to be zero
                IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                    0,
                    token,
                    2
                );
            } else {
                // if withdraw can reach to requiredLeave
                if (requiredLeaveOld <= requiredLeaveNow + amountExp18) {
                    // In normal case, amount will be decreased the gap between old/new requiredLeave
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        amount -
                            (requiredLeaveOld - requiredLeaveNow) /
                            10**(18 - decimals),
                        token,
                        0
                    );
                } else {
                    // If requiredLeave is decreased too much, available will be increased
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        (requiredLeaveOld - requiredLeaveNow) /
                            10**(18 - decimals) -
                            amount,
                        token,
                        1
                    );
                }
            }

            // Update balance, deposited
            tokenTime[token] -= int256(block.timestamp * (amountExp18));
            tokenBalance[token] -= amountExp18;
            tokenDeposited[token] -= amountExp18;
        }
        if (depositor.depositIterate[token] == countEarns_) {
            depositor.tokenTime[token] -= int256(
                block.timestamp * (amountExp18)
            );
        } else {
            depositor.tokenTime[token] =
                int256(
                    depositor.amount[token] *
                        earnBLID[countEarns_ - 1].timestamp
                ) -
                int256(block.timestamp * (amountExp18));
            depositor.depositIterate[token] = countEarns_;
        }
        depositor.amount[token] -= amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(msg.sender, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Withdraw(msg.sender, token, amountExp18);
    }

    /**
     * @notice Claim BLID to accountAddress
     * @param accountAddress account address for claim
     */
    function interestFee(address accountAddress) public {
        uint256 balanceUser = balanceEarnBLID(accountAddress);
        require(reserveBLID >= balanceUser, "E5");
        IERC20Upgradeable(BLID).safeTransfer(accountAddress, balanceUser);
        DepositStruct storage depositor = deposits[accountAddress];
        depositor.balanceBLID = balanceUser;
        depositor.iterate = countEarns;
        //unchecked is used because a check was made in require
        unchecked {
            depositor.balanceBLID = 0;
            reserveBLID -= balanceUser;
        }

        emit UpdateBLIDBalance(reserveBLID);
        emit InterestFee(accountAddress, balanceUser);
    }

    /*** Boosting User function ***/

    /**
     * @notice Deposit BLID token for boosting.
     * @param amount amount of token
     */
    function depositBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(usdDepositAmount > 0, "E11");

        BoostInfo storage userBoost = userBoosts[msg.sender];

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Adjust blidOverDeposit
        uint256 totalAmount = userBoost.blidDeposit + amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        uint256 depositAmount = amount;
        if (totalAmount > blidDepositLimit) {
            uint256 overAmount = totalAmount - blidDepositLimit;
            userBoost.blidOverDeposit += overAmount;
            depositAmount = amount - overAmount;
        }

        userBoost.blidDeposit += depositAmount;

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit DepositBLID(msg.sender, amount);
    }

    /**
     * @notice WithDraw BLID token for boosting.
     * @param amount amount of token
     */
    function withdrawBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        BoostInfo storage userBoost = userBoosts[msg.sender];
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(
            amount <= userBoost.blidDeposit + userBoost.blidOverDeposit,
            "E12"
        );

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransfer(msg.sender, amount);

        // Adjust blidOverDeposit
        uint256 oldBlidDeposit = userBoost.blidDeposit;
        uint256 totalAmount = oldBlidDeposit +
            userBoost.blidOverDeposit -
            amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        if (totalAmount > blidDepositLimit) {
            userBoost.blidDeposit = blidDepositLimit;
            userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
        } else {
            userBoost.blidDeposit = totalAmount;
            userBoost.blidOverDeposit = 0;
        }

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit WithdrawBLID(msg.sender, amount);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     */
    function claimBoostingRewardBLID() external {
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice get deposited Boosting BLID amount of user
     * @param _user address of user
     */
    function getBoostingBLIDAmount(address _user)
        public
        view
        returns (uint256)
    {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 amount = userBoost.blidDeposit + userBoost.blidOverDeposit;
        return amount;
    }

    /*** MultiLogicProxy function ***/

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeToken(uint256 amount, address token)
        external
        onlyMultiLogicProxy
        isUsedToken(token)
    {
        uint8 decimals;

        if (token == address(0)) {
            decimals = 18;
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        uint256 amountExp18 = amount * 10**(18 - decimals);

        if (token == address(0)) {
            _send(payable(logicContract), amount);
        } else {
            IERC20Upgradeable(token).safeTransfer(logicContract, amount);
        }
        tokenBalance[token] = tokenBalance[token] - amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit TakeToken(token, amountExp18);
    }

    /**
     * @notice Transfer amount of token from Logic to Storage Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnToken(uint256 amount, address token)
        external
        onlyMultiLogicProxy
        isUsedToken(token)
    {
        uint8 decimals;

        if (token == address(0)) {
            require(address(this).balance >= amount, "E9");
            decimals = 18;
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        uint256 amountExp18 = amount * 10**(18 - decimals);

        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransferFrom(
                logicContract,
                address(this),
                amount
            );
        }

        tokenBalance[token] = tokenBalance[token] + amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit ReturnToken(token, amountExp18);
    }

    /**
     * @notice Claim all BLID(from strategy and boost) for user
     */
    function claimAllRewardBLID() external {
        interestFee(msg.sender);
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice Take amount BLID from Logic contract  and distributes earned BLID
     * @param amount Amount of distributes earned BLID
     */
    function addEarn(uint256 amount) external onlyMultiLogicProxy {
        IERC20Upgradeable(BLID).safeTransferFrom(
            logicContract,
            address(this),
            amount
        );
        reserveBLID += amount;
        int256 _dollarTime = 0;
        uint256 countTokens_ = countTokens;
        uint256 countEarns_ = countEarns;
        EarnBLID storage thisEarnBLID = earnBLID[countEarns_];
        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            AggregatorV3Interface oracle = AggregatorV3Interface(
                oracles[token]
            );
            thisEarnBLID.rates[token] = (uint256(oracle.latestAnswer()) *
                10**(18 - oracle.decimals()));

            // count all deposited token in usd
            thisEarnBLID.usd +=
                tokenDeposited[token] *
                thisEarnBLID.rates[token];

            // convert token time to dollar time
            _dollarTime += tokenTime[token] * int256(thisEarnBLID.rates[token]);
        }
        require(_dollarTime != 0);
        thisEarnBLID.allBLID = amount;
        thisEarnBLID.timestamp = block.timestamp;
        thisEarnBLID.tdt = uint256(
            (int256(((block.timestamp) * thisEarnBLID.usd)) - _dollarTime) /
                (1 ether)
        ); // count delta of current token time and all user token time

        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            tokenTime[token] = int256(tokenDeposited[token] * block.timestamp); // count curent token time
            updateAccumulatedRewardsPerShareById(token, countEarns_);
        }
        thisEarnBLID.usd /= (1 ether);
        countEarns++;

        emit AddEarn(amount);
        emit UpdateBLIDBalance(reserveBLID);
    }

    /*** External function ***/

    /**
     * @notice Counts the number of accrued СSR
     * @param account Address of Depositor
     */
    function _upBalance(address account) external {
        deposits[account].balanceBLID = balanceEarnBLID(account);
        deposits[account].iterate = countEarns;
    }

    /***  Public View function ***/

    /**
     * @notice Return earned blid
     * @param account Address of Depositor
     */
    function balanceEarnBLID(address account) public view returns (uint256) {
        DepositStruct storage depositor = deposits[account];
        if (depositor.tokenTime[address(1)] == 0 || countEarns == 0) {
            return 0;
        }
        if (countEarns == depositor.iterate) return depositor.balanceBLID;

        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        uint256 depositorIterate = depositor.iterate;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            //if iterate when user deposited
            if (depositorIterate == depositor.depositIterate[token]) {
                sum += getEarnedInOneDepositedIterate(
                    depositorIterate,
                    token,
                    account
                );
                sum += getEarnedInOneNotDepositedIterate(
                    depositorIterate,
                    token,
                    account
                );
            } else {
                sum += getEarnedInOneNotDepositedIterate(
                    depositorIterate - 1,
                    token,
                    account
                );
            }
        }

        return sum + depositor.balanceBLID;
    }

    /**
     * @notice Return usd balance of account
     * @param account Address of Depositor
     */
    function balanceOf(address account) public view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            sum += _calcUSDPrice(token, deposits[account].amount[token]);
        }
        return sum;
    }

    /**
     * @notice Return sums of all distribution BLID.
     */
    function getBLIDReserve() external view returns (uint256) {
        return reserveBLID;
    }

    /**
     * @notice Return deposited usd
     */
    function getTotalDeposit() external view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            sum += _calcUSDPrice(token, tokenDeposited[token]);
        }
        return sum;
    }

    /**
     * @notice Returns the balance of token on this contract
     */
    function getTokenBalance(address token) external view returns (uint256) {
        return tokenBalance[token];
    }

    /**
     * @notice Return deposited token from account
     */
    function getTokenDeposit(address account, address token)
        external
        view
        returns (uint256)
    {
        return deposits[account].amount[token];
    }

    /**
     * @notice Return true if _token  is in token list
     * @param _token Address of Token
     */
    function _isUsedToken(address _token) external view returns (bool) {
        return tokensAdd[_token];
    }

    /**
     * @notice Return true if _token  is in activated
     * @param _token Address of Token
     */
    function isActivatedToken(address _token) external view returns (bool) {
        return (tokensAdd[_token] && tokensActivate[_token]);
    }

    /**
     * @notice Return count distribution BLID token.
     */
    function getCountEarns() external view returns (uint256) {
        return countEarns;
    }

    /**
     * @notice Return data on distribution BLID token.
     * First return value is amount of distribution BLID token.
     * Second return value is a timestamp when  distribution BLID token completed.
     * Third return value is an amount of dollar depositedhen  distribution BLID token completed.
     */
    function getEarnsByID(uint256 id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (earnBLID[id].allBLID, earnBLID[id].timestamp, earnBLID[id].usd);
    }

    /**
     * @notice Return amount of all deposited token
     * @param token Address of Token
     */
    function getTokenDeposited(address token) external view returns (uint256) {
        return tokenDeposited[token];
    }

    /**
     * @notice Return all added tokens
     */
    function getUsedTokens() external view returns (address[] memory) {
        uint256 countTokens_ = countTokens;
        address[] memory ret = new address[](countTokens_);
        for (uint256 i = 0; i < countTokens_; i++) {
            ret[i] = tokens[i];
        }
        return ret;
    }

    /**
     * @notice Get LeaveTokenPolicy
     */
    function getLeaveTokenPolicy()
        external
        view
        returns (LeaveTokenPolicy memory)
    {
        return leaveTokenPolicy;
    }

    /**
     * @notice Return pending BLID amount for boost to see on frontend
     * @param _user address of user
     */

    function getBoostingClaimableBLID(address _user)
        external
        view
        returns (uint256)
    {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 _accBLIDpershare = accBlidPerShare;
        if (block.number > lastRewardBlock) {
            uint256 passedblockcount = block.number - lastRewardBlock + 1; // When claim 1 block is added because of mining
            _accBLIDpershare =
                accBlidPerShare +
                (passedblockcount * blidPerBlock);
        }
        uint256 calcAmount = (userBoost.blidDeposit * _accBLIDpershare) / 1e18;
        return
            calcAmount > userBoost.rewardDebt
                ? calcAmount - userBoost.rewardDebt
                : 0;
    }

    /*** Private Function ***/

    /**
     * @notice deposit token
     * @param amount Amount of deposit token
     * @param token Address of token
     * @param accountAddress Address of depositor
     */
    function depositInternal(
        uint256 amount,
        address token,
        address accountAddress
    ) internal {
        require(tokensActivate[token], "E14");
        require(amount > 0, "E3");
        uint8 decimals;

        if (token == address(0)) {
            require(msg.value >= amount, "E9");
            decimals = 18; // For BNB we fix decimals as 18 - chainlink shows 8
        } else {
            decimals = AggregatorV3Interface(token).decimals();
        }

        DepositStruct storage depositor = deposits[accountAddress];

        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
        }

        uint256 amountExp18 = amount * 10**(18 - decimals);
        if (depositor.tokenTime[address(1)] == 0) {
            depositor.iterate = countEarns;
            depositor.depositIterate[token] = countEarns;
            depositor.tokenTime[address(1)] = 1;
            depositor.tokenTime[token] += int256(
                block.timestamp * (amountExp18)
            );
        } else {
            interestFee(accountAddress);
            if (depositor.depositIterate[token] == countEarns) {
                depositor.tokenTime[token] += int256(
                    block.timestamp * (amountExp18)
                );
            } else {
                depositor.tokenTime[token] = int256(
                    depositor.amount[token] *
                        earnBLID[countEarns - 1].timestamp +
                        block.timestamp *
                        (amountExp18)
                );

                depositor.depositIterate[token] = countEarns;
            }
        }
        depositor.amount[token] += amountExp18;

        // Calculate requiredLeave and set available for strategy
        uint256 requiredLeaveOld = _calcRequiredTokenLeave(
            token,
            tokenDeposited[token]
        );

        uint256 requiredLeaveNow = _calcRequiredTokenLeave(
            token,
            tokenDeposited[token] + amountExp18
        );

        if (requiredLeaveNow > (tokenBalance[token] + amountExp18)) {
            // If deposit can't reach to requiredLeave, make Avaliable to be zero
            IMultiLogicProxy(logicContract).setLogicTokenAvailable(0, token, 2);
        } else {
            // if deposit can to reach requiredLeave
            if (tokenBalance[token] >= requiredLeaveOld) {
                // If the previous balance is more then requiredLeave, amount will be decreased the gap between old/new requiredLeave
                if (amountExp18 >= (requiredLeaveNow - requiredLeaveOld)) {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        amount -
                            (requiredLeaveNow - requiredLeaveOld) /
                            10**(18 - decimals),
                        token,
                        1
                    );
                } else {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        (requiredLeaveNow - requiredLeaveOld) /
                            10**(18 - decimals) -
                            amount,
                        token,
                        0
                    );
                }
            } else {
                // If the preivous balance is less than requiredLeave, amount will be decreased to reach to requiredLeaveNew
                if (amountExp18 >= (requiredLeaveNow - tokenBalance[token])) {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        amount -
                            (requiredLeaveNow - tokenBalance[token]) /
                            10**(18 - decimals),
                        token,
                        1
                    );
                } else {
                    IMultiLogicProxy(logicContract).setLogicTokenAvailable(
                        (requiredLeaveNow - tokenBalance[token]) /
                            10**(18 - decimals) -
                            amount,
                        token,
                        0
                    );
                }
            }
        }

        // Update balance, deposited
        tokenTime[token] += int256(block.timestamp * (amountExp18));
        tokenBalance[token] += amountExp18;
        tokenDeposited[token] += amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(accountAddress, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Deposit(accountAddress, token, amountExp18);
    }

    // Safe blid transfer function, just in case if rounding error causes pool to not have enough BLIDs.
    function safeBlidTransfer(address _to, uint256 _amount) internal {
        IERC20Upgradeable(BLID).safeTransferFrom(boostingAddress, _to, _amount);
    }

    /**
     * @notice Count accumulatedRewardsPerShare
     * @param token Address of Token
     * @param id of accumulatedRewardsPerShare
     */
    function updateAccumulatedRewardsPerShareById(address token, uint256 id)
        private
    {
        EarnBLID storage thisEarnBLID = earnBLID[id];
        //unchecked is used because if id = 0 then  accumulatedRewardsPerShare[token][id-1] equal zero
        unchecked {
            accumulatedRewardsPerShare[token][id] =
                accumulatedRewardsPerShare[token][id - 1] +
                ((thisEarnBLID.allBLID *
                    (thisEarnBLID.timestamp - earnBLID[id - 1].timestamp) *
                    thisEarnBLID.rates[token]) / thisEarnBLID.tdt);
        }
    }

    /**
     * @notice Count user rewards in one iterate, when he  deposited
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        EarnBLID storage thisEarnBLID = earnBLID[depositIterate];
        DepositStruct storage thisDepositor = deposits[account];
        return
            (// all distibution BLID multiply to
            thisEarnBLID.allBLID *
                // delta of  user dollar time and user dollar time if user deposited in at the beginning distibution
                uint256(
                    int256(
                        thisDepositor.amount[token] *
                            thisEarnBLID.rates[token] *
                            thisEarnBLID.timestamp
                    ) -
                        thisDepositor.tokenTime[token] *
                        int256(thisEarnBLID.rates[token])
                )) /
            //div to delta of all users dollar time and all users dollar time if all users deposited in at the beginning distibution
            thisEarnBLID.tdt /
            (1 ether);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     * @param userAccount address of account
     * @param isAdjust true : adjust userBoost.blidDeposit, false : not update userBoost.blidDeposit
     */
    function _claimBoostingRewardBLIDInternal(
        address userAccount,
        bool isAdjust
    ) private {
        _boostingUpdateAccBlidPerShare();
        BoostInfo storage userBoost = userBoosts[userAccount];
        uint256 calcAmount;
        if (userBoost.blidDeposit > 0) {
            calcAmount = (userBoost.blidDeposit * accBlidPerShare) / 1e18;
            if (calcAmount > userBoost.rewardDebt) {
                calcAmount -= userBoost.rewardDebt;
                safeBlidTransfer(userAccount, calcAmount);
            }
        }

        // Adjust blidDeposit
        if (isAdjust) {
            uint256 usdDepositAmount = balanceOf(userAccount);
            uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) /
                1e18;
            uint256 totalAmount = userBoost.blidDeposit +
                userBoost.blidOverDeposit;

            // Update boosting info
            if (totalAmount > blidDepositLimit) {
                userBoost.blidDeposit = blidDepositLimit;
                userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
            } else {
                userBoost.blidDeposit = totalAmount;
                userBoost.blidOverDeposit = 0;
            }

            // Update rewards debt
            userBoost.rewardDebt =
                (userBoost.blidDeposit * accBlidPerShare) /
                1e18;
        }

        emit ClaimBoostBLID(userAccount, calcAmount);
    }

    /**
     * @notice update Accumulated BLID per share
     */
    function _boostingUpdateAccBlidPerShare() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }

        uint256 passedblockcount = block.number - lastRewardBlock;
        accBlidPerShare = accBlidPerShare + (passedblockcount * blidPerBlock);
        lastRewardBlock = block.number;
    }

    /**
     * @notice Send ETH to address
     * @param _to target address to receive ETH
     * @param amount ETH amount (wei) to be sent
     */
    function _send(address payable _to, uint256 amount) private {
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "E10");
    }

    /*** Private View Function ***/

    /**
     * @notice Count user rewards in one iterate, when he was not deposit
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneNotDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        return
            ((accumulatedRewardsPerShare[token][countEarns - 1] -
                accumulatedRewardsPerShare[token][depositIterate]) *
                deposits[account].amount[token]) / (1 ether);
    }

    /**
     * @notice Calculate price in USD
     * returns USD in Exp18 format
     * @param token Address of Token with Exp18 expression
     * @param amountExp18 token amount with Exp18 expression
     */
    function _calcUSDPrice(address token, uint256 amountExp18)
        private
        view
        returns (uint256)
    {
        AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);

        return ((amountExp18 *
            uint256(oracle.latestAnswer()) *
            10**(18 - oracle.decimals())) / (1 ether));
    }

    /**
     * @notice Calculate required leave token base on totalDeposit amount
     * returns requiredTokenLeave balance in Exp18 expression
     * @param token Address of Token
     * @param depositTotalExp18 total token depositedwith Exp18 expression
     */
    function _calcRequiredTokenLeave(address token, uint256 depositTotalExp18)
        private
        view
        returns (uint256)
    {
        AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);

        uint256 limit = (leaveTokenPolicy.limit *
            10**(oracle.decimals()) *
            (1 ether)) / uint256(oracle.latestAnswer());

        // 0 - limit : return leavePerentage %
        if (depositTotalExp18 <= limit)
            return
                (depositTotalExp18 * leaveTokenPolicy.leavePercentage) / 10000;

        // > limit : return leaveFixed
        return
            (leaveTokenPolicy.leaveFixed *
                10**(oracle.decimals()) *
                (1 ether)) / uint256(oracle.latestAnswer());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../utils/LogicUpgradeable.sol";

interface IStorage {
    function takeToken(uint256 amount, address token) external;

    function returnToken(uint256 amount, address token) external;

    function addEarn(uint256 amount) external;
}

interface IDistribution {
    function enterMarkets(address[] calldata vTokens)
        external
        returns (uint256[] memory);

    function markets(address vTokenAddress)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );

    function claimVenus(address holder) external;

    function claimVenus(address holder, address[] memory vTokens) external;
}

interface IMasterChef {
    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function userInfo(uint256 _pid, address account)
        external
        view
        returns (uint256, uint256);
}

interface IVToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function mint() external payable;

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function repayBorrow() external payable;
}

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IPancakeRouter01 {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

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
}

contract LogicV2 is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct ReserveLiquidity {
        address tokenA;
        address tokenB;
        address vTokenA;
        address vTokenB;
        address swap;
        address swapMaster;
        address lpToken;
        uint256 poolID;
        address[][] path;
    }

    address private _storage;
    address private blid;
    address private admin;
    address private venusController;
    address private pancake;
    address private apeswap;
    address private biswap;
    address private pancakeMaster;
    address private apeswapMaster;
    address private biswapMaster;
    address private expenseAddress;
    address private vBNB;
    mapping(address => bool) private usedVTokens;
    mapping(address => address) private VTokens;

    ReserveLiquidity[] reserves;

    event SetBLID(address _blid);
    event SetStorage(address _storage);

    function __Logic_init(
        address _expenseAddress,
        address _venusController,
        address _pancakeRouter,
        address _apeswapRouter,
        address _biswapRouter,
        address _pancakeMaster,
        address _apeswapMaster,
        address _biswapMaster
    ) public initializer {
        LogicUpgradeable.initialize();
        expenseAddress = _expenseAddress;
        venusController = _venusController;

        apeswap = _apeswapRouter;
        pancake = _pancakeRouter;
        biswap = _biswapRouter;
        pancakeMaster = _pancakeMaster;
        apeswapMaster = _apeswapMaster;
        biswapMaster = _biswapMaster;
    }

    fallback() external payable {}

    receive() external payable {}

    modifier onlyStorage() {
        require(msg.sender == _storage, "E1");
        _;
    }

    modifier isUsedVToken(address vToken) {
        require(usedVTokens[vToken], "E2");
        _;
    }

    modifier isUsedSwap(address swap) {
        require(swap == apeswap || swap == pancake || swap == biswap, "E3");
        _;
    }

    modifier isUsedMaster(address swap) {
        require(
            swap == pancakeMaster ||
                apeswapMaster == swap ||
                biswapMaster == swap,
            "E4"
        );
        _;
    }

    /**
     * @notice Add VToken in Contract and approve token  for storage, venus,
     * pancakeswap/apeswap router, and pancakeswap/apeswap master(Main Staking contract)
     * @param token Address of Token for deposited
     * @param vToken Address of VToken
     */
    function addVTokens(address token, address vToken) external onlyOwner {
        bool _isUsedVToken;
        (_isUsedVToken, , ) = IDistribution(venusController).markets(vToken);
        require(_isUsedVToken, "E5");
        if ((token) != address(0)) {
            IERC20Upgradeable(token).approve(vToken, type(uint256).max);
            IERC20Upgradeable(token).approve(apeswap, type(uint256).max);
            IERC20Upgradeable(token).approve(pancake, type(uint256).max);
            IERC20Upgradeable(token).approve(biswap, type(uint256).max);
            IERC20Upgradeable(token).approve(_storage, type(uint256).max);
            IERC20Upgradeable(token).approve(pancakeMaster, type(uint256).max);
            IERC20Upgradeable(token).approve(apeswapMaster, type(uint256).max);
            IERC20Upgradeable(token).approve(biswapMaster, type(uint256).max);
            VTokens[token] = vToken;
        } else {
            vBNB = vToken;
        }
        usedVTokens[vToken] = true;
    }

    /**
     * @notice Set blid in contract and approve blid for storage, venus, pancakeswap/apeswap
     * router, and pancakeswap/apeswap master(Main Staking contract), you can call the
     * function once
     * @param blid_ Adrees of BLID
     */
    function setBLID(address blid_) external onlyOwner {
        require(blid == address(0), "E6");
        blid = blid_;
        IERC20Upgradeable(blid).safeApprove(apeswap, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(pancake, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(biswap, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(pancakeMaster, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(apeswapMaster, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(biswapMaster, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(_storage, type(uint256).max);
        emit SetBLID(blid_);
    }

    /**
     * @notice Set storage, you can call the function once
     * @param storage_ Addres of Storage Contract
     */
    function setStorage(address storage_) external onlyOwner {
        require(_storage == address(0), "E7");
        _storage = storage_;
        emit SetStorage(storage_);
    }

    /**
     * @notice Approve token for storage, venus, pancakeswap/apeswap router,
     * and pancakeswap/apeswap master(Main Staking contract)
     * @param token  Address of Token that is approved
     */
    function approveTokenForSwap(address token) external onlyOwner {
        (IERC20Upgradeable(token).approve(apeswap, type(uint256).max));
        (IERC20Upgradeable(token).approve(pancake, type(uint256).max));
        (IERC20Upgradeable(token).approve(biswap, type(uint256).max));
        (IERC20Upgradeable(token).approve(pancakeMaster, type(uint256).max));
        (IERC20Upgradeable(token).approve(apeswapMaster, type(uint256).max));
        (IERC20Upgradeable(token).approve(biswapMaster, type(uint256).max));
    }

    /**
     * @notice Frees up tokens for the user, but Storage doesn't transfer token for the user,
     * only Storage can this function, after calling this function Storage transfer
     * from Logic to user token.
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnToken(uint256 amount, address token)
        external
        payable
        onlyStorage
    {
        uint256 takeFromVenus = 0;
        uint256 length = reserves.length;
        //check logic balance
        if (IERC20Upgradeable(token).balanceOf(address(this)) >= amount) {
            return;
        }
        //loop by reserves lp token
        for (uint256 i = 0; i < length; i++) {
            address[] memory path = findPath(i, token); // get path for router
            ReserveLiquidity memory reserve = reserves[i];
            uint256 lpAmount = getPriceFromTokenToLp(
                reserve.lpToken,
                amount - takeFromVenus,
                token,
                reserve.swap,
                path
            ); //get amount of lp token that need for reedem liqudity

            //get how many deposited to farming
            (uint256 depositedLp, ) = IMasterChef(reserve.swapMaster).userInfo(
                reserve.poolID,
                address(this)
            );
            if (depositedLp == 0) continue;
            // if deposited LP tokens don't enough  for repay borrow and for reedem token then only repay
            // borow and continue loop, else repay borow, reedem token and break loop
            if (lpAmount >= depositedLp) {
                takeFromVenus += getPriceFromLpToToken(
                    reserve.lpToken,
                    depositedLp,
                    token,
                    reserve.swap,
                    path
                );
                withdrawAndRepay(reserve, depositedLp);
            } else {
                withdrawAndRepay(reserve, lpAmount);

                // get supplied token and break loop
                IVToken(VTokens[token]).redeemUnderlying(amount);
                return;
            }
        }
        //try get supplied token
        IVToken(VTokens[token]).redeemUnderlying(amount);
        //if get money
        if (IERC20Upgradeable(token).balanceOf(address(this)) >= amount) {
            return;
        }
        revert("no money");
    }

    /**
     * @notice Transfer amount of token from Storage to Logic contract token - address of the token
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeTokenFromStorage(uint256 amount, address token)
        external
        onlyOwnerAndAdmin
    {
        IStorage(_storage).takeToken(amount, token);
    }

    /**
     * @notice Transfer amount of token from Logic to Storage contract token - address of token
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnTokenToStorage(uint256 amount, address token)
        external
        onlyOwnerAndAdmin
    {
        IStorage(_storage).returnToken(amount, token);
    }

    /**
     * @notice Distribution amount of blid to depositors.
     * @param amount Amount of BLID
     */
    function addEarnToStorage(uint256 amount) external onlyOwnerAndAdmin {
        IERC20Upgradeable(blid).safeTransfer(
            expenseAddress,
            (amount * 3) / 100
        );
        IStorage(_storage).addEarn((amount * 97) / 100);
    }

    /**
     * @notice Enter into a list of markets(address of VTokens) - it is not an
     * error to enter the same market more than once.
     * @param vTokens The addresses of the vToken markets to enter.
     * @return For each market, returns an error code indicating whether or not it was entered.
     * Each is 0 on success, otherwise an Error code
     */
    function enterMarkets(address[] calldata vTokens)
        external
        onlyOwnerAndAdmin
        returns (uint256[] memory)
    {
        return IDistribution(venusController).enterMarkets(vTokens);
    }

    /**
     * @notice Every Venus user accrues XVS for each block
     * they are supplying to or borrowing from the protocol.
     * @param vTokens The addresses of the vToken markets to enter.
     */
    function claimVenus(address[] calldata vTokens) external onlyOwnerAndAdmin {
        IDistribution(venusController).claimVenus(address(this), vTokens);
    }

    /**
     * @notice Stake token and mint VToken
     * @param vToken: that mint Vtokens to this contract
     * @param mintAmount: The amount of the asset to be supplied, in units of the underlying asset.
     * @return 0 on success, otherwise an Error code
     */
    function mint(address vToken, uint256 mintAmount)
        external
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        if (vToken == vBNB) {
            IVToken(vToken).mint{value: mintAmount}();
        }
        return IVToken(vToken).mint(mintAmount);
    }

    /**
     * @notice The borrow function transfers an asset from the protocol to the user and creates a
     * borrow balance which begins accumulating interest based on the Borrow Rate for the asset.
     * The amount borrowed must be less than the user's Account Liquidity and the market's
     * available liquidity.
     * @param vToken: that mint Vtokens to this contract
     * @param borrowAmount: The amount of underlying to be borrow.
     * @return 0 on success, otherwise an Error code
     */
    function borrow(address vToken, uint256 borrowAmount)
        external
        payable
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        return IVToken(vToken).borrow(borrowAmount);
    }

    /**
     * @notice The repay function transfers an asset into the protocol, reducing the user's borrow balance.
     * @param vToken: that mint Vtokens to this contract
     * @param repayAmount: The amount of the underlying borrowed asset to be repaid.
     * A value of -1 (i.e. 2256 - 1) can be used to repay the full amount.
     * @return 0 on success, otherwise an Error code
     */
    function repayBorrow(address vToken, uint256 repayAmount)
        external
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        if (vToken == vBNB) {
            IVToken(vToken).repayBorrow{value: repayAmount}();
            return 0;
        }
        return IVToken(vToken).repayBorrow(repayAmount);
    }

    /**
     * @notice The redeem underlying function converts vTokens into a specified quantity of the
     * underlying asset, and returns them to the user.
     * The amount of vTokens redeemed is equal to the quantity of underlying tokens received,
     * divided by the current Exchange Rate.
     * The amount redeemed must be less than the user's Account Liquidity and the market's
     * available liquidity.
     * @param vToken: that mint Vtokens to this contract
     * @param redeemAmount: The amount of underlying to be redeemed.
     * @return 0 on success, otherwise an Error code
     */
    function redeemUnderlying(address vToken, uint256 redeemAmount)
        external
        isUsedVToken(vToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        return IVToken(vToken).redeemUnderlying(redeemAmount);
    }

    /**
     * @notice Adds liquidity to a BEP20⇄BEP20 pool.
     * @param swap Address of swap router
     * @param tokenA The contract address of one token from your liquidity pair.
     * @param tokenB The contract address of the other token from your liquidity pair.
     * @param amountADesired The amount of tokenA you'd like to provide as liquidity.
     * @param amountBDesired The amount of tokenA you'd like to provide as liquidity.
     * @param amountAMin The minimum amount of tokenA to provide (slippage impact).
     * @param amountBMin The minimum amount of tokenB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function addLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (amountADesired, amountBDesired, amountAMin) = IPancakeRouter01(swap)
            .addLiquidity(
                tokenA,
                tokenB,
                amountADesired,
                amountBDesired,
                amountAMin,
                amountBMin,
                address(this),
                deadline
            );

        return (amountADesired, amountBDesired, amountAMin);
    }

    /**
     * @notice Removes liquidity from a BEP20⇄BEP20 pool.
     * @param swap Address of swap router
     * @param tokenA The contract address of one token from your liquidity pair.
     * @param tokenB The contract address of the other token from your liquidity pair.
     * @param liquidity The amount of LP Tokens to remove.
     * @param amountAMin he minimum amount of tokenA to provide (slippage impact).
     * @param amountBMin The minimum amount of tokenB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function removeLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        onlyOwnerAndAdmin
        isUsedSwap(swap)
        returns (uint256 amountA, uint256 amountB)
    {
        (amountAMin, amountBMin) = IPancakeRouter01(swap).removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            address(this),
            deadline
        );

        return (amountAMin, amountBMin);
    }

    /**
     * @notice Receive an as many output tokens as possible for an exact amount of input tokens.
     * @param swap Address of swap router
     * @param amountIn TPayable amount of input tokens.
     * @param amountOutMin The minimum amount tokens to receive.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactTokensForTokens(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as few input tokens as possible.
     * @param swap Address of swap router
     * @param amountOut Payable amount of input tokens.
     * @param amountInMax The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapTokensForExactTokens(
        address swap,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        uint256 deadline
    )
        external
        onlyOwnerAndAdmin
        isUsedSwap(swap)
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Adds liquidity to a BEP20⇄WBNB pool.
     * @param swap Address of swap router
     * @param token The contract address of one token from your liquidity pair.
     * @param amountTokenDesired The amount of the token you'd like to provide as liquidity.
     * @param amountETHDesired The minimum amount of the token to provide (slippage impact).
     * @param amountTokenMin The minimum amount of token to provide (slippage impact).
     * @param amountETHMin The minimum amount of BNB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function addLiquidityETH(
        address swap,
        address token,
        uint256 amountTokenDesired,
        uint256 amountETHDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (amountETHDesired, amountTokenMin, amountETHMin) = IPancakeRouter01(
            swap
        ).addLiquidityETH{value: amountETHDesired}(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        return (amountETHDesired, amountTokenMin, amountETHMin);
    }

    /**
     * @notice Removes liquidity from a BEP20⇄WBNB pool.
     * @param swap Address of swap router
     * @param token The contract address of one token from your liquidity pair.
     * @param liquidity The amount of LP Tokens to remove.
     * @param amountTokenMin The minimum amount of the token to remove (slippage impact).
     * @param amountETHMin The minimum amount of BNB to remove (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function removeLiquidityETH(
        address swap,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        payable
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256 amountToken, uint256 amountETH)
    {
        (deadline, amountETHMin) = IPancakeRouter01(swap).removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        return (deadline, amountETHMin);
    }

    /**
     * @notice Receive as many output tokens as possible for an exact amount of BNB.
     * @param swap Address of swap router
     * @param amountETH Payable BNB amount.
     * @param amountOutMin 	The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactETHForTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapExactETHForTokens{value: amountETH}(
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as few input tokens as possible.
     * @param swap Address of swap router
     * @param amountOut Payable BNB amount.
     * @param amountInMax The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapTokensForExactETH(
        address swap,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        uint256 deadline
    )
        external
        payable
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapTokensForExactETH(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive as much BNB as possible for an exact amount of input tokens.
     * @param swap Address of swap router
     * @param amountIn Payable amount of input tokens.
     * @param amountOutMin The maximum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactTokensForETH(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    )
        external
        payable
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapExactTokensForETH(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as little BNB as possible.
     * @param swap Address of swap router
     * @param amountOut The amount tokens to receive.
     * @param amountETH Payable BNB amount.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapETHForExactTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOut,
        address[] calldata path,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapETHForExactTokens{value: amountETH}(
                amountOut,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Deposit LP tokens to Master
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _pid pool id
     * @param _amount amount of lp token
     */
    function deposit(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external isUsedMaster(swapMaster) onlyOwnerAndAdmin {
        IMasterChef(swapMaster).deposit(_pid, _amount);
    }

    /**
     * @notice Withdraw LP tokens from Master
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _pid pool id
     * @param _amount amount of lp token
     */
    function withdraw(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external isUsedMaster(swapMaster) onlyOwnerAndAdmin {
        IMasterChef(swapMaster).withdraw(_pid, _amount);
    }

    /**
     * @notice Stake BANANA/Cake tokens to STAKING.
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _amount amount of lp token
     */
    function enterStaking(address swapMaster, uint256 _amount)
        external
        isUsedMaster(swapMaster)
        onlyOwnerAndAdmin
    {
        IMasterChef(swapMaster).enterStaking(_amount);
    }

    /**
     * @notice Withdraw BANANA/Cake tokens from STAKING.
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _amount amount of lp token
     */
    function leaveStaking(address swapMaster, uint256 _amount)
        external
        isUsedMaster(swapMaster)
        onlyOwnerAndAdmin
    {
        IMasterChef(swapMaster).leaveStaking(_amount);
    }

    /**
     * @notice Add reserve staked lp token to end list
     * @param reserveLiquidity Data is about staked lp in farm
     */
    function addReserveLiquidity(ReserveLiquidity memory reserveLiquidity)
        external
        onlyOwnerAndAdmin
    {
        reserves.push(reserveLiquidity);
    }

    /**
     * @notice Delete last ReserveLiquidity from list of ReserveLiquidity
     */
    function deleteLastReserveLiquidity() external onlyOwnerAndAdmin {
        reserves.pop();
    }

    /**
     * @notice Return count reserves staked lp tokens for return users their tokens.
     */
    function getReservesCount() external view returns (uint256) {
        return reserves.length;
    }

    /**
     * @notice Return reserves staked lp tokens for return user their tokens. return ReserveLiquidity
     */
    function getReserve(uint256 id)
        external
        view
        returns (ReserveLiquidity memory)
    {
        return reserves[id];
    }

    /*** Prive Function ***/

    /**
     * @notice Repay borrow when in farms  erc20 and BNB
     */
    function repayBorrowBNBandToken(
        address swap,
        address tokenB,
        address VTokenA,
        address VTokenB,
        uint256 lpAmount
    ) private {
        (uint256 amountToken, uint256 amountETH) = IPancakeRouter01(swap)
            .removeLiquidityETH(
                tokenB,
                lpAmount,
                0,
                0,
                address(this),
                block.timestamp + 1 days
            );
        {
            uint256 totalBorrow = IVToken(VTokenA).borrowBalanceCurrent(
                address(this)
            );
            if (totalBorrow >= amountETH) {
                IVToken(VTokenA).repayBorrow{value: amountETH}();
            } else {
                IVToken(VTokenA).repayBorrow{value: totalBorrow}();
            }

            totalBorrow = IVToken(VTokenB).borrowBalanceCurrent(address(this));
            if (totalBorrow >= amountToken) {
                IVToken(VTokenB).repayBorrow(amountToken);
            } else {
                IVToken(VTokenB).repayBorrow(totalBorrow);
            }
        }
    }

    /**
     * @notice Repay borrow when in farms only erc20
     */
    function repayBorrowOnlyTokens(
        address swap,
        address tokenA,
        address tokenB,
        address VTokenA,
        address VTokenB,
        uint256 lpAmount
    ) private {
        (uint256 amountA, uint256 amountB) = IPancakeRouter01(swap)
            .removeLiquidity(
                tokenA,
                tokenB,
                lpAmount,
                0,
                0,
                address(this),
                block.timestamp + 1 days
            );
        {
            uint256 totalBorrow = IVToken(VTokenA).borrowBalanceCurrent(
                address(this)
            );
            if (totalBorrow >= amountA) {
                IVToken(VTokenA).repayBorrow(amountA);
            } else {
                IVToken(VTokenA).repayBorrow(totalBorrow);
            }

            totalBorrow = IVToken(VTokenB).borrowBalanceCurrent(address(this));
            if (totalBorrow >= amountB) {
                IVToken(VTokenB).repayBorrow(amountB);
            } else {
                IVToken(VTokenB).repayBorrow(totalBorrow);
            }
        }
    }

    /**
     * @notice Withdraw lp token from farms and repay borrow
     */
    function withdrawAndRepay(ReserveLiquidity memory reserve, uint256 lpAmount)
        private
    {
        IMasterChef(reserve.swapMaster).withdraw(reserve.poolID, lpAmount);
        if (reserve.tokenA == address(0) || reserve.tokenB == address(0)) {
            //if tokenA is BNB
            if (reserve.tokenA == address(0)) {
                repayBorrowBNBandToken(
                    reserve.swap,
                    reserve.tokenB,
                    reserve.vTokenA,
                    reserve.vTokenB,
                    lpAmount
                );
            }
            //if tokenB is BNB
            else {
                repayBorrowBNBandToken(
                    reserve.swap,
                    reserve.tokenA,
                    reserve.vTokenB,
                    reserve.vTokenA,
                    lpAmount
                );
            }
        }
        //if token A and B is not BNB
        else {
            repayBorrowOnlyTokens(
                reserve.swap,
                reserve.tokenA,
                reserve.tokenB,
                reserve.vTokenA,
                reserve.vTokenB,
                lpAmount
            );
        }
    }

    /*** Prive View Function ***/
    /**
     * @notice Convert Lp Token To Token
     */
    function getPriceFromLpToToken(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) private view returns (uint256) {
        //make price returned not affected by slippage rate
        uint256 totalSupply = IERC20Upgradeable(lpToken).totalSupply();
        address token0 = IPancakePair(lpToken).token0();
        uint256 totalTokenAmount = IERC20Upgradeable(token0).balanceOf(
            lpToken
        ) * (2);
        uint256 amountIn = (value * totalTokenAmount) / (totalSupply);

        if (amountIn == 0 || token0 == token) {
            return amountIn;
        }

        uint256[] memory price = IPancakeRouter01(swap).getAmountsOut(
            amountIn,
            path
        );
        return price[price.length - 1];
    }

    /**
     * @notice Convert Token To Lp Token
     */
    function getPriceFromTokenToLp(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) private view returns (uint256) {
        //make price returned not affected by slippage rate
        uint256 totalSupply = IERC20Upgradeable(lpToken).totalSupply();
        address token0 = IPancakePair(lpToken).token0();
        uint256 totalTokenAmount = IERC20Upgradeable(token0).balanceOf(lpToken);

        if (token0 == token) {
            return (value * (totalSupply)) / (totalTokenAmount) / 2;
        }

        uint256[] memory price = IPancakeRouter01(swap).getAmountsOut(
            (1 gwei),
            path
        );
        return
            (value * (totalSupply)) /
            ((price[price.length - 1] * 2 * totalTokenAmount) / (1 gwei));
    }

    /**
     * @notice FindPath for swap router
     */
    function findPath(uint256 id, address token)
        private
        view
        returns (address[] memory path)
    {
        ReserveLiquidity memory reserve = reserves[id];
        uint256 length = reserve.path.length;

        for (uint256 i = 0; i < length; i++) {
            if (reserve.path[i][reserve.path[i].length - 1] == token) {
                return reserve.path[i];
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./../utils/LogicUpgradeable.sol";
import "./../Interfaces/ILogicContract.sol";
import "./../Interfaces/IXToken.sol";
import "./../Interfaces/ICompoundOla.sol";
import "./../Interfaces/IMultiLogicProxy.sol";

contract LendBorrowLendStrategy is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address private blid;
    address private comptroller;
    address private rewardsSwapRouter;
    address private rewardsToken;
    address private logic;
    address[] private pathToSwapRewardsToBLID;
    address private multiLogicProxy;

    uint8 public circlesCount; /* deprecated */
    bool private rewardsInit;
    uint8 private avoidLiquidationFactor; /* deprecated */

    mapping(address => address) private oTokens;
    mapping(address => uint8) public circlesCountTokens;
    mapping(address => uint8) public avoidLiquidationFactorTokens;

    event SetBLID(address _blid);
    event SetMultiLogicProxy(address multiLogicProxy);
    event SetCirclesCount(uint8 _circlesCount, address _token);
    event BuildCircle(address token, uint256 _circlesCount);
    event DestroyCircle(
        address token,
        uint256 amountMultiLogicBalance,
        uint256 balanceToken
    );
    event RebuildCircle(address token, uint256 _circlesCount);
    event ClaimRewards(address token, uint256 amount);
    event Init(address token);
    event ReleaseToken(address token, uint256 amount);

    function __LendBorrowLendStrategy_init(
        address _comptroller,
        address _rewardsSwapRouter,
        address _rewardsToken,
        address _logic
    ) public initializer {
        LogicUpgradeable.initialize();
        comptroller = _comptroller;
        rewardsSwapRouter = _rewardsSwapRouter;
        rewardsToken = _rewardsToken;
        logic = _logic;
        rewardsInit = false;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier onlyMultiLogicProxy() {
        require(msg.sender == multiLogicProxy, "L1");
        _;
    }

    modifier isUsedToken(address token) {
        require(oTokens[token] != address(0), "L2");
        _;
    }

    /*** Public Initialize Function ***/

    /**
     * @notice Set blid in contract
     * @param blid_ Address of BLID
     */
    function setBLID(address blid_) external onlyOwner {
        require(blid == address(0), "L3");
        blid = blid_;
        emit SetBLID(blid_);
    }

    /**
     * @notice Set MultiLogicProxy, you can call the function once
     * @param _multiLogicProxy Address of Multilogic Contract
     */
    function setMultiLogicProxy(address _multiLogicProxy) external onlyOwner {
        require(multiLogicProxy == address(0), "L5");
        multiLogicProxy = _multiLogicProxy;

        emit SetMultiLogicProxy(_multiLogicProxy);
    }

    /**
     * @notice Set circlesCount
     * @param _circlesCount Count number
     * @param _token token address
     */
    function setCirclesCount(uint8 _circlesCount, address _token)
        external
        onlyOwner
    {
        circlesCountTokens[_token] = _circlesCount;

        emit SetCirclesCount(_circlesCount, _token);
    }

    /**
     * @notice Set pathToSwapRewardsToBLID
     * @param path path to rewards to BLID
     */
    function setPathToSwapRewardsToBLID(address[] calldata path)
        external
        onlyOwner
    {
        uint256 length = path.length;
        require(length >= 2, "L6");
        require(path[0] == rewardsToken, "L7");
        require(path[length - 1] == blid, "L8");

        pathToSwapRewardsToBLID = new address[](length);
        for (uint256 i = 0; i < length; ) {
            pathToSwapRewardsToBLID[i] = path[i];

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Set avoidLiquidationFactor
     * @param _factor factor value
     * @param _token token address
     */
    function setAvoidLiquidationFactor(uint8 _factor, address _token)
        external
        onlyOwner
    {
        avoidLiquidationFactorTokens[_token] = _factor;
    }

    /*** Public Strategy Function ***/

    /**
     * @notice Add XToken in Contract and approve token
     * Approve token for storage, venus, pancakeswap/apeswap/biswap router,
     * and pancakeswap/apeswap/biswap master(Main Staking contract)
     * Approve rewardsToken for swap
     */
    function init(address token, address oToken) public onlyOwner {
        require(oTokens[token] == address(0), "L10");

        address _logic = logic;
        oTokens[token] = oToken;

        // Add token/oToken to Logic
        ILogicContract(_logic).addXTokens(token, oToken, 1);

        // Entermarkets with token/otoken
        address[] memory tokens = new address[](1);
        tokens[0] = oToken;
        ILogicContract(_logic).enterMarkets(tokens, 1);

        // Approve rewards token
        if (!rewardsInit) {
            ILogicContract(_logic).approveTokenForSwap(rewardsToken);

            rewardsInit = true;
        }

        emit Init(token);
    }

    /**
     * @notice Build circle strategy
     * take token from storage and create circle
     * @param amount amount of token
     * @param token token address
     */
    function build(uint256 amount, address token)
        external
        onlyOwnerAndAdmin
        isUsedToken(token)
    {
        address _logic = logic;

        // Take token from storage
        ILogicContract(_logic).takeTokenFromStorage(amount, token);

        // create circle with total balance of token
        amount = IERC20Upgradeable(token).balanceOf(_logic);
        createCircles(token, amount, circlesCountTokens[token]);

        emit BuildCircle(token, amount);
    }

    /**
     * @notice Destroy circle strategy
     * destroy circle and return all tokens to storage
     * @param token token address
     */
    function destroy(address token)
        external
        onlyOwnerAndAdmin
        isUsedToken(token)
    {
        address _logic = logic;

        // Destruct circle
        destructCircles(token, circlesCountTokens[token]);

        // Return all tokens to storage
        uint256 balanceToken = IERC20Upgradeable(token).balanceOf(_logic);
        uint256 amountStrategy = IMultiLogicProxy(multiLogicProxy)
            .getTokenTaken(token, _logic);

        if (amountStrategy < balanceToken)
            ILogicContract(_logic).returnTokenToStorage(amountStrategy, token);
        else ILogicContract(_logic).returnTokenToStorage(balanceToken, token);

        emit DestroyCircle(token, amountStrategy, balanceToken);
    }

    /**
     * @notice Rebuild circle strategy
     * destroy/build circle
     * @param token token address
     * @param _circlesCount Count number
     */
    function rebuild(address token, uint8 _circlesCount)
        external
        onlyOwnerAndAdmin
        isUsedToken(token)
    {
        // destruct circle with previous circlesCount
        destructCircles(token, circlesCountTokens[token]);

        // Set circlesCount
        circlesCountTokens[token] = _circlesCount;

        // create circle with total balance of token
        uint256 amount = IERC20Upgradeable(token).balanceOf(logic);
        createCircles(token, amount, _circlesCount);

        emit RebuildCircle(token, _circlesCount);
    }

    /**
     * @notice claim distribution rewards USDT both borrow and lend swap banana token to BLID
     * @param token token address
     * @param minimumBLIDPerRewardToken min BLID amount per rewardsToken (wei)
     */
    function claimRewards(address token, uint256 minimumBLIDPerRewardToken)
        external
        onlyOwnerAndAdmin
        isUsedToken(token)
    {
        require(pathToSwapRewardsToBLID.length >= 2, "L9");

        address _logic = logic;

        // Claim Rewards token
        address[] memory tokens = new address[](1);
        tokens[0] = oTokens[token];
        ILogicContract(_logic).claim(tokens, 1);

        // Convert Rewards to BLID
        uint256 amountIn = IERC20Upgradeable(rewardsToken).balanceOf(_logic);
        uint256 amountOutMin = (amountIn * minimumBLIDPerRewardToken) /
            (10**18);
        uint256 deadline = block.timestamp + 100;
        ILogicContract(_logic).swapExactTokensForTokens(
            rewardsSwapRouter,
            amountIn,
            amountOutMin,
            pathToSwapRewardsToBLID,
            deadline
        );

        // Add BLID earn to storage
        uint256 amountBLID = IERC20Upgradeable(blid).balanceOf(_logic);
        ILogicContract(_logic).addEarnToStorage(amountBLID);

        emit ClaimRewards(token, amountBLID);
    }

    /**
     * @notice Frees up tokens for the user, but Storage doesn't transfer token for the user,
     * only Storage can this function, after calling this function Storage transfer
     * from Logic to user token.
     * @param amount Amount of token
     * @param token Address of token
     */
    function releaseToken(uint256 amount, address token)
        external
        payable
        onlyMultiLogicProxy
        isUsedToken(token)
    {
        address _logic = logic;

        // destruct circle with previous circlesCount
        destructCircles(token, circlesCountTokens[token]);

        uint256 balance;

        if (token == address(0)) {
            balance = address(_logic).balance;
        } else {
            balance = IERC20Upgradeable(token).balanceOf(_logic);
        }

        if (balance < amount) {
            revert("no money");
        } else if (token == address(0)) {
            ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
        }

        // create circle with remaind balance of token
        createCircles(token, balance - amount, circlesCountTokens[token]);

        emit ReleaseToken(token, amount);
    }

    /**
     * @notice multicall to Logic
     */
    function multicall(bytes[] memory callDatas)
        public
        onlyOwnerAndAdmin
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        uint256 length = callDatas.length;
        returnData = new bytes[](length);
        for (uint256 i = 0; i < length; ) {
            (bool success, bytes memory ret) = address(logic).call(
                callDatas[i]
            );
            require(success, "F99");
            returnData[i] = ret;

            unchecked {
                ++i;
            }
        }
    }

    /*** Prive Function ***/

    /**
     * @notice creates circle (borrow-lend) of the base token
     * @param token token address
     * @param _iterateCount the number circles to
     */
    function createCircles(
        address token,
        uint256 _amount,
        uint8 _iterateCount
    ) private {
        uint256 collateralFactor; // the maximum proportion of borrow/lend
        address cToken = oTokens[token];
        address _logic = logic;
        uint8 iterateCount = _iterateCount;
        uint256 amount = _amount;

        require(amount > 0, "L12");

        // Get information from comptroller
        (, collateralFactor, , , , ) = IComptrollerOla(comptroller).markets(
            cToken
        );

        // Apply avoidLiquidationFactor to collateralFactor
        collateralFactor =
            ((collateralFactor * 100) / (10**18)) -
            avoidLiquidationFactorTokens[token];
        require(collateralFactor > 0, "L11");

        for (uint256 i = 0; i < iterateCount; ) {
            ILogicContract(_logic).mint(cToken, amount);

            uint256 borrowAmount = (amount * collateralFactor) / 100;
            ILogicContract(_logic).borrow(cToken, borrowAmount, 1);

            amount = borrowAmount;

            unchecked {
                ++i;
            }
        }

        // lend the last borrowed amount
        ILogicContract(_logic).mint(cToken, amount);
    }

    /**
     * @notice unblock all the money
     * @param token token address
     * @param _iterateCount the number circles to : maximum iterates to do, the real number might be less then iterateCount
     */
    function destructCircles(address token, uint8 _iterateCount) private {
        uint256 collateralFactor;
        address cToken = oTokens[token];
        uint8 iterateCount = _iterateCount + 3; // additional iteration to repay all borrowed
        address _logic = logic;

        // Get information from comptroller
        (, collateralFactor, , , , ) = IComptrollerOla(comptroller).markets(
            cToken
        );

        // Apply avoidLiquidationFactor to collateralFactor
        collateralFactor =
            ((collateralFactor * 100) / (10**18)) -
            avoidLiquidationFactorTokens[token];
        require(collateralFactor > 0, "L11");

        for (uint256 i = 0; i < iterateCount; ) {
            uint256 cTokenBalance; // balance of cToken
            uint256 borrowBalance; // balance of borrowed amount
            uint256 exchangeRateMantissa; //conversion rate from cToken to token

            // get infromation of account
            (, cTokenBalance, borrowBalance, exchangeRateMantissa) = IXToken(
                cToken
            ).getAccountSnapshot(_logic);

            // calculates of supplied balance, divided by 10^18 to safe digits correctly
            uint256 supplyBalance = (cTokenBalance * exchangeRateMantissa) /
                10**18;

            // calculates how much percents could be borroewed and not to be liquidated, then multiply fo supply balance to calculate the amount
            uint256 withdrawBalance = ((collateralFactor -
                ((100 * borrowBalance) / supplyBalance)) * supplyBalance) / 100;

            // if nothing to repay
            if (borrowBalance == 0) {
                if (cTokenBalance > 0) {
                    // redeem and exit
                    ILogicContract(_logic).redeemUnderlying(
                        cToken,
                        supplyBalance
                    );
                    return;
                }
            }
            // if already redeemed
            if (supplyBalance == 0) {
                return;
            }

            // if redeem tokens
            ILogicContract(_logic).redeemUnderlying(cToken, withdrawBalance);
            uint256 repayAmount = IERC20Upgradeable(token).balanceOf(_logic);

            // if there is something to repay
            if (repayAmount > 0) {
                // if borrow balance more then we have on account
                if (borrowBalance > repayAmount) {
                    ILogicContract(_logic).repayBorrow(cToken, repayAmount);
                } else {
                    ILogicContract(_logic).repayBorrow(cToken, borrowBalance);
                }
            }

            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IXToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function underlying() external view returns (address);

    function name() external view returns (string memory);
}

interface IXTokenETH {
    function mint() external payable;

    function borrow(uint256 borrowAmount) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow() external payable;

    function borrowBalanceCurrent(address account) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IComptrollerOla {
    function enterMarkets(address[] calldata xTokens)
        external
        returns (uint256[] memory);

    function markets(address cTokenAddress)
        external
        view
        returns (
            bool,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getAllMarkets() external view returns (address[] memory);

    function getUnderlyingPriceInLen(address underlying)
        external
        view
        returns (uint256);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}

interface IDistributionOla {
    function claimComp(address holder, address[] calldata cTokens) external;

    function compAccrued(address holder) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./utils/LogicUpgradeable.sol";
import "./Interfaces/IXToken.sol";
import "./Interfaces/ISwap.sol";
import "./Interfaces/ICompoundOla.sol";
import "./Interfaces/ICompoundVenus.sol";
import "./Interfaces/IMultiLogicProxy.sol";

contract Logic is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public multiLogicProxy;
    address private blid;
    address private venusComptroller;
    address private olaComptroller;
    address private olaRainMaker;
    address private pancake;
    address private apeswap;
    address private biswap;
    address private pancakeMaster;
    address private apeswapMaster;
    address private biswapMaster;
    address private expenseAddress;
    address private vBNB;
    address private oBNB;
    mapping(address => bool) private usedXTokens;
    mapping(address => address) private XTokens;

    uint8 private constant vTokenType = 0;
    uint8 private constant oTokenType = 1;

    event SetBLID(address _blid);
    event SetExpenseAddress(address expenseAddress);
    event SetMultiLogicProxy(address multiLogicProxy);

    function __Logic_init(
        address _expenseAddress,
        address _venusComptroller,
        address _olaComptroller,
        address _olaRainMaker,
        address _pancakeRouter,
        address _apeswapRouter,
        address _biswapRouter,
        address _pancakeMaster,
        address _apeswapMaster,
        address _biswapMaster
    ) public initializer {
        LogicUpgradeable.initialize();
        expenseAddress = _expenseAddress;

        venusComptroller = _venusComptroller;
        olaComptroller = _olaComptroller;
        olaRainMaker = _olaRainMaker;

        apeswap = _apeswapRouter;
        pancake = _pancakeRouter;
        biswap = _biswapRouter;
        pancakeMaster = _pancakeMaster;
        apeswapMaster = _apeswapMaster;
        biswapMaster = _biswapMaster;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier onlyMultiLogicProxy() {
        require(msg.sender == multiLogicProxy, "E14");
        _;
    }

    modifier isUsedXToken(address xToken) {
        require(usedXTokens[xToken], "E2");
        _;
    }

    modifier isUsedSwap(address swap) {
        require(swap == apeswap || swap == pancake || swap == biswap, "E3");
        _;
    }

    modifier isUsedMaster(address swap) {
        require(
            swap == pancakeMaster ||
                apeswapMaster == swap ||
                biswapMaster == swap,
            "E4"
        );
        _;
    }

    modifier isTokenTypeAccepted(uint8 leadingTokenType) {
        require(
            leadingTokenType == vTokenType || leadingTokenType == oTokenType,
            "E8"
        );
        _;
    }

    /*** User function ***/

    /**
     * @notice Set expenseAddress
     * @param _expenseAddress Address of Expense Account
     */
    function setExpenseAddress(address _expenseAddress) external onlyOwner {
        expenseAddress = _expenseAddress;
        emit SetExpenseAddress(_expenseAddress);
    }

    /**
     * @notice Add XToken in Contract and approve token  for storage, venus,
     * pancakeswap/apeswap router, and pancakeswap/apeswap master(Main Staking contract)
     * @param token Address of Token for deposited
     * @param xToken Address of XToken
     * @param leadingTokenType Type of XToken
     */
    function addXTokens(
        address token,
        address xToken,
        uint8 leadingTokenType
    ) external onlyOwnerAndAdmin isTokenTypeAccepted(leadingTokenType) {
        bool _isUsedXToken;

        if (leadingTokenType == vTokenType) {
            (_isUsedXToken, , ) = IComptrollerVenus(venusComptroller).markets(
                xToken
            );
        }

        if (leadingTokenType == oTokenType) {
            (_isUsedXToken, , , , , ) = IComptrollerOla(olaComptroller).markets(
                xToken
            );
        }

        require(_isUsedXToken, "E5");

        if ((token) != address(0)) {
            IERC20Upgradeable(token).approve(xToken, type(uint256).max);
            IERC20Upgradeable(token).approve(
                multiLogicProxy,
                type(uint256).max
            );
            approveTokenForSwap(token);

            XTokens[token] = xToken;
        } else {
            if (leadingTokenType == vTokenType) vBNB = xToken;
            if (leadingTokenType == oTokenType) oBNB = xToken;
        }

        usedXTokens[xToken] = true;
    }

    /**
     * @notice Set blid in contract and approve blid for storage, venus, pancakeswap/apeswap/biswap
     * router, and pancakeswap/apeswap/biswap master(Main Staking contract), you can call the
     * function once
     * @param blid_ Address of BLID
     */
    function setBLID(address blid_) external onlyOwner {
        require(blid == address(0), "E6");
        blid = blid_;
        IERC20Upgradeable(blid).safeApprove(apeswap, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(pancake, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(biswap, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(pancakeMaster, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(apeswapMaster, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(biswapMaster, type(uint256).max);
        IERC20Upgradeable(blid).safeApprove(multiLogicProxy, type(uint256).max);
        emit SetBLID(blid_);
    }

    /**
     * @notice Set MultiLogicProxy, you can call the function once
     * @param _multiLogicProxy Address of Storage Contract
     */
    function setMultiLogicProxy(address _multiLogicProxy) external onlyOwner {
        require(multiLogicProxy == address(0), "E15");
        multiLogicProxy = _multiLogicProxy;

        emit SetMultiLogicProxy(_multiLogicProxy);
    }

    /**
     * @notice Approve token for storage, venus, pancakeswap/apeswap/biswap router,
     * and pancakeswap/apeswap/biswap master(Main Staking contract)
     * @param token  Address of Token that is approved
     */
    function approveTokenForSwap(address token) public onlyOwnerAndAdmin {
        (IERC20Upgradeable(token).approve(apeswap, type(uint256).max));
        (IERC20Upgradeable(token).approve(pancake, type(uint256).max));
        (IERC20Upgradeable(token).approve(biswap, type(uint256).max));
        (IERC20Upgradeable(token).approve(pancakeMaster, type(uint256).max));
        (IERC20Upgradeable(token).approve(apeswapMaster, type(uint256).max));
        (IERC20Upgradeable(token).approve(biswapMaster, type(uint256).max));
    }

    /**
     * @notice Transfer amount of token from Storage to Logic contract token - address of the token
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeTokenFromStorage(uint256 amount, address token)
        external
        onlyOwnerAndAdmin
    {
        IMultiLogicProxy(multiLogicProxy).takeToken(amount, token);
        if (token == address(0)) {
            require(address(this).balance >= amount, "E16");
        }
    }

    /**
     * @notice Transfer amount of token from Logic to Storage contract token - address of token
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnTokenToStorage(uint256 amount, address token)
        external
        onlyOwnerAndAdmin
    {
        if (token == address(0)) {
            _send(payable(multiLogicProxy), amount);
        }

        IMultiLogicProxy(multiLogicProxy).returnToken(amount, token);
    }

    /**
     * @notice Transfer amount of ETH from Logic to MultiLogicProxy
     * @param amount Amount of ETH
     */
    function returnETHToMultiLogicProxy(uint256 amount)
        external
        onlyOwnerAndAdmin
    {
        _send(payable(multiLogicProxy), amount);
    }

    /**
     * @notice Distribution amount of blid to depositors.
     * @param amount Amount of BLID
     */
    function addEarnToStorage(uint256 amount) external onlyOwnerAndAdmin {
        IERC20Upgradeable(blid).safeTransfer(
            expenseAddress,
            (amount * 3) / 100
        );
        IMultiLogicProxy(multiLogicProxy).addEarn((amount * 97) / 100, blid);
    }

    /**
     * @notice Enter into a list of markets(address of XTokens) - it is not an
     * error to enter the same market more than once.
     * @param xTokens The addresses of the xToken markets to enter.
     * @param leadingTokenType Type of XToken
     * @return For each market, returns an error code indicating whether or not it was entered.
     * Each is 0 on success, otherwise an Error code
     */
    function enterMarkets(address[] calldata xTokens, uint8 leadingTokenType)
        external
        onlyOwnerAndAdmin
        isTokenTypeAccepted(leadingTokenType)
        returns (uint256[] memory)
    {
        if (leadingTokenType == vTokenType)
            return IComptrollerVenus(venusComptroller).enterMarkets(xTokens);
        if (leadingTokenType == oTokenType)
            return IComptrollerOla(olaComptroller).enterMarkets(xTokens);

        revert("E13");
    }

    /**
     * @notice Every Venus user accrues XVS for each block
     * they are supplying to or borrowing from the protocol.
     * @param xTokens The addresses of the xToken markets to enter.
     * @param leadingTokenType Type of XToken
     */
    function claim(address[] calldata xTokens, uint8 leadingTokenType)
        external
        onlyOwnerAndAdmin
        isTokenTypeAccepted(leadingTokenType)
    {
        if (leadingTokenType == vTokenType)
            IDistributionVenus(venusComptroller).claimVenus(
                address(this),
                xTokens
            );
        if (leadingTokenType == oTokenType)
            IDistributionOla(olaRainMaker).claimComp(address(this), xTokens);
    }

    /**
     * @notice Stake token and mint XToken
     * @param xToken: that mint XTokens to this contract
     * @param mintAmount: The amount of the asset to be supplied, in units of the underlying asset.
     * @return 0 on success, otherwise an Error code
     */
    function mint(address xToken, uint256 mintAmount)
        external
        isUsedXToken(xToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        require(mintAmount > 0, "E8");

        if (xToken == vBNB || xToken == oBNB) {
            IXTokenETH(xToken).mint{value: mintAmount}();
            return 0;
        }

        return IXToken(xToken).mint(mintAmount);
    }

    /**
     * @notice The borrow function transfers an asset from the protocol to the user and creates a
     * borrow balance which begins accumulating interest based on the Borrow Rate for the asset.
     * The amount borrowed must be less than the user's Account Liquidity and the market's
     * available liquidity.
     * @param xToken: that mint XTokens to this contract
     * @param borrowAmount: The amount of underlying to be borrow.
     * @param leadingTokenType Type of XToken
     * @return 0 on success, otherwise an Error code
     */
    function borrow(
        address xToken,
        uint256 borrowAmount,
        uint8 leadingTokenType
    )
        external
        payable
        isUsedXToken(xToken)
        onlyOwnerAndAdmin
        isTokenTypeAccepted(leadingTokenType)
        returns (uint256)
    {
        // Get my account's total liquidity value in Compound
        uint256 error;
        uint256 liquidity;
        uint256 shortfall;

        if (leadingTokenType == vTokenType)
            (error, liquidity, shortfall) = IComptrollerVenus(venusComptroller)
                .getAccountLiquidity(address(this));
        if (leadingTokenType == oTokenType)
            (error, liquidity, shortfall) = IComptrollerOla(olaComptroller)
                .getAccountLiquidity(address(this));

        require(error == 0, "E10");
        require(shortfall == 0, "E11");
        require(liquidity > 0, "E12");

        return IXToken(xToken).borrow(borrowAmount);
    }

    /**
     * @notice The repay function transfers an asset into the protocol, reducing the user's borrow balance.
     * @param xToken: that mint XTokens to this contract
     * @param repayAmount: The amount of the underlying borrowed asset to be repaid.
     * A value of -1 (i.e. 2256 - 1) can be used to repay the full amount.
     * @return 0 on success, otherwise an Error code
     */
    function repayBorrow(address xToken, uint256 repayAmount)
        external
        isUsedXToken(xToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        if (xToken == vBNB || xToken == oBNB) {
            IXTokenETH(xToken).repayBorrow{value: repayAmount}();
            return 0;
        }

        return IXToken(xToken).repayBorrow(repayAmount);
    }

    /**
     * @notice The redeem underlying function converts xTokens into a specified quantity of the
     * underlying asset, and returns them to the user.
     * The amount of xTokens redeemed is equal to the quantity of underlying tokens received,
     * divided by the current Exchange Rate.
     * The amount redeemed must be less than the user's Account Liquidity and the market's
     * available liquidity.
     * @param xToken: that mint XTokens to this contract
     * @param redeemAmount: The amount of underlying to be redeemed.
     * @return 0 on success, otherwise an Error code
     */
    function redeemUnderlying(address xToken, uint256 redeemAmount)
        external
        isUsedXToken(xToken)
        onlyOwnerAndAdmin
        returns (uint256)
    {
        return IXToken(xToken).redeemUnderlying(redeemAmount);
    }

    /**
     * @notice Adds liquidity to a BEP20⇄BEP20 pool.
     * @param swap Address of swap router
     * @param tokenA The contract address of one token from your liquidity pair.
     * @param tokenB The contract address of the other token from your liquidity pair.
     * @param amountADesired The amount of tokenA you'd like to provide as liquidity.
     * @param amountBDesired The amount of tokenA you'd like to provide as liquidity.
     * @param amountAMin The minimum amount of tokenA to provide (slippage impact).
     * @param amountBMin The minimum amount of tokenB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function addLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (amountADesired, amountBDesired, amountAMin) = IPancakeRouter01(swap)
            .addLiquidity(
                tokenA,
                tokenB,
                amountADesired,
                amountBDesired,
                amountAMin,
                amountBMin,
                address(this),
                deadline
            );

        return (amountADesired, amountBDesired, amountAMin);
    }

    /**
     * @notice Removes liquidity from a BEP20⇄BEP20 pool.
     * @param swap Address of swap router
     * @param tokenA The contract address of one token from your liquidity pair.
     * @param tokenB The contract address of the other token from your liquidity pair.
     * @param liquidity The amount of LP Tokens to remove.
     * @param amountAMin he minimum amount of tokenA to provide (slippage impact).
     * @param amountBMin The minimum amount of tokenB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function removeLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        onlyOwnerAndAdmin
        isUsedSwap(swap)
        returns (uint256 amountA, uint256 amountB)
    {
        (amountAMin, amountBMin) = IPancakeRouter01(swap).removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            address(this),
            deadline
        );

        return (amountAMin, amountBMin);
    }

    /**
     * @notice Adds liquidity to a BEP20⇄WBNB pool.
     * @param swap Address of swap router
     * @param token The contract address of one token from your liquidity pair.
     * @param amountTokenDesired The amount of the token you'd like to provide as liquidity.
     * @param amountETHDesired The minimum amount of the token to provide (slippage impact).
     * @param amountTokenMin The minimum amount of token to provide (slippage impact).
     * @param amountETHMin The minimum amount of BNB to provide (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function addLiquidityETH(
        address swap,
        address token,
        uint256 amountTokenDesired,
        uint256 amountETHDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (amountETHDesired, amountTokenMin, amountETHMin) = IPancakeRouter01(
            swap
        ).addLiquidityETH{value: amountETHDesired}(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        return (amountETHDesired, amountTokenMin, amountETHMin);
    }

    /**
     * @notice Removes liquidity from a BEP20⇄WBNB pool.
     * @param swap Address of swap router
     * @param token The contract address of one token from your liquidity pair.
     * @param liquidity The amount of LP Tokens to remove.
     * @param amountTokenMin The minimum amount of the token to remove (slippage impact).
     * @param amountETHMin The minimum amount of BNB to remove (slippage impact).
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function removeLiquidityETH(
        address swap,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        payable
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256 amountToken, uint256 amountETH)
    {
        (deadline, amountETHMin) = IPancakeRouter01(swap).removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        return (deadline, amountETHMin);
    }

    /**
     * @notice Receive an as many output tokens as possible for an exact amount of input tokens.
     * @param swap Address of swap router
     * @param amountIn TPayable amount of input tokens.
     * @param amountOutMin The minimum amount tokens to receive.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactTokensForTokens(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as few input tokens as possible.
     * @param swap Address of swap router
     * @param amountOut Payable amount of input tokens.
     * @param amountInMax The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapTokensForExactTokens(
        address swap,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        uint256 deadline
    )
        external
        onlyOwnerAndAdmin
        isUsedSwap(swap)
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive as many output tokens as possible for an exact amount of BNB.
     * @param swap Address of swap router
     * @param amountETH Payable BNB amount.
     * @param amountOutMin 	The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactETHForTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapExactETHForTokens{value: amountETH}(
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as few input tokens as possible.
     * @param swap Address of swap router
     * @param amountOut Payable BNB amount.
     * @param amountInMax The minimum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapTokensForExactETH(
        address swap,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        uint256 deadline
    )
        external
        payable
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapTokensForExactETH(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive as much BNB as possible for an exact amount of input tokens.
     * @param swap Address of swap router
     * @param amountIn Payable amount of input tokens.
     * @param amountOutMin The maximum amount tokens to input.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapExactTokensForETH(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    )
        external
        payable
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapExactTokensForETH(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Receive an exact amount of output tokens for as little BNB as possible.
     * @param swap Address of swap router
     * @param amountOut The amount tokens to receive.
     * @param amountETH Payable BNB amount.
     * @param path (address[]) An array of token addresses. path.length must be >= 2.
     * Pools for each consecutive pair of addresses must exist and have liquidity.
     * @param deadline Unix timestamp deadline by which the transaction must confirm.
     */
    function swapETHForExactTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOut,
        address[] calldata path,
        uint256 deadline
    )
        external
        isUsedSwap(swap)
        onlyOwnerAndAdmin
        returns (uint256[] memory amounts)
    {
        return
            IPancakeRouter01(swap).swapETHForExactTokens{value: amountETH}(
                amountOut,
                path,
                address(this),
                deadline
            );
    }

    /**
     * @notice Deposit LP tokens to Master
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _pid pool id
     * @param _amount amount of lp token
     */
    function deposit(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external isUsedMaster(swapMaster) onlyOwnerAndAdmin {
        IMasterChef(swapMaster).deposit(_pid, _amount);
    }

    /**
     * @notice Withdraw LP tokens from Master
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _pid pool id
     * @param _amount amount of lp token
     */
    function withdraw(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external isUsedMaster(swapMaster) onlyOwnerAndAdmin {
        IMasterChef(swapMaster).withdraw(_pid, _amount);
    }

    /**
     * @notice Stake BANANA/Cake tokens to STAKING.
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _amount amount of lp token
     */
    function enterStaking(address swapMaster, uint256 _amount)
        external
        isUsedMaster(swapMaster)
        onlyOwnerAndAdmin
    {
        IMasterChef(swapMaster).enterStaking(_amount);
    }

    /**
     * @notice Withdraw BANANA/Cake tokens from STAKING.
     * @param swapMaster Address of swap master(Main staking contract)
     * @param _amount amount of lp token
     */
    function leaveStaking(address swapMaster, uint256 _amount)
        external
        isUsedMaster(swapMaster)
        onlyOwnerAndAdmin
    {
        IMasterChef(swapMaster).leaveStaking(_amount);
    }

    /*** Prvate Function ***/

    /**
     * @notice Send ETH to address
     * @param _to target address to receive ETH
     * @param amount ETH amount (wei) to be sent
     */
    function _send(address payable _to, uint256 amount) private {
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "E17");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IPancakeRouter01 {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

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
}

interface IMasterChef {
    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function userInfo(uint256 _pid, address account)
        external
        view
        returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IComptrollerVenus {
    function enterMarkets(address[] calldata xTokens)
        external
        returns (uint256[] memory);

    function markets(address cTokenAddress)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );

    function getAllMarkets() external view returns (address[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function oracle() external view returns (address);
}

interface IDistributionVenus {
    function claimVenus(address holder, address[] memory vTokens) external;
}

interface IOracleVenus {
    function getUnderlyingPrice(address vToken) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./../utils/LogicUpgradeable.sol";
import "./../Interfaces/ILogicContract.sol";
import "./../Interfaces/IXToken.sol";
import "./../Interfaces/ICompoundVenus.sol";
import "./../Interfaces/ISwap.sol";

contract LendBorrowFarmStrategy is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct ReserveLiquidity {
        address tokenA;
        address tokenB;
        address xTokenA;
        address xTokenB;
        address swap;
        address swapMaster;
        address lpToken;
        uint256 poolID;
        address[][] path;
    }

    ReserveLiquidity[] reserves;

    address private blid;
    address private comptroller;
    address private rewardsSwapRouter;
    address private rewardsToken;
    address private logic;
    address private multiLogicProxy;

    bool private rewardsInit;

    mapping(address => address) private vTokens;

    event SetBLID(address _blid);
    event SetMultiLogicProxy(address multiLogicProxy);
    event Init(address token);
    event ReleaseToken(address token, uint256 amount);

    function __LendBorrowFarmStrategy_init(
        address _comptroller,
        address _rewardsSwapRouter,
        address _rewardsToken,
        address _logic
    ) public initializer {
        LogicUpgradeable.initialize();
        comptroller = _comptroller;
        rewardsSwapRouter = _rewardsSwapRouter;
        rewardsToken = _rewardsToken;
        logic = _logic;
        rewardsInit = false;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier onlyMultiLogicProxy() {
        require(msg.sender == multiLogicProxy, "F1");
        _;
    }

    modifier isUsedToken(address token) {
        require(vTokens[token] != address(0), "F2");
        _;
    }

    /**
     * @notice Set blid in contract
     * @param blid_ Address of BLID
     */
    function setBLID(address blid_) external onlyOwner {
        require(blid == address(0), "F3");
        blid = blid_;
        emit SetBLID(blid_);
    }

    /**
     * @notice Set MultiLogicProxy, you can call the function once
     * @param _multiLogicProxy Address of Storage Contract
     */
    function setMultiLogicProxy(address _multiLogicProxy) external onlyOwner {
        require(multiLogicProxy == address(0), "F5");
        multiLogicProxy = _multiLogicProxy;

        emit SetMultiLogicProxy(_multiLogicProxy);
    }

    /**
     * @notice Add XToken in Contract and approve token
     * Approve token for storage, venus, pancakeswap/apeswap/biswap router,
     * and pancakeswap/apeswap/biswap master(Main Staking contract)
     * Approve rewardsToken for swap
     * @param token Address of underlying token
     * @param vToken Address of vToken
     */
    function init(address token, address vToken) public onlyOwner {
        require(vTokens[token] == address(0), "F6");

        address _logic = logic;
        vTokens[token] = vToken;

        // Add token/oToken to Logic
        ILogicContract(_logic).addXTokens(token, vToken, 0);

        // Entermarkets with token/vtoken
        address[] memory tokens = new address[](1);
        tokens[0] = vToken;
        ILogicContract(_logic).enterMarkets(tokens, 0);

        // Approve rewards token
        if (!rewardsInit) {
            ILogicContract(_logic).approveTokenForSwap(rewardsToken);

            rewardsInit = true;
        }

        emit Init(token);
    }

    /**
     * @notice Frees up tokens for the user, but Storage doesn't transfer token for the user,
     * only Storage can this function, after calling this function Storage transfer
     * from Logic to user token.
     * @param _amount Amount of token
     * @param token Address of token
     */
    function releaseToken(uint256 _amount, address token)
        external
        payable
        onlyMultiLogicProxy
        isUsedToken(token)
    {
        uint256 takeFromVenus = 0;
        uint256 length = reserves.length;
        address _logic = logic;
        uint256 amount = _amount;
        address vToken = vTokens[token];

        // check logic balance
        uint256 balance;

        if (token == address(0)) {
            balance = address(_logic).balance;
        } else {
            balance = IERC20Upgradeable(token).balanceOf(_logic);
        }
        if (balance >= amount) {
            if (token == address(0)) {
                ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
            }

            emit ReleaseToken(token, _amount);
            return;
        }

        // decrease redeemAmount
        amount -= balance;

        //loop by reserves lp token
        for (uint256 i = 0; i < length; ) {
            address[] memory path = findPath(i, token); // get path for router
            ReserveLiquidity memory reserve = reserves[i];
            uint256 lpAmount = getPriceFromTokenToLp(
                reserve.lpToken,
                amount - takeFromVenus,
                token,
                reserve.swap,
                path
            ); //get amount of lp token that need for reedem liqudity

            //get how many deposited to farming
            (uint256 depositedLp, ) = IMasterChef(reserve.swapMaster).userInfo(
                reserve.poolID,
                _logic
            );
            if (depositedLp == 0) continue;
            // if deposited LP tokens don't enough  for repay borrow and for reedem token then only repay
            // borow and continue loop, else repay borow, reedem token and break loop
            if (lpAmount >= depositedLp) {
                takeFromVenus += getPriceFromLpToToken(
                    reserve.lpToken,
                    depositedLp,
                    token,
                    reserve.swap,
                    path
                );
                withdrawAndRepay(reserve, depositedLp);
            } else {
                withdrawAndRepay(reserve, lpAmount);

                // get supplied token and break loop
                ILogicContract(_logic).redeemUnderlying(vToken, amount);

                if (token == address(0)) {
                    ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
                }
                emit ReleaseToken(token, _amount);
                return;
            }

            unchecked {
                ++i;
            }
        }
        //try get supplied token
        ILogicContract(_logic).redeemUnderlying(vToken, amount);
        //if get money
        if (
            token != address(0) &&
            IERC20Upgradeable(token).balanceOf(_logic) >= _amount
        ) {
            emit ReleaseToken(token, _amount);
            return;
        }

        if (token == address(0) && address(_logic).balance >= _amount) {
            ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
            emit ReleaseToken(token, _amount);
            return;
        }

        // redeem remaind vToken
        uint256 vTokenBalance; // balance of cToken
        uint256 borrowBalance; // balance of borrowed amount
        uint256 exchangeRateMantissa; //conversion rate from cToken to token

        // Get vToken information and redeem
        (, vTokenBalance, borrowBalance, exchangeRateMantissa) = IXToken(vToken)
            .getAccountSnapshot(_logic);

        if (vTokenBalance > 0) {
            uint256 supplyBalance = (vTokenBalance * exchangeRateMantissa) /
                10**18;

            ILogicContract(_logic).redeemUnderlying(vToken, supplyBalance);
        }

        if (
            token != address(0) &&
            IERC20Upgradeable(token).balanceOf(_logic) >= _amount
        ) {
            emit ReleaseToken(token, _amount);
            return;
        }

        if (token == address(0) && address(_logic).balance >= _amount) {
            ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
            emit ReleaseToken(token, _amount);
            return;
        }

        revert("no money");
    }

    /**
     * @notice Add reserve staked lp token to end list
     * @param reserveLiquidity Data is about staked lp in farm
     */
    function addReserveLiquidity(ReserveLiquidity memory reserveLiquidity)
        external
        onlyOwnerAndAdmin
    {
        reserves.push(reserveLiquidity);
    }

    /**
     * @notice Add reserve staked lp token list to end list
     * @param reserveLiquidityList Data is about staked lp in farm
     */
    function addReserveLiquidityList(
        ReserveLiquidity[] memory reserveLiquidityList
    ) external onlyOwnerAndAdmin {
        uint256 length = reserveLiquidityList.length;
        for (uint256 i = 0; i < length; ) {
            reserves.push(reserveLiquidityList[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Delete last ReserveLiquidity from list of ReserveLiquidity
     */
    function deleteLastReserveLiquidity() external onlyOwnerAndAdmin {
        reserves.pop();
    }

    /**
     * @notice Delete a number of last ReserveLiquidity from list of ReserveLiquidity
     * @param length number of reservedLiquidity to be deleted
     */
    function deleteLastReserveLiquidityList(uint256 length)
        external
        onlyOwnerAndAdmin
    {
        for (uint256 i = 0; i < length; ) {
            reserves.pop();

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Return count reserves staked lp tokens for return users their tokens.
     */
    function getReservesCount() external view returns (uint256) {
        return reserves.length;
    }

    /**
     * @notice Return reserves staked lp tokens for return user their tokens. return ReserveLiquidity
     */
    function getReserve(uint256 id)
        external
        view
        returns (ReserveLiquidity memory)
    {
        return reserves[id];
    }

    /**
     * @notice multicall to Logic
     */
    function multicall(bytes[] memory callDatas)
        public
        onlyOwnerAndAdmin
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        uint256 length = callDatas.length;
        returnData = new bytes[](length);
        for (uint256 i = 0; i < length; ) {
            (bool success, bytes memory ret) = address(logic).call(
                callDatas[i]
            );
            require(success, "F99");
            returnData[i] = ret;

            unchecked {
                ++i;
            }
        }
    }

    /*** Prive Function ***/

    /**
     * @notice Withdraw lp token from farms and repay borrow
     */
    function withdrawAndRepay(ReserveLiquidity memory reserve, uint256 lpAmount)
        private
    {
        ILogicContract(logic).withdraw(
            reserve.swapMaster,
            reserve.poolID,
            lpAmount
        );
        if (reserve.tokenA == address(0) || reserve.tokenB == address(0)) {
            //if tokenA is BNB
            if (reserve.tokenA == address(0)) {
                repayBorrowBNBandToken(
                    reserve.swap,
                    reserve.tokenB,
                    reserve.xTokenA,
                    reserve.xTokenB,
                    lpAmount
                );
            }
            //if tokenB is BNB
            else {
                repayBorrowBNBandToken(
                    reserve.swap,
                    reserve.tokenA,
                    reserve.xTokenB,
                    reserve.xTokenA,
                    lpAmount
                );
            }
        }
        //if token A and B is not BNB
        else {
            repayBorrowOnlyTokens(
                reserve.swap,
                reserve.tokenA,
                reserve.tokenB,
                reserve.xTokenA,
                reserve.xTokenB,
                lpAmount
            );
        }
    }

    /**
     * @notice Repay borrow when in farms  erc20 and BNB
     */
    function repayBorrowBNBandToken(
        address swap,
        address tokenB,
        address xTokenA,
        address xTokenB,
        uint256 lpAmount
    ) private {
        address _logic = logic;

        (uint256 amountToken, uint256 amountETH) = ILogicContract(_logic)
            .removeLiquidityETH(
                swap,
                tokenB,
                lpAmount,
                0,
                0,
                block.timestamp + 1 days
            );
        {
            uint256 totalBorrow = IXTokenETH(xTokenA).borrowBalanceCurrent(
                _logic
            );
            if (totalBorrow >= amountETH) {
                ILogicContract(_logic).repayBorrow(xTokenA, amountETH);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenA, totalBorrow);
            }

            totalBorrow = IXToken(xTokenB).borrowBalanceCurrent(_logic);
            if (totalBorrow >= amountToken) {
                ILogicContract(_logic).repayBorrow(xTokenB, amountToken);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenB, totalBorrow);
            }
        }
    }

    /**
     * @notice Repay borrow when in farms only erc20
     */
    function repayBorrowOnlyTokens(
        address swap,
        address tokenA,
        address tokenB,
        address xTokenA,
        address xTokenB,
        uint256 lpAmount
    ) private {
        address _logic = logic;

        (uint256 amountA, uint256 amountB) = ILogicContract(_logic)
            .removeLiquidity(
                swap,
                tokenA,
                tokenB,
                lpAmount,
                0,
                0,
                block.timestamp + 1 days
            );
        {
            uint256 totalBorrow = IXToken(xTokenA).borrowBalanceCurrent(_logic);
            if (totalBorrow >= amountA) {
                ILogicContract(_logic).repayBorrow(xTokenA, amountA);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenA, totalBorrow);
            }

            totalBorrow = IXToken(xTokenB).borrowBalanceCurrent(_logic);
            if (totalBorrow >= amountB) {
                ILogicContract(_logic).repayBorrow(xTokenB, amountB);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenB, totalBorrow);
            }
        }
    }

    /*** Prive View Function ***/
    /**
     * @notice Convert Lp Token To Token
     */
    function getPriceFromLpToToken(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) private view returns (uint256) {
        //make price returned not affected by slippage rate
        uint256 totalSupply = IERC20Upgradeable(lpToken).totalSupply();
        address token0 = IPancakePair(lpToken).token0();
        uint256 totalTokenAmount = IERC20Upgradeable(token0).balanceOf(
            lpToken
        ) * (2);
        uint256 amountIn = (value * totalTokenAmount) / (totalSupply);

        if (amountIn == 0 || token0 == token) {
            return amountIn;
        }

        uint256[] memory price = IPancakeRouter01(swap).getAmountsOut(
            amountIn,
            path
        );
        return price[price.length - 1];
    }

    /**
     * @notice Convert Token To Lp Token
     */
    function getPriceFromTokenToLp(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) private view returns (uint256) {
        //make price returned not affected by slippage rate
        uint256 totalSupply = IERC20Upgradeable(lpToken).totalSupply();
        address token0 = IPancakePair(lpToken).token0();
        uint256 totalTokenAmount = IERC20Upgradeable(token0).balanceOf(lpToken);

        if (token0 == token) {
            return (value * (totalSupply)) / (totalTokenAmount) / 2;
        }

        uint256[] memory price = IPancakeRouter01(swap).getAmountsOut(
            (1 gwei),
            path
        );
        return
            (value * (totalSupply)) /
            ((price[price.length - 1] * 2 * totalTokenAmount) / (1 gwei));
    }

    /**
     * @notice FindPath for swap router
     */
    function findPath(uint256 id, address token)
        private
        view
        returns (address[] memory path)
    {
        ReserveLiquidity memory reserve = reserves[id];
        uint256 length = reserve.path.length;

        for (uint256 i = 0; i < length; ) {
            if (reserve.path[i][reserve.path[i].length - 1] == token) {
                return reserve.path[i];
            }
            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "./utils/LogicUpgradeable.sol";
import "./Interfaces/IXToken.sol";
import "./Interfaces/ICompoundVenus.sol";
import "./Interfaces/ICompoundOla.sol";

contract StrategyHelper is LogicUpgradeable {
    struct xTokenInfo {
        string name;
        address xToken;
        uint256 borrowAmount;
        uint256 borrowAmountUSD;
    }

    uint8 private constant vStrategyType = 0;
    uint8 private constant oStrategyType = 1;

    function __StrategyHelper_init() public initializer {
        LogicUpgradeable.initialize();
    }

    /*** Modifier ***/
    modifier isStrategyTypeAccepted(uint8 strategyType) {
        require(
            strategyType == vStrategyType || strategyType == oStrategyType,
            "SH1"
        );
        _;
    }

    /*** User function ***/

    /**
     * @notice Get Strategy balance information
     * check all xTokens in market
     * @param logic Logic contract address
     * @param comptroller comptroller address
     * @param strategyType 0: Venus, 1 Ola
     * @return totalBorrowLimitUSD sum of borrow limit for each xToken in USD
     * @return supplyUSD sum of supply for each xToken in USD
     * @return borrowUSD sum of borrow for each xToken in USD
     * @return percentLimit borrowUSD / totalBorrowLimitUSD in percentage
     * @return tokensInfo detailed information about xTokens
     */
    function getStrategyBalance(
        address logic,
        address comptroller,
        uint8 strategyType
    )
        external
        view
        isStrategyTypeAccepted(strategyType)
        returns (
            uint256 totalBorrowLimitUSD,
            uint256 supplyUSD,
            uint256 borrowUSD,
            uint256 percentLimit,
            xTokenInfo[] memory tokensInfo
        )
    {
        // Get the list of vTokens
        address[] memory xTokenList = IComptrollerVenus(comptroller)
            .getAllMarkets();
        uint256 index;
        tokensInfo = new xTokenInfo[](xTokenList.length);

        for (index = 0; index < xTokenList.length; ) {
            address xToken = address(xTokenList[index]);

            // Get USD price
            uint256 priceUSD;
            if (strategyType == vStrategyType) {
                priceUSD = IOracleVenus(IComptrollerVenus(comptroller).oracle())
                    .getUnderlyingPrice(xToken);
            }
            if (strategyType == oStrategyType) {
                priceUSD = IComptrollerOla(comptroller).getUnderlyingPriceInLen(
                        IXToken(xToken).underlying()
                    );
            }

            // getAccountSnapshot of xToken
            uint256 totalSupply;
            uint256 borrowBalance;
            (totalSupply, borrowBalance) = _getAccountSnapshot(logic, xToken);
            totalSupply = (totalSupply * priceUSD) / 10**18; // Supply Balance in USD

            // Get collateralFactor from market
            uint256 mantissa;
            if (strategyType == vStrategyType) {
                (, mantissa, ) = IComptrollerVenus(comptroller).markets(xToken);
            }
            if (strategyType == oStrategyType) {
                (, mantissa, , , , ) = IComptrollerOla(comptroller).markets(
                    xToken
                );
            }

            // Calculation
            totalBorrowLimitUSD += (totalSupply * mantissa) / 10**18;
            supplyUSD += totalSupply;
            borrowUSD += (borrowBalance * priceUSD) / 10**18;

            // Token Info
            tokensInfo[index] = xTokenInfo(
                IXToken(xToken).name(),
                xToken,
                borrowBalance,
                (borrowBalance * priceUSD) / 10**18
            );

            unchecked {
                ++index;
            }
        }
        percentLimit = totalBorrowLimitUSD == 0
            ? 0
            : (borrowUSD * 10**18) / totalBorrowLimitUSD;
    }

    /**
     * @notice Get xToken's total supply, borrow amount
     * @param logic Logic contract address
     * @param xToken xToken address
     * @return totalSupply total Supply
     * @return borrowAmount total borrow amount
     */
    function _getAccountSnapshot(address logic, address xToken)
        private
        view
        returns (uint256 totalSupply, uint256 borrowAmount)
    {
        uint256 xTokenBalance;
        uint256 exchangeRateMantissa;
        (, xTokenBalance, borrowAmount, exchangeRateMantissa) = IXToken(xToken)
            .getAccountSnapshot(logic);

        totalSupply = (xTokenBalance * exchangeRateMantissa) / 10**18;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../utils/LogicUpgradeable.sol";
import "../Interfaces/IStargateRouter.sol";

contract CrossChainDepositor is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address private accumulatedDepositor;
    address private stargateRouter;
    mapping(address => uint8) private stargateTokenPoolId;

    event SetAccumulatedDepositor(address accumulatedDepositor);
    event SetStargateTokenPoolId(address token, uint8 poolId);
    event DepositStargate(
        uint16 chainId,
        uint8 srcPoolId,
        uint8 dstPoolId,
        uint256 amountIn,
        uint256 dstGasForCall,
        uint256 gasFee,
        address depositor,
        address receiver
    );

    function __CrossChainDepositor_init(address _stargateRouter)
        public
        initializer
    {
        LogicUpgradeable.initialize();
        stargateRouter = _stargateRouter;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier isUsedStargateToken(address token) {
        require(stargateTokenPoolId[token] != 0, "CD1");
        _;
    }

    /*** User function ***/

    /**
     * @notice Set AccumulatedDepositor address on destination chain
     * @param _accumulatedDepositor Address AccumulatedDepositor on destination chain
     */
    function setAccumulatedDepositor(address _accumulatedDepositor)
        external
        onlyOwner
    {
        require(accumulatedDepositor == address(0), "CD8");
        accumulatedDepositor = _accumulatedDepositor;

        emit SetAccumulatedDepositor(_accumulatedDepositor);
    }

    /**
     * @notice Add Stargate accepted token and poolID
     * @param token Address of Token for deposited
     * @param poolId Pool ID defined in Stargate
     */
    function addStargateToken(address token, uint8 poolId) external onlyOwner {
        require(token != address(0), "CD2");
        require(stargateTokenPoolId[token] == 0, "CD3");

        stargateTokenPoolId[token] = poolId;

        emit SetStargateTokenPoolId(token, poolId);
    }

    /**
     * @notice Estimate swap fee for Stargate
     * @param chainId Destination chainId
     * @param dstGasForCall Destination required gas for call
     */
    function getDepositFeeStargate(uint16 chainId, uint256 dstGasForCall)
        public
        view
        returns (uint256 feeWei)
    {
        require(accumulatedDepositor != address(0), "CD4");

        bytes memory data = abi.encode(msg.sender);

        (feeWei, ) = IStargateRouter(stargateRouter).quoteLayerZeroFee(
            chainId,
            1, // swap remote
            abi.encodePacked(accumulatedDepositor),
            data,
            IStargateRouter.lzTxObj(dstGasForCall, 0, "0x")
        );
    }

    /**
     * @notice Deposit stablecoin to destination chain
     * @param chainId Destination chainId
     * @param srcToken stablecoin address in source chain
     * @param dstToken stablecoin address in destination chain
     * @param amountIn deposit amount
     * @param amountOutMin expected out amount minimum
     * @param dstGasForCall Destination required gas for call
     */
    function depositStarGate(
        uint16 chainId,
        address srcToken,
        address dstToken,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 dstGasForCall
    )
        external
        payable
        isUsedStargateToken(srcToken)
        isUsedStargateToken(dstToken)
    {
        require(msg.value > 0, "CD5");
        require(accumulatedDepositor != address(0), "CD4");
        require(amountIn > 0, "CD6");

        // Payload via anyCall
        bytes memory data = abi.encode(msg.sender);

        // Estimate gas fee
        uint256 feeWei;
        (feeWei, ) = IStargateRouter(stargateRouter).quoteLayerZeroFee(
            chainId,
            1, // swap remote
            abi.encodePacked(accumulatedDepositor),
            data,
            IStargateRouter.lzTxObj(dstGasForCall, 0, "0x")
        );
        require(msg.value >= feeWei, "CD7");

        // Take token from user wallet
        IERC20Upgradeable(srcToken).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        // Approve token for swap
        IERC20Upgradeable(srcToken).safeApprove(
            address(stargateRouter),
            amountIn
        );

        // Swap via Stargate
        IStargateRouter(stargateRouter).swap{value: msg.value}(
            chainId,
            stargateTokenPoolId[srcToken],
            stargateTokenPoolId[dstToken],
            payable(msg.sender),
            amountIn,
            amountOutMin,
            IStargateRouter.lzTxObj(dstGasForCall, 0, "0x"),
            abi.encodePacked(accumulatedDepositor),
            data
        );

        emit DepositStargate(
            chainId,
            stargateTokenPoolId[srcToken],
            stargateTokenPoolId[dstToken],
            amountIn,
            dstGasForCall,
            msg.value,
            msg.sender,
            stargateRouter
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../utils/LogicUpgradeable.sol";
import "../Interfaces/IStorage.sol";

contract AccumulatedDepositor is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    mapping(address => bool) private tokensAdd;
    address private storageContract;
    address private stargateRouter;

    event AddToken(address token);
    event ReceivedOnDestination(
        address token,
        uint256 amount,
        address accountAddress
    );

    function __AccumulatedDepositor_init(address _stargateRouter)
        public
        initializer
    {
        LogicUpgradeable.initialize();
        stargateRouter = _stargateRouter;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier isUsedToken(address _token) {
        require(tokensAdd[_token], "AD2");
        _;
    }

    /*** User function ***/

    /**
     * @notice set Storage address
     * @param _storage storage address
     */
    function setStorage(address _storage) external {
        require(storageContract == address(0), "AD1");
        storageContract = _storage;
    }

    /**
     * @notice Add token
     * @param _token Address of Token
     */
    function addStargateToken(address _token) external onlyOwner {
        require(_token != address(0), "AD3");
        require(!tokensAdd[_token], "AD4");
        require(storageContract != address(0), "AD1");

        IERC20Upgradeable(_token).safeApprove(
            storageContract,
            type(uint256).max
        );

        tokensAdd[_token] = true;

        emit AddToken(_token);
    }

    /// @param '_chainId' The remote chainId sending the tokens
    /// @param '_srcAddress' The remote Bridge address
    /// @param '_nonce' The message ordering nonce
    /// @param _token The token contract on the local chain
    /// @param amountLD The qty of local _token contract tokens
    /// @param _payload The bytes containing the toAddress
    function sgReceive(
        uint16, /*_chainId*/
        bytes memory, /*_srcAddress*/
        uint256, /*_nonce*/
        address _token,
        uint256 amountLD,
        bytes memory _payload
    ) external isUsedToken(_token) {
        require(msg.sender == address(stargateRouter), "AD5");

        address accountAddress = abi.decode(_payload, (address));

        IStorage(storageContract).depositOnBehalf(
            amountLD,
            _token,
            accountAddress
        );

        emit ReceivedOnDestination(_token, amountLD, accountAddress);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface ILogicContract {
    function returnToken(uint256 amount, address token) external;
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256 answer);
}

contract StorageV21Beta is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    //struct
    struct DepositStruct {
        mapping(address => uint256) amount;
        mapping(address => int256) tokenTime;
        uint256 iterate;
        uint256 balanceBLID;
        mapping(address => uint256) depositIterate;
    }

    struct EarnBLID {
        uint256 allBLID;
        uint256 timestamp;
        uint256 usd;
        uint256 tdt;
        mapping(address => uint256) rates;
    }

    struct BoostInfo {
        uint256 blidDeposit;
        uint256 rewardDebt;
        uint256 blidOverDeposit;
    }

    /*** events ***/

    event Deposit(address depositor, address token, uint256 amount);
    event Withdraw(address depositor, address token, uint256 amount);
    event UpdateTokenBalance(uint256 balance, address token);
    event TakeToken(address token, uint256 amount);
    event ReturnToken(address token, uint256 amount);
    event AddEarn(uint256 amount);
    event UpdateBLIDBalance(uint256 balance);
    event InterestFee(address depositor, uint256 amount);
    event SetBLID(address blid);
    event AddToken(address token, address oracle);
    event SetLogic(address logic);
    event SetBoostInfo(uint256 maxBlidPerUSD, uint256 blidPerBlock);
    event DepositBLID(address depositor, uint256 amount);
    event WithdrawBLID(address depositor, uint256 amount);
    event ClaimBoostBLID(address depositor, uint256 amount);
    event SetBoostingAddress(address boostingAddress);
    event SetAdmin(address admin);
    event UpgradeVersion(string version, string purpose);

    function initialize(address _logicContract) external initializer {
        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
        logicContract = _logicContract;
    }

    mapping(uint256 => EarnBLID) private earnBLID;
    uint256 private countEarns;
    uint256 private countTokens;
    mapping(uint256 => address) private tokens;
    mapping(address => uint256) private tokenBalance;
    mapping(address => address) private oracles;
    mapping(address => bool) private tokensAdd;
    mapping(address => DepositStruct) private deposits;
    mapping(address => uint256) private tokenDeposited;
    mapping(address => int256) private tokenTime;
    uint256 private reserveBLID;
    address private logicContract;
    address private BLID;
    mapping(address => mapping(uint256 => uint256)) public accumulatedRewardsPerShare;

    // ****** Add from V21 ******

    // Boost2.0
    mapping(address => BoostInfo) private userBoosts;
    uint256 public maxBlidPerUSD;
    uint256 public blidPerBlock;
    uint256 public initBlidPerBlock;
    uint256 public maxBlidPerBlock; // deprecated  - should be to remove in staging / production
    uint256 public accBlidPerShare;
    uint256 public lastRewardBlock;
    uint256 public totalSupplyBLID; // deprecated  - should be to remove in staging / production
    address public expenseAddress; // deprecated - should be to remove in staging / production
    address private accumulatedDepositor; // CrossChain : deprecated - should be to remove in staging / production
    address public boostingAddress;

    /*** modifiers ***/

    modifier isUsedToken(address _token) {
        require(tokensAdd[_token], "E1");
        _;
    }

    modifier isLogicContract(address account) {
        require(logicContract == account, "E2");
        _;
    }

    /*** Owner functions ***/

    /**
     * @notice Set blid in contract
     * @param _blid address of BLID
     */
    function setBLID(address _blid) external onlyOwner {
        BLID = _blid;

        emit SetBLID(_blid);
    }

    /**
     * @notice Set blid in contract
     * @param _boostingAddress address of expense
     */
    function setBoostingAddress(address _boostingAddress) external onlyOwner {
        boostingAddress = _boostingAddress;

        emit SetBoostingAddress(boostingAddress);
    }

    /**
     * @notice Set boosting parameters
     * @param _maxBlidperUSD max value of BLID per USD
     * @param _blidperBlock blid per Block
     */
    function setBoostingInfo(uint256 _maxBlidperUSD, uint256 _blidperBlock) external onlyOwner {
        _boostingUpdateAccBlidPerShare();

        maxBlidPerUSD = _maxBlidperUSD;
        blidPerBlock = _blidperBlock;
        initBlidPerBlock = _blidperBlock;

        emit SetBoostInfo(_maxBlidperUSD, _blidperBlock);
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Update AccumulatedRewardsPerShare for token, using once after update contract
     * @param token Address of token
     */
    function updateAccumulatedRewardsPerShare(address token) external onlyOwner {
        require(accumulatedRewardsPerShare[token][0] == 0, "E7");
        uint256 countEarns_ = countEarns;
        for (uint256 i = 0; i < countEarns_; i++) {
            updateAccumulatedRewardsPerShareById(token, i);
        }
    }

    /**
     * @notice Add token and token's oracle
     * @param _token Address of Token
     * @param _oracles Address of token's oracle(https://docs.chain.link/docs/binance-smart-chain-addresses/
     */
    function addToken(address _token, address _oracles) external onlyOwner {
        require(_token != address(0) && _oracles != address(0));
        require(!tokensAdd[_token], "E6");
        oracles[_token] = _oracles;
        tokens[countTokens++] = _token;
        tokensAdd[_token] = true;

        emit AddToken(_token, _oracles);
    }

    /**
     * @notice Set logic in contract(only for upgradebale contract,use only whith DAO)
     * @param _logic Address of Logic Contract
     */
    function setLogic(address _logic) external onlyOwner {
        logicContract = _logic;

        emit SetLogic(_logic);
    }

    /*** User functions ***/

    /**
     * @notice Deposit amount of token for msg.sender
     * @param amount amount of token
     * @param token address of token
     */
    function deposit(uint256 amount, address token) external payable isUsedToken(token) whenNotPaused {
        depositInternal(amount, token, msg.sender);
    }

    /**
     * @notice Deposit amount of token on behalf of depositor wallet
     * @param amount amount of token
     * @param token address of token
     * @param accountAddress Address of depositor
     */
    function depositOnBehalf(
        uint256 amount,
        address token,
        address accountAddress
    ) external payable isUsedToken(token) whenNotPaused {
        depositInternal(amount, token, accountAddress);
    }

    /**
     * @notice Withdraw amount of token  from Strategy and receiving earned tokens.
     * @param amount Amount of token
     * @param token Address of token
     */
    function withdraw(uint256 amount, address token) external isUsedToken(token) whenNotPaused {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 countEarns_ = countEarns;
        uint256 amountExp18 = amount * 10**(18 - decimals);
        DepositStruct storage depositor = deposits[msg.sender];
        require(depositor.amount[token] >= amountExp18 && amount > 0, "E4");
        if (amountExp18 > tokenBalance[token]) {
            ILogicContract(logicContract).returnToken(amount, token);
            interestFee(msg.sender);
            IERC20Upgradeable(token).safeTransferFrom(logicContract, msg.sender, amount);
            tokenDeposited[token] -= amountExp18;
            tokenTime[token] -= int256(block.timestamp * (amountExp18));
        } else {
            interestFee(msg.sender);
            IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
            tokenTime[token] -= int256(block.timestamp * (amountExp18));

            tokenBalance[token] -= amountExp18;
            tokenDeposited[token] -= amountExp18;
        }
        if (depositor.depositIterate[token] == countEarns_) {
            depositor.tokenTime[token] -= int256(block.timestamp * (amountExp18));
        } else {
            depositor.tokenTime[token] =
                int256(depositor.amount[token] * earnBLID[countEarns_ - 1].timestamp) -
                int256(block.timestamp * (amountExp18));
            depositor.depositIterate[token] = countEarns_;
        }
        depositor.amount[token] -= amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(msg.sender, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Withdraw(msg.sender, token, amountExp18);
    }

    /**
     * @notice Claim BLID to accountAddress
     * @param accountAddress account address for claim
     */
    function interestFee(address accountAddress) public {
        uint256 balanceUser = balanceEarnBLID(accountAddress);
        require(reserveBLID >= balanceUser, "E5");
        IERC20Upgradeable(BLID).safeTransfer(accountAddress, balanceUser);
        DepositStruct storage depositor = deposits[accountAddress];
        depositor.balanceBLID = balanceUser;
        depositor.iterate = countEarns;
        //unchecked is used because a check was made in require
        unchecked {
            depositor.balanceBLID = 0;
            reserveBLID -= balanceUser;
        }

        emit UpdateBLIDBalance(reserveBLID);
        emit InterestFee(accountAddress, balanceUser);
    }

    /*** Boosting User function ***/

    /**
     * @notice Deposit BLID token for boosting.
     * @param amount amount of token
     */
    function depositBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(usdDepositAmount > 0, "E11");

        BoostInfo storage userBoost = userBoosts[msg.sender];

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransferFrom(msg.sender, address(this), amount);

        // Adjust blidOverDeposit
        uint256 totalAmount = userBoost.blidDeposit + amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        uint256 depositAmount = amount;
        if (totalAmount > blidDepositLimit) {
            uint256 overAmount = totalAmount - blidDepositLimit;
            userBoost.blidOverDeposit += overAmount;
            depositAmount = amount - overAmount;
        }

        userBoost.blidDeposit += depositAmount;
        totalSupplyBLID += amount;

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit DepositBLID(msg.sender, amount);
    }

    /**
     * @notice WithDraw BLID token for boosting.
     * @param amount amount of token
     */
    function withdrawBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        BoostInfo storage userBoost = userBoosts[msg.sender];
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(amount <= userBoost.blidDeposit + userBoost.blidOverDeposit, "E12");

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransfer(msg.sender, amount);

        // Adjust blidOverDeposit
        uint256 oldBlidDeposit = userBoost.blidDeposit;
        uint256 totalAmount = oldBlidDeposit + userBoost.blidOverDeposit - amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        if (totalAmount > blidDepositLimit) {
            userBoost.blidDeposit = blidDepositLimit;
            userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
        } else {
            userBoost.blidDeposit = totalAmount;
            userBoost.blidOverDeposit = 0;
        }

        totalSupplyBLID -= amount;

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit WithdrawBLID(msg.sender, amount);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     */
    function claimBoostingRewardBLID() external {
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice get deposited Boosting BLID amount of user
     * @param _user address of user
     */
    function getBoostingBLIDAmount(address _user) public view returns (uint256) {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 amount = userBoost.blidDeposit + userBoost.blidOverDeposit;
        return amount;
    }

    /*** LogicContract function ***/

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeToken(uint256 amount, address token)
        external
        isLogicContract(msg.sender)
        isUsedToken(token)
    {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 amountExp18 = amount * 10**(18 - decimals);
        IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
        tokenBalance[token] = tokenBalance[token] - amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit TakeToken(token, amountExp18);
    }

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnToken(uint256 amount, address token)
        external
        isLogicContract(msg.sender)
        isUsedToken(token)
    {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 amountExp18 = amount * 10**(18 - decimals);
        IERC20Upgradeable(token).safeTransferFrom(logicContract, address(this), amount);
        tokenBalance[token] = tokenBalance[token] + amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit ReturnToken(token, amountExp18);
    }

    /**
     * @notice Claim all BLID(from strategy and boost) for user
     */
    function claimAllRewardBLID() external {
        interestFee(msg.sender);
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice Take amount BLID from Logic contract  and distributes earned BLID
     * @param amount Amount of distributes earned BLID
     */
    function addEarn(uint256 amount) external isLogicContract(msg.sender) {
        IERC20Upgradeable(BLID).safeTransferFrom(msg.sender, address(this), amount);
        reserveBLID += amount;
        int256 _dollarTime = 0;
        uint256 countTokens_ = countTokens;
        uint256 countEarns_ = countEarns;
        EarnBLID storage thisEarnBLID = earnBLID[countEarns_];
        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);
            thisEarnBLID.rates[token] = (uint256(oracle.latestAnswer()) * 10**(18 - oracle.decimals()));

            // count all deposited token in usd
            thisEarnBLID.usd += tokenDeposited[token] * thisEarnBLID.rates[token];

            // convert token time to dollar time
            _dollarTime += tokenTime[token] * int256(thisEarnBLID.rates[token]);
        }
        require(_dollarTime != 0);
        thisEarnBLID.allBLID = amount;
        thisEarnBLID.timestamp = block.timestamp;
        thisEarnBLID.tdt = uint256(
            (int256(((block.timestamp) * thisEarnBLID.usd)) - _dollarTime) / (1 ether)
        ); // count delta of current token time and all user token time

        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            tokenTime[token] = int256(tokenDeposited[token] * block.timestamp); // count curent token time
            updateAccumulatedRewardsPerShareById(token, countEarns_);
        }
        thisEarnBLID.usd /= (1 ether);
        countEarns++;

        emit AddEarn(amount);
        emit UpdateBLIDBalance(reserveBLID);
    }

    /*** External function ***/

    /**
     * @notice Counts the number of accrued СSR
     * @param account Address of Depositor
     */
    function _upBalance(address account) external {
        deposits[account].balanceBLID = balanceEarnBLID(account);
        deposits[account].iterate = countEarns;
    }

    /***  Public View function ***/

    /**
     * @notice Return earned blid
     * @param account Address of Depositor
     */
    function balanceEarnBLID(address account) public view returns (uint256) {
        DepositStruct storage depositor = deposits[account];
        if (depositor.tokenTime[address(0)] == 0 || countEarns == 0) {
            return 0;
        }
        if (countEarns == depositor.iterate) return depositor.balanceBLID;

        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        uint256 depositorIterate = depositor.iterate;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            //if iterate when user deposited
            if (depositorIterate == depositor.depositIterate[token]) {
                sum += getEarnedInOneDepositedIterate(depositorIterate, token, account);
                sum += getEarnedInOneNotDepositedIterate(depositorIterate, token, account);
            } else {
                sum += getEarnedInOneNotDepositedIterate(depositorIterate - 1, token, account);
            }
        }

        return sum + depositor.balanceBLID;
    }

    /**
     * @notice Return usd balance of account
     * @param account Address of Depositor
     */
    function balanceOf(address account) public view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);

            sum += ((deposits[account].amount[token] *
                uint256(oracle.latestAnswer()) *
                10**(18 - oracle.decimals())) / (1 ether));
        }
        return sum;
    }

    /**
     * @notice Return sums of all distribution BLID.
     */
    function getBLIDReserve() external view returns (uint256) {
        return reserveBLID;
    }

    /**
     * @notice Return deposited usd
     */
    function getTotalDeposit() external view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);
            sum +=
                (tokenDeposited[token] * uint256(oracle.latestAnswer()) * 10**(18 - oracle.decimals())) /
                (1 ether);
        }
        return sum;
    }

    /**
     * @notice Returns the balance of token on this contract
     */
    function getTokenBalance(address token) external view returns (uint256) {
        return tokenBalance[token];
    }

    /**
     * @notice Return deposited token from account
     */
    function getTokenDeposit(address account, address token) external view returns (uint256) {
        return deposits[account].amount[token];
    }

    /**
     * @notice Return true if _token  is in token list
     * @param _token Address of Token
     */
    function _isUsedToken(address _token) external view returns (bool) {
        return tokensAdd[_token];
    }

    /**
     * @notice Return count distribution BLID token.
     */
    function getCountEarns() external view returns (uint256) {
        return countEarns;
    }

    /**
     * @notice Return data on distribution BLID token.
     * First return value is amount of distribution BLID token.
     * Second return value is a timestamp when  distribution BLID token completed.
     * Third return value is an amount of dollar depositedhen  distribution BLID token completed.
     */
    function getEarnsByID(uint256 id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (earnBLID[id].allBLID, earnBLID[id].timestamp, earnBLID[id].usd);
    }

    /**
     * @notice Return amount of all deposited token
     * @param token Address of Token
     */
    function getTokenDeposited(address token) external view returns (uint256) {
        return tokenDeposited[token];
    }

    /**
     * @notice Return pending BLID amount for boost to see on frontend
     * @param _user address of user
     */

    function getBoostingClaimableBLID(address _user) external view returns (uint256) {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 _accBLIDpershare = accBlidPerShare;
        if (block.number > lastRewardBlock) {
            uint256 passedblockcount = block.number - lastRewardBlock + 1; // When claim 1 block is added because of mining
            _accBLIDpershare = accBlidPerShare + (passedblockcount * blidPerBlock);
        }
        uint256 calcAmount = (userBoost.blidDeposit * _accBLIDpershare) / 1e18;
        return calcAmount > userBoost.rewardDebt ? calcAmount - userBoost.rewardDebt : 0;
    }

    /*** Private Function ***/

    /**
     * @notice deposit token
     * @param amount Amount of deposit token
     * @param token Address of token
     * @param accountAddress Address of depositor
     */
    function depositInternal(
        uint256 amount,
        address token,
        address accountAddress
    ) internal {
        require(amount > 0, "E3");
        uint8 decimals = AggregatorV3Interface(token).decimals();
        DepositStruct storage depositor = deposits[accountAddress];
        IERC20Upgradeable(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 amountExp18 = amount * 10**(18 - decimals);
        if (depositor.tokenTime[address(0)] == 0) {
            depositor.iterate = countEarns;
            depositor.depositIterate[token] = countEarns;
            depositor.tokenTime[address(0)] = 1;
            depositor.tokenTime[token] += int256(block.timestamp * (amountExp18));
        } else {
            interestFee(accountAddress);
            if (depositor.depositIterate[token] == countEarns) {
                depositor.tokenTime[token] += int256(block.timestamp * (amountExp18));
            } else {
                depositor.tokenTime[token] = int256(
                    depositor.amount[token] *
                        earnBLID[countEarns - 1].timestamp +
                        block.timestamp *
                        (amountExp18)
                );

                depositor.depositIterate[token] = countEarns;
            }
        }
        depositor.amount[token] += amountExp18;

        tokenTime[token] += int256(block.timestamp * (amountExp18));
        tokenBalance[token] += amountExp18;
        tokenDeposited[token] += amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(accountAddress, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Deposit(accountAddress, token, amountExp18);
    }

    // Safe blid transfer function, just in case if rounding error causes pool to not have enough BLIDs.
    function safeBlidTransfer(address _to, uint256 _amount) internal {
        IERC20Upgradeable(BLID).safeTransferFrom(boostingAddress, _to, _amount);
    }

    /**
     * @notice Count accumulatedRewardsPerShare
     * @param token Address of Token
     * @param id of accumulatedRewardsPerShare
     */
    function updateAccumulatedRewardsPerShareById(address token, uint256 id) private {
        EarnBLID storage thisEarnBLID = earnBLID[id];
        //unchecked is used because if id = 0 then  accumulatedRewardsPerShare[token][id-1] equal zero
        unchecked {
            accumulatedRewardsPerShare[token][id] =
                accumulatedRewardsPerShare[token][id - 1] +
                ((thisEarnBLID.allBLID *
                    (thisEarnBLID.timestamp - earnBLID[id - 1].timestamp) *
                    thisEarnBLID.rates[token]) / thisEarnBLID.tdt);
        }
    }

    /**
     * @notice Count user rewards in one iterate, when he  deposited
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        EarnBLID storage thisEarnBLID = earnBLID[depositIterate];
        DepositStruct storage thisDepositor = deposits[account];
        return
            (// all distibution BLID multiply to
            thisEarnBLID.allBLID *
                // delta of  user dollar time and user dollar time if user deposited in at the beginning distibution
                uint256(
                    int256(thisDepositor.amount[token] * thisEarnBLID.rates[token] * thisEarnBLID.timestamp) -
                        thisDepositor.tokenTime[token] *
                        int256(thisEarnBLID.rates[token])
                )) /
            //div to delta of all users dollar time and all users dollar time if all users deposited in at the beginning distibution
            thisEarnBLID.tdt /
            (1 ether);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     * @param userAccount address of account
     * @param isAdjust true : adjust userBoost.blidDeposit, false : not update userBoost.blidDeposit
     */
    function _claimBoostingRewardBLIDInternal(address userAccount, bool isAdjust) private {
        _boostingUpdateAccBlidPerShare();
        BoostInfo storage userBoost = userBoosts[userAccount];
        uint256 calcAmount;
        if (userBoost.blidDeposit > 0) {
            calcAmount = (userBoost.blidDeposit * accBlidPerShare) / 1e18;
            if (calcAmount > userBoost.rewardDebt) {
                calcAmount -= userBoost.rewardDebt;
                safeBlidTransfer(userAccount, calcAmount);
            }
        }

        // Adjust blidDeposit
        if (isAdjust) {
            uint256 usdDepositAmount = balanceOf(userAccount);
            uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
            uint256 totalAmount = userBoost.blidDeposit + userBoost.blidOverDeposit;

            // Update boosting info
            if (totalAmount > blidDepositLimit) {
                userBoost.blidDeposit = blidDepositLimit;
                userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
            } else {
                userBoost.blidDeposit = totalAmount;
                userBoost.blidOverDeposit = 0;
            }

            // Update rewards debt
            userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;
        }

        emit ClaimBoostBLID(userAccount, calcAmount);
    }

    /**
     * @notice update Accumulated BLID per share
     */
    function _boostingUpdateAccBlidPerShare() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }

        uint256 passedblockcount = block.number - lastRewardBlock;
        accBlidPerShare = accBlidPerShare + (passedblockcount * blidPerBlock);
        lastRewardBlock = block.number;
    }

    /*** Private View Function ***/

    /**
     * @notice Count user rewards in one iterate, when he was not deposit
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneNotDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        return
            ((accumulatedRewardsPerShare[token][countEarns - 1] -
                accumulatedRewardsPerShare[token][depositIterate]) * deposits[account].amount[token]) /
            (1 ether);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface ILogicContract {
    function returnToken(uint256 amount, address token) external;
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256 answer);
}

contract StorageV21 is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    //struct
    struct DepositStruct {
        mapping(address => uint256) amount;
        mapping(address => int256) tokenTime;
        uint256 iterate;
        uint256 balanceBLID;
        mapping(address => uint256) depositIterate;
    }

    struct EarnBLID {
        uint256 allBLID;
        uint256 timestamp;
        uint256 usd;
        uint256 tdt;
        mapping(address => uint256) rates;
    }

    struct BoostInfo {
        uint256 blidDeposit;
        uint256 rewardDebt;
        uint256 blidOverDeposit;
    }

    /*** events ***/

    event Deposit(address depositor, address token, uint256 amount);
    event Withdraw(address depositor, address token, uint256 amount);
    event UpdateTokenBalance(uint256 balance, address token);
    event TakeToken(address token, uint256 amount);
    event ReturnToken(address token, uint256 amount);
    event AddEarn(uint256 amount);
    event UpdateBLIDBalance(uint256 balance);
    event InterestFee(address depositor, uint256 amount);
    event SetBLID(address blid);
    event AddToken(address token, address oracle);
    event SetLogic(address logic);
    event SetBoostInfo(uint256 maxBlidPerUSD, uint256 blidPerBlock);
    event DepositBLID(address depositor, uint256 amount);
    event WithdrawBLID(address depositor, uint256 amount);
    event ClaimBoostBLID(address depositor, uint256 amount);
    event SetBoostingAddress(address boostingAddress);
    event SetAdmin(address admin);
    event UpgradeVersion(string version, string purpose);

    function initialize(address _logicContract) external initializer {
        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
        logicContract = _logicContract;
    }

    mapping(uint256 => EarnBLID) private earnBLID;
    uint256 private countEarns;
    uint256 private countTokens;
    mapping(uint256 => address) private tokens;
    mapping(address => uint256) private tokenBalance;
    mapping(address => address) private oracles;
    mapping(address => bool) private tokensAdd;
    mapping(address => DepositStruct) private deposits;
    mapping(address => uint256) private tokenDeposited;
    mapping(address => int256) private tokenTime;
    uint256 private reserveBLID;
    address private logicContract;
    address private BLID;
    mapping(address => mapping(uint256 => uint256)) public accumulatedRewardsPerShare;

    // ****** Add from V21 ******

    // Boost2.0
    mapping(address => BoostInfo) private userBoosts;
    uint256 public maxBlidPerUSD;
    uint256 public blidPerBlock;
    uint256 public initBlidPerBlock;
    uint256 public accBlidPerShare;
    uint256 public lastRewardBlock;
    address public boostingAddress;
    uint256 public totalSupplyBLID;

    /*** modifiers ***/

    modifier isUsedToken(address _token) {
        require(tokensAdd[_token], "E1");
        _;
    }

    modifier isLogicContract(address account) {
        require(logicContract == account, "E2");
        _;
    }

    /*** Owner functions ***/

    /**
     * @notice Set blid in contract
     * @param _blid address of BLID
     */
    function setBLID(address _blid) external onlyOwner {
        BLID = _blid;

        emit SetBLID(_blid);
    }

    /**
     * @notice Set blid in contract
     * @param _boostingAddress address of expense
     */
    function setBoostingAddress(address _boostingAddress) external onlyOwner {
        boostingAddress = _boostingAddress;

        emit SetBoostingAddress(boostingAddress);
    }

    /**
     * @notice Set boosting parameters
     * @param _maxBlidperUSD max value of BLID per USD
     * @param _blidperBlock blid per Block
     */
    function setBoostingInfo(uint256 _maxBlidperUSD, uint256 _blidperBlock) external onlyOwner {
        _boostingUpdateAccBlidPerShare();

        maxBlidPerUSD = _maxBlidperUSD;
        blidPerBlock = _blidperBlock;
        initBlidPerBlock = _blidperBlock;

        emit SetBoostInfo(_maxBlidperUSD, _blidperBlock);
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Update AccumulatedRewardsPerShare for token, using once after update contract
     * @param token Address of token
     */
    function updateAccumulatedRewardsPerShare(address token) external onlyOwner {
        require(accumulatedRewardsPerShare[token][0] == 0, "E7");
        uint256 countEarns_ = countEarns;
        for (uint256 i = 0; i < countEarns_; i++) {
            updateAccumulatedRewardsPerShareById(token, i);
        }
    }

    /**
     * @notice Add token and token's oracle
     * @param _token Address of Token
     * @param _oracles Address of token's oracle(https://docs.chain.link/docs/binance-smart-chain-addresses/
     */
    function addToken(address _token, address _oracles) external onlyOwner {
        require(_token != address(0) && _oracles != address(0));
        require(!tokensAdd[_token], "E6");
        oracles[_token] = _oracles;
        tokens[countTokens++] = _token;
        tokensAdd[_token] = true;

        emit AddToken(_token, _oracles);
    }

    /**
     * @notice Set logic in contract(only for upgradebale contract,use only whith DAO)
     * @param _logic Address of Logic Contract
     */
    function setLogic(address _logic) external onlyOwner {
        logicContract = _logic;

        emit SetLogic(_logic);
    }

    /*** User functions ***/

    /**
     * @notice Deposit amount of token for msg.sender
     * @param amount amount of token
     * @param token address of token
     */
    function deposit(uint256 amount, address token) external payable isUsedToken(token) whenNotPaused {
        depositInternal(amount, token, msg.sender);
    }

    /**
     * @notice Deposit amount of token on behalf of depositor wallet
     * @param amount amount of token
     * @param token address of token
     * @param accountAddress Address of depositor
     */
    function depositOnBehalf(
        uint256 amount,
        address token,
        address accountAddress
    ) external payable isUsedToken(token) whenNotPaused {
        depositInternal(amount, token, accountAddress);
    }

    /**
     * @notice Withdraw amount of token  from Strategy and receiving earned tokens.
     * @param amount Amount of token
     * @param token Address of token
     */
    function withdraw(uint256 amount, address token) external isUsedToken(token) whenNotPaused {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 countEarns_ = countEarns;
        uint256 amountExp18 = amount * 10**(18 - decimals);
        DepositStruct storage depositor = deposits[msg.sender];
        require(depositor.amount[token] >= amountExp18 && amount > 0, "E4");
        if (amountExp18 > tokenBalance[token]) {
            ILogicContract(logicContract).returnToken(amount, token);
            interestFee(msg.sender);
            IERC20Upgradeable(token).safeTransferFrom(logicContract, msg.sender, amount);
            tokenDeposited[token] -= amountExp18;
            tokenTime[token] -= int256(block.timestamp * (amountExp18));
        } else {
            interestFee(msg.sender);
            IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
            tokenTime[token] -= int256(block.timestamp * (amountExp18));

            tokenBalance[token] -= amountExp18;
            tokenDeposited[token] -= amountExp18;
        }
        if (depositor.depositIterate[token] == countEarns_) {
            depositor.tokenTime[token] -= int256(block.timestamp * (amountExp18));
        } else {
            depositor.tokenTime[token] =
                int256(depositor.amount[token] * earnBLID[countEarns_ - 1].timestamp) -
                int256(block.timestamp * (amountExp18));
            depositor.depositIterate[token] = countEarns_;
        }
        depositor.amount[token] -= amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(msg.sender, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Withdraw(msg.sender, token, amountExp18);
    }

    /**
     * @notice Claim BLID to accountAddress
     * @param accountAddress account address for claim
     */
    function interestFee(address accountAddress) public {
        uint256 balanceUser = balanceEarnBLID(accountAddress);
        require(reserveBLID >= balanceUser, "E5");
        IERC20Upgradeable(BLID).safeTransfer(accountAddress, balanceUser);
        DepositStruct storage depositor = deposits[accountAddress];
        depositor.balanceBLID = balanceUser;
        depositor.iterate = countEarns;
        //unchecked is used because a check was made in require
        unchecked {
            depositor.balanceBLID = 0;
            reserveBLID -= balanceUser;
        }

        emit UpdateBLIDBalance(reserveBLID);
        emit InterestFee(accountAddress, balanceUser);
    }

    /*** Boosting User function ***/

    /**
     * @notice Deposit BLID token for boosting.
     * @param amount amount of token
     */
    function depositBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(usdDepositAmount > 0, "E11");

        BoostInfo storage userBoost = userBoosts[msg.sender];

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransferFrom(msg.sender, address(this), amount);

        // Adjust blidOverDeposit
        uint256 totalAmount = userBoost.blidDeposit + amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        uint256 depositAmount = amount;
        if (totalAmount > blidDepositLimit) {
            uint256 overAmount = totalAmount - blidDepositLimit;
            userBoost.blidOverDeposit += overAmount;
            depositAmount = amount - overAmount;
        }

        userBoost.blidDeposit += depositAmount;
        totalSupplyBLID += amount;

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit DepositBLID(msg.sender, amount);
    }

    /**
     * @notice WithDraw BLID token for boosting.
     * @param amount amount of token
     */
    function withdrawBLID(uint256 amount) external whenNotPaused {
        require(amount > 0, "E3");
        BoostInfo storage userBoost = userBoosts[msg.sender];
        uint256 usdDepositAmount = balanceOf(msg.sender);
        require(amount <= userBoost.blidDeposit + userBoost.blidOverDeposit, "E12");

        _claimBoostingRewardBLIDInternal(msg.sender, false);
        IERC20Upgradeable(BLID).safeTransfer(msg.sender, amount);

        // Adjust blidOverDeposit
        uint256 oldBlidDeposit = userBoost.blidDeposit;
        uint256 totalAmount = oldBlidDeposit + userBoost.blidOverDeposit - amount;
        uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
        if (totalAmount > blidDepositLimit) {
            userBoost.blidDeposit = blidDepositLimit;
            userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
        } else {
            userBoost.blidDeposit = totalAmount;
            userBoost.blidOverDeposit = 0;
        }

        totalSupplyBLID -= amount;

        // Save rewardDebt
        userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;

        emit WithdrawBLID(msg.sender, amount);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     */
    function claimBoostingRewardBLID() external {
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice get deposited Boosting BLID amount of user
     * @param _user address of user
     */
    function getBoostingBLIDAmount(address _user) public view returns (uint256) {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 amount = userBoost.blidDeposit + userBoost.blidOverDeposit;
        return amount;
    }

    /*** LogicContract function ***/

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function takeToken(uint256 amount, address token)
        external
        isLogicContract(msg.sender)
        isUsedToken(token)
    {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 amountExp18 = amount * 10**(18 - decimals);
        IERC20Upgradeable(token).safeTransfer(msg.sender, amount);
        tokenBalance[token] = tokenBalance[token] - amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit TakeToken(token, amountExp18);
    }

    /**
     * @notice Transfer amount of token from Storage to Logic Contract.
     * @param amount Amount of token
     * @param token Address of token
     */
    function returnToken(uint256 amount, address token)
        external
        isLogicContract(msg.sender)
        isUsedToken(token)
    {
        uint8 decimals = AggregatorV3Interface(token).decimals();
        uint256 amountExp18 = amount * 10**(18 - decimals);
        IERC20Upgradeable(token).safeTransferFrom(logicContract, address(this), amount);
        tokenBalance[token] = tokenBalance[token] + amountExp18;

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit ReturnToken(token, amountExp18);
    }

    /**
     * @notice Claim all BLID(from strategy and boost) for user
     */
    function claimAllRewardBLID() external {
        interestFee(msg.sender);
        _claimBoostingRewardBLIDInternal(msg.sender, true);
    }

    /**
     * @notice Take amount BLID from Logic contract  and distributes earned BLID
     * @param amount Amount of distributes earned BLID
     */
    function addEarn(uint256 amount) external isLogicContract(msg.sender) {
        IERC20Upgradeable(BLID).safeTransferFrom(msg.sender, address(this), amount);
        reserveBLID += amount;
        int256 _dollarTime = 0;
        uint256 countTokens_ = countTokens;
        uint256 countEarns_ = countEarns;
        EarnBLID storage thisEarnBLID = earnBLID[countEarns_];
        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);
            thisEarnBLID.rates[token] = (uint256(oracle.latestAnswer()) * 10**(18 - oracle.decimals()));

            // count all deposited token in usd
            thisEarnBLID.usd += tokenDeposited[token] * thisEarnBLID.rates[token];

            // convert token time to dollar time
            _dollarTime += tokenTime[token] * int256(thisEarnBLID.rates[token]);
        }
        require(_dollarTime != 0);
        thisEarnBLID.allBLID = amount;
        thisEarnBLID.timestamp = block.timestamp;
        thisEarnBLID.tdt = uint256(
            (int256(((block.timestamp) * thisEarnBLID.usd)) - _dollarTime) / (1 ether)
        ); // count delta of current token time and all user token time

        for (uint256 i = 0; i < countTokens_; i++) {
            address token = tokens[i];
            tokenTime[token] = int256(tokenDeposited[token] * block.timestamp); // count curent token time
            updateAccumulatedRewardsPerShareById(token, countEarns_);
        }
        thisEarnBLID.usd /= (1 ether);
        countEarns++;

        emit AddEarn(amount);
        emit UpdateBLIDBalance(reserveBLID);
    }

    /*** External function ***/

    /**
     * @notice Counts the number of accrued СSR
     * @param account Address of Depositor
     */
    function _upBalance(address account) external {
        deposits[account].balanceBLID = balanceEarnBLID(account);
        deposits[account].iterate = countEarns;
    }

    /***  Public View function ***/

    /**
     * @notice Return earned blid
     * @param account Address of Depositor
     */
    function balanceEarnBLID(address account) public view returns (uint256) {
        DepositStruct storage depositor = deposits[account];
        if (depositor.tokenTime[address(0)] == 0 || countEarns == 0) {
            return 0;
        }
        if (countEarns == depositor.iterate) return depositor.balanceBLID;

        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        uint256 depositorIterate = depositor.iterate;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            //if iterate when user deposited
            if (depositorIterate == depositor.depositIterate[token]) {
                sum += getEarnedInOneDepositedIterate(depositorIterate, token, account);
                sum += getEarnedInOneNotDepositedIterate(depositorIterate, token, account);
            } else {
                sum += getEarnedInOneNotDepositedIterate(depositorIterate - 1, token, account);
            }
        }

        return sum + depositor.balanceBLID;
    }

    /**
     * @notice Return usd balance of account
     * @param account Address of Depositor
     */
    function balanceOf(address account) public view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);

            sum += ((deposits[account].amount[token] *
                uint256(oracle.latestAnswer()) *
                10**(18 - oracle.decimals())) / (1 ether));
        }
        return sum;
    }

    /**
     * @notice Return sums of all distribution BLID.
     */
    function getBLIDReserve() external view returns (uint256) {
        return reserveBLID;
    }

    /**
     * @notice Return deposited usd
     */
    function getTotalDeposit() external view returns (uint256) {
        uint256 countTokens_ = countTokens;
        uint256 sum = 0;
        for (uint256 j = 0; j < countTokens_; j++) {
            address token = tokens[j];
            AggregatorV3Interface oracle = AggregatorV3Interface(oracles[token]);
            sum +=
                (tokenDeposited[token] * uint256(oracle.latestAnswer()) * 10**(18 - oracle.decimals())) /
                (1 ether);
        }
        return sum;
    }

    /**
     * @notice Returns the balance of token on this contract
     */
    function getTokenBalance(address token) external view returns (uint256) {
        return tokenBalance[token];
    }

    /**
     * @notice Return deposited token from account
     */
    function getTokenDeposit(address account, address token) external view returns (uint256) {
        return deposits[account].amount[token];
    }

    /**
     * @notice Return true if _token  is in token list
     * @param _token Address of Token
     */
    function _isUsedToken(address _token) external view returns (bool) {
        return tokensAdd[_token];
    }

    /**
     * @notice Return count distribution BLID token.
     */
    function getCountEarns() external view returns (uint256) {
        return countEarns;
    }

    /**
     * @notice Return data on distribution BLID token.
     * First return value is amount of distribution BLID token.
     * Second return value is a timestamp when  distribution BLID token completed.
     * Third return value is an amount of dollar depositedhen  distribution BLID token completed.
     */
    function getEarnsByID(uint256 id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (earnBLID[id].allBLID, earnBLID[id].timestamp, earnBLID[id].usd);
    }

    /**
     * @notice Return amount of all deposited token
     * @param token Address of Token
     */
    function getTokenDeposited(address token) external view returns (uint256) {
        return tokenDeposited[token];
    }

    /**
     * @notice Return pending BLID amount for boost to see on frontend
     * @param _user address of user
     */

    function getBoostingClaimableBLID(address _user) external view returns (uint256) {
        BoostInfo storage userBoost = userBoosts[_user];
        uint256 _accBLIDpershare = accBlidPerShare;
        if (block.number > lastRewardBlock) {
            uint256 passedblockcount = block.number - lastRewardBlock + 1; // When claim 1 block is added because of mining
            _accBLIDpershare = accBlidPerShare + (passedblockcount * blidPerBlock);
        }
        uint256 calcAmount = (userBoost.blidDeposit * _accBLIDpershare) / 1e18;
        return calcAmount > userBoost.rewardDebt ? calcAmount - userBoost.rewardDebt : 0;
    }

    /*** Private Function ***/

    /**
     * @notice deposit token
     * @param amount Amount of deposit token
     * @param token Address of token
     * @param accountAddress Address of depositor
     */
    function depositInternal(
        uint256 amount,
        address token,
        address accountAddress
    ) internal {
        require(amount > 0, "E3");
        uint8 decimals = AggregatorV3Interface(token).decimals();
        DepositStruct storage depositor = deposits[accountAddress];
        IERC20Upgradeable(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 amountExp18 = amount * 10**(18 - decimals);
        if (depositor.tokenTime[address(0)] == 0) {
            depositor.iterate = countEarns;
            depositor.depositIterate[token] = countEarns;
            depositor.tokenTime[address(0)] = 1;
            depositor.tokenTime[token] += int256(block.timestamp * (amountExp18));
        } else {
            interestFee(accountAddress);
            if (depositor.depositIterate[token] == countEarns) {
                depositor.tokenTime[token] += int256(block.timestamp * (amountExp18));
            } else {
                depositor.tokenTime[token] = int256(
                    depositor.amount[token] *
                        earnBLID[countEarns - 1].timestamp +
                        block.timestamp *
                        (amountExp18)
                );

                depositor.depositIterate[token] = countEarns;
            }
        }
        depositor.amount[token] += amountExp18;

        tokenTime[token] += int256(block.timestamp * (amountExp18));
        tokenBalance[token] += amountExp18;
        tokenDeposited[token] += amountExp18;

        // Claim BoostingRewardBLID
        _claimBoostingRewardBLIDInternal(accountAddress, true);

        emit UpdateTokenBalance(tokenBalance[token], token);
        emit Deposit(accountAddress, token, amountExp18);
    }

    // Safe blid transfer function, just in case if rounding error causes pool to not have enough BLIDs.
    function safeBlidTransfer(address _to, uint256 _amount) internal {
        IERC20Upgradeable(BLID).safeTransferFrom(boostingAddress, _to, _amount);
    }

    /**
     * @notice Count accumulatedRewardsPerShare
     * @param token Address of Token
     * @param id of accumulatedRewardsPerShare
     */
    function updateAccumulatedRewardsPerShareById(address token, uint256 id) private {
        EarnBLID storage thisEarnBLID = earnBLID[id];
        //unchecked is used because if id = 0 then  accumulatedRewardsPerShare[token][id-1] equal zero
        unchecked {
            accumulatedRewardsPerShare[token][id] =
                accumulatedRewardsPerShare[token][id - 1] +
                ((thisEarnBLID.allBLID *
                    (thisEarnBLID.timestamp - earnBLID[id - 1].timestamp) *
                    thisEarnBLID.rates[token]) / thisEarnBLID.tdt);
        }
    }

    /**
     * @notice Count user rewards in one iterate, when he  deposited
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        EarnBLID storage thisEarnBLID = earnBLID[depositIterate];
        DepositStruct storage thisDepositor = deposits[account];
        return
            (// all distibution BLID multiply to
            thisEarnBLID.allBLID *
                // delta of  user dollar time and user dollar time if user deposited in at the beginning distibution
                uint256(
                    int256(thisDepositor.amount[token] * thisEarnBLID.rates[token] * thisEarnBLID.timestamp) -
                        thisDepositor.tokenTime[token] *
                        int256(thisEarnBLID.rates[token])
                )) /
            //div to delta of all users dollar time and all users dollar time if all users deposited in at the beginning distibution
            thisEarnBLID.tdt /
            (1 ether);
    }

    /**
     * @notice Claim Boosting Reward BLID to msg.sender
     * @param userAccount address of account
     * @param isAdjust true : adjust userBoost.blidDeposit, false : not update userBoost.blidDeposit
     */
    function _claimBoostingRewardBLIDInternal(address userAccount, bool isAdjust) private {
        _boostingUpdateAccBlidPerShare();
        BoostInfo storage userBoost = userBoosts[userAccount];
        uint256 calcAmount;
        if (userBoost.blidDeposit > 0) {
            calcAmount = (userBoost.blidDeposit * accBlidPerShare) / 1e18;
            if (calcAmount > userBoost.rewardDebt) {
                calcAmount -= userBoost.rewardDebt;
                safeBlidTransfer(userAccount, calcAmount);
            }
        }

        // Adjust blidDeposit
        if (isAdjust) {
            uint256 usdDepositAmount = balanceOf(userAccount);
            uint256 blidDepositLimit = (usdDepositAmount * maxBlidPerUSD) / 1e18;
            uint256 totalAmount = userBoost.blidDeposit + userBoost.blidOverDeposit;

            // Update boosting info
            if (totalAmount > blidDepositLimit) {
                userBoost.blidDeposit = blidDepositLimit;
                userBoost.blidOverDeposit = totalAmount - blidDepositLimit;
            } else {
                userBoost.blidDeposit = totalAmount;
                userBoost.blidOverDeposit = 0;
            }

            // Update rewards debt
            userBoost.rewardDebt = (userBoost.blidDeposit * accBlidPerShare) / 1e18;
        }

        emit ClaimBoostBLID(userAccount, calcAmount);
    }

    /**
     * @notice update Accumulated BLID per share
     */
    function _boostingUpdateAccBlidPerShare() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }

        uint256 passedblockcount = block.number - lastRewardBlock;
        accBlidPerShare = accBlidPerShare + (passedblockcount * blidPerBlock);
        lastRewardBlock = block.number;
    }

    /*** Private View Function ***/

    /**
     * @notice Count user rewards in one iterate, when he was not deposit
     * @param token Address of Token
     * @param depositIterate iterate when deposit happened
     * @param account Address of Depositor
     */
    function getEarnedInOneNotDepositedIterate(
        uint256 depositIterate,
        address token,
        address account
    ) private view returns (uint256) {
        return
            ((accumulatedRewardsPerShare[token][countEarns - 1] -
                accumulatedRewardsPerShare[token][depositIterate]) * deposits[account].amount[token]) /
            (1 ether);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Migrations {
    address public owner = msg.sender;

    // A function with the signature `last_completed_migration()`, returning a uint, is required.
    uint256 public last_completed_migration;

    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    // A function with the signature `setCompleted(uint)` is required.
    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract Aggregator {
    function decimals() external pure returns (uint8) {
        return 8;
    }

    function latestAnswer() external pure returns (int256 answer) {
        return 99997069;
    }
}

contract AggregatorN3 {
    uint8 _decimals;
    int256 _latestAnswer;

    constructor() public {
        _decimals = 8;
        _latestAnswer = 100000000;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function latestAnswer() external view returns (int256 answer) {
        return _latestAnswer;
    }

    function updateRate(uint8 newDecimals, int256 newLatestAnswer) external {
        _decimals = newDecimals;
        _latestAnswer = newLatestAnswer;
    }
}

contract AggregatorN2 {
    function decimals() external pure returns (uint8) {
        return 8;
    }

    function latestAnswer() external pure returns (int256 answer) {
        return 99997069 * 2;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract VenusCompotroller {
    function enterMarkets(address[] calldata xTokens)
        external
        returns (uint256[] memory)
    {
        uint256[] memory results = new uint256[](1);
        results[0] = 1;

        return results;
    }

    function markets(address cTokenAddress)
        external
        view
        returns (
            bool,
            uint256,
            bool
        )
    {
        return (true, 100, true);
    }
}