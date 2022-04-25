/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File contracts/dex/interfaces/IRouter.sol
// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external view returns (address);

    function WETH() external view returns (address);

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

// File @openzeppelin/contracts/token/ERC20/[email protected]

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

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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

// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
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

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File contracts/dex/interfaces/IFactory.sol

pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// File contracts/dex/interfaces/IPancakePair.sol

pragma solidity ^0.8.0;

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

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
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
}

// File contracts/dex/common/PancakeLibrary.sol

pragma solidity ^0.8.0;

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            // hex"cf86802e4bacc35c7b9e68c15ec90dae433edfef136b1d11cdfb9fc3156c3e03" // local env
                            hex"ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074" // test net
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(998);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File contracts/token/mt/Mt1Dex.sol

pragma solidity ^0.8.0;

// import "hardhat/console.sol";

abstract contract Mt1Dex is Ownable, ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public usdt;
    address public zcm;

    address public router;
    address public factory;

    address public lpMtUsdt; // LP

    uint256 public constant PRICE_MULTIP = 1e6;

    mapping(address => bool) internal dexPairs;

    function getLpMtUsdtAddress() internal onlyOwner {
        if (factory == address(0) || usdt == address(0)) {
            return;
        }
        address lp = IPancakeFactory(factory).getPair(address(this), usdt);
        if (lp == address(0)) {
            lp = IPancakeFactory(factory).createPair(address(this), usdt);
        }
        setLpMtUsdt(lp);
    }

    function setUsdt(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (usdt != addr) {
            usdt = addr;
            getLpMtUsdtAddress();
        }
    }

    function setZcm(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (zcm != addr) {
            zcm = addr;
        }
    }

    function setRouter(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (router != addr) {
            if (router != address(0)) {
                setDexPair(router, false);
            }
            router = addr;
            setDexPair(router, true);
            setFactory(IPancakeRouter02(router).factory());
        }
    }

    function setFactory(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (factory != addr) {
            factory = addr;
            getLpMtUsdtAddress();
        }
    }

    function setLpMtUsdt(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (lpMtUsdt != addr) {
            if (lpMtUsdt != address(0)) {
                setDexPair(lpMtUsdt, false);
            }
            lpMtUsdt = addr;
            setDexPair(lpMtUsdt, true);
        }
    }

    function setDexPair(address addr, bool isPair) public onlyOwner {
        require(addr != address(0), "address zero");
        if (dexPairs[addr] != isPair) {
            dexPairs[addr] = isPair;
        }
    }

    function getPairAddress(address tokenA, address tokenB)
        public
        view
        returns (address)
    {
        // console.log(factory, tokenA, tokenB);
        if (
            factory == address(0) ||
            tokenA == address(0) ||
            tokenB == address(0)
        ) {
            return address(0);
        }
        return PancakeLibrary.pairFor(factory, tokenA, tokenB);
    }

    function getMtPriceByUsdt() public view returns (uint256) {
        if (factory == address(0) || usdt == address(0)) {
            return 0;
        }
        (uint256 reserveM, uint256 reserveU) = PancakeLibrary.getReserves(
            factory,
            address(this),
            usdt
        );
        if (reserveM == 0) {
            return 0;
        }
        return reserveU.mul(PRICE_MULTIP).div(reserveM);
    }

    function getZcmPriceByUsdt() public view returns (uint256) {
        if (factory == address(0) || usdt == address(0) || zcm == address(0)) {
            return 0;
        }
        (uint256 reserveZ, uint256 reserveU) = PancakeLibrary.getReserves(
            factory,
            zcm,
            usdt
        );
        if (reserveZ == 0) {
            return 0;
        }
        return reserveU.mul(PRICE_MULTIP).div(reserveZ);
    }
}

// File contracts/token/mt/Mt2TxFee.sol

//
pragma solidity ^0.8.0;

