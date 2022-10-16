/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

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
        if (returndata.length > 0) {
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

abstract contract Initializable {

    uint8 private _initialized;
    bool private _initializing;

    event Initialized(uint8 version);

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

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

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

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

		require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
		require((b == 0) || (c / b == a));
		return c;
	}
	function div(int256 a, int256 b) internal pure returns (int256) {
		require(b != -1 || a != MIN_INT256);

		return a / b;
	}
	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));
		return c;
	}
	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));
		return c;
	}
	function abs(int256 a) internal pure returns (int256) {
		require(a != MIN_INT256);
		return a < 0 ? -a : a;
	}
	function toUint256Safe(int256 a) internal pure returns (uint256) {
		require(a >= 0);
		return uint256(a);
	}
}

library SafeMathUint {
	function toInt256Safe(uint256 a) internal pure returns (int256) {
		int256 b = int256(a);
		require(b >= 0);
		return b;
	}
}

library IterableMappingUpgradeable {
	struct Map {
		address[] keys;
		mapping(address => uint) values;
		mapping(address => uint) indexOf;
		mapping(address => bool) inserted;
	}

	function get(Map storage map, address key) public view returns (uint) {
		return map.values[key];
	}

	function getIndexOfKey(Map storage map, address key) public view returns (int) {
		if(!map.inserted[key]) {
			return -1;
		}
		return int(map.indexOf[key]);
	}

	function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
		return map.keys[index];
	}

	function size(Map storage map) public view returns (uint) {
		return map.keys.length;
	}

	function set(Map storage map, address key, uint val) public {
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

		uint index = map.indexOf[key];
		uint lastIndex = map.keys.length - 1;
		address lastKey = map.keys[lastIndex];

		map.indexOf[lastKey] = index;
		delete map.indexOf[key];

		map.keys[index] = lastKey;
		map.keys.pop();
	}
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

interface IERC20Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns(uint256);
    function withdrawDividend() external;
  
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount
    );
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount
    );
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns(uint256);
    function withdrawnDividendOf(address _owner) external view returns(uint256);
    function accumulativeDividendOf(address _owner) external view returns(uint256);
}

contract DividendPayingToken is ERC20Upgradeable, OwnableUpgradeable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMathUpgradeable for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;
    uint256 internal magnitude;
    uint256 internal magnifiedDividendPerShare;
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;
    uint256 public totalDividendsDistributed;

    function __DividendPayingToken_init( string memory _name, string memory _symbol) internal initializer {
        __Ownable_init();
        __ERC20_init(_name, _symbol);
        magnitude = 2**128;
    }

    function distributeDividends(uint256 amount) public onlyOwner {
        require(totalSupply() > 0);
        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount);
            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256){
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            bool success = user.send(_withdrawableDividend);

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }
            return _withdrawableDividend;
        }
        return 0;
    }

    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner)public view override returns (uint256){
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view override returns (uint256){
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view override returns (uint256){
        return  magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe().add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    }

    function _transfer(address,address,uint256) internal virtual override {
        require(false);
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);
        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract DividendTracker is OwnableUpgradeable, DividendPayingToken {
    using SafeMathUpgradeable for uint256;
    using SafeMathInt for int256;
    using IterableMappingUpgradeable for IterableMappingUpgradeable.Map;
    IterableMappingUpgradeable.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    receive() external payable {

  	}
    function initialize() external initializer {
        DividendPayingToken.__DividendPayingToken_init("DIVIDEND_TRACKER","DIVIDEND_TRACKER");//Testnet
        claimWait = 3600;
        minimumTokenBalanceForDividends = 2_000*1e18;
    }

    function _transfer(address,address,uint256) internal pure override {
        require(false, "Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false,"Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main Token contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function isExcludedFromDividends(address account)public view returns (bool){
        return excludedFromDividends[account];
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait,"Dividend_Tracker: Cannot update claimWait to same value");

        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function updateMinimumTokenBalanceForDividends(uint256 amount) external onlyOwner {
        minimumTokenBalanceForDividends = amount;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account) public view returns (
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
        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;
                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }


    function getAccountAtIndex(uint256 index)public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= tokenHoldersMap.size()) {
            return (address(0), -1, -1, 0, 0, 0, 0, 0);
        }
        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner{
        if (excludedFromDividends[account]) {
            return;
        }
        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }
        processAccount(account, true);
    }

    function process(uint256 gas)public returns(uint256,uint256,uint256){
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;
        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }
            iterations++;
            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }
        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
    	lastProcessedIndex = index;
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool){
        uint256 amount = _withdrawDividendOfUser(account);
        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }
}

