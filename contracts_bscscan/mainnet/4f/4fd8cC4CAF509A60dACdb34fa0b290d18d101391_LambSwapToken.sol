/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

/**LAMBSWAP AGGREGATION PROTOCOL 
	*LambSwap is a multi-chain compatible decentralised exchange aggregator protocol focused 
	on making zero-fee transactions possible. We are aiming to make on-chain trading simple and 
	easy, by providing access to multi-chains like, BSC, Polygon, Solana under one roof. 
	The core product is being designed to function gasless and focused on aggregating liquidity 
	from multiple protocols.*
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

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

contract Context {
	// Empty internal constructor, to prevent people from mistakenly deploying
	// an instance of this contract, which should be used via inheritance.
	constructor () internal { }

	function _msgSender() internal view returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}
    /* --------- Access Control --------- */
contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	* @dev Initializes the contract setting the deployer as the initial owner.
	*/
	constructor () internal {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	/**
	* @dev Returns the address of the current owner.
	*/
	function owner() public view returns (address) {
		return _owner;
	}

	/**
	* @dev Throws if called by any account other than the owner.
	*/
	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	/**
	* @dev Leaves the contract without owner. It will not be possible to call
	* `onlyOwner` functions anymore. Can only be called by the current owner.
	*
	* NOTE: Renouncing ownership will leave the contract without an owner,
	* thereby removing any functionality that is only available to the owner.
	*/
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	* @dev Transfers ownership of the contract to a new account (`newOwner`).
	* Can only be called by the current owner.
	*/
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	/**
	* @dev Transfers ownership of the contract to a new account (`newOwner`).
	*/
	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

    /* --------- safe math --------- */
library SafeMath {
	/**
	* @dev Returns the addition of two unsigned integers, reverting on
	* overflow.
	*
	* Counterpart to Solidity's `+` operator.
	*
	* Requirements:
	* - Addition cannot overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	/**
	* @dev Returns the subtraction of two unsigned integers, reverting on
	* overflow (when the result is negative).
	*
	* Counterpart to Solidity's `-` operator.
	*
	* Requirements:
	* - Subtraction cannot overflow.
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	/**
	* @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	* overflow (when the result is negative).
	*
	* Counterpart to Solidity's `-` operator.
	*
	* Requirements:
	* - Subtraction cannot overflow.
	*/
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	/**
	* @dev Returns the multiplication of two unsigned integers, reverting on
	* overflow.
	*
	* Counterpart to Solidity's `*` operator.
	*
	* Requirements:
	* - Multiplication cannot overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
		if (a == 0) {
		return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	/**
	* @dev Returns the integer division of two unsigned integers. Reverts on
	* division by zero. The result is rounded towards zero.
	*
	* Counterpart to Solidity's `/` operator. Note: this function uses a
	* `revert` opcode (which leaves remaining gas untouched) while Solidity
	* uses an invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	/**
	* @dev Returns the integer division of two unsigned integers. Reverts with custom message on
	* division by zero. The result is rounded towards zero.
	*
	* Counterpart to Solidity's `/` operator. Note: this function uses a
	* `revert` opcode (which leaves remaining gas untouched) while Solidity
	* uses an invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	* Reverts when dividing by zero.
	*
	* Counterpart to Solidity's `%` operator. This function uses a `revert`
	* opcode (which leaves remaining gas untouched) while Solidity uses an
	* invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	/**
	* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	* Reverts with custom message when dividing by zero.
	*
	* Counterpart to Solidity's `%` operator. This function uses a `revert`
	* opcode (which leaves remaining gas untouched) while Solidity uses an
	* invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, 'EnumerableSet: index out of bounds');
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

contract LambSwapToken is  Context, Ownable  {

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _minters;
	/* --------- Math info --------- */

	using SafeMath for uint256;

    /* --------- exchange info --------- */
	IUniswapV2Router02 public UniswapV2Router;
	address public UniswapV2Pair;

	uint256 private _totalSupply;
	uint8 private _decimals;

    /* --------- max tx info --------- */
	uint256 public _maxSupply = 500e9 * 1e9; // maximum supply: 500,000,000,000
	uint public _limitTxAmount = 500e9 * 1e9; // transaction limit: 500,000,000,000
	uint public numTokensSellToAddToLiquidity = 39e2 * 1e9; // swap token amount: 3900

	string private _symbol;
	string private _name;

    /* --------- special address info --------- */
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
	address public marketingAddress = 0x8B2057A12503b7270A50955909445cE7287CBa1a;
	address public LPAddress = 0x63E69DE92628b05802f5887d88a3D640be8A7bca;
	bool inSwapAndLiquify;
	bool public swapAndLiquifyEnabled = true;

	/* --------- mapping define --------- */

	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) _isExcludeFromFee;
    mapping(address => bool) isBlackList;

	/* --------- struct define --------- */

	struct FeesStruct {
		uint buyFee;
		uint sellFee;
		uint transferFee;
	}
	struct Fees {
		uint burn;
		uint marketing;
		uint liquidity;
		uint buyback;
        uint maxFee;
	}

	Fees private checkFee;	
	/* --------- Fees info --------- */
    Fees public buyFees = Fees({
		burn : 1,
		liquidity : 3,
        marketing : 1,
		buyback : 1,
        maxFee : 25
	});
    Fees public sellFees = Fees({
		burn : 2,
		liquidity : 4,
        marketing : 2,
		buyback : 2,
        maxFee : 25
	});
	Fees public transferFees = Fees({
		burn : 0,
		liquidity : 0,
        marketing : 0,
		buyback : 0,
        maxFee : 25
	});
	FeesStruct public _taxRates = FeesStruct({
		buyFee : 6,
		sellFee : 10,
		transferFee : 0
	});

	/* --------- event define --------- */

    event SetWhiteList(address user, bool isWhiteList);
    event SetBlackList(address user, bool isBlackList);
    event SetSellFee(Fees sellFees);
    event SetBuyFee(Fees buyFees);
	event SetTransferFee(Fees transferFees);
	event SetTaxRate(FeesStruct taxRates);
    event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

	/* --------- delegate define --------- */

    // @notice A record of each accounts delegate
    mapping (address => address) internal _delegates;

    // @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    // @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    // @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    // @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    // @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    // @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

	/* --------- modifier --------- */

	modifier lockTheSwap {
		inSwapAndLiquify = true;
		_;
		inSwapAndLiquify = false;
	}

    // modifier for mint function
    modifier onlyMinter() {
        require(isMinter(msg.sender), "caller is not the minter");
        _;
    }

    ////////////////////////////////////////////////
    /* --------- General Implementation --------- */
    ////////////////////////////////////////////////

	function getOwner() external view returns (address) {
		return owner();
	}

	function decimals() external view returns (uint8) {
		return _decimals;
	}

	function symbol() external view returns (string memory) {
		return _symbol;
	}

	function name() external view returns (string memory) {
		return _name;
	}

	function totalSupply() external view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) external returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "LST::transferFrom: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "LST::decreaseAllowance: decreased allowance below zero"));
		return true;
	}

	function burn(uint256 amount) external {
		_burn(msg.sender,amount);
	}

	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "LST::_mint: mint to the zero address");
		require(
            _maxSupply >= _totalSupply + amount,
            "LST::_mint: The total supply has exceeded the max supply."
        );
		_totalSupply += amount;
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "LST::_burn: burn from the zero address");
		_balances[account] = _balances[account].sub(amount, "LST::_burn: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, burnAddress, amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "LST::_approve approve from the zero address");
		require(spender != address(0), "LST::_approve approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
 
	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "LST::_burnFrom: burn amount exceeds allowance"));
	}

	//////////////////////////////////////////////
    /* ----------- special features ----------- */
	//////////////////////////////////////////////

    constructor () public {
        _name = "LambSwapToken";
        _symbol = "LST";
        _decimals = 9;
        _totalSupply = 39e9*1e9; /// initial supply 39,000,000,000
        _balances[msg.sender] = _totalSupply;

        IUniswapV2Router02 _UniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
		UniswapV2Router = _UniswapV2Router;
		UniswapV2Pair = IUniswapV2Factory(_UniswapV2Router.factory()).createPair(address(this), _UniswapV2Router.WETH()); //MD vs USDT pair
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // @notice Creates `_amount` token to `owner`.
	function mint(uint256 _amount) external onlyOwner returns (bool) {
        _mint(owner(), _amount);
        _moveDelegates(address(0), owner(), _amount);
        return true;
    }

    // @notice Creates `_amount` token to `_recipient`.
    function mint(address _recipient, uint256 _amount)
        external
        onlyMinter
        returns (bool)
    {
		require(!isBlackList[_recipient], "LST::mint: recipient is backlisted");
        _mint(_recipient, _amount);
        _moveDelegates(address(0), _delegates[_recipient], _amount);
        return true;
    }

    /* --------- set token parameters--------- */

	function setInitialAddresses(address _RouterAddress) external onlyOwner {
        IUniswapV2Router02 _UniswapV2Router = IUniswapV2Router02(_RouterAddress);
		UniswapV2Router = _UniswapV2Router;
		UniswapV2Pair = IUniswapV2Factory(_UniswapV2Router.factory()).createPair(address(this), _UniswapV2Router.WETH()); //LST vs USDT pair
	}

	function setFeeAddresses( address _marketingAddress, address _LPAddress) external onlyOwner {
		marketingAddress = _marketingAddress;		
		LPAddress = _LPAddress;
	}

	function setLimitTxAmount(uint limitTxAmount) external onlyOwner {
		_limitTxAmount = limitTxAmount;
	}

	function setNumTokensSellToAddToLiquidity(uint _numTokensSellToAddToLiquidity) external onlyOwner {
		numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
	}
    
    function setBuyFee(uint256 _burnFee, uint256 _LPFee, uint256 _marketingFee, uint256 _buybackFee) external onlyOwner {
		require(buyFees.maxFee >= _LPFee + _marketingFee + _buybackFee + _burnFee, "LST::setBuyFee: Buy fee exceeds max buy fee");
		buyFees.burn = _burnFee;
		buyFees.liquidity = _LPFee;
        buyFees.marketing = _marketingFee;
		buyFees.buyback = _buybackFee;
        _taxRates.buyFee = _LPFee + _marketingFee + _buybackFee + _burnFee;
        emit SetBuyFee(buyFees);
		emit SetTaxRate(_taxRates);
    }

	function setSellFee(uint256 _burnFee, uint256 _LPFee, uint256 _marketingFee, uint256 _buybackFee) external onlyOwner {
		require(sellFees.maxFee >= _LPFee + _marketingFee + _buybackFee + _burnFee, "LST::setSellFee: Sell fee exceeds max transfer fee");
		sellFees.burn = _burnFee;
		sellFees.liquidity = _LPFee;
        sellFees.marketing = _marketingFee;
		sellFees.buyback = _buybackFee;
        _taxRates.sellFee = _LPFee + _marketingFee + _buybackFee + _burnFee;
        emit SetSellFee(sellFees);
		emit SetTaxRate(_taxRates);
    }

	function setTransferFee(uint256 _burnFee, uint256 _LPFee, uint256 _marketingFee, uint256 _buybackFee) external onlyOwner{
		require(transferFees.maxFee >= _LPFee + _marketingFee + _buybackFee + _burnFee, "LST::setTransferFee: Transfer fee exceeds max transfer fee");
		transferFees.burn = _burnFee;
		transferFees.liquidity = _LPFee;
        transferFees.marketing = _marketingFee;
		transferFees.buyback = _buybackFee;
        _taxRates.transferFee = _LPFee + _marketingFee + _buybackFee + _burnFee;
		emit SetTransferFee(transferFees);
		emit SetTaxRate(_taxRates);
	}

	function getTotalSellFee() external view returns (uint) {
		return _taxRates.sellFee;
	}
	
	function getTotalBuyFee() external view returns (uint) {
		return _taxRates.buyFee;
	}

    /* --------- exclude address from buyFees--------- */

	function addBlackList(address account) external onlyOwner {
        require(
            account != address(0) && account != address(this) && account != owner() && account != burnAddress && account != marketingAddress && account != LPAddress,
            "LST::addBlackList: It account can`t add on blacklist"
        );
        require(
            isBlackList[account] != true,
            "LST::setBlackList: Account in list already."
        );
        isBlackList[account] = true;
        emit SetBlackList(account, true);
    }

    function removeBlackList(address account) external onlyOwner {
        require(
            isBlackList[account] != false,
            "LST::setBlackList: Account not in list."
        );
        isBlackList[account] = false;
        emit SetBlackList(account, false);
    }

    function excludeFromFee(address account) external onlyOwner {
        require(
            _isExcludeFromFee[account] != true,
            "LST::excludeFromFee: Account in list already."
        );
        _isExcludeFromFee[account] = true;

        emit SetWhiteList(account, true);
    }

    function includeInFee(address account) external onlyOwner {
        require(
            _isExcludeFromFee[account] == true,
            "LST::includeInFee: Account not in list."
        );
        _isExcludeFromFee[account] = false;

        emit SetWhiteList(account, false);
    }

    /* --------- transfer --------- */

	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "LST::_transfer: transfer from the zero address");
		require(recipient != address(0), "LST::_transfer: transfer to the zero address");
		require(!isBlackList[sender], "LST::_transfer: Sender is backlisted");
		require(!isBlackList[recipient], "LST::_transfer: Recipient is backlisted");

		// transfer 
		if((sender == UniswapV2Pair || recipient == UniswapV2Pair )&& !_isExcludeFromFee[sender])
			require(_limitTxAmount>=amount,"LST::_transfer: transfer amount exceeds max transfer amount");

		_balances[sender] = _balances[sender].sub(amount, "LST::_transfer: transfer amount exceeds balance");
		_moveDelegates(_delegates[sender], address(0), amount);
		uint recieveAmount = amount;

		uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _limitTxAmount)
        {
            contractTokenBalance = _limitTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;

		if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != UniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

		checkFee.burn = 0;

		if(!_isExcludeFromFee[sender] && !_isExcludeFromFee[recipient] && sender!=owner()) {
			if(sender == UniswapV2Pair){
				// buy fee
				checkFee.burn = buyFees.burn;
				checkFee.marketing = buyFees.marketing;
				checkFee.liquidity = buyFees.liquidity;
				checkFee.buyback = buyFees.buyback;
			}
			else if(recipient == UniswapV2Pair){
				// sell fee
				checkFee.burn = sellFees.burn;
				checkFee.marketing = sellFees.marketing;
				checkFee.liquidity = sellFees.liquidity;
				checkFee.buyback = sellFees.buyback;
			}
			else {
				// transfer fee
				checkFee.burn = transferFees.burn;
				checkFee.marketing = transferFees.marketing;
				checkFee.liquidity = transferFees.liquidity;
				checkFee.buyback = transferFees.buyback;
			}
			_balances[marketingAddress] += amount.mul(checkFee.marketing).div(100);
			_balances[LPAddress] += amount.mul(checkFee.liquidity).div(100);
			_balances[address(this)] += amount.mul(checkFee.buyback).div(100);

			emit Transfer(sender, marketingAddress, amount.mul(checkFee.marketing).div(100));
			emit Transfer(sender, LPAddress, amount.mul(checkFee.liquidity).div(100));
			emit Transfer(sender, address(this), amount.mul(checkFee.buyback).div(100));

			recieveAmount -= amount.mul(checkFee.marketing+checkFee.liquidity+checkFee.buyback).div(100);
		}

		_balances[recipient] = _balances[recipient].add(recieveAmount);
		_burn(recipient,amount.mul(checkFee.burn).div(100));
		_moveDelegates(address(0), _delegates[recipient], recieveAmount-amount.mul(checkFee.burn).div(100));
		emit Transfer(sender, recipient, recieveAmount-amount.mul(checkFee.burn).div(100));
	}

	function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half); 

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

	function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniswapV2Router.WETH();

        _approve(address(this), address(UniswapV2Router), tokenAmount);

        UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(UniswapV2Router), tokenAmount);

        UniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

	function withdrawStuckBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

	receive() external payable {}

	/**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(_name)),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "LST::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "LST::delegateBySig: invalid nonce");
        require(now <= expiry, "LST::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "LST::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of delegator
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "LST::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function addMinter(address _addMinter) public onlyOwner returns (bool) {
        require(_addMinter != address(0), "LST::addMinter: _addMinter is the zero address");
        return EnumerableSet.add(_minters, _addMinter);
    }

    function delMinter(address _delMinter) public onlyOwner returns (bool) {
        require(_delMinter != address(0), "LST::delMinter: _delMinter is the zero address");
        return EnumerableSet.remove(_minters, _delMinter);
    }

    function getMinterLength() public view returns (uint256) {
        return EnumerableSet.length(_minters);
    }

    function isMinter(address account) public view returns (bool) {
        return EnumerableSet.contains(_minters, account);
    }

    function getMinter(uint256 _index) public view onlyOwner returns (address){
        require(_index <= getMinterLength() - 1, "LST::getMinter: index out of bounds");
        return EnumerableSet.at(_minters, _index);
    }
}