abstract contract Mt2TxFee is Mt1Dex {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => bool) private creators;

    uint256 public constant RATE_BASE = 10000;
    uint256 public buyFeeRate = RATE_BASE;
    uint256 public sellFeeRate = 1000;
    uint256 public txFeeRate = 400;
    address private feeReceiver;

    event TakeFee(
        address indexed from,
        address indexed to,
        uint256 indexed feeRate,
        uint256 feeAmount
    );

    function setCreator(address addr, bool isCreator) public onlyOwner {
        require(addr != address(0), "address zero");
        if (creators[addr] != isCreator) {
            creators[addr] = isCreator;
        }
    }

    function setFeeRate(
        uint256 buyRate,
        uint256 sellRate,
        uint256 txRate
    ) public onlyOwner {
        require(
            buyRate <= RATE_BASE &&
                sellRate <= RATE_BASE &&
                txRate <= RATE_BASE,
            "over rate_base"
        );
        buyFeeRate = buyRate;
        sellFeeRate = sellRate;
        txFeeRate = txRate;
    }

    function setFeeReceiver(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (feeReceiver != address(0)) {
            setCreator(feeReceiver, false);
        }
        feeReceiver = addr;
        setCreator(feeReceiver, true);
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        return _transferRouter(_msgSender(), to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _transferRouter(from, to, amount);
        uint256 currentAllowance = allowance(from, _msgSender());
        require(currentAllowance >= amount, "ERC20: exceeds allowance");
        super._approve(from, _msgSender(), currentAllowance.sub(amount));
        return true;
    }

    function _takeFee(
        address from,
        address to,
        uint256 amount,
        uint256 feeRate
    ) internal returns (bool) {
        if (amount == 0) {
            return true;
        }

        if (feeRate == 0 || feeReceiver == address(0)) {
            super._transfer(from, to, amount);
            return true;
        }

        if (feeRate == RATE_BASE) {
            super._transfer(from, feeReceiver, amount);
            emit TakeFee(from, to, feeRate, amount);
            return true;
        }

        uint256 fee = amount.mul(feeRate).div(RATE_BASE);
        super._transfer(from, to, amount.sub(fee));
        super._transfer(from, feeReceiver, fee);
        emit TakeFee(from, to, feeRate, fee);

        return true;
    }

    function _transferRouter(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        if (dexPairs[from] && !dexPairs[to]) {
            // buy or remove LP : from pair ; to not pair
            if (creators[from]) {
                super._transfer(from, to, amount);
                return true;
            } else {
                return _takeFee(from, to, amount, buyFeeRate);
            }
        } else if (!dexPairs[from] && dexPairs[to]) {
            // sell or add LP : from not pair ; to pair
            if (creators[from]) {
                super._transfer(from, to, amount);
                return true;
            } else {
                return _takeFee(from, to, amount, sellFeeRate);
            }
        } else if (dexPairs[from] && dexPairs[to]) {
            // router in pair path: from pair to pair
            super._transfer(from, to, amount);
            return true;
        } else {
            // user transfer: from not pair; to not pair
            if (creators[from]) {
                super._transfer(from, to, amount);
                return true;
            } else {
                return _takeFee(from, to, amount, txFeeRate);
            }
        }
    }
}

// File contracts/token/mt/Mt3Power.sol

pragma solidity ^0.8.0;