contract COOKIE is Initializable, ERC20Upgradeable, OwnableUpgradeable {

    uint256 public  marketingFeeOnBuy;
    uint256 public  marketingFeeOnSell;

    uint256 public developmentFeeOnBuy;
    uint256 public developmentFeeOnSell;

    uint256 public  rewardFeeOnBuy;
    uint256 public  rewardFeeOnSell;

    uint256 public liquidityFeeOnBuy;
    uint256 public liquidityFeeOnSell;

    uint256 public  buyBackFeeOnBuy;
    uint256 public  buyBackFeeOnSell;

    uint256 private _totalFeesOnBuy;
    uint256 private _totalFeesOnSell;

    address public marketingWallet;
    address public developmentWallet;
    address public buybackToken;

    uint256 public bnbValueForBuyBurn;
    uint256 public accumulatedBuybackBNB;

    
    bool    public walletToWalletTransferWithoutFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    
    address private DEAD;

    bool    private swapping;
    uint256 public swapTokensAtAmount;
    bool    public swapEnabled;
    bool    public swapWithLimit;

    bool public tradingEnabled;
    uint256 public launchTime;
    bool    private antibotEnabled;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint256)public specialFees;

    DividendTracker public  dividendTracker;
    address public rewardToken;
    uint256 public gasForProcessing;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludedFromMaxTransactionLimit(address indexed account, bool isExcluded);
    event ExcludedFromMaxWalletLimit(address indexed account, bool isExcluded);
    event UpdateBuyFees(uint256 marketingFeeOnBuy, uint256 developmentFeeOnBuy, uint256 rewardFeeOnBuy, uint256 liquidityFeeOnBuy, uint256 buyBackOnBuy);
    event UpdateSellFees(uint256 marketingFeeOnSell, uint256 developmentFeeOnSell, uint256 rewardFeeOnSell, uint256 liquidityFeeOnSell, uint256 buyBackOnSell);
    event MarketingWalletChanged(address marketingWallet);
    event DevelopmentWalletChanged(address developmentWallet);
    event MaxWalletLimitAmountChanged(uint256 maxWalletLimitRate);
    event MaxWalletLimitStateChanged(bool maxWalletLimit);
    event MaxTransactionLimitAmountChanged(uint256 maxTransferRateBuy, uint256 maxTransferRateSell);
    event MaxTransactionLimitStateChanged(bool maxTransactionLimit);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SendMarketing(uint256 bnbSend);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 amount);
    event SendDevelopment(uint256 amount);
    event BuybackTokenChanged(address buybackToken);
    event BuybackAndBurn(uint256 amount);
    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    function initialize() initializer public{
        __Ownable_init();
        __ERC20_init("CookieSale", "COOKIE");

        maxWalletLimitEnabled = true;
        maxTransactionLimitEnabled = true;
        marketingFeeOnBuy   = 3;
        marketingFeeOnSell  = 3;

        developmentFeeOnBuy  = 2;
        developmentFeeOnSell = 2;

        rewardFeeOnBuy      = 2;
        rewardFeeOnSell     = 2;

        liquidityFeeOnBuy   = 1;
        liquidityFeeOnSell  = 1;

        buyBackFeeOnBuy    = 1;
        buyBackFeeOnSell   = 1;

        _totalFeesOnBuy     = 9;
        _totalFeesOnSell    = 9;

        walletToWalletTransferWithoutFee = true;
        swapEnabled = true;
        antibotEnabled = true;
        DEAD = 0x000000000000000000000000000000000000dEaD;
        marketingWallet = 0x3Ab481BD7b55394ea86ad28793248E47A8c272eC;
        developmentWallet = 0x076727113DD9e271856D70279628eaBa4807C298;
        buybackToken = 0xbA5eAB68a7203C9FF72E07b708991F07f55eF40E;
        rewardToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        transferOwnership(0x0c935E43Adc96C9A9B7B814D9A070164e1150a72);

        _mint(owner(), 100_000_000 * (10 ** 18));
        swapTokensAtAmount = totalSupply() / 5000;

        maxTransactionAmountBuy    = totalSupply() / 200;
        maxTransactionAmountSell   = totalSupply() / 200;
        maxWalletAmount            = (11 * totalSupply()) / 1000;


    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _isExcludedFromMaxTxLimit[owner()] = true;
        _isExcludedFromMaxTxLimit[address(0)] = true;
        _isExcludedFromMaxTxLimit[address(this)] = true;
        _isExcludedFromMaxTxLimit[DEAD] = true;
        
        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[address(0)] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[DEAD] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        bnbValueForBuyBurn = 2 ether;
    }

    receive() external payable {

  	}

    function setbnbValueForBuyBurn(uint256 _bnbValueForBuyBurn) external onlyOwner{
        bnbValueForBuyBurn = _bnbValueForBuyBurn;
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            accumulatedBuybackBNB=0;
            return;
        }
        ERC20Upgradeable ERC20token = ERC20Upgradeable(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function updateUniswapV2Router(address newAddress) external onlyOwner {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

//=======FeeManagement=======//
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setSpecialFees(address[] memory accounts, uint256 fee) external onlyOwner{
        require(fee <= 100, "Fee is too high");
        for(uint256 i = 0; i < accounts.length; i++){
            specialFees[accounts[i]] = fee;
        }
    }

    function updateBuyFees(uint256 _marketingFeeOnBuy, uint256 _developmentFeeOnBuy, uint256 _rewardFeeOnBuy, uint256 _liquidityFeeOnBuy, uint256 _buybackFeeOnBuy) external onlyOwner {
        require(
             _marketingFeeOnBuy + _developmentFeeOnBuy + _rewardFeeOnBuy + _liquidityFeeOnBuy + _buybackFeeOnBuy <= 25,
            "Fees must be less than 25%"
        );
        marketingFeeOnBuy = _marketingFeeOnBuy;
        developmentFeeOnBuy = _developmentFeeOnBuy;
        rewardFeeOnBuy = _rewardFeeOnBuy;
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        buyBackFeeOnBuy = _buybackFeeOnBuy;
        _totalFeesOnBuy = marketingFeeOnBuy + developmentFeeOnBuy + rewardFeeOnBuy + liquidityFeeOnBuy + buyBackFeeOnBuy;
        emit UpdateBuyFees(_marketingFeeOnBuy, _developmentFeeOnBuy, _rewardFeeOnBuy, _liquidityFeeOnBuy, _buybackFeeOnBuy);
    }

    function updateSellFees(uint256 _marketingFeeOnSell, uint256 _developmentFeeOnSell, uint256 _rewardFeeOnSell, uint256 _liquidityFeeOnSell, uint256 _buyBackFeeOnSell) external onlyOwner {
        require(
             _marketingFeeOnSell + _developmentFeeOnSell + _rewardFeeOnSell + _liquidityFeeOnSell + _buyBackFeeOnSell <= 25,
            "Fees must be less than 25%"
        );
        marketingFeeOnSell = _marketingFeeOnSell;
        developmentFeeOnSell = _developmentFeeOnSell;
        rewardFeeOnSell = _rewardFeeOnSell;
        liquidityFeeOnSell = _liquidityFeeOnSell;
        buyBackFeeOnSell = _buyBackFeeOnSell;
        _totalFeesOnSell = marketingFeeOnSell + developmentFeeOnSell + rewardFeeOnSell + liquidityFeeOnSell + buyBackFeeOnSell;
        emit UpdateSellFees(_marketingFeeOnSell, _developmentFeeOnSell, _rewardFeeOnSell, _liquidityFeeOnSell, _buyBackFeeOnSell);
    }        

    function enableWalletToWalletTransferWithoutFee(bool enable) external onlyOwner {
        walletToWalletTransferWithoutFee = enable;
    }

    function changeMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address(0), "Marketing wallet cannot be the zero address");
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    function changeDevelopmentWallet(address _developmentWallet) external onlyOwner {
        developmentWallet = _developmentWallet;
        emit DevelopmentWalletChanged(developmentWallet);
    }

    function changeBuybackToken(address _buybackToken) external onlyOwner {
        buybackToken = _buybackToken;
        emit BuybackTokenChanged(buybackToken);
    }

    function disableTrading() external onlyOwner {
        tradingEnabled = false;
    }

    function enableTrading() external onlyOwner {
        tradingEnabled = true;
    }

    function enableTradingWithAntiBot() external onlyOwner {
        launchTime = block.timestamp;
        tradingEnabled = true;
    }

    function setAntibotEnabled(bool _enabled) external onlyOwner {
        antibotEnabled = _enabled;
    }

//=======Transfer=======//
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(
            tradingEnabled ||
            _isExcludedFromFees[from] || 
            _isExcludedFromFees[to],
            "Trading is not enabled yet"
        );

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (maxTransactionLimitEnabled) 
        {
            if ((from == uniswapV2Pair || to == uniswapV2Pair) &&
                _isExcludedFromMaxTxLimit[from] == false && 
                _isExcludedFromMaxTxLimit[to]   == false) 
            {
                if (from == uniswapV2Pair) {
                    require(
                        amount <= maxTransactionAmountBuy,  
                        "AntiWhale: Transfer amount exceeds the maxTransactionAmount"
                    );
                } else {
                    require(
                        amount <= maxTransactionAmountSell, 
                        "AntiWhale: Transfer amount exceeds the maxTransactionAmount"
                    );
                }
            }
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( swapEnabled&&
            canSwap &&
            !swapping &&
            automatedMarketMakerPairs[to]
        ) {
            swapping = true;
            if (swapWithLimit) {
                contractTokenBalance = swapTokensAtAmount;
            }

            uint256 totalFee = _totalFeesOnBuy + _totalFeesOnSell;
            uint256 marketingShare = marketingFeeOnBuy + marketingFeeOnSell;
            uint256 developmentShare = developmentFeeOnBuy + developmentFeeOnSell;
            uint256 rewardShare    = rewardFeeOnBuy    + rewardFeeOnSell;
            uint256 liquidityShare = liquidityFeeOnBuy + liquidityFeeOnSell;
            uint256 buybackShare = buyBackFeeOnBuy + buyBackFeeOnSell;
            
            uint256 liquidityTokens;

            if(liquidityShare > 0) {
                liquidityTokens = contractTokenBalance * liquidityShare / totalFee;
                swapAndLiquify(liquidityTokens);
            }

            contractTokenBalance -= liquidityTokens;
            uint256 bnbShare = marketingShare + developmentShare + rewardShare + buybackShare;
            
            if(contractTokenBalance > 0 && bnbShare > 0) {
                uint256 initialBalance = address(this).balance;

                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();

                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    contractTokenBalance,
                    0,
                    path,
                    address(this),
                    block.timestamp);
                
                uint256 newBalance = address(this).balance - initialBalance;

                if(marketingShare > 0) {
                    uint256 marketingBNB = (newBalance * marketingShare) / bnbShare;
                    sendBNB(payable(marketingWallet), marketingBNB);
                    emit SendMarketing(marketingBNB);
                }

                if(developmentShare > 0) {
                    uint256 developmentBNB = (newBalance * developmentShare) / bnbShare;
                    sendBNB(payable(developmentWallet), developmentBNB);
                    emit SendDevelopment(developmentBNB);
                }

                if(rewardShare > 0) {
                    uint256 rewardBNB = (newBalance * rewardShare) / bnbShare;
                    swapAndSendDividends(rewardBNB);
                }

                if(buybackShare > 0) {
                    uint256 buybackBNB = newBalance * buybackShare / bnbShare;
                    accumulatedBuybackBNB += buybackBNB;
                    if (accumulatedBuybackBNB > bnbValueForBuyBurn) {
                        if (address(this).balance >= accumulatedBuybackBNB) {
                            buyBack(accumulatedBuybackBNB);
                        } else {
                            buyBack(address(this).balance);
                        }
                        accumulatedBuybackBNB = 0;
                    }
                } 
               
            }

            swapping = false;
        }

        
        uint256 _totalFees;
        if((_isExcludedFromFees[from] || _isExcludedFromFees[to])
                                      ||
            (walletToWalletTransferWithoutFee && from != uniswapV2Pair && to != uniswapV2Pair) 
                                      || 
                                    swapping) {

            _totalFees = 0;
        }else if (antibotEnabled && block.timestamp - 18 <= launchTime){
            _totalFees = 99;
        }else if(from == uniswapV2Pair) {
            _totalFees = specialFees[to]==0 ? _totalFeesOnBuy: specialFees[to];
        } else {
            _totalFees = specialFees[from]==0 ? _totalFeesOnSell: specialFees[from];
        }

        if( _totalFees > 0) {
        	uint256 fees = (amount * _totalFees) / 100;
        	amount = amount - fees;
            super._transfer(from, _totalFees == 99 ?address(marketingWallet) : address(this), fees);
        }

        if (maxWalletLimitEnabled) {
            if (_isExcludedFromMaxWalletLimit[from]  == false && 
                _isExcludedFromMaxWalletLimit[to]    == false &&
                to != uniswapV2Pair
            ) {
                uint balance  = balanceOf(to);
                require(
                    balance + amount <= maxWalletAmount, 
                    "MaxWallet: Recipient exceeds the maxWalletAmount"
                );
            }
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {

	    	}
        }
    }

