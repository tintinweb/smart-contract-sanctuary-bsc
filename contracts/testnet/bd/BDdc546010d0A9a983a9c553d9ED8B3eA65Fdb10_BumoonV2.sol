// SPDX-License-Identifier: MIT

//                 .................
//             ...::^~~!!777777!!~~^::...
//          ...:~!777777777777777???77!~:...
//       ...:^!7777777777G&&P7777777777?77~:...
//      ..:[email protected]@@@?777777777777?7~:..
//    ...^[email protected]@@@?77777777777777?7^...            :777777777!~.      :!777:          ^777!.    ~777^         :777!.                                       ~777!:        :!777^
//   ...~!!!!!!!!!B&@@@@@@@@@@@@&&B57777777777?!...           [email protected]@@@@@@@@@@@&Y.   [email protected]@@@#         :&@@@@P   [email protected]@@@@Y       [email protected]@@@@5                                      [email protected]@@@@@?       [email protected]@@@&.
//  ...~!!!!!!!!!7&@@@@@@@@@@@@@@@@@@57777777777!...          [email protected]@@@@@@@@@@@@@#.  [email protected]@@@#         :&@@@@P   [email protected]@@@@@P     [email protected]@@@@@#.                                     [email protected]@@@@@@G.     [email protected]@@@&.
// ...^[email protected]@@@Y7777777777~...         [email protected]@@@B. [email protected]@@@@?  [email protected]@@@#         :&@@@@P  .&@@@@@@@G.  [email protected]@@@@@@@^      .^!77!~:          .^!77!~:     [email protected]@@@@@@@&!    [email protected]@@@&.
// ..:~~~~~~~~!!!!~~~~~~~~~~!!!!!!&@@@G!7777777777:..         [email protected]@@@B.  [email protected]@@@@~  [email protected]@@@#         :&@@@@P  [email protected]@@@@@@@@#^[email protected]@@@@@@@@?   .Y&@@@@@@@@@B!    :5&@@@@@@@@&G~  [email protected]@@@@@@@@@5.  [email protected]@@@&.
// ..^~~~~~~~~~~~~?5PPPPPPPPPPPPG&@@@@?!7777777777^..         [email protected]@@@@@@@@@@@@@P   [email protected]@@@#         :&@@@@P  [email protected]@@@@&@@@@@@@@@@&@@@@G  [email protected]@@@@@@@@@@@@@#: [email protected]@@@@@@@@@@@@@[email protected]@@@@[email protected]@@@@#^ [email protected]@@@&.
// ..^[email protected]@@@@@@@@@@@@@@@@@@?!!!777777777~..         [email protected]@@@@@@@@@@@@@@B^ [email protected]@@@#         :&@@@@P  [email protected]@@@#~#@@@@@@@&[email protected]@@@&:[email protected]@@@@P:. .!&@@@@#[email protected]@@@@Y:...7&@@@@[email protected]@@@@?^#@@@@@[email protected]@@@&.
// ..:[email protected]@@@&7!!!!!!77777^..         [email protected]@@@&[email protected]@@@@&[email protected]@@@&.        :&@@@@P :&@@@@P [email protected]@@@@&^ [email protected]@@@@[email protected]@@@B      ^@@@@@&@@@@P      [email protected]@@@@[email protected]@@@@? [email protected]@@@@&@@@@&.
// ..:^^^~~~~~~~~~~^^^^~~~~~~~~~~!&@@@P~!!!!!!!!!7:..         [email protected]@@@B      [email protected]@@@@[email protected]@@@@!        [email protected]@@@@? [email protected]@@@@?  [email protected]@@#:  [email protected]@@@@[email protected]@@@B      ^@@@@@@@@@@5      [email protected]@@@@[email protected]@@@@?   !&@@@@@@@@&.
// ...^^^^^^^~~~~~^[email protected]@@@Y~!!!!!!!!7~...         [email protected]@@@B:...:!#@@@@@7:&@@@@&J.    :[email protected]@@@@#. [email protected]@@@@^    J#P.   .&@@@@[email protected]@@@@Y.   ^#@@@@&[email protected]@@@@?.   ~&@@@@[email protected]@@@@?    [email protected]@@@@@@&.
//  ...^^^^^^^^^^[email protected]@@@@@@@@@@@@@@@@@P~!!!!!!!!!~...          [email protected]@@@@@@@@@@@@@@@P  ^&@@@@@@&&&@@@@@@@#: .&@@@@#.            [email protected]@@@@[email protected]@@@@@&&&@@@@@&^[email protected]@@@@@&&@@@@@@#:[email protected]@@@@?      [email protected]@@@@@&.
//   ...^^^^^^^^^[email protected]@@@@@@@@@@@@@&#P7~~~!!!!!!!~...           [email protected]@@@@@@@@@@@@&G^     7#@@@@@@@@@@@@B7   [email protected]@@@@5             [email protected]@@@@? ^P&@@@@@@@@@#?.   [email protected]@@@@@@@@@#7  [email protected]@@@@7       :[email protected]@@@&.
//    ...:^^^^^^^^^[email protected]@@@7!!!~~~~~~~~~~!!!^...            :!!!!!!!!!!!^:          .^7JYYYYJ7^.      ^!!!~.              ^!!!~.    :!?JYJ?~.        .^7JJJJ7~.     ^!!!~          ^!!!:
//     ....:^^^^^^^^^^^^[email protected]@@@!^~~~~~~~~~~~~~^:...
//       ....::^^^^^^^^^^P&&5^^^~~~~~~~~~~^:...
//         ....:::^^^^^^^:^^^^^^^^~~~~^^:...
//            .....:::::^^^^^^^^^^::::....
//                 ..................