abstract contract Mt3Power is Mt2TxFee {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant POINT_MT_POWER = 1;
    uint256 public constant POINT_CP_STATIC = 2;
    uint256 public constant POINT_CP_DYN_1_INVITE = 3;
    uint256 public constant POINT_CP_DYN_2_MINING = 4;

    address public mtTempHolder; // use for hold mt that returned from dex when proxy user to swap mt on buy mtPower
    bool private isMtBurn = true;

    mapping(address => uint256) public mtPowers; // amount equal to U that input on buyMT
    uint256 public totalMtPower;

    function setMtTempHolder(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (mtTempHolder != addr) {
            if (mtTempHolder != address(0)) {
                super.setCreator(mtTempHolder, false);
                _approve(mtTempHolder, address(this), 0);
            }
            mtTempHolder = addr;
            super.setCreator(mtTempHolder, true);
            _approve(mtTempHolder, address(this), type(uint256).max);
        }
    }

    function setIsMtBurn(bool isBurn) public onlyOwner {
        if (isMtBurn != isBurn) {
            isMtBurn = isBurn;
        }
    }

    function buyMtPowerProxyToDex(uint256 amountUsdt, address inviteFrom)
        public
    {
        require(amountUsdt > 0, "Input U zero");
        uint256 balanceUsdt = IERC20(usdt).balanceOf(_msgSender());
        require(balanceUsdt >= amountUsdt, "U balance less");

        // apply
        // proxy to dex
        IERC20(usdt).safeTransferFrom(_msgSender(), address(this), amountUsdt);
        IERC20(usdt).approve(router, amountUsdt);
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = address(this);
        uint256 amountMtInDexSwapTo = balanceOf(mtTempHolder);
        IPancakeRouter02(router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountUsdt,
                0,
                path,
                mtTempHolder,
                block.timestamp.add(60)
            );
        if (isMtBurn) {
            _burn(
                mtTempHolder,
                balanceOf(mtTempHolder).sub(amountMtInDexSwapTo)
            );
        }
        _pointMint(1, _msgSender(), amountUsdt);

        _setInviteFrom(_msgSender(), inviteFrom);
    }

    // deprecated
    // function buyMtPowerInDapp(uint256 usdtAmount, address inviteFrom) public {
    //     //p-1: MT price -> mt_burn_amount
    //     //p-2: apply
    //     // transfer usdt to usdt_receiver;
    //     // burn MT from 4000W min pool
    //     // add mtPower to sender
    //     require(usdtReceiver != address(0), "Usdt Receiver address zero");
    //     require(usdtAmount > 0, "Input U zero");
    //     uint256 balanceUsdt = IERC20(usdt).balanceOf(_msgSender());
    //     require(balanceUsdt >= usdtAmount, "U balance less");

    //     uint256 price_mt = getMtPriceByUsdt();
    //     require(price_mt > 0, "MT price zero");
    //     uint256 amount_mt_burn = usdtAmount.div(price_mt).mul(10**6);

    //     // apply
    //     IERC20(usdt).safeTransferFrom(_msgSender(), usdtReceiver, usdtAmount);
    //     // _burn(owner(), amount_mt_burn);
    //     // mint mtPower
    //     _point_mint(1, _msgSender(), usdtAmount);
    //     // todo:use event to return values
    //     // build invite relation
    //     _set_inviteFrom(_msgSender(), inviteFrom);
    // }

    function _pointMint(
        uint256 pointIndex,
        address to,
        uint256 amount
    ) internal virtual;

    function _pointBurn(
        uint256 pointIndex,
        address from,
        uint256 amount
    ) internal virtual;

    function _setInviteFrom(address to, address from) internal virtual;
}

// File contracts/token/mt/Mt4Invite.sol

pragma solidity ^0.8.0;

abstract contract Mt4Invite is Mt3Power {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => address) public inviteRoots;
    address internal inviteRootMin;
    mapping(address => address) public inviteFroms;
    mapping(address => uint256) public inviteToCountDirects;
    mapping(address => uint256) public inviteToCountIndirects;
    uint256 public inviteCountTimes = 7;
    uint256 public inviteCpDyn1Times = 7;
    uint256 public inviteCpDyn1EqZcmUsdtRate = 1000;

    function setInviteRootMin(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        inviteRootMin = addr;
    }

    function setInviteRoot(address to, address from) public onlyOwner {
        require(to != address(0), "invite to zero");
        inviteRoots[to] = from;
    }

    function setInviteCountTimes(uint256 t) public onlyOwner {
        inviteCountTimes = t;
    }

    function setInviteCpDyn1Times(uint256 t) public onlyOwner {
        inviteCpDyn1Times = t;
    }

    function setInviteCpDyn1EqZcmUsdtRate(uint256 rate) public onlyOwner {
        require(
            inviteCpDyn1EqZcmUsdtRate <= RATE_BASE,
            string(abi.encodePacked("large than ", RATE_BASE))
        );
        inviteCpDyn1EqZcmUsdtRate = rate;
    }

    function _setInviteFrom(address to, address from) internal override {
        require(to != address(0), "invite from or to zero");
        if (from == address(0)) {
            return;
        }
        // console.log(to, from, inviteFroms[to]);
        if (inviteFroms[to] == address(0)) {
            inviteFroms[to] = from;
            _addInviteCountIter(from);
        } else {
            //ignore, had accept others invite
            return;
        }
    }

    function _addInviteCountIter(address from) internal {
        if (from == address(0)) {
            return;
        }
        _addInviteCount(from, true);
        address ff = from;
        for (uint256 i = 0; i < inviteCountTimes; i++) {
            ff = inviteFroms[ff];
            if (ff == address(0)) {
                break;
            }
            _addInviteCount(ff, false);
        }
    }

    function _addInviteCount(address from, bool isDirect) internal {
        if (isDirect) {
            inviteToCountDirects[from] = inviteToCountDirects[from].add(1);
        } else {
            inviteToCountIndirects[from] = inviteToCountIndirects[from].add(1);
        }
    }
}

