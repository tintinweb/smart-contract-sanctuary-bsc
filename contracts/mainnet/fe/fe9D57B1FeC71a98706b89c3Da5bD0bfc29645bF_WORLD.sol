/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
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

//
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

//
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

//
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)
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

//
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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

interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

//
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)
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

contract WORLD is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 total = 100 * 10**8 * 10**decimals();

    mapping(address => uint256) private _balances;

    mapping(address => bool) public _taxExclude;
    mapping(address => bool) public _deflationExclude;

    uint256 public teamFee = 15;
    uint256 public rewardFee = 20;
    uint256 public liquidityFee = 15;

    uint256 public skyFee = 50;
    uint256 public genFee = 50;
    uint256[9] public genFeeList = [10, 5, 5, 5, 5, 5, 5, 5, 5];

    address public tokenB;

    uint256 public usdts1 = 10;

    uint256 public lps1 = 10;
    uint256 public usdts2 = 40;

    uint256 public skys1 = 40;

    address public usdtw1;
    address public usdtw2;

    address public skyc;

    mapping(address => address) public _referrerByAddr;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    AutoSwap public rewardWallet;
    AutoSwap public usdtas1;
    AutoSwap public usdtas2;

    AutoSwap public rewardas1;

    AutoSwap public skyas1;

    AutoSwap public _autoSwap;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    address public prevBuyer;

    uint256 public basePrice;
    uint256 public markPrice;
    uint256 public highPrice;
    uint256 public prevPrice;

    uint256 public markRate;
    uint256 public deflationRate = 10 ** 20;
    uint256 public constant deflationAnchor = 10 ** 20;

    bool public swapEnabled = true;
    bool public _pairState = false;

    bool private swapping;

    constructor() ERC20("WORLD", "WORLD") {
        if (block.chainid == 56) {
            uniswapV2Router = IUniswapV2Router02(
                0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
            tokenB = address(0x55d398326f99059fF775485246999027B3197955);
        } else {
            uniswapV2Router = IUniswapV2Router02(
                0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0
            );
            tokenB = address(0x7afd064DaE94d73ee37d19ff2D264f5A2903bBB0);
        }

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), tokenB);

        uniswapV2Pair = _uniswapV2Pair;

        _mint(msg.sender, total);
        _balances[msg.sender] = total;

        rewardWallet = new AutoSwap(address(this));
        usdtas1 = new AutoSwap(address(this));
        usdtas2 = new AutoSwap(address(this));
        rewardas1 = new AutoSwap(address(this));
        skyas1 = new AutoSwap(address(this));
        _autoSwap = new AutoSwap(address(this));

        usdtw1 = address(0xd4e9b1b216a9e227C735483e076B09c42ac24a09);
        usdtw2 = address(0xefc381550DcbeB203ED298044512BE7A0851dd46);

        _taxExclude[address(rewardWallet)] = true;
        _taxExclude[address(usdtas1)] = true;
        _taxExclude[address(usdtas2)] = true;
        _taxExclude[address(rewardas1)] = true;
        _taxExclude[address(skyas1)] = true;
        _taxExclude[address(_autoSwap)] = true;
        _taxExclude[address(msg.sender)] = true;
        _taxExclude[address(this)] = true;


        _deflationExclude[uniswapV2Pair] = true;
        _deflationExclude[address(rewardWallet)] = true;
        _deflationExclude[address(usdtas1)] = true;
        _deflationExclude[address(usdtas2)] = true;
        _deflationExclude[address(rewardas1)] = true;
        _deflationExclude[address(skyas1)] = true;
        _deflationExclude[address(_autoSwap)] = true;
        _deflationExclude[address(msg.sender)] = true;
        _deflationExclude[address(this)] = true;
        
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return deflationFrom(account, _balances[account]);
        // return _balances[account].mul(deflationRate).div(deflationAnchor);
    }

    function deflationFrom(address owner, uint256 amount)
        public
        view
        returns (uint256)
    {
        (bool senderPair, ) = isPair(owner, address(0), address(this));
        if (senderPair || _deflationExclude[owner]) {
            return amount;
        }
        return amount.mul(deflationRate).div(deflationAnchor);
    }

    function reductionFrom(address owner, uint256 amount)
        public
        view
        returns (uint256)
    {
        (bool senderPair, ) = isPair(owner, address(0), address(this));
        if (senderPair || _deflationExclude[owner]) {
            return amount;
        }
        return amount.mul(deflationAnchor).div(deflationRate);
    }

    function isPair(
        address sender,
        address recipient,
        address token
    ) public view returns (bool senderPair, bool recipientPair) {
        if (isContract(sender)) {
            try IUniswapV2Pair(sender).token0() returns (address token0) {
                if (token0 == token) {
                    senderPair = true;
                }
            } catch {}
            if (!senderPair) {
                try IUniswapV2Pair(sender).token1() returns (address token1) {
                    if (token1 == token) {
                        senderPair = true;
                    }
                } catch {}
            }
        }

        if (isContract(recipient)) {
            try IUniswapV2Pair(recipient).token0() returns (address token0) {
                if (token0 == token) {
                    recipientPair = true;
                }
            } catch {}
            if (!recipientPair) {
                try IUniswapV2Pair(recipient).token1() returns (
                    address token1
                ) {
                    if (token1 == token) {
                        recipientPair = true;
                    }
                } catch {}
            }
        }
    }

    function lockPair() public onlyOwner {
        _pairState = false;
    }

    function unLockPair() public onlyOwner {
        _pairState = true;
    }

    function updateUsdtw1t(address _address) public onlyOwner {
        usdtw1 = _address;
    }

    function updateUsdtw2t(address _address) public onlyOwner {
        usdtw2 = _address;
    }

    function updateSky(address _address) public onlyOwner {
        skyc = _address;
        _taxExclude[_address] = true;
        _deflationExclude[_address] = true;
    }

    function updateTaxExclude(address account, bool enabled) public onlyOwner {
        _taxExclude[account] = enabled;
    }

    function updateDeflationExclude(address account, bool enabled) public onlyOwner {
        _deflationExclude[account] = enabled;
    }

    function updateRewardWallet(address _address) public onlyOwner {
        require(address(rewardWallet) != _address, "Same");
        rewardWallet.withdraw(tokenB, _address);
        rewardWallet = AutoSwap(_address);
        require(rewardWallet.owner() != address(0), "Invalid address");
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "zero amount");

        _tokenTransfer(sender, recipient, amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        if (
            balanceOf(recipient) == 0 &&
            _referrerByAddr[recipient] == address(0) &&
            !isContract(sender) &&
            !isContract(recipient)
        ) {
            if (_referrerByAddr[sender] != recipient) {
                _referrerByAddr[recipient] = sender;
            }
        }
            

        uint256 rAmount1 = reductionFrom(sender, tAmount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= rAmount1,
            "ERC20: transfer amount exceeds balance"
        );

        unchecked {
            _balances[sender] = senderBalance - rAmount1;
        }
        uint256 tokens = tAmount;
        bool takeFee = true;
        if (_taxExclude[sender] || _taxExclude[recipient]) {
            takeFee = false;
        }
        if (takeFee) {
            require(_pairState, "pair is closed");
        }
        if (
            basePrice == 0 &&
            balanceOf(uniswapV2Pair) > 0 &&
            IERC20(tokenB).balanceOf(uniswapV2Pair) > 0
        ) {
            basePrice = worldPrice();
            highPrice = basePrice;
            markPrice = basePrice;
            prevPrice = basePrice;
            markRate = 1;
        } else if (basePrice > 0) {
            uint256 nowPrice = worldPrice();

            uint256 _rate = nowPrice.div(basePrice);
            uint256 rewardPoolBalance = balanceOf(
                address(rewardWallet)
            );

            if (_rate > markRate) {
                uint256 diffRate = _rate.sub(markRate);
                for (uint256 i = 0; i < diffRate; i++) {
                    deflationRate = deflationRate.mul(99).div(100);
                    uint256 rewardb = rewardPoolBalance.div(5);
                    uint256 rRewardb1 = reductionFrom(address(prevBuyer), rewardb);
                    if (rewardb > 0 && _balances[address(rewardWallet)] >= rRewardb1) {
                        
                        _balances[address(rewardWallet)] = _balances[address(rewardWallet)]-rRewardb1;

                        uint256 rRewardb2 = reductionFrom(address(prevBuyer), rewardb);
                        _balances[address(prevBuyer)] += rRewardb2;
                        emit Transfer(address(rewardWallet), address(prevBuyer), rewardb);
                    }
                    
                }
                markRate = _rate;
            }

            if (nowPrice > highPrice) {
                if (nowPrice >= prevPrice.mul(105).div(100)) {
                    uint256 rewardb = rewardPoolBalance.div(10);
                    uint256 rRewardb1 = reductionFrom(address(prevBuyer), rewardb);

                    if (rewardb > 0 && _balances[address(rewardWallet)] >= rRewardb1) {

                        _balances[address(rewardWallet)] = _balances[address(rewardWallet)]-rRewardb1;

                        uint256 rRewardb2 = reductionFrom(address(prevBuyer), rewardb);
                        _balances[address(prevBuyer)] += rRewardb2;
                        emit Transfer(address(rewardWallet), address(prevBuyer), rewardb);
                    }
                }
                highPrice = nowPrice;
            }
            prevPrice = nowPrice;
        }

        if (sender == uniswapV2Pair) {
            prevBuyer = recipient;
        }

        if (sender == uniswapV2Pair && takeFee) {
            
            if (teamFee > 0) {
                uint256 teamTokens = tAmount.mul(teamFee).div(1000);
                tokens = tokens.sub(teamTokens);
                uint256 rTeamTokens = reductionFrom(
                    address(usdtas1),
                    teamTokens
                );
                _balances[address(usdtas1)] += rTeamTokens;
                emit Transfer(sender, address(usdtas1), teamTokens);
            }

            if (rewardFee > 0) {
                uint256 rewardTokens = tAmount.mul(rewardFee).div(1000);
                tokens = tokens.sub(rewardTokens);
                uint256 rRewardTokens = reductionFrom(
                    address(rewardWallet),
                    rewardTokens
                );
                _balances[address(rewardWallet)] += rRewardTokens;
                emit Transfer(sender, address(rewardWallet), rewardTokens);
            }

            if (liquidityFee > 0) {
                uint256 liquidityTokens = tAmount.mul(liquidityFee).div(1000);
                tokens = tokens.sub(liquidityTokens);
                uint256 rLiquidityTokens = reductionFrom(
                    address(uniswapV2Pair),
                    liquidityTokens
                );

                _balances[address(uniswapV2Pair)] += rLiquidityTokens;
                emit Transfer(sender, address(uniswapV2Pair), liquidityTokens);
            }

            if (skyFee > 0) {
                uint256 skyTokens = tAmount.mul(skyFee).div(1000);
                tokens = tokens.sub(skyTokens);
                uint256 rSkyTokens = reductionFrom(address(skyas1), skyTokens);
                _balances[address(skyas1)] += rSkyTokens;
                emit Transfer(sender, address(skyas1), rSkyTokens);
            }

            if (genFee > 0) {
                uint256 genFees = tAmount.mul(genFee).div(1000);

                address taxer = sender;
                if (sender == uniswapV2Pair) {
                    taxer = recipient;
                }

                for (uint256 i = 0; i < genFeeList.length; i++) {
                    taxer = _referrerByAddr[taxer];
                    if (taxer == address(0)) {
                        taxer = address(deadWallet);
                    }
                    uint256 oGenFee = genFeeList[i];
                    uint256 oGenFees = genFees.mul(oGenFee).div(genFee);
                    uint256 rOGenFeess = reductionFrom(address(taxer), oGenFees);
                    _balances[address(taxer)] += rOGenFeess;

                    tokens = tokens.sub(oGenFees);
                    emit Transfer(sender, taxer, oGenFees);
                }
            }
        } else if (recipient == uniswapV2Pair && takeFee) {
            {
                uint256 usdts1Tokens = tAmount.mul(usdts1).div(1000);
                tokens = tokens.sub(usdts1Tokens);
                uint256 rUsdts1Tokens = reductionFrom(
                    address(usdtas1),
                    usdts1Tokens
                );
                _balances[address(usdtas1)] += rUsdts1Tokens;
                emit Transfer(sender, address(usdtas1), usdts1Tokens);
            }

            {
                uint256 usdts2Tokens = tAmount.mul(usdts2).div(1000);
                tokens = tokens.sub(usdts2Tokens);
                uint256 rUsdts2Tokens = reductionFrom(
                    address(usdtas2),
                    usdts2Tokens
                );
                _balances[address(usdtas2)] += rUsdts2Tokens;
                emit Transfer(sender, address(usdtas2), usdts2Tokens);
            }

            {
                uint256 liquidityTokens = tAmount.mul(lps1).div(1000);
                tokens = tokens.sub(liquidityTokens);
                uint256 rLiquidityTokens = reductionFrom(
                    address(uniswapV2Pair),
                    liquidityTokens
                );
                _balances[address(uniswapV2Pair)] += rLiquidityTokens;
                emit Transfer(sender, address(uniswapV2Pair), liquidityTokens);
            }

            uint256 skyTokens = tAmount.mul(skys1).div(1000);
            {
                tokens = tokens.sub(skyTokens);

                uint256 rSkyTokens = reductionFrom(address(this), skyTokens);
                _balances[address(this)] += rSkyTokens;
                emit Transfer(sender, address(this), skyTokens);
            }

            {
                if (genFee > 0) {
                    uint256 genFees = tAmount.mul(genFee).div(1000);

                    address taxer = sender;
                    if (sender == uniswapV2Pair) {
                        taxer = recipient;
                    }

                    for (uint256 i = 0; i < genFeeList.length; i++) {
                        taxer = _referrerByAddr[taxer];
                        if (taxer == address(0)) {
                            taxer = address(deadWallet);
                        }
                        uint256 oGenFee = genFeeList[i];
                        uint256 oGenFees = genFees.mul(oGenFee).div(genFee);
                        uint256 rOGenFeess = reductionFrom(address(taxer), oGenFees);
                        _balances[address(taxer)] += rOGenFeess;

                        tokens = tokens.sub(oGenFees);
                        emit Transfer(sender, taxer, oGenFees);
                    }
                }
            }

            if (!swapping) {
                if (swapEnabled) {
                    swapping = true;
                    swapTokensForSky(skyTokens, address(this));
                    uint256 skyBalance = IERC20(skyc).balanceOf(address(this));
                    if (skyBalance > 0) {
                        IERC20(skyc).transfer(sender, skyBalance);
                    }
                    swapping = false;
                    _swap();
                }
                
            }
        }

        uint256 rTokens = reductionFrom(recipient, tokens);
        _balances[recipient] += rTokens;

        emit Transfer(sender, recipient, tokens);
    }

    function worldPrice2() public view returns (uint256) {
        // uint256[] memory amounts = _router.getAmountsIn(_amountOut, path);
        address[] memory path = new address[](2);
        path[0] = tokenB;
        path[1] = address(this);

        uint256 oneWorld = 10**(decimals()-10);

        uint256[] memory amounts = uniswapV2Router.getAmountsIn(oneWorld, path);
        uint256 oneWorldPrice = amounts[0]*10**10;
        return oneWorldPrice;
        // return
        //     IERC20(tokenB).balanceOf(uniswapV2Pair).mul(10**decimals()).div(
        //         balanceOf(uniswapV2Pair)
        //     );
    }

    function worldPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenB;
        

        // uint256 oneTokenB = 10**IERC20Metadata(tokenB).decimals();

        // uint256[] memory amounts = uniswapV2Router.getAmountsIn(oneTokenB.div(10**6), path);
        // uint256 oneUsdtPrice = amounts[0];
        // uint256 totalWorld = oneUsdtPrice.mul(10**6);

        // return oneTokenB.mul(10**decimals()).div(totalWorld);

        uint256 tokens = IERC20(tokenB).balanceOf(uniswapV2Pair);
        if (tokens < 1000) {
            return 0;
        }
        try uniswapV2Router.getAmountsIn(tokens.div(1000), path) returns (uint256[] memory amounts) {
            // uint256[] memory amounts = uniswapV2Router.getAmountsIn(tokens.div(100), path);
            uint256 oneUsdtPrice = amounts[0];
            uint256 totalWorld = oneUsdtPrice.mul(10**6);

            return tokens.div(1000).mul(10**decimals()).div(totalWorld);
        } catch {
            return 0;
        }
        

        
    }

    function swapAll() public {
        if (!swapping) {
            _swap();
        }
    }

    function _swap() private lockSwap {
        

        uint256 liquidityTokens = balanceOf(address(this));
        if (liquidityTokens > 0) {
            swapAndLiquify(liquidityTokens);
        }

        usdtas1.withdraw(address(this));
        swapTokensForTokenB(balanceOf(address(this)), usdtw1);

        usdtas2.withdraw(address(this));
        swapTokensForTokenB(balanceOf(address(this)), usdtw2);

        skyas1.withdraw(address(this));
        swapTokensForSky(balanceOf(address(this)), deadWallet);
    }

    function swapTokensForTokenB(uint256 tokenAmount, address recipient)
        private
    {
        if (tokenAmount == 0) return;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(tokenB);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            recipient,
            block.timestamp
        );
    }

    function swapTokensForSky(uint256 tokenAmount, address recipient) private {
        if (tokenAmount == 0) return;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = address(tokenB);
        path[2] = address(skyc);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            recipient,
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount, address recipient) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(recipient),
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 tokens) private {
        if (tokens == 0) {
            return;
        }
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        address receiver = address(this);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(tokenB).balanceOf(receiver);

        // swap tokens for TokenB
        swapTokensForTokenB(half, address(_autoSwap)); // <- this breaks the USDT -> HATE swap when swap+liquify is triggered
        _autoSwap.withdraw(tokenB);

        // how much ETH did we just swap into?
        uint256 newBalance = IERC20(tokenB).balanceOf(receiver).sub(
            initialBalance
        );

        // add liquidity to uniswap
        addLiquidityForTokenB(otherHalf, newBalance);
    }

    function addLiquidityForTokenB(uint256 amountA, uint256 amountB) private {
        if (amountA == 0 || amountB == 0) return;
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), amountA);
        IERC20(tokenB).approve(address(uniswapV2Router), amountB);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            address(tokenB),
            amountA,
            amountB,
            0,
            0,
            address(usdtw1),
            block.timestamp
        );
    }

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }

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
}

contract AutoSwap {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function withdraw(address token) public {
        require(msg.sender == owner, "caller is not owner");
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer(msg.sender, balance);
        }
    }

    function withdraw(address token, uint256 amount) public {
        require(msg.sender == owner, "caller is not owner");
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(amount > 0 && balance >= amount, "Illegal amount");
        IERC20(token).transfer(msg.sender, amount);
    }

    function withdraw(address token, address to) public {
        require(msg.sender == owner, "caller is not owner");
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer(to, balance);
        }
    }
}