/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// File: Doughpad-BackEnd/contracts/Tokens/DoughRewardCloneable/IDividendTrackerCloneable.sol



pragma solidity ^0.8.4;

interface IDividendTrackerCloneable {
    function getTotalDividendsDistributed() external view returns (uint256);
    function excludeFromDividends (address account) external;
    function setBalance (address account, uint256 newBalance) external;
    function process (uint256 gasPerTracker) external returns (uint256, uint256, uint256);
    function updateMinimumBalanceForDividends (uint256 newMinBalance) external;
    function updateClaimWait (uint24 newClaimWait) external;
    function processAccount (address account, bool automatic) external returns (bool);
    function distributeDividends (uint256 amount) external;
    function initialize (string memory _name, string memory _symbol, address _rewardToken, uint24 _claimWait, uint256 _minimumTokenBalanceForDividends, address _router) external;
    function getAccount (address _account) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256);
}
// File: Doughpad-BackEnd/contracts/Router/SwapInterfaces.sol



pragma solidity ^0.8.4;


interface ISwapFactory {
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

interface ISwapPair {
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

interface ISwapRouter01 {
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


interface ISwapRouter02 is ISwapRouter01 {
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
// File: Doughpad-BackEnd/contracts/Utils/SafeMathConversion.sol



pragma solidity ^0.8.4;

/**
 * @title SafeMathConversion
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathConversion {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
    
    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}
// File: Doughpad-BackEnd/contracts/ERC20/IERC20.sol



pragma solidity ^0.8.4;

interface IERC20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
// File: Doughpad-BackEnd/contracts/ERC20/IERC20Metadata.sol



pragma solidity ^0.8.4;


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
// File: Doughpad-BackEnd/contracts/Utils/IOwnable.sol



pragma solidity ^0.8.4;

interface IOwnable {
    function transferOwnership (address newOwner) external;
    function owner() external view returns (address _owner);
}
// File: Doughpad-BackEnd/contracts/Utils/IterableMapping.sol



pragma solidity ^0.8.4;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        internal
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        internal
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
// File: Doughpad-BackEnd/contracts/Utils/Initializable.sol


// OpenZeppelin Contracts v4.4.0-rc.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}
// File: Doughpad-BackEnd/contracts/Utils/ContextUpgradeable.sol


// OpenZeppelin Contracts v4.4.0-rc.0 (utils/Context.sol)

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[20] private __gap;
}
// File: Doughpad-BackEnd/contracts/ERC20/ERC20Upgradeable.sol


// OpenZeppelin Contracts v4.4.0-rc.0 (token/ERC20/ERC20.sol)

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;

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
    function __ERC20_init(string memory name_, string memory symbol_, uint8 decimals_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_, decimals_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_, uint8 decimals_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
        return _decimals;
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
        require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
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
        require(currentAllowance >= subtractedValue, "ERC20: allowance below zero");
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
        require(sender != address(0), "ERC20: transfer from 0 address");
        require(recipient != address(0), "ERC20: transfer to 0 address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: amount exceeds balance");
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
        require(account != address(0), "ERC20: mint to 0 address");

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
        require(account != address(0), "ERC20: burn from 0 address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: amount exceeds balance");
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
        require(owner != address(0), "ERC20: approve from 0 address");
        require(spender != address(0), "ERC20: approve to 0 address");

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
    uint256[45] private __gap;
}
// File: Doughpad-BackEnd/contracts/Utils/OwnableUpgradeable.sol


// OpenZeppelin Contracts v4.4.0-rc.0 (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable, IOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual override returns (address) {
        return _owner;
    }
    
    /**
     * @dev Throws if called by any account other than the owner. Modifier gas savings
     */
    function _onlyOwner() private view {
        require(_owner == _msgSender(), "Ownable: owner only");
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _onlyOwner();
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
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: can't be 0 address");
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

    uint256[20] private __gap;
}
// File: Doughpad-BackEnd/contracts/Tokens/DoughRewardCloneable/DividendPayingTokenCloneable.sol



pragma solidity ^0.8.4;






/// @title Dividend-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable ERC20 token that allows anyone to pay and distribute rewards
///  to token holders as dividends and allows token holders to withdraw their dividends.
///  Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract DividendPayingTokenCloneable is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    using SafeMathConversion for uint256;
    using SafeMathConversion for int256;

    // With `MAGNITUDE`, we can properly distribute dividends even if the amount of received reward is small.
    // For more discussion about choosing the value of `MAGNITUDE`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 internal constant MAGNITUDE = 2**128;

    uint256 internal magnifiedDividendPerShare;
    
