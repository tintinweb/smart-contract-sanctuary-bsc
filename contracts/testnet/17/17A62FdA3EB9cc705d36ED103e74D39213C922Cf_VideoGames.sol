/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// File: contracts/Uniswap.sol


pragma solidity ^0.8.7;

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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
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

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



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

// File: contracts/Videogames.sol


pragma solidity ^0.8.4;





contract VideoGames is ERC20, ERC20Burnable, Ownable {
    string private _name;
    string private _symbol;
    /* SwapAndLiquify */
    bool private _isSwappingContractModifier;
    bool public swapAndLiquifyEnabled = true;
    /* Taxes */
    uint256 public _lpTaxBuy = 5;
    uint256 public _lpTaxSell = 5;
    uint256 public _gamePotTax = 8;
    uint256 public _marketingTax = 2;
    /* Supply */
    uint256 private _initialTotalSupply = 1000000000 * 10**decimals();
    uint256 public _lpThreshold = totalSupply() / 10000;
    /* Internal Contract Counters */
    uint256 public _contractLpTokens;
    address public _marketingWallet;
    uint256 public _contractMarketingAmount;
    uint256 public _contractGamePotTokens;
    /* Wallet Caps */
    uint256 public _maxWalletSize = 100; 
    uint256 public constant _maxSellDelay = 5 minutes;
    uint256 public _sellDelay = 0;
    /* AMM */
    mapping(address => bool) private _automatedMarketMakers;
    bool private _swapAndLiquifyEnabled;
    bool private inSwapAndLiquify;
    address public uniswapV2Pair;
    address public constant routerAddress = 0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0;
    address public constant _burnWallet = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 private router;
    mapping(address => Holder) public _holders;
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }
    struct Holder {
        // Used for sell delay & token vesting (locking)
        uint256 nextSell;
        uint256 pancakeswapTotalPurchased;
        bool excludeFromFees;
    }

    /* Game */
    int public _currentGameId = 0;
    struct Bet {
        address betWallet;
        bytes32 competitor;
        int gameId;
    }

    struct Competitor {
        string name;
        mapping(address => Bet) bets;
        address[] bettingWallets;
        uint betCount;
    }

    struct Game {
        int id;
        string name;
        bool winnerSelected;
        bytes32 winningCompetitor;
        mapping(bytes32 => Competitor) competitors;
        mapping(address => Bet) bets;
        address[] bettingWallets;
    }

    //Bet Hash - Bet
    mapping(bytes32 => Bet) public _bets;
    mapping(bytes32 => Competitor) public _competitors;
    //Incrementing Id Game - Game
    mapping(int256 => Game) public _games;

    constructor() ERC20("VideoGames", "VGB") {
        router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        _automatedMarketMakers[uniswapV2Pair] = true;
        // Exclude from fees
        _holders[_msgSender()].excludeFromFees = true;
        _holders[address(this)].excludeFromFees = true;
        _mint(_msgSender(), _initialTotalSupply);
    }

    function decimals() public pure override returns (uint8) {
        return 9;
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
        override
        returns (bool)
    {
        bool overMinTokenBalance = _contractLpTokens >= _lpThreshold;
        if (
            overMinTokenBalance &&
            !_isSwappingContractModifier &&
            _msgSender() != routerAddress &&
            swapAndLiquifyEnabled
        ) {
            swapContractTokens();
        }

        bool isBuy = _automatedMarketMakers[_msgSender()];
        bool isSell = _automatedMarketMakers[to];
        //apply taxes to amount

        if (isBuy || isSell) {
            uint256 gamePotTaxAmount = (amount * _gamePotTax) / 100;
            uint256 marketingTaxAmount = (amount * _marketingTax) / 100;
            uint256 lPTaxAmount;
            if (isBuy) {
                // Balance + amount cannot exceed 1 % of circulating supply (_maxWalletSize)
                require(balanceOf(to) + amount <= getMaxWalletSize(), "Balance + amount cannot exceed 1 % of circulating supply.");
                lPTaxAmount = (amount * _lpTaxBuy) / 100;
                // Reset sell delay
                _holders[to].nextSell = block.timestamp + _sellDelay;
            } else if (isSell) {
                lPTaxAmount = (amount * _lpTaxSell) / 100;
                _holders[_msgSender()].nextSell = block.timestamp + _sellDelay;
            }
            //require amount be greater than the sum of taxes
            require(
                amount >= lPTaxAmount + gamePotTaxAmount + marketingTaxAmount,
                "Amount must be greater than the sum of taxes"
            );
            //send lpTaxAmount to Contract
            _transfer(_msgSender(), address(this), lPTaxAmount);
            _contractLpTokens += lPTaxAmount;
            //add lpTaxAmount to contractLpTokens
            //send gamePotTaxAmount to Contract
            _transfer(_msgSender(), address(this), gamePotTaxAmount);
            //add gamePotTaxAmount to contractGamePotTokens
            _contractGamePotTokens += gamePotTaxAmount;
            //send marketingTaxAmount to marketingWallet
            _transfer(_msgSender(), address(this), marketingTaxAmount);
            _contractMarketingAmount += marketingTaxAmount;
            //subtract these amounts from amount
            amount -= lPTaxAmount + gamePotTaxAmount + marketingTaxAmount;
            if(isBuy) {
                //Set pancake total purchased amount
                _holders[to].pancakeswapTotalPurchased = _holders[to].pancakeswapTotalPurchased + amount;
            }
        } else {
            require(balanceOf(to) + amount <= getMaxWalletSize());
            transferExcluded(to, amount);
        }
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function getMaxWalletSize() public view returns (uint256) {
        return totalSupply() / _maxWalletSize;
    }

    function transferExcluded(address to, uint256 amount)
        private
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function swapContractTokens() private lockTheSwap {
        uint256 remainingBalance = balanceOf(address(this)) - _contractLpTokens - _contractMarketingAmount;
        require(
            remainingBalance >= 0,
            "Contract cannot liquify if there are no tokens remaining"
        );

        (uint256 tokensLiquidity, uint256 BNBLiquidity) = swapAndLiquify(_contractLpTokens, _contractMarketingAmount); 
   
        // remove allocated tokens from tally
        _contractLpTokens = 0;
        _contractMarketingAmount = 0;
        emit SwapAndLiquify(tokensLiquidity, BNBLiquidity);
    }

    function swapAndLiquify(uint256 tokensForLP, uint256 tokensForMarketing) private returns (uint256, uint256) {
        if(tokensForMarketing > 0) {
            //swap tokens for Marketing to BNB and send to marketing wallet
            // swap the tokens for BNB
            _swapTokensForBNB(tokensForMarketing, _marketingWallet);
        }
        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // split the tokensForLP into halves
        uint256 half = tokensForLP / 2;
        uint256 otherHalf = tokensForLP - half;
        
        // swap tokens for BNB
        _swapTokensForBNB(half, address(this));

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to pancakeswap
        addLiquidity(otherHalf, newBalance, _burnWallet);
        return (half, newBalance);
    }

    function _swapTokensForBNB(uint256 amount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        //WBNB
        path[1] = address(router.WETH());
        
        _approve(address(this), address(router), amount);
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            // Receiver address
            to,
            block.timestamp
        );
    }

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address to
    ) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            to,
            block.timestamp
        );
    }

    function createGame(string memory name) public {
        if(_currentGameId > 0) {
            require(_games[_currentGameId - 1].winnerSelected, "Winner not selected for previous game.");
            _currentGameId++;
        }
        //create game
        _games[_currentGameId].id = _currentGameId;
        _games[_currentGameId].name = name;
    }

    function addCompetitors(int gameId, string[] memory names) public onlyOwner {
        require(gameId == _currentGameId, "Game id does not match current game id.");
        require(names.length > 0, "No competitor names.");
        for(uint i = 0; i < names.length; i++) {
            bytes32 competitorHash = getHashOfCompetitor(gameId, names[i]);
            _competitors[competitorHash].name = names[i];
            _games[gameId].competitors[competitorHash].name = names[i];
        }
    }

    function bet(int gameId, string memory name) public {
        require(gameId == _currentGameId, "Game id does not match current game id.");
        bytes32 competitorHash = getHashOfCompetitor(gameId, name);
        //check is hash exists on game
        require(compareStrings(_games[gameId].competitors[competitorHash].name, name), "Competitor name does not match.");
        bytes32 betHash = getHashOfBet(gameId, _msgSender());
        //ensure bet doesn't exist on game
        require(_games[gameId].bets[_msgSender()].competitor == 0, "Bet has already been placed.");
        
        //GAMES
        //add wallet to game reference
        _games[gameId].bettingWallets.push(_msgSender());
        //add bet to game reference
        _games[gameId].bets[_msgSender()].competitor = competitorHash;
        _games[gameId].bets[_msgSender()].betWallet = _msgSender();
        _games[gameId].bets[_msgSender()].gameId = gameId;

        //add competitor to game reference
        _games[gameId].competitors[competitorHash].betCount++;
        _games[gameId].competitors[competitorHash].bettingWallets.push(_msgSender());
        _games[gameId].competitors[competitorHash].bets[_msgSender()].gameId = gameId;
        _games[gameId].competitors[competitorHash].bets[_msgSender()].competitor = competitorHash;
        _games[gameId].competitors[competitorHash].bets[_msgSender()].betWallet = _msgSender();
        
        //add bet to competitor reference
        _competitors[competitorHash].betCount++;
        _competitors[competitorHash].bettingWallets.push(_msgSender());
        _competitors[competitorHash].bets[_msgSender()].gameId = gameId;
        _competitors[competitorHash].bets[_msgSender()].competitor = competitorHash;
        _competitors[competitorHash].bets[_msgSender()].betWallet = _msgSender();

        //add bet
        _bets[betHash].gameId = gameId;
        _bets[betHash].competitor = competitorHash;
        _bets[betHash].betWallet = _msgSender();
    }

    function selectWinningCompetitor(bytes32 winningCompetitorHash) public onlyOwner {
        if(_currentGameId > 0) {
            require(_games[_currentGameId - 1].winnerSelected, "Winner not selected for previous game.");
        }
        _games[_currentGameId].winnerSelected = true;
        _games[_currentGameId].winningCompetitor = winningCompetitorHash;

        payoutPlayers(winningCompetitorHash);
    }

    function payoutPlayers(bytes32 winningCompetitorHash) private {
        //get the total payout per player
        uint256 payoutPerPlayer = getCurrentGamePotPayoutByDivisor(_games[_currentGameId].competitors[winningCompetitorHash].bettingWallets.length);
        //iterate over betCount of competitors
        for (uint i = 0; i < _competitors[winningCompetitorHash].betCount; i++) {
            address walletAddress = _competitors[winningCompetitorHash].bettingWallets[i];
            //add winnings to wallet
            transferExcluded(walletAddress, payoutPerPlayer);
            //TODO: How does this scale with gas fees?  Opt for a claim function otherwise.
        }
    }

    function getCurrentGamePotPayoutByDivisor(uint256 count) public view returns (uint256) {
        return _contractGamePotTokens / count;
    }

    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function getHashOfCompetitor(int gameId, string memory name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(gameId, name));
    }
    
    function getHashOfBet(int gameId, address wallet) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(gameId, wallet));
    }

    function getGameWalletBet(int gameId, address wallet) public view returns (address, bytes32, int) {
        bytes32 hash = getHashOfBet(gameId, wallet);
        return (_bets[hash].betWallet, _bets[hash].competitor, _bets[hash].gameId);
    }

    function getGameCompetitor(int gameId, string memory name) public view returns (string memory, address[] memory, uint) {
        bytes32 hash = getHashOfCompetitor(gameId, name);
        return (_competitors[hash].name, _competitors[hash].bettingWallets, _competitors[hash].betCount);
    }

    //Events
    event SwapAndLiquify(
        uint256 amountToken,
        uint256 amountBNB
    );
}