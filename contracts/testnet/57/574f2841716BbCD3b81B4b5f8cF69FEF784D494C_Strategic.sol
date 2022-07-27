/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// File: Uniswap.sol


pragma solidity ^0.8.0;

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
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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

// File: Token.sol

pragma solidity ^0.8.0;






interface IBPContract {

    function protect(address sender, address receiver, uint256 amount) external;

}

contract MAoE is Context, ERC20, Ownable {
    mapping(address => uint256) private adminlist;
    mapping(address => uint256) private blacklist;

    address BUSD;
    address addressReceiver;
    address addressTreasury;
    address addressBurn;

    address public uniswapV2Pair;

    uint256 public sellFeeRate = 200;
    uint256 public buyFeeRate = 0;
    uint256 public transferRate = 0;
    uint256 public antiBot = 0;
    uint256 percentAmountWhale = 100;
    address private constant UNISWAP_V2_ROUTER =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

     uint256 public burnRate = 2000;
     uint256 public treasuryRate = 5000;


    IBPContract public bpContract;
    bool public bpEnabled;
    bool public bpDisabledForever;

    /* 
================================================================
                        CONSTRUCTOR
================================================================
 */

    constructor(address _BUSD, address _addressReceiver, address _addressTreasury, address _addressBurn)
        ERC20("MAoE Token", "MAoE")
    {
        _mint(msg.sender, 250*10**6 * 10**18);
        adminlist[msg.sender] = 1;

        BUSD = _BUSD;
        addressReceiver = _addressReceiver;
        addressTreasury = _addressTreasury;
        addressBurn = _addressBurn;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), BUSD);
    }

    /*
===================================================
                    MODIFIER
===================================================
 */
    modifier onlyAdmin() {
        require(adminlist[_msgSender()] == 1, "OnlyAdmin");
        _;
    }

    modifier isNotInBlackList(address account) {
        require(!checkBlackList(account), "Revert blacklist");
        _;
    }

    modifier isNotAddressZero(address account) {
        require(account != address(0), "ERC20: transfer from the zero address");
        _;
    }

    /*
===================================================
                CHECK FUNCTION
===================================================
 */
    function checkAdmin(address account) public view returns (bool) {
        return adminlist[account] > 0;
    }

    function checkBlackList(address account) public view returns (bool) {
        return blacklist[account] > 0;
    }

    function checkAntiBot() public view returns (bool) {
        return antiBot == 1 ? true : false;
    }

    /*
===================================================
                    BOT PREVENT
===================================================
 */

    function setBPContract(address addr)
        public
        onlyOwner
    {
        require(addr != address(0), "BP address cannot be 0x0");

        bpContract = IBPContract(addr);
    }

    function setBPEnabled(bool enabled)
        public
        onlyOwner
    {
        bpEnabled = enabled;
    }

    function setBPDisableForever()
        public
        onlyOwner
    {
        require(!bpDisabledForever, "Bot protection disabled");

        bpDisabledForever = true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        if (bpEnabled && !bpDisabledForever) {
            bpContract.protect(from, to, amount);
        }

        super._beforeTokenTransfer(from, to, amount);

    }

 /*
===================================================
                    SWAP FUNCTION
===================================================
 */

    // function swap(
    //     address _tokenIn,
    //     address _tokenOut,
    //     uint256 _amountIn,
    //     uint256 _amountOutMin,
    //     address _to
    // ) internal {
    //     super.transferFrom(msg.sender, address(this), _amountIn);
    //     super.approve(UNISWAP_V2_ROUTER, _amountIn);
    //     address[] memory path;
    //     if (_tokenIn == BUSD || _tokenOut == BUSD) {
    //         path = new address[](2);
    //         path[0] = _tokenIn;
    //         path[1] = _tokenOut;
    //     } else {
    //         path = new address[](3);
    //         path[0] = _tokenIn;
    //         path[1] = BUSD;
    //         path[2] = _tokenOut;
    //     }
    //     IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
    //         _amountIn,
    //         _amountOutMin,
    //         path,
    //         _to,
    //         block.timestamp
    //     );
    // }

    // function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) internal view returns (uint256) {
    //     address[] memory path;
    //     if (_tokenIn == BUSD || _tokenOut == BUSD) {
    //         path = new address[](2);
    //         path[0] = _tokenIn;
    //         path[1] = _tokenOut;
    //     } else {
    //         path = new address[](3);
    //         path[0] = _tokenIn;
    //         path[1] = BUSD;
    //         path[2] = _tokenOut;
    //     }
    //     uint256[] memory amountOutMins = IUniswapV2Router02(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn, path);
    //     return amountOutMins[path.length -1];  
    // }  

    /*
===================================================
            TRANSFER & FEE CALCULATION
===================================================
 */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        uint256 feeRate = _feeCalculation(sender, recipient, amount);
        if (feeRate > 0) {
            uint256 _fee = (amount * feeRate) / 10000;
            uint256 _burnAmount = _fee * burnRate / 10000;
            uint256 _treasuryAmount = _fee * treasuryRate / 10000;
            uint256 _profitAmount = _fee - _burnAmount - _treasuryAmount;

            // uint256 _amountOutMin = getAmountOutMin(address(this), BUSD, _fee1);
            // swap(address(this), BUSD, _fee1, _amountOutMin, addressReceiver);
            super._transfer(sender, addressReceiver ,_profitAmount);
            super._transfer(sender, addressTreasury ,_treasuryAmount);
            super._transfer(sender, addressBurn ,_burnAmount);

            amount = amount - _fee;
        }
        super._transfer(sender, recipient, amount);
    }

    function _feeCalculation(
        address sender,
        address recipient,
        uint256 amount
    )
        internal view
        isNotInBlackList(sender)
        isNotInBlackList(recipient)
        isNotAddressZero(sender)
        isNotAddressZero(recipient)
        returns (uint256)
    {
        uint256 feeRate = 0;

        if (checkAntiBot()) {
            require(checkAdmin(sender) || checkAdmin(recipient), "Anti Bot");
            feeRate = 0;
        } else {
            if (recipient == uniswapV2Pair) {
                if (checkAdmin(sender)) {
                    feeRate = 0;
                } else {
                    require(
                        amount <=
                            (this.balanceOf(uniswapV2Pair) *
                                percentAmountWhale) /
                                10000,
                        "Revert whale transaction"
                    );
                    feeRate = sellFeeRate;
                }
            } else if (sender == uniswapV2Pair) {
                if (checkAdmin(recipient)) {
                    feeRate = 0;
                } else {
                    require(
                        amount <=
                            (this.balanceOf(uniswapV2Pair) *
                                percentAmountWhale) /
                                10000,
                        "Revert whale transaction"
                    );
                    feeRate = buyFeeRate;
                }
            } else {
                if (checkAdmin(sender)) {
                    feeRate = 0;
                } else {
                    feeRate = transferRate;
                }
            }
        }
        return feeRate;
    }
