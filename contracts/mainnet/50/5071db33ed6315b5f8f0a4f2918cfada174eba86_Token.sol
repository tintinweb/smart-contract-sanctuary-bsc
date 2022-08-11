/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


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

    uint256 internal _totalSupply;

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
        // require(to != address(0), "ERC20: transfer to the zero address");

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



pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.8.0;

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

// pragma solidity >=0.6.2;

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


pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}


pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);

    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
}


pragma solidity ^0.8.0;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function contains(Map storage map, address key) public view returns (bool) {
        return getIndexOfKey(map, key) != -1;
    }

    function getIndexOfKey(Map storage map, address key)
        public
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
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


pragma solidity ^0.8.0;

contract Data is Ownable {
    address logicAddress;

    mapping(string => address) public string2addressMapping;
    mapping(string => uint256) public string2uintMapping;
    mapping(string => bool) public string2boolMapping;

    mapping(address => uint256) public address2uintMapping;

    constructor(
        address router,
        uint256 numToSwapAddLiquidity,
        uint256 numToHandleDividend
    ) {
        string2addressMapping["take"] = msg.sender;
        string2addressMapping["perwallet"] = msg.sender;
        string2addressMapping["outputwallet"] = msg.sender;

        string2addressMapping["lpDestroyAddress"] = address(
            0x000000000000000000000000000000000000dEaD
        );

        string2addressMapping["router"] = router;

        string2uintMapping["limit"] = 3 minutes;

        string2uintMapping["buyFeeRate"] = 3000000;
        string2uintMapping["sellFeeRate"] = 3000000;

        string2uintMapping["lpDestroyRate"] = 33000000; //33%
        string2uintMapping["lpDividendRate"] = 67000000; //67%

        string2uintMapping["numToSwapAddLiquidity"] = numToSwapAddLiquidity;
        string2uintMapping["numToHandleDividend"] = numToHandleDividend;
    }

    modifier onlyOwnerAndLogic() {
        require(
            msg.sender == owner() || msg.sender == logicAddress,
            "no permission"
        );
        _;
    }

    function setLogicAddress(address logic) public onlyOwner {
        logicAddress = logic;
    }

    function setString2AddressData(string memory str, address addr)
        public
        onlyOwnerAndLogic
    {
        string2addressMapping[str] = addr;
    }

    function setString2UintData(string memory str, uint256 _uint)
        public
        onlyOwnerAndLogic
    {
        string2uintMapping[str] = _uint;
    }

    function setString2BoolData(string memory str, bool _bool)
        public
        onlyOwnerAndLogic
    {
        string2boolMapping[str] = _bool;
    }

    function setAddress2UintData(address addr, uint256 _uint)
        public
        onlyOwnerAndLogic
    {
        address2uintMapping[addr] = _uint;
    }
}

pragma solidity ^0.8.0;

contract DividendHandler is Ownable {
    using SafeMath for uint256;

    address logicAddress;
    address investorAddress;
    uint256 investorLpAmount;
    IUniswapV2Pair pair;

    IterableMapping.Map lpProviders;

    constructor(address _pairAddress) {
        pair = IUniswapV2Pair(_pairAddress);
    }

    function putLpProvider(address _addr)
        public
        onlyOwnerAndLogic
        pairCreated
        returns (bool)
    {
        syn();
        IterableMapping.set(lpProviders, _addr, pair.balanceOf(_addr));

        return true;
    }

    function putInvestorLpProvider(address _addr, uint256 _lpAmount)
        public
        onlyOwnerAndLogic
        pairCreated
        returns (bool)
    {
        investorAddress = _addr;
        investorLpAmount = _lpAmount;
        return true;
    }

    function syn() public pairCreated returns (uint256) {
        uint256 _delCount = 0;
        for (
            uint256 index = 0;
            index < IterableMapping.size(lpProviders);
            index++
        ) {
            address _key = IterableMapping.getKeyAtIndex(lpProviders, index);
            if (pair.balanceOf(_key) == 0) {
                _delCount++;
            }
        }

        if (_delCount > 0) {
            uint256 _tempIndex = 0;
            address[] memory _delAddr = new address[](_delCount);
            for (
                uint256 index = 0;
                index < IterableMapping.size(lpProviders);
                index++
            ) {
                address _key = IterableMapping.getKeyAtIndex(
                    lpProviders,
                    index
                );
                if (pair.balanceOf(_key) == 0) {
                    _delAddr[_tempIndex] = _key;
                    _tempIndex++;
                }
            }

            for (uint256 index = 0; index < _delAddr.length; index++) {
                IterableMapping.remove(lpProviders, _delAddr[index]);
            }
        }

        return _delCount;
    }

    function excludeLpProviders(address _addr) public onlyOwnerAndLogic {
        IterableMapping.remove(lpProviders, _addr);
    }

    function handleDividend(uint256 _lpBalance)
        public
        view
        pairCreated
        returns (address[] memory lpHolders, uint256[] memory dividenAmount)
    {
        uint256 _lpHoldersAmount = IterableMapping.size(lpProviders);
        address[] memory _lpHolders = new address[](_lpHoldersAmount.add(1));
        uint256[] memory _dividendNums = new uint256[](_lpHoldersAmount.add(1));

        uint256 _lpSupply = pair.totalSupply();

        for (uint256 index = 0; index < _lpHoldersAmount; index++) {
            address _key = IterableMapping.getKeyAtIndex(lpProviders, index);
            uint256 _lpNum = pair.balanceOf(_key);
            _lpHolders[index] = _key;
            _dividendNums[index] = _lpBalance.mul(_lpNum).div(_lpSupply);
        }

        _lpHolders[_lpHoldersAmount] = investorAddress;
        _dividendNums[_lpHoldersAmount] = _lpBalance.mul(investorLpAmount).div(
            _lpSupply
        );

        uint256 _dividendSupply = 0;
        for (uint256 index = 0; index < _dividendNums.length; index++) {
            _dividendSupply = _dividendSupply.add(_dividendNums[index]);
        }

        require(_dividendSupply <= _lpSupply, "investor lp amount is over");

        return (_lpHolders, _dividendNums);
    }

    function takeToken(address token, address to) public onlyOwnerAndLogic {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, balance);
    }

    modifier onlyOwnerAndLogic() {
        require(
            msg.sender == owner() || msg.sender == logicAddress,
            "no permission"
        );
        _;
    }

    modifier pairCreated() {
        require(address(pair) != address(0), "pair not set");
        _;
    }

    function setLogicAddress(address logic) public onlyOwner {
        logicAddress = logic;
    }
}

