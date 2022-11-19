/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
// pragma solidity >=0.6.2;
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
// pragma solidity >=0.6.2;
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
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

contract CsToken is Ownable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    using EnumerableSet for EnumerableSet.AddressSet;

    address public civilizationFundAddress;
    address public greyTraceFundAddress;
    address public vortexBlessingAddress;
    address public daoAddress;
    address public bountyMechanismAddress;
    address public _DEAD;

    uint256 public burnRate;
    uint256 public civilizationFundRate;
    uint256 public greyTraceFundRate;
    uint256 public vortexBlessingRate;
    uint256 public daoRate;
    uint256 public bountyMechanismRate;

    mapping(address => bool) public isPair;
    mapping(address => bool) private _isExcludedFromFee;

    address public pairAddress;

    address public uniswapRouterAddress;

    address public usdtAddress;
    uint256 public profitBalanceLimit;
    function setProfitBalanceLimit(uint256 _profitBalanceLimit) public onlyOwner {
        profitBalanceLimit = _profitBalanceLimit;
    }
    spotBonus spot;
    constructor() {

        uniswapRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        civilizationFundAddress = 0x08A6babD9d2F3216fb547692F958F634283BA557;
        greyTraceFundAddress = 0x488F6D05Dc40a66c8d46e231Ce3eFCd32307b224;
        vortexBlessingAddress = 0xD3fee77fb7D415AADdAF4e9a8F97e0227f390e04;
        bountyMechanismAddress = 0x68619AE44fCD7eF7E2EC280504687D94E240d8Ad;
        daoAddress = 0x2EE452d8fF7492283a5C82ce7b874894fDE7b12E;
        _DEAD = 0x000000000000000000000000000000000000dEaD;

        burnRate = 200;
        civilizationFundRate = 100;
        greyTraceFundRate = 100;
        vortexBlessingRate = 200;
        daoRate = 300;
        bountyMechanismRate = 800;

        _name = "Cosmic scale";
        _symbol = "CS";
        uint256 burnNumber = 36 * 10**8;
        _mint(_DEAD, burnNumber * 10**decimals());
        uint256 initNumber = 3 * 10**7;
        _mint(greyTraceFundAddress, initNumber * 10**decimals());
        _isExcludedFromFee[_DEAD] = true;
        _isExcludedFromFee[address(0)] = true;
        _isExcludedFromFee[civilizationFundAddress] = true;
        _isExcludedFromFee[greyTraceFundAddress] = true;
        _isExcludedFromFee[vortexBlessingAddress] = true;
        _isExcludedFromFee[bountyMechanismAddress] = true;
        _isExcludedFromFee[daoAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouterAddress);
        // Create a uniswap pair for this new token
        pairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdtAddress);
        isPair[pairAddress] = true;
        
        swapAndLiquifyEnabled = true;
        distributor = new Distributor(usdtAddress);
        numTokensSellToAddToLiquidity = 100 * 10**4 * 10**18;
    }
    function init2() public onlyOwner{
        spot = new spotBonus(address(this));
        maxTotalSupply = 210 *10**8 * 10**18;
        profitBalanceLimit = 1000 * 10**18;
        funcAddress = 0xaE0051473C99b303090efE1F377a9BaA67721439;
        spot.addWhitelist(civilizationFundAddress);
        spot.addWhitelist(greyTraceFundAddress);
        spot.addWhitelist(vortexBlessingAddress);
        spot.addWhitelist(bountyMechanismAddress);
        spot.addWhitelist(daoAddress);
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
        return _totalSupply + spot.spotTotal();
    }
    function totalSupplyForSpot() public view returns (uint256) {
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
        if(isPair[account]){
            return _balances[account];
        }
        (,,,uint256 stakeAmount) = spot.spotMap(account);
        if(_balances[account]+stakeAmount<=profitBalanceLimit){
            return _balances[account];
        }
        
        return _balances[account] + spot.earned(account);
    }
    function balanceForSpotOf(address account)
        public
        view
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
        _approve(_msgSender(), spender, amount);
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

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
    event TransferDaoLog(address indexed user, uint256 amount, uint256 time);
    event TransferBountyLog(address indexed user, uint256 amount, uint256 time);
    event PancakeLog(address indexed user,bool isBuy, uint256 amount, uint256 time);
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 profitNumberFrom = spot.takeProfit(from);
        _totalSupply +=profitNumberFrom;
        if(_balances[from]<=profitBalanceLimit){
            _balances[_DEAD] += profitNumberFrom;
        }else{
            _balances[from] += profitNumberFrom;
        }
        uint256 profitNumberTo = spot.takeProfit(to);
        _totalSupply +=profitNumberTo;
        if(_balances[to]<=profitBalanceLimit){
            _balances[_DEAD] += profitNumberTo;
        }else{
            _balances[to] += profitNumberTo;
        }
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 senderBalance = _balances[from];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[from] = senderBalance-amount;

        //buy or sell
        uint256 toAmount = amount;

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            //sell
            if (isPair[to] ) {
                uint256 daoAmount  = 0;
                if (daoRate > 0) {
                    daoAmount = amount*daoRate/10**4;
                    _balances[daoAddress] = _balances[daoAddress]+daoAmount;
                    emit Transfer(from, daoAddress, daoAmount);
                    toAmount = toAmount-daoAmount;
                    emit TransferDaoLog(daoAddress, daoAmount, block.timestamp);
                }
                uint256 burnAmount = 0;
                if (burnRate > 0) {
                    burnAmount = amount*burnRate/10**4;
                    _balances[_DEAD] = _balances[_DEAD]+burnAmount;
                    emit Transfer(from, _DEAD, burnAmount);
                    toAmount = toAmount-burnAmount;
                }
                uint256 civilizationFundAmount = 0;
                if (civilizationFundRate > 0) {
                    civilizationFundAmount = amount*civilizationFundRate/10**4;
                    _balances[civilizationFundAddress] = _balances[civilizationFundAddress]+civilizationFundAmount;
                    emit Transfer(from, civilizationFundAddress, civilizationFundAmount);
                    toAmount = toAmount-civilizationFundAmount;
                }
                uint256 greyTraceFundAmount = 0;
                if (greyTraceFundRate > 0) {
                    greyTraceFundAmount = amount*greyTraceFundRate/10**4;
                    _balances[greyTraceFundAddress] = _balances[greyTraceFundAddress]+greyTraceFundAmount;
                    emit Transfer(from, greyTraceFundAddress, greyTraceFundAmount);
                    toAmount = toAmount-greyTraceFundAmount;
                }
                uint256 vortexBlessingAmount = 0;
                if (vortexBlessingRate > 0) {
                    vortexBlessingAmount = amount*vortexBlessingRate/10**4;
                    _balances[address(this)] = _balances[address(this)]+vortexBlessingAmount;
                    emit Transfer(from, address(this), vortexBlessingAmount);
                    toAmount = toAmount-vortexBlessingAmount;
                }
                emit PancakeLog(from, false, amount, block.timestamp);
                
            }else if(isPair[from]){
                uint256 civilizationFundAmount = 0;
                if (civilizationFundRate > 0) {
                    civilizationFundAmount = amount*civilizationFundRate/10**4;
                    _balances[civilizationFundAddress] = _balances[civilizationFundAddress]+civilizationFundAmount;
                    emit Transfer(from, civilizationFundAddress, civilizationFundAmount);
                    toAmount = toAmount-civilizationFundAmount;
                }
                uint256 bountyMechanismAmount = 0;
                if (bountyMechanismRate > 0) {
                    bountyMechanismAmount = amount*bountyMechanismRate/10**4;
                    _balances[bountyMechanismAddress] = _balances[bountyMechanismAddress]+bountyMechanismAmount;
                    emit Transfer(from, bountyMechanismAddress, bountyMechanismAmount);
                    toAmount = toAmount-bountyMechanismAmount;
                    emit TransferBountyLog(bountyMechanismAddress,bountyMechanismAmount,block.timestamp);
                }
                emit PancakeLog(from, true, amount, block.timestamp);
            }
            
        }

        _balances[to] = _balances[to]+toAmount;
        uint256 contractTokenBalance = _balances[address(this)];
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !isPair[from] &&
            !isPair[to] &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        emit Transfer(from, to, toAmount);
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
        // require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        // emit Transfer(address(0), account, amount);
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

    function setFeeAddress(address _daoAddress,address _civilizationFundAddress,address _greyTraceFundAddress,address _vortexBlessingAddress,address _bountyMechanismAddress) external onlyOwner {
        daoAddress = _daoAddress;
        civilizationFundAddress = _civilizationFundAddress;
        greyTraceFundAddress = _greyTraceFundAddress;
        vortexBlessingAddress = _vortexBlessingAddress;
        bountyMechanismAddress = _bountyMechanismAddress;
    }

    function setFeeRate(uint256 _daoRate,uint256 _burnRate,uint256 _civilizationFundRate,uint256 _greyTraceFundRate,uint256 _vortexBlessingRate,uint256 _bountyMechanismRate) external onlyOwner {
        daoRate = _daoRate;
        burnRate = _burnRate;
        civilizationFundRate = _civilizationFundRate;
        greyTraceFundRate = _greyTraceFundRate;
        vortexBlessingRate = _vortexBlessingRate;
        bountyMechanismRate = _bountyMechanismRate;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setIsPair(address _pairAddress, bool isFee) public onlyOwner {
        isPair[_pairAddress] = isFee;
    }
    uint256 public maxTotalSupply; 
    function setMaxTotalSupply(uint256 _maxTotalSupply) public onlyOwner {
        maxTotalSupply = _maxTotalSupply;
    }
    function grantReward(address to, uint256 amount) external onlySpot {
        if (totalSupply() + amount >= maxTotalSupply) {
            _mint(to, maxTotalSupply - totalSupply());
        } else {
            _mint(to, amount);
        }
    }

    modifier onlySpot() {
        require(msg.sender == address(spot), "caller is not the stake contract");
        _;
    }
    address public funcAddress;
    modifier onlyFunc() {
        require(
                funcAddress == msg.sender,
            "caller is not the funcAddress"
        );
        _;
    }
    function setFuncAddress(address _funcAddress) public onlyOwner {
        funcAddress = _funcAddress;
    }

    mapping(address=>uint256) public stakeMap;
    event StakeLp(address userAddress, uint256 lpAmount,uint256 csAmount,uint256 time);
    function stakeLp() public {
        require(msg.sender ==tx.origin,"not allow contract call");
        require(stakeMap[msg.sender]==0,"already stake");
        uint256 lpBalance = IERC20(pairAddress).balanceOf(msg.sender);
        uint256 csAmount = 30000 * 1e18;
        
        require(lpBalance>=1000*1e18, "lp less than 1000");

        if(lpBalance>=4800*1e18){
            csAmount = 150000 * 1e18;
        }else if(lpBalance>=1600*1e18){
            csAmount = 50000 * 1e18;
        }
        uint256 profitNumber = spot.takeProfit(msg.sender);
        _totalSupply +=profitNumber;
        if(_balances[msg.sender]<=profitBalanceLimit){
            _balances[_DEAD] += profitNumber;
        }else{
            _balances[msg.sender] += profitNumber;
        }

        IERC20(pairAddress).transferFrom(
            msg.sender,
            address(this),
            lpBalance
        );
        stakeMap[msg.sender] = lpBalance;
        spot.stake(msg.sender,csAmount);
        emit StakeLp(msg.sender,lpBalance,csAmount,block.timestamp);
    }
    event UnstakeLp(address userAddress, uint256 lpAmount,uint256 time);
    function unstakeLp() public {
        require(msg.sender ==tx.origin,"not allow contract call");
        require(stakeMap[msg.sender]>0,"no stake");
        uint256 profitNumber = spot.takeProfit(msg.sender);
        _totalSupply +=profitNumber;
        if(_balances[msg.sender]<=profitBalanceLimit){
            _balances[_DEAD] += profitNumber;
        }else{
            _balances[msg.sender] += profitNumber;
        }
        uint256 lpAmount = stakeMap[msg.sender];
        stakeMap[msg.sender] = 0;
        IERC20(pairAddress).transfer(msg.sender, lpAmount);
        spot.unstake(msg.sender);
        emit UnstakeLp(msg.sender,lpAmount,block.timestamp);
    }
    function getLpAmount(uint256 csAmount) public view returns(uint256 amount) {
        uint256 lpTotal = IPair(pairAddress).totalSupply();
        address token0 = IPair(pairAddress).token0();
        (uint112 reserve0, uint112 reserve1,) = IPair(pairAddress).getReserves();
        uint256 totalCs = token0 == address(this) ? reserve0 : reserve1;
        uint256 perLpCsAmount = totalCs * 1e18 / lpTotal;
        return csAmount * 1e18 / perLpCsAmount ;
    }
    function setCommonAddress(address _uniswapV2RouterAddress,address _usdtAddress,address _pairAddress) public onlyOwner{
        uniswapRouterAddress = _uniswapV2RouterAddress;
        usdtAddress = _usdtAddress;
        pairAddress = _pairAddress;
    }
    Distributor distributor;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;
    uint256 public numTokensSellToAddToLiquidity;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2 ;
        uint256 otherHalf = contractTokenBalance - half ;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 receivedEth = IERC20(usdtAddress).balanceOf(address(this)) - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, receivedEth);
        
        emit SwapAndLiquify(half, receivedEth, otherHalf);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;

        _approve(address(this), uniswapRouterAddress, tokenAmount);

        // make the swap
        IUniswapV2Router02(uniswapRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(distributor),
            block.timestamp
        );
        distributor.sendUSDT(address(this), IERC20(usdtAddress).balanceOf(address(distributor)));
    }

  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), uniswapRouterAddress, tokenAmount);
        IERC20(usdtAddress).approve(uniswapRouterAddress, ethAmount);

        // add the liquidity
        (,uint256 amountToken2,) = IUniswapV2Router02(uniswapRouterAddress).addLiquidity(
            address(this),
            usdtAddress,
            tokenAmount,
            ethAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            vortexBlessingAddress,
            block.timestamp
        );
        if(amountToken2 > 0) {
          IERC20(usdtAddress).transfer(vortexBlessingAddress, IERC20(usdtAddress).balanceOf(address(this)));
        }
    }

    function setNumTokensSellToAddToLiquidity(uint256 number) public onlyOwner {
        numTokensSellToAddToLiquidity = number;
    }
}
contract spotBonus{
    address mainAddress;
    using EnumerableSet for EnumerableSet.AddressSet;
    constructor(address _mainAddress){
        mainAddress = _mainAddress;
        lastBlockNumber = block.number;
        coreRate = 50;
        earlyRate = 50;
        daoRate = 50;
        ashRate = 50;
        burnRate = 250;

        coreAddress = address(0xA5b6d2699Cb7391b0ED21B2403c6642B7Be79D0A);
        earlyAddress = address(0x54db542d1f88289a3eE9b321094568f95d3CB935);
        daoAddress = address(0x027957C46CC793af63238E9454F8646d8e682f77);
        ashAddress = address(0xdf0Eed2A7A64597458728C24ad271E8b734B0ee0);
        burnAddress = address(0x000000000000000000000000000000000000dEaD);
        _whitelist.add(coreAddress);
        _whitelist.add(earlyAddress);
        _whitelist.add(daoAddress);
        _whitelist.add(ashAddress);
    }
    //distribution
    struct spot {
        uint256 remainProfit;
        uint256 receivedProfit;
        uint256 stakeAverage;
        uint256 stakeAmount;
    }
    mapping(address=>spot) public spotMap;

    uint256 public stakeTotalAverage = 0;
    uint256 public lastBlockNumber = 0;
    uint256 public coreRate;
    uint256 public earlyRate;
    uint256 public daoRate;
    uint256 public ashRate;
    uint256 public burnRate;

    address public coreAddress;
    address public earlyAddress;
    address public daoAddress;
    address public ashAddress;
    address public burnAddress;

    uint256 public canBurnAmount;
    uint256 public lastBurnTime;

    uint256 public oneProfit = 900 * 1e18;
    uint256 public issuedQuantity;
    uint256 public totalProfit;

    EnumerableSet.AddressSet private _whitelist;
    function rewardPerTime() public returns (uint256 amount) {
        uint256 tokenBalance = IERC20(mainAddress).totalSupply();
        uint256 tempProfit=0;
        if (tokenBalance <= 1800000000 * 1e18) {
            tempProfit = 900 * 1e18;
        } else if (tokenBalance < 3600000000 * 1e18) {
            tempProfit = 840 * 1e18;
        } else if (tokenBalance < 7200000000 * 1e18) {
            tempProfit = 780 * 1e18;
        } else if (tokenBalance < CsToken(mainAddress).maxTotalSupply()) {
            tempProfit = 270 * 1e18;
        }
        if(tempProfit < oneProfit){
            oneProfit = tempProfit;
        }
        return tempProfit;
    }

    function spotTotal() public view returns(uint256){
        uint256 tempProfit = oneProfit *(block.number - lastBlockNumber);
        return tempProfit+totalProfit-issuedQuantity;
    }

    function rewardPerToken() public view returns (uint256) {
        uint256 _totalSupply = CsToken(mainAddress).totalSupplyForSpot();
        uint256 whiteLength = _whitelist.length();
        for (uint256 i = 0; i < whiteLength; i++) {
            address account = _whitelist.at(i);
            _totalSupply -= CsToken(mainAddress).balanceOf(account);
        }
        if (_totalSupply == 0) {
            return stakeTotalAverage;
        }
        uint256 addPerTokenStored = (((oneProfit *
            (block.number - lastBlockNumber)) / 2) * 1e18) / _totalSupply;
        return stakeTotalAverage + addPerTokenStored;
    }
    
    function earned(address account) public view returns (uint256) {
        if(isWhitelist(account)){
            return 0;
        }
        uint256 _balance = CsToken(mainAddress).balanceForSpotOf(account) + spotMap[account].stakeAmount;
        if (_balance == 0) {
            return 0;
        }
        return _balance * (rewardPerToken() - spotMap[account].stakeAverage) / 1e18 + spotMap[account].remainProfit;
    }
    function changeAverageFunc(address account) public onlyMain {
        if(lastBlockNumber != block.number){
            stakeTotalAverage = rewardPerToken();
            rewardPerTime();
            (  uint256 amount,
                uint256 coreAmount,
                uint256 earlyAmount,
                uint256 daoAmount,
                uint256 ashAaseAmount,
                uint256 burnAmount
            ) = rewardDaoToken();
            if(amount > 0) {
                CsToken(mainAddress).grantReward(coreAddress, coreAmount);
                CsToken(mainAddress).grantReward(earlyAddress, earlyAmount);
                CsToken(mainAddress).grantReward(daoAddress, daoAmount);
                CsToken(mainAddress).grantReward(ashAddress, ashAaseAmount);
                canBurnAmount += burnAmount;
                totalProfit += amount;
            }
            
            if(block.timestamp >= lastBurnTime + 10 * 1 days) {
                CsToken(mainAddress).grantReward(burnAddress, canBurnAmount);  
                canBurnAmount = 0;
            }
            lastBlockNumber = block.number;
        }
        
        if (account != address(0)) {
            spotMap[account].remainProfit = earned(account);
            spotMap[account].stakeAverage = stakeTotalAverage;
        }
    }
    modifier changeAverage(address account){
        changeAverageFunc(account);
        _;
    }
    
    function takeProfit(address userAddress) public changeAverage(userAddress) onlyMain returns(uint256){
        uint256 takeToken = spotMap[userAddress].remainProfit;

        spotMap[userAddress].remainProfit = 0;
        spotMap[userAddress].receivedProfit += takeToken;
        issuedQuantity += takeToken;
        return takeToken;
    }
    function stake(address userAddress,uint256 amount) public onlyMain{
        spotMap[userAddress].stakeAmount += amount;
    }
    function unstake(address userAddress) public onlyMain{
        spotMap[userAddress].stakeAmount = 0;
    }
    function rewardDaoToken()
        public
        view
        returns (
            uint256 amount,
            uint256 coreAmount,
            uint256 earlyAmount,
            uint256 daoAmount,
            uint256 ashAaseAmount,
            uint256 burnAmount
        )
    {
        amount = (oneProfit * (block.number - lastBlockNumber)) / 2;
        coreAmount = amount * coreRate / (coreRate + earlyRate + daoRate + ashRate + burnRate);
        earlyAmount = amount * earlyRate / (coreRate + earlyRate + daoRate + ashRate + burnRate);
        daoAmount = amount * daoRate / (coreRate + earlyRate + daoRate + ashRate + burnRate);
        ashAaseAmount = amount * ashRate / (coreRate + earlyRate + daoRate + ashRate + burnRate);
        burnAmount = amount * burnRate / (coreRate + earlyRate + daoRate + ashRate + burnRate);

    }
    modifier onlyMain() {
        require(mainAddress == msg.sender||address(this)==msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Add a whitelist address that calls the mint function
     * @param account Whitelist address to be added
     */
    function addWhitelist(address account) external onlyFunc returns (bool) {
        require(account != address(0), "nft: account is the zero address");
        _whitelist.add(account);
        return true;
    }

    /**
     * @dev delete a whitelist address that calls the mint function
     * @param account Whitelist address to be deleted
     */
    function delWhitelist(address account) external onlyFunc returns (bool) {
        require(account != address(0), "nft: account is the zero address");
        _whitelist.remove(account);
        return true;
    }
    function getWhitelistLength() public view returns (uint256) {
        return _whitelist.length();
    }

    function isWhitelist(address account) public view returns (bool) {
        return _whitelist.contains(account);
    }
    function getWhitelist(uint256 _index)
        public
        view
        returns (address)
    {
        require(_index <= getWhitelistLength() - 1, "nft: index out of bounds");
        return _whitelist.at(_index);
    }
    modifier onlyFunc() {
        require(CsToken(mainAddress).funcAddress() == msg.sender||mainAddress== msg.sender, "Ownable: caller is not the func");
        _;
    }
    function setCommonAddress(address _coreAddress,address _earlyAddress,address _daoAddress,address _ashAddress) public onlyFunc{
        _whitelist.remove(coreAddress);
        _whitelist.remove(earlyAddress);
        _whitelist.remove(daoAddress);
        _whitelist.remove(ashAddress);
        coreAddress = _coreAddress;
        earlyAddress = _earlyAddress;
        daoAddress = _daoAddress;
        ashAddress = _ashAddress;
        _whitelist.add(coreAddress);
        _whitelist.add(earlyAddress);
        _whitelist.add(daoAddress);
        _whitelist.add(ashAddress);
    }
    function setCommonRate(uint256 _coreRate,uint256 _earlyRate,uint256 _daoRate,uint256 _ashRate,uint256 _burnRate) public onlyFunc{
        coreRate = _coreRate;
        earlyRate = _earlyRate;
        daoRate = _daoRate;
        ashRate = _ashRate;
        burnRate = _burnRate;
    }
}
struct IdoUser {
    uint256 investAmount;
    uint256 teamReward;
    bool isIdo;
    uint256 amount;
}
interface IPair {
    function totalSupply() external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IIdo {
  function userInfo(address user) external view returns (IdoUser memory info);
}
interface IDistributor {
    function sendUSDT(address to, uint256 amount) external;
}

contract Distributor is IDistributor {
    address USDT;
    address owner;

    constructor(address u) {
        USDT = u;
        owner = msg.sender;
        IERC20(USDT).approve(owner, ~uint256(0));
    }

    function sendUSDT(address to, uint256 amount) external override {
        require(msg.sender == owner, "not owner");
        IERC20(USDT).transfer(to, amount);
    }
}