/*----------------------------------------------------------------
                            WITHDRAW
 -----------------------------------------------------------------*/
    function withdrawTokenForOwner(uint256 amount) public onlyOwner {
        this.transfer(owner(), amount);
        emit WithDraw(amount);
    }

    function withdrawBUSDForOwner(address token_address, uint256 amount)
        public
        onlyOwner
    {
        IERC20 busd = IERC20(token_address);
        busd.transfer(owner(), amount);
        emit WithDraw(amount);
    }
/*
===================================================
                        EVENT
===================================================
 */
    event ChangeBuyFeeRate(uint256 rate);
    event ChangeSellFeeRate(uint256 rate);
    event ChangeBurnRate(uint256 rate);
    event ChangeTransferRate(uint256 rate);
    event ChangePercentAmountWhale(uint256 rate);
    event ActivateAntiBot(uint256 status);
    event DeactivateAntiBot(uint256 status);
    event AddedAdmin(address account);
    event AddedBatchAdmin(address[] accounts);
    event RemovedAdmin(address account);
    event TransferStatus(address sender, address recipient, uint256 amount);
    event WithDraw(uint256 amount);
    /*
===================================================
                UPDATE FUNCTION
===================================================
 */
    function changeBuyFeeRate(uint256 rate) external onlyAdmin {
        buyFeeRate = rate;
        emit ChangeBuyFeeRate(buyFeeRate);
    }

    function changeBurnRate(uint256 rate) external onlyAdmin {
        burnRate = rate;
        emit ChangeBurnRate(burnRate);
    }

    function changeSellFeeRate(uint256 rate) external onlyAdmin {
        sellFeeRate = rate;
        emit ChangeSellFeeRate(sellFeeRate);
    }

    function changeTransferRate(uint256 rate) external onlyAdmin {
        transferRate = rate;
        emit ChangeTransferRate(transferRate);
    }

    function changePercentAmountWhale(uint256 rate) external onlyAdmin {
        percentAmountWhale = rate;
        emit ChangePercentAmountWhale(sellFeeRate);
    }

    /*
===================================================
                CHANGE ANTIBOT STATUS
===================================================
 */

    function activateAntiBot() external onlyAdmin {
        antiBot = 1;
        emit ActivateAntiBot(antiBot);
    }

    function deactivateAntiBot() external onlyAdmin {
        antiBot = 0;
        emit DeactivateAntiBot(antiBot);
    }

    /*
===================================================
                    ADMINLIST
===================================================
 */
    function addToAdminlist(address account) external onlyOwner {
        adminlist[account] = 1;
        emit AddedAdmin(account);
    }

    function addBatchToAdminlist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            adminlist[accounts[i]] = 1;
        }
        emit AddedBatchAdmin(accounts);
    }

    function removeFromAdminlist(address account) external onlyOwner {
        adminlist[account] = 0;
        emit RemovedAdmin(account);
    }

    /*
===================================================
                    BLACKLIST
===================================================
 */

    function addToBlacklist(address account) external onlyOwner {
        blacklist[account] = 1;
        emit AddedAdmin(account);
    }

    function addBatchToBlacklist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklist[accounts[i]] = 1;
        }
        emit AddedBatchAdmin(accounts);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        blacklist[account] = 0;
        emit RemovedAdmin(account);
    }
}