pragma solidity ^0.8.0;

contract Token is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint112;

    Data data;
    address public pair;

    uint256 initOutput;
    uint256 public initOutputTime;
    uint256 public lastOutputTime;

    event OutputEveryDay(address outputAddr, uint256 amount, uint256 timestamp);

    constructor(address dataAddr, address tokenAddr) ERC20("OMT", "OMT") {
        data = Data(dataAddr);

        initOutput = 54300 * 10**decimals();
        initOutputTime = getCurrentTime0(block.timestamp);

        outputEveryDay();

        _mint(
            data.string2addressMapping("perwallet"),
            5 * 10**7 * 10**decimals()
        );

        pair = IUniswapV2Factory(getRouter().factory()).createPair(
            address(this),
            tokenAddr
        );

        _approve(address(this), getRouterAddress(), totalSupply());
    }

    function test(uint256 init, uint256 last) public onlyOwner {
        initOutputTime = init;
        lastOutputTime = last;
    }

    // function totalSupply() public view virtual override returns (uint256) {
    //     return 2 * 10**8 * 10**decimals();
    // }

    // function realTotalSupply() public view returns (uint256) {
    //     return _totalSupply;
    // }

    function outputEveryDay() public returns (uint256) {
        uint256 _time = block.timestamp;
        uint256 _currentTime = getCurrentTime0(_time);
        require(
            lastOutputTime == 0 || lastOutputTime != _currentTime,
            "output not now"
        );

        lastOutputTime = _currentTime;
        uint256 _outputAmount = initOutput.div(
            2**((lastOutputTime.sub(initOutputTime)).div(126144000))
        );

        _mint(data.string2addressMapping("outputwallet"), _outputAmount);

        emit OutputEveryDay(
            data.string2addressMapping("outputwallet"),
            _outputAmount,
            block.timestamp
        );

        return _outputAmount;
    }

    function getCurrentTime0(uint256 _time) public pure returns (uint256) {
        return _time - ((_time.add(8 * 3600)) % 86400);
    }

    function burn(uint256 amount) public returns (bool) {
        super._burn(_msgSender(), amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(this) || to == address(this) || 0 == amount) {
            super._transfer(from, to, amount);
            return;
        }

        if (pairInclude(from) || pairInclude(to)) {
            bool open = data.string2boolMapping("open");
            if (open && from != owner() && to != owner()) {
                uint256 openTime = data.string2uintMapping("opentime");
                uint256 limit = data.string2uintMapping("limit");

                if (block.timestamp - openTime < limit) {
                    address user = pairInclude(from) ? to : from;
                    if (data.address2uintMapping(user) == 0)
                        data.setAddress2UintData(user, 1);
                }

                uint256 feeAmount;

                if (pairInclude(from)) {
                    if (data.address2uintMapping(to) == 2) {
                        super._transfer(from, to, amount);
                        return;
                    }

                    feeAmount = amount
                        .mul(data.string2uintMapping("buyFeeRate"))
                        .div(1000000)
                        .div(100);

                    super._transfer(from, to, amount);
                    super._transfer(to, address(this), feeAmount);
                } else {
                    if (data.address2uintMapping(from) == 1) {
                        return;
                    }

                    getDividendHandler().putLpProvider(from);

                    if (data.address2uintMapping(from) == 2) {
                        super._transfer(from, to, amount);
                        return;
                    }

                    feeAmount = amount
                        .mul(data.string2uintMapping("sellFeeRate"))
                        .div(1000000)
                        .div(100);

                    uint256 realamount = amount.sub(feeAmount);
                    super._transfer(from, to, realamount);
                    super._transfer(from, address(this), feeAmount);
                }
            } else {
                if (pairInclude(to)) {
                    getDividendHandler().putLpProvider(from);
                }

                if (
                    from == owner() ||
                    to == owner() ||
                    data.address2uintMapping(from) == 3 ||
                    data.address2uintMapping(to) == 3
                ) {
                    super._transfer(from, to, amount);
                }
            }
        } else {
            require(
                data.address2uintMapping(from) != 1,
                "the address is in black list"
            );
            super._transfer(from, to, amount);
        }
    }

    function handleDividend() public {
        uint256 swapOverlimit = data.string2uintMapping(
            "numToSwapAddLiquidity"
        );
        require(
            balanceOf(address(this)) >= swapOverlimit,
            "balance not enough"
        );

        swapAddLiquidity();

        uint256 lpOverlimit = data.string2uintMapping("numToHandleDividend");
        uint256 balanceLp = IERC20(pair).balanceOf(address(this));
        require(balanceLp >= lpOverlimit, "balanceLp not enough");
        uint256 destroyAmount = balanceLp
            .mul(data.string2uintMapping("lpDestroyRate"))
            .div(1000000)
            .div(100);
        IERC20(pair).transfer(
            data.string2addressMapping("lpDestroyAddress"),
            destroyAmount
        );

        (
            address[] memory lpHolders,
            uint256[] memory dividenAmount
        ) = getDividendHandler().handleDividend(balanceLp.sub(destroyAmount));
        for (uint256 index = 0; index < lpHolders.length; index++) {
            if (dividenAmount[index] > 0)
                IERC20(pair).transfer(lpHolders[index], dividenAmount[index]);
        }
    }

    function swapAddLiquidity() private {
        uint256 overlimit = balanceOf(address(this));

        uint256 half = overlimit.div(2);
        uint256 otherHalf = overlimit.sub(half);

        address[] memory path = new address[](2);
        path[0] = address(this);
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        path[1] = token0 == address(this) ? token1 : token0;

        if (path[1] == getRouter().WETH()) {
            uint256 initialBalance = address(this).balance;

            getRouter().swapExactTokensForETHSupportingFeeOnTransferTokens(
                half,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 wethAmount = address(this).balance.sub(initialBalance);

            getRouter().addLiquidityETH{value: wethAmount}(
                address(this),
                otherHalf,
                0,
                0,
                address(this),
                block.timestamp
            );
        } else {
            uint256 initialBalance = IERC20(path[1]).balanceOf(address(this));

            getRouter().swapExactTokensForTokensSupportingFeeOnTransferTokens(
                half,
                0,
                path,
                getDividendHandlerAddress(),
                block.timestamp
            );
            getDividendHandler().takeToken(path[1], address(this));

            uint256 token1Amount = IERC20(path[1]).balanceOf(address(this)).sub(
                initialBalance
            );

            IERC20(path[1]).approve(getRouterAddress(), token1Amount);

            getRouter().addLiquidity(
                path[0],
                path[1],
                otherHalf,
                token1Amount,
                0,
                0,
                address(this),
                block.timestamp
            );
        }
    }

    function switchState(bool open) public onlyOwner {
        data.setString2BoolData("open", open);
        if (open) {
            data.setString2UintData("opentime", block.timestamp);
        }
    }

    function getDividendHandler() private view returns (DividendHandler) {
        return DividendHandler(getDividendHandlerAddress());
    }

    function getDividendHandlerAddress() public view returns (address) {
        return data.string2addressMapping("dividendHandler");
    }

    function getRouterAddress() public virtual returns (address) {
        return data.string2addressMapping("router");
    }

    function getTakeAddress() public virtual returns (address) {
        return data.string2addressMapping("take");
    }

    function getRouter() public returns (IUniswapV2Router02) {
        return IUniswapV2Router02(getRouterAddress());
    }

    function pairInclude(address _addr) public view returns (bool) {
        return pair == _addr;
    }

    function takeToken(address token) public {
        if (token == getRouter().WETH()) {
            payable(getTakeAddress()).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(getTakeAddress(), balance);
        }
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    receive() external payable {}
}