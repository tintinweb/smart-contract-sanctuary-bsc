/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(
            c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256),
            "mul: invalid with MIN_INT256"
        );
        require((b == 0) || (c / b == a), "mul: combi values invalid");
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256, "div: b == 1 or a == MIN_INT256");
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require(
            (b >= 0 && c <= a) || (b < 0 && c > a),
            "sub: combi values invalid"
        );
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require(
            (b >= 0 && c >= a) || (b < 0 && c < a),
            "add: combi values invalid"
        );
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256, "abs: a equal MIN INT256");
        return a < 0 ? -a : a;
    }
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// File: contracts\interfaces\IPancakeRouter02.sol
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

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface InterfaceLP {
    function sync() external;
}

interface ISpiceBot {
    function arbitrage() external;
}

contract Spice is ERC20, Ownable {
    using SafeMathInt for int256;
    using SafeMath for uint256;

    IPancakeRouter02 private router;

    address public busd;
    address public pairBusd;

    address public devAndMarketingWallet;
    address public treasuryWallet;
    address public charityWallet;
    address public liquidityReceiver;
    address public rewardContract;

    mapping(address => uint256) private _balances;
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) marketPairs;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    address[] _markerPairs;

    uint256 private _totalSupply;

    uint256 public feeCollectedSpice;
    uint256 SWAP_TRESHOLD = 5 ether;
    uint256 PRECISION = 1000000000000000000;

    // fees
    uint256 public totalBuyFee = 5;
    uint256 public totalSellFee = 10;

    uint256 buyLP = 3;
    uint256 buyTreasury = 2;

    uint256 sellDevMarketing = 2;
    uint256 sellLP = 2;
    uint256 sellTreasury = 2;
    uint256 sellCharity = 2;
    uint256 sellReward = 2;

    bool swapEnabled = true;
    bool private inSwap = false;
    bool isRewardContractSet = false;
    bool botEnabled = false;

    // Reentrancy Guard
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrancy Guard call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(
        address _busd,
        address _router,
        address ownerAddress
    )
        //busd address,
        ERC20("2Spice", "Spice")
    {
        busd = _busd;
        router = IPancakeRouter02(_router);

        pairBusd = IPancakeFactory(router.factory()).createPair(
            address(this),
            busd
        );

        address routerAddress = _router;
        _markerPairs.push(pairBusd);
        marketPairs[pairBusd] = true;

        IERC20(busd).approve(routerAddress, type(uint256).max);
        // IERC20(busd).approve(address(pairBusd), type(uint256).max);
        IERC20(busd).approve(address(this), type(uint256).max);

        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        _allowedFragments[address(this)][address(this)] = type(uint256).max;
        _allowedFragments[address(this)][pairBusd] = type(uint256).max;

        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[ownerAddress] = true;
    }

    function setRewardContract(address _rewardContract) external onlyOwner {
        require(isRewardContractSet == false, "reward alredy set");
        _isFeeExempt[_rewardContract] = true;
        rewardContract = _rewardContract;
    }

    //Internal pool sell to function, takes fees in BUSD
    function sellToThis(uint256 spiceAmount) external nonReentrant {
        _sell(msg.sender, spiceAmount, msg.sender);
    }

    function sellToThis(uint256 spiceAmount, address receipient)
        external
        nonReentrant
    {
        _sell(msg.sender, spiceAmount, receipient);
    }

    //Internal pool buy from function, takes fees in BUSD

    function purchaseFromThis(uint256 busdAmount) external {
        _mintWithBacking(busdAmount, msg.sender);
        _checkGarbageCollector();
    }

    function purchaseFromThis(uint256 busdAmount, address receipient) external {
        _mintWithBacking(busdAmount, receipient);
    }

    function _mintWithBacking(uint256 numTokens, address receipient)
        internal
        returns (uint256)
    {
        // users token balance
        uint256 userTokenBalance = IERC20(busd).balanceOf(msg.sender);
        // ensure user has enough to send
        require(
            userTokenBalance > 0 && numTokens <= userTokenBalance,
            "Insufficient Balance"
        );

        // calculate price change
        uint256 oldPrice = _calculatePrice();

        // previous backing
        uint256 previousBacking = calculateBacking();

        // transfer in token
        uint256 received = _transferIn(numTokens);

        // if this is the first purchase, use new amount
        uint256 relevantBacking = previousBacking == 0
            ? 1 ether
            : previousBacking;

        // Handle Minting
        return _mintTo(receipient, received, relevantBacking, oldPrice);
    }

    function _mintTo(
        address receipient,
        uint256 received,
        uint256 relevantBacking,
        uint256 oldPrice
    ) private returns (uint256 tokensMinted) {
        uint256 busdAmountAfterFees = collectBuyFees(received, receipient);
        uint256 calculatedSupply = _totalSupply == 0 ? 10**18 : _totalSupply;
        uint256 spiceAmountAfterFees = busdAmountAfterFees
            .mul(calculatedSupply)
            .div(relevantBacking);
        _mint(receipient, spiceAmountAfterFees);
        _requirePriceRises(oldPrice);
        return spiceAmountAfterFees;
    }

    function _sell(
        address seller,
        uint256 spiceAmount,
        address receipient
    ) internal {
        uint256 spicePrice = _calculatePrice();
        uint256 sellerBalance = balanceOf(seller);
        require(spiceAmount > 0, "Amount must be greater than zero");
        require(sellerBalance >= spiceAmount, "Amount exceeds balance");
        //gets the spice price
        uint256 sellAmountSpice = collectSellFees(spiceAmount, seller);

        uint256 sellAmount = amountOut(sellAmountSpice);

        bool successful = IERC20(busd).transfer(receipient, sellAmount);

        //burns all spice sent to contract
        _balances[receipient] -= spiceAmount;
        _totalSupply -= spiceAmount;

        require(successful, "Transfer Failure");

        _requirePriceRises(spicePrice);
        emit Transfer(receipient, address(0), sellAmountSpice);
    }

    //check
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowanceForUser(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _spendAllowanceForUser(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = _allowedFragments[owner][spender];
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);
        uint256 feesCollected = feeCollectedSpice;

        if (
            feesCollected >= SWAP_TRESHOLD &&
            !marketPairs[from] &&
            inSwap == false &&
            !_isFeeExempt[from]
        ) {
            inSwap = true;
            swapExternalPoolFees();
            inSwap = false;
        }

        if (
            botEnabled &&
            liquidityReceiver != address(0) &&
            !marketPairs[from] &&
            inSwap == false &&
            !_isFeeExempt[from]
        ) {
            inSwap = true;
            ISpiceBot(liquidityReceiver).arbitrage();
            inSwap = false;
        }

        uint256 fromBalance = _balances[from];

        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 amountReceived = _shouldTakeFee(from, to)
            ? takeFees(from, to, amount)
            : amount;

        unchecked {
            _balances[from] = fromBalance.sub(amount);
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amountReceived;
        }

        emit Transfer(from, to, amountReceived);

        _afterTokenTransfer(from, to, amountReceived);
    }

    //check
    //set take fee amount returns amount minus fees
    function takeFees(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 _realFee = 0;
        uint256 rewardContractFees = 0;
        //determine the fee
        if (marketPairs[recipient]) _realFee = totalSellFee;
        if (marketPairs[sender]) _realFee = totalBuyFee;

        _realFee = (_realFee * amount) / 100;
        uint256 gonAmount = amount.sub(_realFee);

        uint256 feeAmount = amount - gonAmount;

        if (marketPairs[recipient]) {
            _realFee = totalSellFee;
            rewardContractFees = sellReward.mul(feeAmount).div(_realFee);
        }

        if (rewardContract != address(0) && rewardContractFees > 0) {
            uint256 newFees = feeAmount - rewardContractFees;
            _balances[address(this)] += newFees;
            _mint(rewardContract, rewardContractFees);
            emit Transfer(sender, address(this), newFees);
            emit Transfer(sender, rewardContract, rewardContractFees);
        } else {
            _balances[address(this)] = _balances[address(this)] + feeAmount;
            feeCollectedSpice += feeAmount;
            emit Transfer(sender, address(this), feeAmount);
        }
        //return fee
        return gonAmount;
    }

    //check//helper functions
    function _shouldTakeFee(address from, address to)
        private
        view
        returns (bool isExempt)
    {
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return false;
        } else if (marketPairs[from] || marketPairs[to]) {
            return true;
        } else {
            return false;
        }
    }

    function manualSync() public {
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            InterfaceLP(_markerPairs[i]).sync();
        }
    }

    function toggleFeeSwapping(bool isEnabled) public onlyOwner {
        swapEnabled = isEnabled;
        emit SwappingStateChanged(isEnabled);
    }

    function toggleArbitrage(bool isEnabled) public onlyOwner {
        botEnabled = isEnabled;
        emit ArbitrageStateChanged(isEnabled);
    }

    //transfers busd fees collected
    function collectBuyFees(uint256 amount, address receipient)
        private
        returns (uint256 afterAmount)
    {
        uint256 gonAmount;
        if (!_isFeeExempt[receipient]) {
            uint256 amountToTreasury = (buyTreasury * amount) / 100;
            uint256 amountToLP = (buyLP * amount) / 100;
            uint256 half = amountToLP.div(2);
            uint256 otherHalf = amountToLP - half;
            if (liquidityReceiver == address(0)) {
                buyTreasury += otherHalf;
            } else {
                IERC20(busd).transfer(liquidityReceiver, half);
            }
            IERC20(busd).transfer(treasuryWallet, amountToTreasury);
            gonAmount = amount - (amountToLP + amountToTreasury);
        } else {
            uint256 exemptLiquidityTax = 10;
            gonAmount = amount.sub(exemptLiquidityTax);
        }
        return gonAmount;
    }

    function collectSellFees(uint256 amount, address receipient)
        private
        returns (uint256 afterAmount)
    {
        uint256 gonAmount;
        if (!_isFeeExempt[receipient]) {
            uint256 amountToTreasury = (sellTreasury * amount) / 100;
            uint256 amountToLP = (sellLP * amount) / 100;
            uint256 amountToMarketing = (sellDevMarketing * amount) / 100;
            uint256 amountToCharity = (sellCharity * amount) / 100;
            uint256 amountToReward = (sellReward * amount) / 100;

            IERC20(busd).transfer(treasuryWallet, amountOut(amountToTreasury));
            IERC20(busd).transfer(
                devAndMarketingWallet,
                amountOut(amountToMarketing)
            );
            IERC20(busd).transfer(charityWallet, amountOut(amountToCharity));
            if (liquidityReceiver == address(0)) {
                buyTreasury += amountToLP.div(2);
            } else {
                IERC20(busd).transfer(
                    liquidityReceiver,
                    amountOut(amountToLP.div(2))
                );
            }
            if (rewardContract != address(0)) {
                transfer(rewardContract, amountToReward);
            }
            gonAmount =
                amountToTreasury +
                amountToLP +
                amountToMarketing +
                amountToCharity +
                amountToReward;
        } else {
            uint256 exemptLiquidityTax = 10;
            gonAmount = amount.sub(exemptLiquidityTax);
        }
        return gonAmount;
    }

    function swapExternalPoolFees() public {
        uint256 totalFees = feeCollectedSpice;
        uint256 total = totalBuyFee + totalSellFee - sellReward;
        //get porpotions to sell
        uint256 amountToTreasury = amountOut(
            (sellTreasury + buyTreasury).mul(totalFees).div(total)
        );
        uint256 amountToLP = amountOut(
            (sellLP + buyLP).div(2).mul(totalFees).div(total)
        );
        uint256 amountToMarketing = amountOut(
            sellDevMarketing.mul(totalFees).div(total)
        );
        uint256 amountToCharity = amountOut(
            sellCharity.mul(totalFees).div(total)
        );

        _sell(address(this), amountToTreasury, treasuryWallet);
        _sell(address(this), amountToLP, liquidityReceiver);
        _sell(address(this), amountToMarketing, devAndMarketingWallet);
        _sell(address(this), amountToCharity, charityWallet);
        _burn(address(this), amountToLP);
        feeCollectedSpice -= (amountToTreasury +
            amountToLP +
            amountToCharity +
            amountToCharity +
            amountToLP);
    }

    //check//
    function setNewMarketMakerPair(address _pair, bool _value)
        public
        onlyOwner
    {
        require(marketPairs[_pair] != _value, "Value already set");

        marketPairs[_pair] = _value;
        _markerPairs.push(_pair);
    }

    function _transferIn(uint256 desiredAmount) internal returns (uint256) {
        uint256 balBefore = IERC20(busd).balanceOf(address(this));
        bool s = IERC20(busd).transferFrom(
            msg.sender,
            address(this),
            desiredAmount
        );
        uint256 received = IERC20(busd).balanceOf(address(this)) - balBefore;
        require(s && received > 0 && received <= desiredAmount);
        return received;
    }

    //check
    //Erc20 function overrides
    function balanceOf(address who) public view override returns (uint256) {
        return _balances[who];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowedFragments[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowedFragments[owner][spender];
    }

    function burn(uint256 amount) external {
        // get balance of caller
        uint256 bal = _balances[msg.sender];
        require(bal >= amount && bal > 0, "Zero Holdings");
        // Track Change In Price
        uint256 oldPrice = _calculatePrice();
        // burn tokens from sender + supply
        _burn(msg.sender, amount);
        // require price rises
        _requirePriceRises(oldPrice);
    }

    //check
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal virtual override {
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

    function _burn(address account, uint256 amount) internal virtual override {
        _balances[account] = _balances[account].sub(
            amount,
            "Insufficient Balance"
        );
        _totalSupply = _totalSupply.sub(amount, "Negative Supply");
        emit Transfer(account, address(0), amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        override
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    //check
    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    //set accounts that are exempt from fees
    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
        emit SetFeeExempted(_addr, _value);
    }

    function clearStuckFees(address _receiver) external onlyOwner {
        uint256 balance = feeCollectedSpice; //gas optimization
        transfer(_receiver, balance);
        feeCollectedSpice = 0;
        emit ClearStuckBalance(_receiver);
    }

    function amountOut(uint256 numTokens) public view returns (uint256) {
        return _calculatePrice().mul(numTokens).div(PRECISION);
    }

    function calculatePrice() public view returns (uint256) {
        return _calculatePrice();
    }

    function _calculatePrice() public view returns (uint256) {
        uint256 backing = calculateBacking();
        uint256 totalShares = _totalSupply == 0 ? 1 ether : _totalSupply;
        uint256 price = backing.mul(PRECISION).div(totalShares);
        return price;
    }

    function calculateBacking() public view returns (uint256) {
        uint256 poolBacking = IERC20(busd).balanceOf(address(this));
        return poolBacking;
    }

    function _requirePriceRises(uint256 oldPrice) internal {
        // Calculate Price After Transaction
        uint256 newPrice = _calculatePrice();
        // Require Current Price >= Last Price
        require(newPrice >= oldPrice, "Price Cannot Fall");
        // Emit The Price Change
        emit PriceChange(oldPrice, newPrice, _totalSupply);
    }

    function fetchPCSPrice() public view returns (uint256) {
        address[] memory cvxPath = new address[](2);
        cvxPath[0] = address(this);
        cvxPath[1] = busd;
        uint256[] memory out = router.getAmountsOut(1 ether, cvxPath);
        return out[1];
    }

    function changeSwapTreshold(uint256 newSwapTreshold) external onlyOwner {
        require(newSwapTreshold >= 1e18, "treshold must be higher than 1 eth");
        SWAP_TRESHOLD = newSwapTreshold;
    }

    //set fee wallets:
    function setFeeReceivers(
        address _liquidityReceiver,
        address _treasuryReceiver,
        address _charityValueReceiver,
        address _devAndMarketing
    ) external onlyOwner {
        liquidityReceiver = _liquidityReceiver;
        treasuryWallet = _treasuryReceiver;
        charityWallet = _charityValueReceiver;
        devAndMarketingWallet = _devAndMarketing;
        _isFeeExempt[liquidityReceiver] = true;
        _isFeeExempt[treasuryWallet] = true;
        _isFeeExempt[charityWallet] = true;
        _isFeeExempt[devAndMarketingWallet] = true;
        emit SetFeeReceivers(
            _liquidityReceiver,
            _treasuryReceiver,
            _charityValueReceiver,
            _devAndMarketing
        );
    }

    function _checkGarbageCollector() internal {
        uint256 bal = _balances[address(this)];
        uint256 overflow = bal - feeCollectedSpice;
        if (overflow > 0) {
            // Track Change In Price
            uint256 oldPrice = _calculatePrice();
            // burn amount
            _burn(address(this), overflow);
            // Emit Price Difference
            emit PriceChange(oldPrice, _calculatePrice(), _totalSupply);
        }
    }

    //events
    event SetFeeExempted(address _addr, bool _value);
    event WalletTransfers(uint256 time, uint256 amount);
    event NewMarketMakerPair(address _pair, uint256 time);
    event PresaleWithdrawn(address receiver, uint256 amount);
    event PresaleOver(bool _over);
    event PresaleOpened(uint256 time, address sender);
    event SetFeeReceivers(
        address _liquidityReceiver,
        address _treasuryReceiver,
        address _riskFreeValueReceiver,
        address _marketing
    );
    event SwapBack(
        uint256 contractTokenBalance,
        uint256 amountToLiquify,
        uint256 amountToRFV,
        uint256 amountToDevMarketing,
        uint256 amountToTreasury,
        bool buy
    );
    event ClearStuckBalance(address _receiver);
    event SwappingStateChanged(bool enabled);
    event ArbitrageStateChanged(bool enabled);
    event PriceChange(
        uint256 previousPrice,
        uint256 currentPrice,
        uint256 totalSupply
    );
}