// File: Strategic.sol

pragma solidity ^0.8.0;


contract Strategic is Ownable {
    uint256 public startTime;
    uint256 public cliff;
    uint256 public totalPeriods;
    uint256 public timePerPeriod;
    uint256 public firstReturn;
    uint256 public periodReturn;
    address private tokenAddress;
    uint256 public numOfAccount = 0;
    uint256 public status = 1;

    mapping(uint256 => address) public vestingList;
    mapping(address => uint256) public userAmount;
    mapping(address => uint256) public userRemain;
    mapping(address => uint256) public userClaimed;
    mapping(address => uint256) public adminlist;
    mapping(address => uint256) public blacklist;

    MAoE MATK;

    constructor(
        address _tokenAddress,
        uint256 _startTime,
        uint256 _cliff,
        uint256 _totalPeriods,
        uint256 _timePerPeriod,
        uint256 _firstReturn,
        uint256 _periodReturn,
        address[] memory accounts,
        uint256[] memory packages
    ) {
        tokenAddress = _tokenAddress;
        MATK = MAoE(tokenAddress);
        firstReturn = _firstReturn;
        periodReturn = _periodReturn;
        startTime = _startTime;
        cliff = _cliff;
        totalPeriods = _totalPeriods;
        timePerPeriod = _timePerPeriod;
        adminlist[msg.sender] = 1;
        for (uint256 i = 0; i < accounts.length; i++) {
            if (userAmount[accounts[i]] == 0) {
                vestingList[numOfAccount] = accounts[i];
                numOfAccount++;
                userClaimed[accounts[i]] = 0;
            }
            userAmount[accounts[i]] = packages[i] * 10**18;
            userRemain[accounts[i]] = userAmount[accounts[i]];
        }
    }

    /*
===================================================
                    MODIFIERS
===================================================
 */
    modifier onlyAdmin() {
        require(adminlist[_msgSender()] == 1, "OnlyAdmin");
        _;
    }

    modifier isNotInBlackList(address account) {
        require(!checkBlackList(account), "Revert blacklist");
        _;
    }

    modifier isNotAddressZero(address account) {
        require(account != address(0), "ERC20: transfer from the zero address");
        _;
    }

    modifier eventGoingOn() {
        require(status == 1, "This feature has been stopped!");
        _;
    }

/* 
================================================================
                        OPEN/CLOSE EVENT
================================================================
 */
    function startEvent() public onlyAdmin {
        status = 1;
        emit EventStarted(msg.sender, status);
    }

    function stopEvent() public onlyAdmin {
        status = 0;
        emit EventStopped(msg.sender, status);
    }
    /*
===================================================
                    CHECK FUNCTION
===================================================
 */
    function checkAdmin(address account) public view returns (bool) {
        return adminlist[account] > 0;
    }

    function checkBlackList(address account) public view returns (bool) {
        return blacklist[account] > 0;
    }

    /*
===================================================
                ADD/REMOVE VESTING LIST
===================================================
 */

    function addToVestingList(address user, uint256 amount) public onlyAdmin {
        if (userAmount[user] == 0) {
            vestingList[numOfAccount] = user;
            numOfAccount++;
            userClaimed[user] = 0;
        }
        userAmount[user] = amount * 10**18;
        userRemain[user] = userAmount[user];
    }

    function addBatchToVestingList(address[] memory user, uint256[] memory num)
        public
        onlyAdmin
    {
        for (uint256 i = 0; i < user.length; i++) {
            addToVestingList(user[i], num[i]);
        }
    }

    function removeFromVesting(address receiver) public onlyAdmin {
        userRemain[receiver] = 0;
    }

    /*
===================================================
                    CLAIM TOKEN
===================================================
 */
    function claimTokens(address receiver) internal eventGoingOn {
        require(userRemain[receiver] > 0, "Remain Token is zero");
        uint256 claimableAmount = getClaimableAmount(receiver);
        require(claimableAmount > 0, "Claimable Token is zero");

        userClaimed[receiver] += claimableAmount;
        userRemain[receiver] = userRemain[receiver] - claimableAmount;
        MATK = MAoE(tokenAddress);
        MATK.transfer(receiver, claimableAmount);
        emit TokensClaimed(receiver, claimableAmount);
    }

    function userClaimTokens()
        external
        isNotInBlackList(msg.sender)
        isNotAddressZero(msg.sender)
    {
        claimTokens(_msgSender());
    }

    /*
===================================================
                    ADMIN CLAIM
===================================================
 */

    function claimForUser(address receiver) external onlyAdmin {
        claimTokens(receiver);
    }

    function claimBatch(address[] memory accounts) external onlyAdmin {
        for (uint256 i = 0; i < accounts.length; i++) {
            claimTokens(accounts[i]);
        }
    }

    function claimAll() external onlyAdmin {
        for (uint256 i = 0; i < numOfAccount; i++) {
            claimTokens(vestingList[i]);
        }
    }

/*
===================================================
                        UPDATE
===================================================
 */

    function changeTokenAddress(address token) external onlyAdmin {
        tokenAddress = token;
    }

/*
===================================================
                CHECK CLAIMABLE AMOUNT
===================================================
 */

    function getClaimableAmount(address receiver)
        public
        view
        returns (uint256)
    {
        if (block.timestamp < startTime) {
            return 0;
        }
        uint256 claimAmount = (userAmount[receiver] * firstReturn) / 10000;
        if (block.timestamp < startTime + cliff) {
            return claimAmount - userClaimed[receiver];
        }
        uint256 currentPeriod = (block.timestamp - (startTime + cliff)) /
            timePerPeriod;

        if (currentPeriod > totalPeriods) {
            currentPeriod = totalPeriods;
        }
        claimAmount +=
            (currentPeriod * userAmount[receiver] * periodReturn) /
            10000;
        if (claimAmount > userAmount[receiver]) {
            claimAmount = userAmount[receiver];
        }
        return claimAmount - userClaimed[receiver];
    }

    /*
===================================================
                    ADMINLIST
===================================================
 */

    function addToAdminlist(address account) external onlyOwner {
        adminlist[account] = 1;
        emit AddedAdmin(account);
    }

    function addBatchToAdminlist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            adminlist[accounts[i]] = 1;
        }
        emit AddedBatchAdmin(accounts);
    }

    function removeFromAdminlist(address account) external onlyOwner {
        adminlist[account] = 0;
        emit RemovedAdmin(account);
    }

    /*
===================================================
                    BLACKLIST
===================================================
 */

    function addToBlacklist(address account) external onlyOwner {
        blacklist[account] = 1;
        emit AddedAdmin(account);
    }

    function addBatchToBlacklist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklist[accounts[i]] = 1;
        }
        emit AddedBatchAdmin(accounts);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        blacklist[account] = 0;
        emit RemovedAdmin(account);
    }

    /*
===================================================
                    WITHDRAW
===================================================
 */

    function withdrawTokenForOwner(uint256 amount) public onlyOwner {
        MATK = MAoE(tokenAddress);
        MATK.transfer(owner(), amount);
        emit WithDraw(amount);
    }

    function withdrawBUSDForOwner(address token_address, uint256 amount)
        public
        onlyOwner
    {
        IERC20 busd = IERC20(token_address);
        busd.transfer(owner(), amount);
        emit WithDraw(amount);
    }

    /*
===================================================
                    CHECK BALANCE
===================================================
 */

    function checkBalanceOfToken() external view returns (uint256) {
        uint256 balance = MATK.balanceOf(address(this));
        return balance;
    }

    function checkBalanceOfBUSD(address token_address)
        external
        view
        returns (uint256)
    {
        IERC20 busd = IERC20(token_address);
        uint256 balance = busd.balanceOf(address(this));
        return balance;
    }

    /*
===================================================
                    EVENT
===================================================
 */
    event TokensClaimed(address receiver, uint256 tokensClaimed);
    event WithDraw(uint256 amount);
    event AddedAdmin(address account);
    event AddedBatchAdmin(address[] accounts);
    event RemovedAdmin(address account);
    event ClaimedAmount(uint256 amount, uint256 amount01);
    event EventStarted(address user, uint256 status);
    event EventStopped(address user, uint256 status);
}