    address internal rewardToken;
    ISwapRouter02 internal router;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 internal totalDividendsDistributed;
    

    /// @dev This event MUST emit when a dividend is distributed to token holders.
    /// @param from The address which sends dividends to this contract.
    /// @param weiAmount The amount of distributed dividends in wei.
    event DividendsDistributed(address indexed from, uint256 weiAmount);

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws dividends from this contract.
    /// @param weiAmount The amount of withdrawn dividends in wei.
    event DividendWithdrawn(address indexed to, uint256 weiAmount);

    constructor () { }
    
    function __DividendPayingToken_init (string memory _name, string memory _symbol, address _rewardToken, address _router) internal initializer {
        require (_rewardToken != address(0) && _router != address(0), "DPT: can't use 0 address");
        __ERC20_init (_name, _symbol, 18);
        __Ownable_init();
        rewardToken = _rewardToken;
        router = ISwapRouter02 (_router);
    }
    
    receive() external payable {
        distributeDividends();
    }

    function distributeDividends() public payable {
        uint256 _totalSupply = totalSupply();

        require (_totalSupply > 0, "DPT: No tracker holders");

        ISwapRouter02 _router = router;
        address _rewardToken = rewardToken;
        uint256 amount = address(this).balance;
        
        if (amount > 100_000_000_000_000_000) {
            if (_rewardToken != _router.WETH()) {
                uint256 initialBalance = IERC20(_rewardToken).balanceOf (address(this));
                address[] memory path = new address[](2);
                path[0] = _router.WETH();
                path[1] = _rewardToken;
                
                // make the swap
                _router.swapExactETHForTokensSupportingFeeOnTransferTokens {value: amount} (
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
            
                amount = IERC20(_rewardToken).balanceOf (address(this)) - initialBalance;
            }
    
            magnifiedDividendPerShare += amount * MAGNITUDE / _totalSupply;
            emit DividendsDistributed (msg.sender, amount);
            totalDividendsDistributed += amount;
        }
    }

    function _distributeDividends (uint256 amount) internal {
        uint256 supply = totalSupply();

        require (supply > 0, "DPT: No tracker holders");

        if (amount > 0) {
            magnifiedDividendPerShare += amount * MAGNITUDE / supply;
            emit DividendsDistributed (msg.sender, amount);
            totalDividendsDistributed += amount;
        }
    }

    /// @notice Withdraws the reward distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn reward is greater than 0.
    function withdrawDividend() public virtual {
        _withdrawDividendOfUser (msg.sender);
    }

    /// @notice Withdraws the reward distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn reward is greater than 0.
    function _withdrawDividendOfUser (address user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf (user);
        
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] += _withdrawableDividend;
            emit DividendWithdrawn (user, _withdrawableDividend);
            bool success;
            address _rewardToken = rewardToken;
            
            if (_rewardToken == router.WETH())
                (success,) = payable(user).call{ value: _withdrawableDividend, gas: 3000 }("");
            else
                 success = IERC20(_rewardToken).transfer (user, _withdrawableDividend);
        
            if (!success) {
                withdrawnDividends[user] -= _withdrawableDividend;
                return 0;
            }
            
            return _withdrawableDividend;
        }