//=======Swap=======//
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp);
        
        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function setSwapEnabled(bool _swapEnabled) external onlyOwner {
        swapEnabled = _swapEnabled;
    }

    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        swapTokensAtAmount = newAmount;
    }

    function setSwapWithLimit(bool _swapWithLimit) external onlyOwner {
        swapWithLimit = _swapWithLimit;
    }

     function swapAndSendDividends(uint256 amount) private{
        (bool success, ) = payable(address(dividendTracker)).call{value: amount}("");

        if (success) {
            dividendTracker.distributeDividends(amount);
            emit SendDividends(amount);
        }
    }

    function buyBack(uint256 BNBAmount) internal {
        address[] memory path = new address[](2);

        path[0] = uniswapV2Router.WETH();
        path[1] = buybackToken;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: BNBAmount}(
            0, // accept any amount of ETH
            path, 
            DEAD,
            block.timestamp);

        emit BuybackAndBurn(BNBAmount);
    }

//=======MaxWallet=======//
    mapping(address => bool) private _isExcludedFromMaxWalletLimit;
    bool    public maxWalletLimitEnabled;
    uint256 public maxWalletAmount;

    function setEnableMaxWalletLimit(bool enable) external onlyOwner {
        maxWalletLimitEnabled = enable;
        emit MaxWalletLimitStateChanged(maxWalletLimitEnabled);
    }

    function setMaxWalletAmount(uint256 _maxWalletAmount) external onlyOwner {
        maxWalletAmount = _maxWalletAmount * (10 ** decimals());
        emit MaxWalletLimitAmountChanged(maxWalletAmount);
    }

    function setExcludeFromMaxWallet(address account, bool exclude) external onlyOwner {
        _isExcludedFromMaxWalletLimit[account] = exclude;
        emit ExcludedFromMaxWalletLimit(account, exclude);
    }

    function isExcludedFromMaxWalletLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxWalletLimit[account];
    }