// File contracts/token/mt/Mt5CpStatic.sol

pragma solidity ^0.8.0;

abstract contract Mt5CpStatic is Mt4Invite {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct AmountZcmSub {
        uint256 amount1;
        uint256 amount2;
        uint256 amount3;
        uint256 amount4;
        uint256 amount5;
        uint256 amount6;
    }

    address public zcmReceiver1AsCPdyn1Claimable;
    address public zcmReceiver2;
    address public zcmReceiver3;
    address public zcmReceiver4;
    address public zcmReceiver5;
    address public zcmReceiver6;

    uint256 public zcmRate2 = 500;
    uint256 public zcmRate3 = 500;
    uint256 public zcmRate4 = 300;
    uint256 public zcmRate5 = 700;
    uint256 public zcmRate6 = 1000;

    uint256 public cpStaticBuyRate = 6; // (zcm equal usdt + mt power equal usdt ) * 3; 100U_zcm => 600U_Cp_static

    uint256 public totalCpStatic;
    mapping(address => uint256) public cpStatics; // static computer powers

    function setZcmHolders(
        address tempAddr,
        address addr2,
        address addr3,
        address addr4,
        address addr5,
        address addr6
    ) public onlyOwner {
        zcmReceiver1AsCPdyn1Claimable = tempAddr;
        zcmReceiver2 = addr2;
        zcmReceiver3 = addr3;
        zcmReceiver4 = addr4;
        zcmReceiver5 = addr5;
        zcmReceiver6 = addr6;
    }

    function setZcmRates(
        uint256 rate2,
        uint256 rate3,
        uint256 rate4,
        uint256 rate5,
        uint256 rate6
    ) public onlyOwner {
        require(
            rate2.add(rate3).add(rate4).add(rate5).add(rate6) < RATE_BASE,
            "rate over 10000"
        );
        zcmRate2 = rate2;
        zcmRate3 = rate3;
        zcmRate4 = rate4;
        zcmRate5 = rate5;
        zcmRate6 = rate6;
    }

    function setCpStaticBuyRate(uint256 rate) public onlyOwner {
        cpStaticBuyRate = rate;
    }
}

// File contracts/token/mt/Mt6CpDynFromInvite.sol

pragma solidity ^0.8.0;

abstract contract Mt6CpDynFromInvite is Mt5CpStatic {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => uint256) public cpDyn1s; // dynamic computer powers 1 from invite
    uint256 public totalCpDyn1;

    function withdrawCpDyn1() public {
        uint256 amountCpDyn1 = cpDyn1s[_msgSender()];
        require(amountCpDyn1 > 0, "balance zero");
        //
        if (cpStatics[_msgSender()] < amountCpDyn1) {
            amountCpDyn1 = cpStatics[_msgSender()];
        }

        uint256 amountZcm = amountCpDyn1.mul(PRICE_MULTIP).div(
            getZcmPriceByUsdt()
        );
        // apply
        _pointBurn(POINT_CP_STATIC, _msgSender(), amountCpDyn1);
        _pointBurn(POINT_CP_DYN_1_INVITE, _msgSender(), amountCpDyn1);
        IERC20(zcm).safeTransferFrom(
            zcmReceiver1AsCPdyn1Claimable,
            _msgSender(),
            amountZcm
        );
    }

    function _mintCpDyn1(address cpStaticBuyer, uint256 amountUsdt) internal {
        if (cpStaticBuyer == address(0)) {
            return;
        }
        if (amountUsdt == 0) {
            return;
        }
        uint256 amountCpDyn1Mint = amountUsdt
            .mul(inviteCpDyn1EqZcmUsdtRate)
            .div(RATE_BASE);
        if (amountCpDyn1Mint == 0) {
            return;
        }

        address ff = cpStaticBuyer;
        bool isRoot = false;
        for (uint256 i = 0; i < inviteCpDyn1Times; i++) {
            if (!isRoot) {
                ff = inviteFroms[ff];
                if (ff == address(0)) {
                    if (inviteRootMin == address(0)) {
                        break;
                    }
                    ff = inviteRootMin;
                    isRoot = true;
                }
            } else {
                ff = inviteRoots[ff];
                if (ff == address(0)) {
                    break;
                }
            }

            if (ff == address(0)) {
                break;
            }
            // console.log(i, isRoot, ff, inviteToCountDirects[ff]);
            if (!isRoot && inviteToCountDirects[ff] < (i + 1)) {
                continue;
            }
            _pointMint(POINT_CP_DYN_1_INVITE, ff, amountCpDyn1Mint);
        }
    }
}