        return 0;
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf (address _owner) public view returns (uint256) {
        return withdrawableDividendOf (_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf (address _owner) public view returns (uint256) {
        return (accumulativeDividendOf(_owner) - withdrawnDividends[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf (address _owner) public view returns (uint256) {
        return withdrawnDividends[_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / MAGNITUDE
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf (address _owner) public view returns (uint256) {
        return (((magnifiedDividendPerShare * balanceOf(_owner)).toInt256Safe() + magnifiedDividendCorrections[_owner]).toUint256Safe() / MAGNITUDE);
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer (address from, address to, uint256 value) internal virtual override {
        require (false);

        int256 _magCorrection = (magnifiedDividendPerShare * value).toInt256Safe();
        magnifiedDividendCorrections[from] += _magCorrection;
        magnifiedDividendCorrections[to] -= _magCorrection;
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint (address account, uint256 value) internal override {
        super._mint (account, value);

        magnifiedDividendCorrections[account] -= (magnifiedDividendPerShare * value).toInt256Safe();
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn (address account, uint256 value) internal override {
        super._burn (account, value);

        magnifiedDividendCorrections[account] += (magnifiedDividendPerShare * value).toInt256Safe();
    }

    function _setBalance (address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf (account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance - currentBalance;
            _mint (account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance - newBalance;
            _burn (account, burnAmount);
        }
    }
}
// File: Doughpad-BackEnd/contracts/Utils/VersionedUpgradeable.sol



pragma solidity ^0.8.4;



abstract contract VersionedUpgradeable is Initializable, OwnableUpgradeable {
    string internal version;

    function __Versioned_init (string memory _version) internal initializer {
        __Versioned_init_unchained (_version);
        __Ownable_init();
    }

    function __Versioned_init_unchained (string memory _version) internal initializer {
        version = _version;
    }

    function getVersion() external view returns (string memory) {
        return version;
    }

    function setVersion (string memory _version) external onlyOwner {
        version = _version;
    }
    
    uint256[20] private __gap;
}
// File: Doughpad-BackEnd/contracts/Tokens/DoughRewardCloneable/DividendTrackerCloneable.sol



pragma solidity ^0.8.4;






contract DividendTrackerCloneable is IDividendTrackerCloneable, Initializable, DividendPayingTokenCloneable, VersionedUpgradeable {
    using SafeMathConversion for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint48) private lastClaimTimes;

    uint24 private claimWait;
    uint256 private minimumTokenBalanceForDividends;
    uint256 private lastProcessedIndex;

    event ExcludeFromDividends (address indexed account);
    event ClaimWaitUpdated (uint256 indexed newValue, uint256 indexed oldValue);
    event Claim (address indexed account, uint256 amount, bool indexed automatic);

    constructor () { }
    
    function initialize (string memory _name, string memory _symbol, address _rewardToken, uint24 _claimWait, uint256 _minimumTokenBalanceForDividends, address _router) 
        external override initializer
    {
        __DividendPayingToken_init (_name, _symbol, _rewardToken, _router);
        __Versioned_init ("0.0.2");
        updateClaimWait (_claimWait);
        minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends;
        
    }
    
    function distributeDividends (uint256 amount) external override onlyOwner {
        _distributeDividends (amount);
    }
    
    function getTotalDividendsDistributed() external view override returns (uint256) {
        return totalDividendsDistributed;
    }
    
    function updateMinimumBalanceForDividends (uint256 newMinBalance) external override onlyOwner {
        minimumTokenBalanceForDividends = newMinBalance;
    }
    function _transfer (address, address, uint256) internal pure override {
        require(false, "DT: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "DT: Use token's claim function");
    }

    function excludeFromDividends (address account) external override onlyOwner {
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromDividends(account);
    }

    function updateClaimWait (uint24 newClaimWait) public override onlyOwner {
        require (newClaimWait >= 900 && newClaimWait <= 86400, "DT: must be >=15m & <=24hr");
        emit ClaimWaitUpdated (newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
    
    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount (address _account) public view override returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = -1;
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 tokenHoldersLength = tokenHoldersMap.keys.length;

        if (index >= 0) {
            if (uint256(index) > _lastProcessedIndex) {
                iterationsUntilProcessed = index - int256(_lastProcessedIndex);
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersLength > _lastProcessedIndex ? tokenHoldersLength - _lastProcessedIndex : 0;
                iterationsUntilProcessed = index + int256(processesUntilEndOfArray);
            }
        }

        withdrawableDividends = withdrawableDividendOf (account);
        totalDividends = accumulativeDividendOf (account);

        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime + claimWait : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime - block.timestamp : 0;
    }

    function canAutoClaim (uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)
            return false;

        return block.timestamp - lastClaimTime >= claimWait;
    }

    function setBalance (address account, uint256 newBalance) external override onlyOwner {
        if (excludedFromDividends[account])
            return;

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance (account, newBalance);
            tokenHoldersMap.set (account, newBalance);
        } else {
            _setBalance (account, 0);
            tokenHoldersMap.remove (account);
        }

        processAccount (account, true);
    }

    function process (uint256 gas) external override returns (uint256 iterations, uint256 claims, uint256 _lastProcessedIndex) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        _lastProcessedIndex = lastProcessedIndex;

        if (numberOfTokenHolders == 0)
            return (0, 0, _lastProcessedIndex);
        
        uint256 gasUsed;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= numberOfTokenHolders)
                _lastProcessedIndex = 0;

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim (lastClaimTimes[account])) {
                if (processAccount (account, true)) {
                    claims++;
                }
            }

            iterations++;
            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft)
                gasUsed += (gasLeft - newGasLeft);

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
    }

    function processAccount (address account, bool /* automatic */) public override onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser (account);

        if (amount > 0) {
            lastClaimTimes[account] = uint48(block.timestamp);
            return true;
        }

        return false;
    }
}