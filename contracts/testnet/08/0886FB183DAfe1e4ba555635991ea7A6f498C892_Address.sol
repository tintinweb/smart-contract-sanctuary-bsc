/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

/**
 
 SPDX-License-Identifier: MIT                            
                                                                    
*/

pragma solidity 0.8.7;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

interface IPancakeBEP20 {
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
}

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

interface IPancakeRouter01 {
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

    function addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountBNB,
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

    function removeLiquidityBNB(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountBNB);

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

    function removeLiquidityBNBWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountBNB);

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

    function swapExactBNBForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactBNB(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapBNBForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getamountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getamountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getamountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getamountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountBNB);

    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountBNB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

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
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https:     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https:     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https:     */
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
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https:     *
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
     * - the calling contract must have an BNB balance of at least `value`.
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

/**
 * @dev Library for managing
 * https: * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *      *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *      *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    struct Set {
        bytes32[] _values;
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
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex;
            set._values.pop();

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
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }

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
}

contract Lyst is IBEP20, Ownable {
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => bool) public is_auth;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _sellLock;

    address public _BUSDTokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    EnumerableSet.AddressSet private _excluded;
    EnumerableSet.AddressSet private _whiteList;
    EnumerableSet.AddressSet private _excludedFromSellLock;
    EnumerableSet.AddressSet private _excludedFromStaking;

    mapping(address => bool) public _blacklist;
    bool  public isBlacklist = true;

    string private constant _name = "Crypto Lyst";
    string private constant _symbol = "LYST";
    uint8 private constant _decimals = 18;
    uint256 public constant InitialSupply = 3500**9 * 10**_decimals;
    uint8 public constant BalanceLimitDivider = 100;
    uint16 public constant WhiteListBalanceLimitDivider = 1;
    uint16 public constant BuyLimitDivider = 150;
    uint16 public constant SellLimitDivider = 150;
    uint16 public constant MaxSellLockTime = 10 seconds;
    address private constant PancakeRouter =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant kaibaWallet = 0xcD531C959D6bB19B8C3b775fA39A4096cf2cd014;

    uint256 private _circulatingSupply = InitialSupply;
    uint256 public balanceLimit = _circulatingSupply;
    uint256 public sellLimit = _circulatingSupply;
    uint256 public buyLimit = _circulatingSupply;

    uint256 public qtyTokenToSwap = 17 * 10**9 * 10**_decimals;
    bool private manualTokenToSwap = false;
    bool private autoTokenToSwap = true;
    uint256 private manualQtyTokenToSwap = qtyTokenToSwap;
    bool private sellPeg = true;

    uint8 private _buyTax;
    uint8 private _sellTax;
    uint8 private _transferTax;

    uint8 private _marketingTax;
    uint8 private _liquidityTax;
    uint8 private _stakingTax;
    uint8 private _kaibaTax;

    address public deployer = 0xA1a1C6D8349D383BfF173255D7bA9Df1ba3aB800;

    address private _PancakePairAddress;
    IPancakeRouter02 private _PancakeRouter;

    modifier onlyAuthorized() {
        require(_isAuthorized(msg.sender), "Caller not in Authorized");
        _;
    }

    function _isAuthorized(address addr) private view returns (bool) {
        return addr == owner() || is_auth[addr];
    }

    constructor() {
        uint256 deployerBalance = (_circulatingSupply * 9) / 10;
        _balances[deployer] = deployerBalance;
        emit Transfer(address(0), deployer, deployerBalance);
        uint256 injectBalance = _circulatingSupply - deployerBalance;
        _balances[address(this)] = injectBalance;
        emit Transfer(address(0), address(this), injectBalance);

        _PancakeRouter = IPancakeRouter02(PancakeRouter);
        _PancakePairAddress = IPancakeFactory(_PancakeRouter.factory())
            .createPair(address(this), _PancakeRouter.WETH());
        _excludedFromSellLock.add(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _excludedFromStaking.add(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        balanceLimit = InitialSupply / BalanceLimitDivider;
        sellLimit = InitialSupply / SellLimitDivider;

        sellLockTime = 2 seconds;

        _buyTax = 16;
        _sellTax = 16;
        _transferTax = 16;
        _marketingTax = 50;
        _liquidityTax = 12;
        _stakingTax = 32;
        _kaibaTax = 6;
        _excluded.add(deployer);
        _excluded.add(msg.sender);
        _excludedFromStaking.add(address(_PancakeRouter));
        _excludedFromStaking.add(_PancakePairAddress);
        _excludedFromStaking.add(address(this));
        _excludedFromStaking.add(0x000000000000000000000000000000000000dEaD);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");

        bool isExcluded = (_excluded.contains(sender) ||
            _excluded.contains(recipient) ||
            is_auth[sender]);

        bool isContractTransfer = (sender == address(this) ||
            recipient == address(this));

        address _PancakeRouter_ = address(_PancakeRouter);
        bool isLiquidityTransfer = ((sender == _PancakePairAddress &&
            recipient == _PancakeRouter_) ||
            (recipient == _PancakePairAddress && sender == _PancakeRouter_));

        bool isBuy = sender == _PancakePairAddress || sender == _PancakeRouter_;
        bool isSell = recipient == _PancakePairAddress ||
            recipient == _PancakeRouter_;

        if (isContractTransfer || isLiquidityTransfer || isExcluded) {
            _feelessTransfer(sender, recipient, amount);
        } else {
            require(tradingEnabled, "trading not yet enabled");
            if (whiteListTrading) {
                _whiteListTransfer(sender, recipient, amount, isBuy, isSell);
            } else {
                _taxedTransfer(sender, recipient, amount, isBuy, isSell);
            }
        }
    }

    function _whiteListTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool isBuy,
        bool isSell
    ) private {
        if (!isSell) {
            require(
                _whiteList.contains(recipient),
                "recipient not on whitelist"
            );
            require(
                (_balances[recipient] + amount <=
                    InitialSupply / WhiteListBalanceLimitDivider),
                "amount exceeds whitelist max"
            );
        }
        _taxedTransfer(sender, recipient, amount, isBuy, isSell);
    }

    function _taxedTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool isBuy,
        bool isSell
    ) private {
        uint256 recipientBalance = _balances[recipient];
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");

        uint8 tax;
        if (isSell) {
            if (isBlacklist) {
                require(!_blacklist[sender]);
            }
            if (!_excludedFromSellLock.contains(sender)) {
                require(
                    _sellLock[sender] <= block.timestamp || sellLockDisabled,
                    "Seller in sellLock"
                );
                _sellLock[sender] = block.timestamp + sellLockTime;
            }
            require(amount <= sellLimit, "Dump protection");
            tax = _sellTax;
        } else if (isBuy) {
            require(
                recipientBalance + amount <= balanceLimit,
                "whale protection"
            );
            tax = _buyTax;
        } else {
            if (amount <= 10**(_decimals))
                claimFarmedToken(sender, _BUSDTokenAddress);
            require(
                recipientBalance + amount <= balanceLimit,
                "whale protection"
            );
            if (!_excludedFromSellLock.contains(sender))
                require(
                    _sellLock[sender] <= block.timestamp || sellLockDisabled,
                    "Sender in Lock"
                );
            tax = _transferTax;
        }
        if (
            (sender != _PancakePairAddress) &&
            (!manualConversion) &&
            (!_isSwappingContractModifier) &&
            isSell
        ) _swapContractToken(amount);
        uint256 tokensToBeMarketed = _calculateFee(amount, tax, _marketingTax);
        uint256 contractToken = _calculateFee(
            amount,
            tax,
            _stakingTax + _liquidityTax + _kaibaTax
        );
        uint256 taxedAmount = amount - (tokensToBeMarketed + contractToken);

        _removeToken(sender, amount);

        _balances[address(this)] += contractToken + tokensToBeMarketed;

        _addToken(recipient, taxedAmount);

        emit Transfer(sender, recipient, taxedAmount);
    }

    function _feelessTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _removeToken(sender, amount);
        _addToken(recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    function _calculateFee(
        uint256 amount,
        uint8 tax,
        uint8 taxPBEPent
    ) private pure returns (uint256) {
        return (amount * tax * taxPBEPent) / 10000;
    }

    bool private _isWithdrawing;
    uint256 private constant DistributionMultiplier = 2**64;
    uint256 public profitPerShare;
    uint256 public totalStakingReward;
    uint256 public totalPayouts;

    uint8 public marketingShare = 50;
    uint8 public kaibaShare = 10;
    uint256 public marketingBalance;
    uint256 public KaibaBalance;

    mapping(address => uint256) private alreadyPaidShares;
    mapping(address => uint256) private toBePaid;

    function isExcludedFromStaking(address addr) public view returns (bool) {
        return _excludedFromStaking.contains(addr);
    }

    function _getTotalShares() public view returns (uint256) {
        uint256 shares = _circulatingSupply;
        for (uint256 i = 0; i < _excludedFromStaking.length(); i++) {
            shares -= _balances[_excludedFromStaking.at(i)];
        }
        return shares;
    }

    function _addToken(address addr, uint256 amount) private {
        uint256 newAmount = _balances[addr] + amount;

        if (isExcludedFromStaking(addr)) {
            _balances[addr] = newAmount;
            return;
        }

        uint256 payment = _newDividentsOf(addr);
        alreadyPaidShares[addr] = profitPerShare * newAmount;
        toBePaid[addr] += payment;
        _balances[addr] = newAmount;
    }

    function _removeToken(address addr, uint256 amount) private {
        uint256 newAmount = _balances[addr] - amount;

        if (isExcludedFromStaking(addr)) {
            _balances[addr] = newAmount;
            return;
        }

        uint256 payment = _newDividentsOf(addr);
        _balances[addr] = newAmount;
        alreadyPaidShares[addr] = profitPerShare * newAmount;
        toBePaid[addr] += payment;
    }

    function _newDividentsOf(address staker) private view returns (uint256) {
        uint256 fullPayout = profitPerShare * _balances[staker];
        if (fullPayout < alreadyPaidShares[staker]) return 0;
        return
            (fullPayout - alreadyPaidShares[staker]) / DistributionMultiplier;
    }

    function _distributeStake(uint256 BNBamount) private {
        uint256 marketingSplit = (BNBamount * marketingShare) / 100;
        uint256 kaibaSplit = (BNBamount * kaibaShare) / 100;
        uint256 amount = BNBamount - marketingSplit - kaibaSplit;

        marketingBalance += marketingSplit;
        KaibaBalance += kaibaSplit;

        if (amount > 0) {
            totalStakingReward += amount;
            uint256 totalShares = _getTotalShares();
            if (totalShares == 0) {
                marketingBalance += amount;
            } else {
                profitPerShare += ((amount * DistributionMultiplier) /
                    totalShares);
            }
        }
    }

    event OnWithdrawFarmedToken(uint256 amount, address recipient);

    function claimFarmedToken(address addr, address tkn) private {
        require(!_isWithdrawing);
        _isWithdrawing = true;
        uint256 amount;
        if (isExcludedFromStaking(addr)) {
            amount = toBePaid[addr];
            toBePaid[addr] = 0;
        } else {
            uint256 newAmount = _newDividentsOf(addr);
            alreadyPaidShares[addr] = profitPerShare * _balances[addr];
            amount = toBePaid[addr] + newAmount;
            toBePaid[addr] = 0;
        }
        if (amount == 0) {
            _isWithdrawing = false;
            return;
        }
        totalPayouts += amount;
        address[] memory path = new address[](2);
        path[0] = _PancakeRouter.WETH();
        path[1] = tkn;
        _PancakeRouter.swapExactBNBForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, addr, block.timestamp);

        emit OnWithdrawFarmedToken(amount, addr);
        _isWithdrawing = false;
    }

    uint256 public totalLPBNB;
    bool private _isSwappingContractModifier;
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    function _swapContractToken(uint256 sellAmount) private lockTheSwap {
        uint256 contractBalance = _balances[address(this)];
        uint16 totalTax = _liquidityTax + _stakingTax + _marketingTax;
        uint256 tokenToSwap = (sellLimit * 50) / 100;
        if (manualTokenToSwap) {
            tokenToSwap = manualQtyTokenToSwap;
        }
        if (autoTokenToSwap && !manualTokenToSwap) {
            tokenToSwap =
                ((_circulatingSupply -
                    _balances[0x10ED43C718714eb63d5aA57B78B54704E256024E]) *
                    5) /
                100;
        }

        if (sellPeg) {
            if (tokenToSwap > sellAmount) {
                tokenToSwap = sellAmount - 1;
            }
        }

        if (contractBalance < tokenToSwap || totalTax == 0) {
            return;
        }
        uint256 tokenForLiquidity = (tokenToSwap * _liquidityTax) / totalTax;
        uint256 tokenForMarketing = (tokenToSwap * _marketingTax) / totalTax;
        uint tokenForKaiba =  (tokenToSwap * _kaibaTax) / totalTax;
        uint256 tokenForStaking = tokenToSwap -
            tokenForMarketing -
            tokenForKaiba -
            tokenForLiquidity;
        uint256 liqToken = tokenForLiquidity / 2;
        uint256 liqBNBToken = tokenForLiquidity - liqToken;

        uint256 swapToken = liqBNBToken + tokenForMarketing + tokenForStaking + tokenForKaiba;
        uint256 initialBNBBalance = address(this).balance;
        _swapTokenForBNB(swapToken);
        uint256 newBNB = (address(this).balance - initialBNBBalance);
        uint256 liqBNB = (newBNB * liqBNBToken) / swapToken;
        _addLiquidity(liqToken, liqBNB);
        uint256 distributeBNB = (address(this).balance - initialBNBBalance);
        _distributeStake(distributeBNB);
    }

    function _swapTokenForBNB(uint256 amount) private {
        _approve(address(this), address(_PancakeRouter), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _PancakeRouter.WETH();

        _PancakeRouter.swapExactTokensForBNBSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenamount, uint256 BNBamount) private {
        totalLPBNB += BNBamount;
        _approve(address(this), address(_PancakeRouter), tokenamount);
        _PancakeRouter.addLiquidityBNB{value: BNBamount}(
            address(this),
            tokenamount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function getLimits() public view returns (uint256 balance, uint256 sell) {
        return (balanceLimit / 10**_decimals, sellLimit / 10**_decimals);
    }

    function getTaxes()
        public
        view
        returns (
            uint256 Marketedax,
            uint256 liquidityTax,
            uint256 stakingTax, 
            uint kaibaTax,
            uint256 buyTax,
            uint256 sellTax,
            uint256 transferTax
        )
    {
        return (
            _marketingTax,
            _liquidityTax,
            _stakingTax,
            _kaibaTax,
            _buyTax,
            _sellTax,
            _transferTax
        );
    }

    function getWhitelistedStatus(address AddressToCheck)
        public
        view
        returns (bool)
    {
        return _whiteList.contains(AddressToCheck);
    }

    function getAddressSellLockTimeInSeconds(address AddressToCheck)
        public
        view
        returns (uint256)
    {
        uint256 lockTime = _sellLock[AddressToCheck];
        if (lockTime <= block.timestamp) {
            return 0;
        }
        return lockTime - block.timestamp;
    }

    function getSellLockTimeInSeconds() public view returns (uint256) {
        return sellLockTime;
    }

    function AddressResetSellLock() public {
        _sellLock[msg.sender] = block.timestamp + sellLockTime;
    }

    function FarmedBUSDWithdraw() public {
        claimFarmedToken(msg.sender, _BUSDTokenAddress);
    }
    function getDividends(address addr) public view returns (uint256) {
        if (isExcludedFromStaking(addr)) return toBePaid[addr];
        return _newDividentsOf(addr) + toBePaid[addr];
    }

    bool public sellLockDisabled;
    uint256 public sellLockTime;
    bool public manualConversion;

    function AuthorizedExcludeFromStaking(address addr) public onlyAuthorized {
        require(_excludedFromStaking.length() < 30);
        require(!isExcludedFromStaking(addr));
        uint256 newDividents = _newDividentsOf(addr);
        alreadyPaidShares[addr] = _balances[addr] * profitPerShare;
        toBePaid[addr] += newDividents;
        _excludedFromStaking.add(addr);
    }

    function AuthorizedIncludeToStaking(address addr) public onlyAuthorized {
        require(isExcludedFromStaking(addr));
        _excludedFromStaking.remove(addr);
        alreadyPaidShares[addr] = _balances[addr] * profitPerShare;
    }

    function AuthorizedWithdrawMarketingBNB() public onlyAuthorized {
        uint256 amount = marketingBalance;
        marketingBalance = 0;
        (bool sent, ) = msg.sender.call{value: (amount)}("");
        require(sent, "withdraw failed");
    }

    function AuthorizedWithdrawKaibaBNB() public onlyAuthorized {
        uint256 amount = KaibaBalance;
        KaibaBalance = 0;
        (bool sent, ) = kaibaWallet.call{value: (amount)}("");
        require(sent, "withdraw failed");
    }

    function AuthorizedSwapSetSellPeg(bool setter) public onlyAuthorized {
        sellPeg = setter;
    }

    function AuthorizedSwapSetAutoUpdateLiqSell(bool setter)
        public
        onlyAuthorized
    {
        autoTokenToSwap = setter;
    }

    function AuthorizedSwapSetManualLiqSell(bool setter) public onlyAuthorized {
        manualTokenToSwap = setter;
    }

    function AuthorizedSwapSetManualLiqSellTokens(uint256 amount)
        public
        onlyAuthorized
    {
        require(
            amount > 1 && amount < 100000000,
            "Values between 1 and 100000000"
        );
        manualQtyTokenToSwap = amount * 10**9;
    }

    function AuthorizedSwapSwitchManualBNBConversion(bool manual)
        public
        onlyAuthorized
    {
        manualConversion = manual;
    }

    function AuthorizedDisableSellLock(bool disabled) public onlyAuthorized {
        sellLockDisabled = disabled;
    }

    function AuthorizedSetSellLockTime(uint256 sellLockSeconds)
        public
        onlyAuthorized
    {
        require(sellLockSeconds <= MaxSellLockTime, "Sell Lock time too high");
        sellLockTime = sellLockSeconds;
    }

    function AuthorizedSetTaxes(
        uint8 Marketedaxes,
        uint8 liquidityTaxes,
        uint8 stakingTaxes,
        uint8 buyTax,
        uint8 sellTax,
        uint8 transferTax
    ) public onlyAuthorized {
        uint8 totalTax = Marketedaxes + liquidityTaxes + stakingTaxes;
        require(totalTax == 100, "burn+liq+marketing needs to equal 100%");

        _marketingTax = Marketedaxes;
        _liquidityTax = liquidityTaxes;
        _stakingTax = stakingTaxes;

        _buyTax = buyTax;
        _sellTax = sellTax;
        _transferTax = transferTax;
    }

    function AuthorizedChangeMarketingShare(uint8 newShare)
        public
        onlyAuthorized
    {
        require(newShare <= 90);
        marketingShare = newShare;
    }

    function AuthorizedExcludeAccountFromFees(address account)
        public
        onlyAuthorized
    {
        _excluded.add(account);
    }

    function AuthorizedIncludeAccountToFees(address account)
        public
        onlyAuthorized
    {
        _excluded.remove(account);
    }

    function AuthorizedExcludeAccountFromSellLock(address account)
        public
        onlyAuthorized
    {
        _excludedFromSellLock.add(account);
    }

    function AuthorizedIncludeAccountToSellLock(address account)
        public
        onlyAuthorized
    {
        _excludedFromSellLock.remove(account);
    }

    function AuthorizedUpdateLimits(
        uint256 newBalanceLimit,
        uint256 newSellLimit
    ) public onlyAuthorized {
        require(newSellLimit < _circulatingSupply / 50);
        newBalanceLimit = newBalanceLimit * 10**_decimals;
        newSellLimit = newSellLimit * 10**_decimals;
        uint256 targetBalanceLimit = _circulatingSupply / BalanceLimitDivider;
        uint256 targetSellLimit = _circulatingSupply / SellLimitDivider;

        require(
            (newBalanceLimit >= targetBalanceLimit),
            "newBalanceLimit needs to be at least target"
        );
        require(
            (newSellLimit >= targetSellLimit),
            "newSellLimit needs to be at least target"
        );

        balanceLimit = newBalanceLimit;
        sellLimit = newSellLimit;
    }

    bool public tradingEnabled;
    bool public whiteListTrading;
    address private _liquidityTokenAddress;

    function SetupEnableTrading() public onlyAuthorized {
        require(!tradingEnabled);
        tradingEnabled = true;
    }

    function SetupLiquidityTokenAddress(address liquidityTokenAddress)
        public
        onlyAuthorized
    {
        _liquidityTokenAddress = liquidityTokenAddress;
    }

    function SetupAddToWhitelist(address addressToAdd) public onlyAuthorized {
        _whiteList.add(addressToAdd);
    }

    function SetupAddArrayToWhitelist(address[] memory addressesToAdd)
        public
        onlyAuthorized
    {
        for (uint256 i = 0; i < addressesToAdd.length; i++) {
            _whiteList.add(addressesToAdd[i]);
        }
    }

    function SetupRemoveFromWhitelist(address addressToRemove)
        public
        onlyAuthorized
    {
        _whiteList.remove(addressToRemove);
    }

    function rescueTokens(address tknAddress) public onlyAuthorized {
        IBEP20 token = IBEP20(tknAddress);
        uint256 ourBalance = token.balanceOf(address(this));
        require(ourBalance > 0, "No tokens in our balance");
        token.transfer(msg.sender, ourBalance);
    }

    function setBlacklistEnabled(bool isBlacklistEnabled)
        public
        onlyAuthorized
    {
        isBlacklist = isBlacklistEnabled;
    }

    function setBlacklistedAddress(address toBlacklist) public onlyAuthorized {
        _blacklist[toBlacklist] = true;
    }

    function removeBlacklistedAddress(address toRemove) public onlyAuthorized {
        _blacklist[toRemove] = false;
    }

    function AuthorizedRemoveRemainingBNB() public onlyAuthorized {
        (bool sent, ) = msg.sender.call{value: (address(this).balance)}(
            ""
        );
        require(sent);
    }

    receive() external payable {}

    fallback() external payable {}

    function getOwner() external view override returns (address) {
        return owner();
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _circulatingSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}