// File contracts/token/mt/Mt7CpStaticMining.sol

pragma solidity ^0.8.0;

abstract contract Mt7CpStaticMining is Mt6CpDynFromInvite {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public poolRewardPerShareSum;
    uint256 public poolBlockHightPreSum;
    uint256 public poolMtPerBlock = 76;
    mapping(address => uint256) public poolUserRewardPerShareSumCopys;

    function pendingCpDyn2(address addr) public view returns (uint256) {
        // console.log(
        //     "pendingCpDyn2",
        //     addr,
        //     poolUserRewardPerShareSumCopys[addr]
        // );
        // if (poolUserRewardPerShareSumCopys[addr] == 0) {
        //     return 0;
        // }
        if (totalCpStatic == 0) {
            return 0;
        }
        uint256 pendingReward = block
            .number
            .sub(poolBlockHightPreSum)
            .mul(poolMtPerBlock)
            .mul(10**decimals())
            .mul(getMtPriceByUsdt())
            .div(PRICE_MULTIP);
        uint256 rewardPerShare = pendingReward.mul(1e12).div(totalCpStatic);
        // console.log(
        //     poolUserRewardPerShareSumCopys[addr],
        //     pendingReward,
        //     rewardPerShare,
        //     cpStatics[addr]
        // );
        uint256 pending = poolRewardPerShareSum
            .add(rewardPerShare)
            .sub(poolUserRewardPerShareSumCopys[addr])
            .mul(cpStatics[addr])
            .div(1e12);
        return pending;
    }

    function _claimCpdyn2OnCpStaticChange(address staker) internal {
        // console.log(
        //     "_claimCpdyn2OnCpStaticChange",
        //     poolRewardPerShareSum,
        //     staker
        // );
        _updateCpStaticPool();
        // console.log(
        //     "_claimCpdyn2OnCpStaticChange",
        //     poolRewardPerShareSum,
        //     staker
        // );
        uint256 amountPendingCpDyn2 = poolRewardPerShareSum
            .sub(poolUserRewardPerShareSumCopys[staker])
            .mul(cpStatics[staker])
            .div(1e12);
        // console.log(
        //     poolRewardPerShareSum,
        //     poolUserRewardPerShareSumCopys[staker],
        //     cpStatics[staker],
        //     amountPendingCpDyn2
        // );
        if (amountPendingCpDyn2 > 0) {
            _pointMint(POINT_CP_DYN_2_MINING, staker, amountPendingCpDyn2);
            poolUserRewardPerShareSumCopys[staker] = poolRewardPerShareSum;
        }
    }

    function _setPoolBlockHeightPreSumOnFirstMintCpStatic() internal {
        poolBlockHightPreSum = block.number;
    }

    function _updateCpStaticPool() internal {
        if (totalCpStatic == 0) {
            return;
        }
        uint256 reward = block
            .number
            .sub(poolBlockHightPreSum)
            .mul(poolMtPerBlock)
            .mul(10**decimals())
            .mul(getMtPriceByUsdt())
            .div(PRICE_MULTIP);
        // console.log(block.number, poolBlockHightPreSum, reward);
        // console.log(poolMtPerBlock, getMtPriceByUsdt(), PRICE_MULTIP);
        uint256 rewardPerShare = reward.mul(1e12).div(totalCpStatic);
        poolRewardPerShareSum += rewardPerShare;
        poolBlockHightPreSum = block.number;
    }
}

// File contracts/token/mt/Mt8CpDynFromMining.sol

