/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBscPrice {
    function getTokenUsdtPrice(address _token) external view returns (uint256);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex;
                // Replace lastvalue's index to valueIndex
            }

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
    function _contains(Set storage set, bytes32 value)
    private
    view
    returns (bool)
    {
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
    function _at(Set storage set, uint256 index)
    private
    view
    returns (bytes32)
    {
        return set._values[index];
    }

    /**
    * @dev Return the entire set in an array
*
* WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
* to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
* this function has an unbounded cost, and using it as part of a state-changing function may render the function
* uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
*/
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
    * @dev Add a value to a set. O(1).
*
* Returns true if the value was added to the set, that is if it was not
* already present.
*/
    function add(Bytes32Set storage set, bytes32 value)
    internal
    returns (bool)
    {
        return _add(set._inner, value);
    }

    /**
    * @dev Removes a value from a set. O(1).
*
* Returns true if the value was removed from the set, that is if it was
* present.
*/
    function remove(Bytes32Set storage set, bytes32 value)
    internal
    returns (bool)
    {
        return _remove(set._inner, value);
    }

    /**
    * @dev Returns true if the value is in the set. O(1).
*/
    function contains(Bytes32Set storage set, bytes32 value)
    internal
    view
    returns (bool)
    {
        return _contains(set._inner, value);
    }

    /**
    * @dev Returns the number of values in the set. O(1).
*/
    function length(Bytes32Set storage set) internal view returns (uint256) {
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
    function at(Bytes32Set storage set, uint256 index)
    internal
    view
    returns (bytes32)
    {
        return _at(set._inner, index);
    }

    /**
    * @dev Return the entire set in an array
*
* WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
* to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
* this function has an unbounded cost, and using it as part of a state-changing function may render the function
* uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
*/
    function values(Bytes32Set storage set)
    internal
    view
    returns (bytes32[] memory)
    {
        return _values(set._inner);
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
    function add(AddressSet storage set, address value)
    internal
    returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
    * @dev Removes a value from a set. O(1).
*
* Returns true if the value was removed from the set, that is if it was
* present.
*/
    function remove(AddressSet storage set, address value)
    internal
    returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
    * @dev Returns true if the value is in the set. O(1).
*/
    function contains(AddressSet storage set, address value)
    internal
    view
    returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
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
    function at(AddressSet storage set, uint256 index)
    internal
    view
    returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
    * @dev Return the entire set in an array
*
* WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
* to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
* this function has an unbounded cost, and using it as part of a state-changing function may render the function
* uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
*/
    function values(AddressSet storage set)
    internal
    view
    returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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
    function remove(UintSet storage set, uint256 value)
    internal
    returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
    * @dev Returns true if the value is in the set. O(1).
*/
    function contains(UintSet storage set, uint256 value)
    internal
    view
    returns (bool)
    {
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
    function at(UintSet storage set, uint256 index)
    internal
    view
    returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }

    /**
    * @dev Return the entire set in an array
*
* WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
* to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
* this function has an unbounded cost, and using it as part of a state-changing function may render the function
* uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
*/
    function values(UintSet storage set)
    internal
    view
    returns (uint256[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}



contract ETCsToken is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public startTime = 1659916800;
    uint256 public maxRate = 1000;

    uint256 public tradeBuyFee = 100;

    uint256 public buyDestroyRate = 30;

    uint256 public  buyLpRate = 40;

    uint256 public  buyMarketingRate = 30;
    
    uint256 public exrtraRate1=100;
    uint256 public exrtraRate2=150; 

    uint256 public tradeSellFee = 150;

    uint256 public sellDestroyRate = 45;

    uint256 public  sellLpRate = 60;

    uint256 public  sellMarketingRate = 45;

    uint256 public transferRate = 100;

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public marketingWalletAddress; 

    address public receiveAddress;

    bool public autoLiqudityEnable;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(uint256 => uint256) public priceMap;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event LiqudityDividend(address indexed user, uint256 amount);

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private lpHolderSet;

    address public lastFrom;
    address public lastTo;

    uint256 public minAmount;
    uint256 public totalLP;
    uint256 public totalMarketing;

    address public etcAddress;

    constructor(
        string memory name_,
        string memory symbol_
    ) payable ERC20(name_, symbol_) {
        _totalSupply = 490000 * (10 ** 18);

        receiveAddress = 0xcE53034B1D072d55012E8c748AaF32458C0C8eBa;
        marketingWalletAddress = 0xe02D80ce0E3EEE79833Ce6a9581B23Ca9B7969Bb; 
        etcAddress = 0x55d398326f99059fF775485246999027B3197955;

        _balances[receiveAddress] = 490000 * (10 ** 18);
        emit Transfer(address(0), receiveAddress, 490000 * (10 ** 18));

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(marketingWalletAddress, true);
        excludeFromFees(receiveAddress, true); 

        minAmount = 1e16;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        autoLiqudityEnable = true;
        lastFrom = msg.sender;
        lastTo = msg.sender;
    }

    event SwapTokensForToken(uint256 amountIn, address[] path);

    function setMinAmount(uint256 val) public onlyOwner {
        minAmount = val;
    }

    function setAutoLiqudityEnable(bool val) public onlyOwner {
        autoLiqudityEnable = val;
    }

    function setMarketingWalletAddress(address addr) public onlyOwner {
        marketingWalletAddress = addr;
    }

    function setExtraRate(uint256 rate1,uint256 rate2) public onlyOwner {
        exrtraRate1 = rate1;
        exrtraRate2 = rate2; 
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if (_isExcludedFromFees[account] != excluded) {
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function check(address from, address to) internal {
        if (from != uniswapV2Pair) {
            setLiqudityHolder(from);
        }
        if (to != uniswapV2Pair) {
            setLiqudityHolder(to);
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");


        if (to==deadAddress) {
            super._transfer(from, to, amount);
            _totalSupply = _totalSupply.sub(amount);
            return;
        }

        check(lastFrom, lastTo);
        lastFrom = from;
        lastTo = to;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }
        uint256 finalAmount = takeAllFee(from, to, amount);
        super._transfer(from, to, finalAmount);
        setPrice();

        uint256 etcAmoount = IERC20(etcAddress).balanceOf(address(this));
        if( etcAmoount > minAmount ){
            lpDividendProcess(etcAmoount);
        }
    }


    function takeAllFee(address from, address to, uint256 amount) internal returns (uint256 amountAfter) {
        uint256 destroyAmount;
        uint256 tradeFeeAmount;

        if (from == uniswapV2Pair) { 
            tradeFeeAmount = amount.mul(tradeBuyFee).div(maxRate);
            destroyAmount = amount.mul(buyDestroyRate).div(maxRate);
 
            uint256 lpAmount = amount.mul(buyLpRate).div(maxRate);
            super._transfer(from, address(this), lpAmount);
            totalLP = totalLP.add(lpAmount);

            uint256 marketingAmount = amount.mul(buyMarketingRate).div(maxRate);
            super._transfer(from, address(this), marketingAmount);
            totalMarketing = totalMarketing.add(marketingAmount);
  
        } else if (to == uniswapV2Pair) { 
            tradeFeeAmount = amount.mul(tradeSellFee).div(maxRate);
            destroyAmount = amount.mul(sellDestroyRate).div(maxRate);

            uint256 lpAmount = amount.mul(sellLpRate).div(maxRate);
            super._transfer(from, address(this), lpAmount);
            _swapLp(lpAmount.add(totalLP));
            totalLP = 0;
 
            uint256 marketingAmount = amount.mul(sellMarketingRate).div(maxRate);
            super._transfer(from, address(this), marketingAmount);
            _swapMarketing(marketingAmount.add(totalMarketing));
            totalMarketing=0;

            uint256 currentDownRate = getPriceDownRate();
            if (currentDownRate >= 3) {
                uint256 exrtraRate;
                if (currentDownRate >= 3 && currentDownRate < 5) {
                    exrtraRate = exrtraRate1;
                }else if (currentDownRate >= 5 && currentDownRate < 9) {
                    exrtraRate = exrtraRate2;
                } else { 
                    exrtraRate = exrtraRate2;
                }
                uint256 extraDestroyAmount = amount.mul(exrtraRate).div(maxRate);
                tradeFeeAmount = extraDestroyAmount.add(tradeFeeAmount);
                destroyAmount = extraDestroyAmount.add(destroyAmount);
            }

        } else {
            destroyAmount = amount.mul(transferRate).div(maxRate);
            tradeFeeAmount = destroyAmount;
        }

        super._transfer(from, deadAddress, destroyAmount);

        _totalSupply = _totalSupply.sub(destroyAmount);
        amountAfter = amount.sub(tradeFeeAmount);
        return amountAfter;
    }

    function  _swapMarketing (uint256 amount ) internal {
         if(amount > 0){
              address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = 0x55d398326f99059fF775485246999027B3197955; 
            swapTokensForToken(amount, marketingWalletAddress, path);
         }
    }

    function  _swapLp (uint256 amount ) internal {
        if(amount > 0){
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = 0x55d398326f99059fF775485246999027B3197955; 
            swapTokensForToken(amount, address(this), path);
        } 
    }

    function swapTokensForToken(uint256 tokenAmount, address to,  address[] memory path) internal {
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of token
            path,
            to, // The contract
            block.timestamp
        );
        emit SwapTokensForToken(tokenAmount, path);
    }

    function lpDividendProcess(uint256 dividendAmount) internal {
        uint256 _total = IERC20(uniswapV2Pair).totalSupply();
        for (uint256 i = 0; i < lpHolderSet.length(); i++) {
            address holder = lpHolderSet.at(i);
            uint256 accountBalance = IERC20(uniswapV2Pair).balanceOf(holder);
            if (accountBalance == 0) {
                continue;
            }
            uint256 amount = dividendAmount.mul(accountBalance).div(_total);
            if(amount > 0){ 
                IERC20(etcAddress).transfer(holder, amount ); 
                emit LiqudityDividend(holder, amount);
            }
            
        }
    }

    function setLiqudityHolder(address holder) internal {
        if (lpHolderSet.contains(holder)) {
            if (IERC20(uniswapV2Pair).balanceOf(holder) == 0) {
                lpHolderSet.remove(holder);
            }
            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(holder) == 0) return;
        lpHolderSet.add(holder);
    }


    function getCurrentPrice() view public returns (uint256 currentPrice){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0x55d398326f99059fF775485246999027B3197955;
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(1e18, path);
        return amounts[1];
    }

    function getIntervalDays() public view returns (uint256) {
        return block.timestamp.sub(startTime).div(1 days);
    }

    function setPrice() internal {
        uint256 intervalDay = getIntervalDays();
        if (priceMap[intervalDay] == 0) {
            priceMap[intervalDay] = getCurrentPrice();
        }
    }

    function getStartPrice() view public returns (uint256){
        uint256 intervalDay = getIntervalDays();
        uint256 _startPrice = priceMap[intervalDay];
        if (priceMap[intervalDay] == 0) {
            _startPrice = getCurrentPrice();
        }
        return _startPrice;
    }

    function getPriceDownRate() view public returns (uint256){
        uint256 currentPrice = getCurrentPrice();
        uint256 _startPrice = getStartPrice();
        uint256 ze = 0;
        if (currentPrice >= _startPrice) {
            return ze;
        }
        uint256 downRate = _startPrice.sub(currentPrice).mul(100).div(_startPrice);
        return downRate;
    }

    function burn(uint256 amount) public {
        require(msg.sender != address(0), "burn from the zero address");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[deadAddress] = _balances[deadAddress].add(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, deadAddress, amount);
    }


}