//=======MaxTransaction=======//
    mapping(address => bool) private _isExcludedFromMaxTxLimit;
    bool    public  maxTransactionLimitEnabled;
    uint256 public  maxTransactionAmountBuy;
    uint256 public  maxTransactionAmountSell;

    function setEnableMaxTransactionLimit(bool enable) external onlyOwner  {
        maxTransactionLimitEnabled = enable;
        emit MaxTransactionLimitStateChanged(maxTransactionLimitEnabled);
    }

    function setMaxTransactionAmounts(uint256 _maxTransactionAmountBuy, uint256 _maxTransactionAmountSell) external onlyOwner {
        maxTransactionAmountBuy  = _maxTransactionAmountBuy  * (10 ** decimals());
        maxTransactionAmountSell = _maxTransactionAmountSell * (10 ** decimals());
        emit MaxTransactionLimitAmountChanged(maxTransactionAmountBuy, maxTransactionAmountSell);
    }

    function setExcludeFromMaxTransactionLimit(address account, bool exclude) external onlyOwner {
        _isExcludedFromMaxTxLimit[account] = exclude;
        emit ExcludedFromMaxTransactionLimit(account, exclude);
    }

    function isExcludedFromMaxTransaction(address account) public view returns(bool) {
        return _isExcludedFromMaxTxLimit[account];
    }

//=======Dividend Tracker=======//
    function updateDividendTracker(address newAddress) public onlyOwner {
        DividendTracker newDividendTracker = DividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "The new dividend tracker must be owned by the token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(DEAD);
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(address(uniswapV2Pair));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateMinimumBalanceForDividends(uint256 newMinimumBalance) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

    function totalRewardsEarned(address account) public view returns (uint256) {
        return dividendTracker.accumulativeDividendOf(account);
    }

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }

    function claimAddress(address claimee) external onlyOwner {
		dividendTracker.processAccount(payable(claimee), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
    	dividendTracker.setLastProcessedIndex(index);
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
}