pragma solidity ^0.8.0;

abstract contract Mt8CpDynFromMining is Mt7CpStaticMining {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public mtHolder; // withdraw dyn2 reward mt from: is creator address

    uint256 public totalCpDyn2;
    mapping(address => uint256) public cpDyn2s; // dynamic computer powers 2 from mint with compute power mining

    function setMtHolderAsCpDyn2WithdrawFrom(address addr) public onlyOwner {
        require(addr != address(0), "address zero");
        if (mtHolder != addr) {
            if (mtHolder != address(0)) {
                super.setCreator(mtHolder, false);
            }

            mtHolder = addr;
            super.setCreator(mtHolder, true);
            _approve(mtHolder, address(this), type(uint256).max);
            // uint256 allowance = allowance(mtHolder, address(this));
            // console.log(
            //     "\n\nsetMtHolderAsCpDyn2WithdrawFrom",
            //     mtHolder,
            //     allowance
            // );
        }
    }

    function withdrawCpDyn2() public {
        uint256 amountCpDyn2 = cpDyn2s[_msgSender()];
        amountCpDyn2 = amountCpDyn2.add(super.pendingCpDyn2(_msgSender()));
        //
        if (cpStatics[_msgSender()] < amountCpDyn2) {
            amountCpDyn2 = cpStatics[_msgSender()];
        }

        uint256 amountMt = amountCpDyn2.mul(PRICE_MULTIP).div(
            getMtPriceByUsdt()
        );
        // apply
        _pointBurn(POINT_CP_STATIC, _msgSender(), amountCpDyn2);
        _pointBurn(POINT_CP_DYN_2_MINING, _msgSender(), amountCpDyn2);

        IERC20(address(this)).safeTransferFrom(
            mtHolder,
            address(this),
            amountMt
        );
        IERC20(address(this)).approve(router, amountMt);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        IPancakeRouter02(router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountMt,
                0,
                path,
                _msgSender(),
                block.timestamp.add(60)
            );
    }
}

// File contracts/token/mt/Mt9CpStaticBuy.sol

pragma solidity ^0.8.0;