// 2022 BUMooN.io - V2 Contracts

// BUMooN V2 Main Contracts

pragma solidity ^0.8.14;

import "../dependencies/ERC20.sol";

contract BumoonV2 is IERC20, ERC20 {
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Only EOA");
        _;
    }

    modifier onlyOperator() {
        require(_msgSender() == crossOperator, "Caller is not verified");
        _;
    }

    //EVENTS
    event CrossIn(address indexed to, uint256 amount);
    event CrossOut(address indexed from, uint256 amount);
    event Migrate(uint256 amountIn, uint256 amountOut);

    //VARIABLE
    uint256 public taxSell = 10;
    uint256 public taxBuy = 5;
    address public crossOperator;
    uint256 public migrateDueDate = 1653035841;

    constructor() ERC20("BUMooN", "BOO", 18, 1 * 10**9) {
        _mint(owner(), 1 * 10e9 * 10e9);
        approve(address(this), 1 * 10e9 * 10e9);
    }

    function migrateFromV1(address contractAddr) external onlyEOA {
        require(block.timestamp < migrateDueDate, "Migration closed");
        uint256 balanceAmount = IERC20(contractAddr).balanceOf(_msgSender());
        uint256 allowance = IERC20(contractAddr).allowance(
            _msgSender(),
            address(this)
        );
        require(balanceAmount > 0, "Balance must be greater than 0");
        require(
            allowance >= balanceAmount,
            "transfer amounts are greater than allowance"
        );
        _doMigrate(balanceAmount, contractAddr);
    }

    function _doMigrate(uint256 balanceAmount, address contractAddr) private {
        IERC20(contractAddr).transferFrom(_msgSender(), owner(), balanceAmount);
        uint256 amountOut = (balanceAmount / (1 * 10e6 * 1e9));
        transferFrom(owner(), _msgSender(), amountOut);
        emit Migrate(balanceAmount, amountOut);
    }

    function setMigrateDueDate(uint256 date) external onlyOwner {
        migrateDueDate = date;
    }

    function setOperator(address operator) external onlyOwner {
        crossOperator = operator;
    }

    function rescueCoin() external onlyOwner {
        require(address(this).balance > 0, "Zero Balance");
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueToken(address contractAddr) external onlyOwner {
        uint256 balanceAmount = IERC20(contractAddr).balanceOf(address(this));
        require(balanceAmount > 0, "Balance must be greater than 0");
        IERC20(contractAddr).transfer(_msgSender(), balanceAmount);
    }

    function crossIn(uint256 amount, address account) external onlyOperator {
        require(amount > 0, "Balance must be greater than 0");
        _mint(account, amount);
        emit CrossIn(account, amount);
    }

    function crossOut(uint256 amount) external onlyOperator {
        require(amount > 0, "Balance must be greater than 0");
        _burn(_msgSender(), amount);
        emit CrossOut(_msgSender(), amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

pragma solidity ^0.8.6;

import "../dependencies/Ownable.sol";

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
    }

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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