abstract contract Mt9CpStaticBuy is Mt8CpDynFromMining {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function bugCPstatic(uint256 amountZcm) public {
        require(amountZcm > 0, "Args Zero");
        require(
            IERC20(zcm).allowance(_msgSender(), address(this)) >= amountZcm,
            "zcm allow less"
        );

        // zcm price multed 10**6
        uint256 amountU = amountZcm.mul(getZcmPriceByUsdt()).div(PRICE_MULTIP);
        // mtPower
        require(mtPowers[_msgSender()] >= amountU, "mt power less");

        // apply
        //  =>zcm_70%_to_address_a_for_claim_CP_dyn_1 zcm_30%_to_address_5
        _zcmSub(amountZcm);
        //  =>mt_power_burn
        _pointBurn(POINT_MT_POWER, _msgSender(), amountU);
        //  <=CP_static_to_sender
        _pointMint(POINT_CP_STATIC, _msgSender(), amountU.mul(cpStaticBuyRate));
        //  <=CP_dyn_1_to_parent
        super._mintCpDyn1(_msgSender(), amountU);
    }

    function _pointMint(
        uint256 pointIndex,
        address to,
        uint256 amount
    ) internal override {
        // pointIndex: 1=>mtPower,2=>CpStatic,3=>CpDyn1,4=>CpDyn2
        require(pointIndex >= 1 || pointIndex <= 4, "point index invalid");
        require(to != address(0), "mint to zero");
        require(amount > 0, "mint amount zero");
        if (pointIndex == 1) {
            mtPowers[to] = mtPowers[to].add(amount);
            totalMtPower = totalMtPower.add(amount);
        } else if (pointIndex == 2) {
            if (totalCpStatic == 0) {
                _setPoolBlockHeightPreSumOnFirstMintCpStatic();
            }
            if (totalCpStatic > 0) {
                _claimCpdyn2OnCpStaticChange(to);
            }
            cpStatics[to] = cpStatics[to].add(amount);
            uint256 totalCpStaticOld = totalCpStatic;
            totalCpStatic = totalCpStatic.add(amount);
            if (totalCpStaticOld == 0) {
                _claimCpdyn2OnCpStaticChange(to);
            }
        } else if (pointIndex == 3) {
            cpDyn1s[to] = cpDyn1s[to].add(amount);
            totalCpDyn1 = totalCpDyn1.add(amount);
        } else if (pointIndex == 4) {
            cpDyn2s[to] = cpDyn2s[to].add(amount);
            totalCpDyn2 = totalCpDyn2.add(amount);
        }
    }

    function _pointBurn(
        uint256 pointIndex,
        address from,
        uint256 amount
    ) internal override {
        // pointIndex: 1=>mtPower,2=>CpStatic,3=>CpDyn1,4=>CpDyn2
        require(pointIndex >= 1 || pointIndex <= 4, "point index invalid");
        require(from != address(0), "mint to zero");
        require(amount > 0, "mint amount zero");
        if (pointIndex == 1) {
            mtPowers[from] = mtPowers[from].sub(amount);
            totalMtPower = totalMtPower.sub(amount);
        } else if (pointIndex == 2) {
            if (totalCpStatic > 0) {
                _claimCpdyn2OnCpStaticChange(from);
            }
            cpStatics[from] = cpStatics[from].sub(amount);
            totalCpStatic = totalCpStatic.sub(amount);
        } else if (pointIndex == 3) {
            cpDyn1s[from] = cpDyn1s[from].sub(amount);
            totalCpDyn1 = totalCpDyn1.sub(amount);
        } else if (pointIndex == 4) {
            cpDyn2s[from] = cpDyn2s[from].sub(amount);
            totalCpDyn2 = totalCpDyn2.sub(amount);
        }
    }

    function _zcmSub(uint256 amountZcm) internal {
        require(
            // zcmReceiver1AsCPdyn1Claimable != address(0) &&
            zcmReceiver2 != address(0) &&
                zcmReceiver3 != address(0) &&
                zcmReceiver4 != address(0) &&
                zcmReceiver5 != address(0) &&
                zcmReceiver6 != address(0),
            "zcm receives zero"
        );
        AmountZcmSub memory a;
        a.amount2 = amountZcm.mul(zcmRate2).div(RATE_BASE);
        a.amount3 = amountZcm.mul(zcmRate3).div(RATE_BASE);
        a.amount4 = amountZcm.mul(zcmRate4).div(RATE_BASE);
        a.amount5 = amountZcm.mul(zcmRate5).div(RATE_BASE);
        a.amount6 = amountZcm.mul(zcmRate6).div(RATE_BASE);
        a.amount1 = amountZcm
            .sub(a.amount2)
            .sub(a.amount3)
            .sub(a.amount4)
            .sub(a.amount5)
            .sub(a.amount6);
        // console.log("zcmReceiver2 address is ", zcmReceiver2);
        // console.log("zcmReceiver3 address is ", zcmReceiver3);
        // console.log("zcmReceiver4 address is ", zcmReceiver4);
        // console.log("zcmReceiver5 address is ", zcmReceiver5);
        // console.log("zcmReceiver6 address is ", zcmReceiver6);
        // console.log("zcmReceiver1 address is ", zcmReceiver1AsCPdyn1Claimable);
        // console.log("zcm address is ", zcm);
        IERC20(zcm).safeTransferFrom(_msgSender(), zcmReceiver2, a.amount2);
        IERC20(zcm).safeTransferFrom(_msgSender(), zcmReceiver3, a.amount3);
        IERC20(zcm).safeTransferFrom(_msgSender(), zcmReceiver4, a.amount4);
        IERC20(zcm).safeTransferFrom(_msgSender(), zcmReceiver5, a.amount5);
        IERC20(zcm).safeTransferFrom(_msgSender(), zcmReceiver6, a.amount6);
        IERC20(zcm).safeTransferFrom(
            _msgSender(),
            zcmReceiver1AsCPdyn1Claimable,
            a.amount1
        );
    }
}

// File contracts/token/MT.sol

pragma solidity ^0.8.0;

contract MT is Mt9CpStaticBuy {
    constructor() ERC20("MTtoken", "MT") {
        super.setCreator(msg.sender, true);
        super.setCreator(address(this), true);
        _mint(msg.sender, 130 * (10**(6 + decimals())));
        _burn(msg.sender, 60 * (10**(6 + decimals())));
    }
}