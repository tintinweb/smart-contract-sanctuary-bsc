/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: GPL-3.0-or-later

// A fork of Reflect.Finance and EverestCoin

pragma solidity ^0.8.15;

interface IERC20Upgradeable {
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

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
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

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
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
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
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

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

contract DabloonInu is IERC20Upgradeable, ContextUpgradeable, OwnableUpgradeable {
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    enum FeeType {
        REFLECTION, DEV, BURN
    }

    enum TransferType {
        STANDARD, TO_EXCLUDED, FROM_EXCLUDED, BOTH_EXCLUDED
    }

    struct TValues {
        uint256 tTransferAmount;
        uint256 reflectionFee;
        uint256 devFee;
        uint256 burnFee;
    }

    struct RInputs {
        uint256 tAmount;
        uint256 reflectionFee;
        uint256 devFee;
        uint256 burnFee;
        uint256 currentRate;
    }

    struct RValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rReflectionFee;
        uint256 rDevFee;
        uint256 rBurnFee;
    }

    mapping (address => bool) private _isExcludedFromReflections;
    address[] private _excludedFromReflections;

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excludedFromFee;

    mapping (address => bool) private _isExcludedFromTxLimitFromAddresses;
    address[] private _excludedFromTxLimitFromAddresses;

    struct TransferHistory {
    uint256 timestamp;
    address to;
    uint256 amount;
    }

    mapping (address => TransferHistory[]) transferHistory;

    address private _appWallet;

    uint256 private constant MAX = ~uint256(0);
    uint private constant UINT_MAX = type(uint).max;

    event AppWalletTransferred(address indexed previousAppWallet, address indexed newAppWallet);

    event FeePercentageUpdated(FeeType feeType, uint256 feePercentage);

    event TxTimeLimitUpdated(uint256 txTimeLimit);
    event TxLimitUpdated(uint256 txLimit);

    event SniperStartBlockUpdated(uint256 _block);
    event SniperBlockDeltaUpdated(uint256 _delta);

    // one block is around 5 seconds
    uint256 public sniperStartBlock;
    uint256 private sniperBlockDelta;

    uint256 private constant _tTotal = 1 * 10**9 * 10**18;

    address private constant devWallet = 0xcB5A4d56f5dF144d3B38FC18a365771a170e7403;
    address private constant burnWallet = 0x0000000000000000000000000000000000000000;

    // PancakeSwap Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // PancakeSwap Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address private constant uniswapRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private constant _name = 'Dabloon Inu';
    string private constant _symbol = 'DBLN';

    uint256 public reflectionFeePercentage;
    uint256 public devFeePercentage;
    uint256 public burnFeePercentage;

    uint256 public txTimeLimit;
    uint256 public txLimit;

    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    uint8 private constant _decimals = 18;

    function initialize() public initializer {
        __Context_init();
        __Ownable_init();

        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[_msgSender()] = _rTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _excludedFromFee.push(owner());

        sniperBlockDelta = 120;

        reflectionFeePercentage = 0;
        devFeePercentage = 0;
        burnFeePercentage = 0;

        txTimeLimit = 60 * 60 * 24;
        txLimit = 1000 * 1000 * 10**18;

         _isExcludedFromFee[address(this)] = true;
        _excludedFromFee.push(address(this));

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReflections[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReflections(address account) public view returns (bool) {
        return _isExcludedFromReflections[account];
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function totalReflectionFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcludedFromReflections[sender], "Excluded addresses cannot call this function");
        (,RValues memory _rValues) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount);
        _rTotal = _rTotal.sub(_rValues.rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");

        (,RValues memory _rValues) = _getValues(tAmount);

        if (!deductTransferFee) {
            return _rValues.rAmount;
        } else {
            return _rValues.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccountFromReflections(address account) external onlyOwner {
        _excludeAccountFromReflections(account);
    }

    function _excludeAccountFromReflections(address account) internal {
        require(!_isExcludedFromReflections[account], "Account is already excluded");

        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }

        _isExcludedFromReflections[account] = true;
        _excludedFromReflections.push(account);
    }

    function includeAccountToReflections(address account) external onlyOwner {
        require(_isExcludedFromReflections[account], "Account is already included");

        for (uint i = 0; i < _excludedFromReflections.length; i = unsafeInc(i)) {
            if (_excludedFromReflections[i] == account) {
                _excludedFromReflections[i] = _excludedFromReflections[_excludedFromReflections.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReflections[account] = false;
                _excludedFromReflections.pop();
                break;
            }
        }
    }

    function excludeAccountFromFee(address account) external onlyOwner {
        require(!_isExcludedFromFee[account], "Account is already excluded from fee");
        _isExcludedFromFee[account] = true;
        _excludedFromFee.push(account);
    }

    function includeAccountToFee(address account) external onlyOwner {
        require(_isExcludedFromFee[account], "Account is already included to fee");

        for (uint i = 0; i < _excludedFromFee.length; i = unsafeInc(i)) {
            if (_excludedFromFee[i] == account) {
                _excludedFromFee[i] = _excludedFromFee[_excludedFromFee.length - 1];
                _isExcludedFromFee[account] = false;
                _excludedFromFee.pop();
                break;
            }
        }
    }

    function excludeAccountFromTxLimitFromAddress(address account) external onlyOwner {
        require(!_isExcludedFromTxLimitFromAddresses[account], "Account is already excluded from tx limit");
        _isExcludedFromTxLimitFromAddresses[account] = true;
        _excludedFromTxLimitFromAddresses.push(account);
    }

    function includeAccountToTxLimitFromAddress(address account) external onlyOwner {
        require(_isExcludedFromTxLimitFromAddresses[account], "Account is already included to tx limit");

        for (uint i = 0; i < _excludedFromTxLimitFromAddresses.length; i = unsafeInc(i)) {
            if (_excludedFromTxLimitFromAddresses[i] == account) {
                _excludedFromTxLimitFromAddresses[i] = _excludedFromTxLimitFromAddresses[_excludedFromTxLimitFromAddresses.length - 1];
                _isExcludedFromTxLimitFromAddresses[account] = false;
                _excludedFromTxLimitFromAddresses.pop();
                break;
            }
        }
    }

    function setFeePercentage(FeeType _feeType, uint256 _feePercentage) public onlyOwner {
        if (_feeType == FeeType.REFLECTION) {
            reflectionFeePercentage = _feePercentage;
        } else if (_feeType == FeeType.DEV) {
            devFeePercentage = _feePercentage;
        } else if (_feeType == FeeType.BURN) {
            burnFeePercentage = _feePercentage;
        }

        emit FeePercentageUpdated(_feeType, _feePercentage);
    }

    function setTxTimeLimit(uint256 _txTimeLimit) public onlyOwner {
        txTimeLimit = _txTimeLimit;
        emit TxTimeLimitUpdated(_txTimeLimit);
    }

    function setTxLimit(uint256 _txLimit) public onlyOwner {
        txLimit = _txLimit;
        emit TxLimitUpdated(_txLimit);
    }

    function setSniperStartBlock(uint256 _block) public onlyOwner {
        sniperStartBlock = _block;
        emit SniperStartBlockUpdated(_block);
    }

    function setSniperBlockDelta(uint256 _delta) public onlyOwner {
        sniperBlockDelta = _delta;
        emit SniperBlockDeltaUpdated(_delta);
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function shouldLimitTransfer(address sender, uint256 amount) public returns (bool) {
        if (_isExcludedFromTxLimitFromAddresses[sender]) {
            return false;
        }

        return txAmountSinceTimeLimit(sender) + amount > txLimit;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!shouldLimitTransfer(sender, amount), "You've hit the transaction limit. Wait for a bit and try again.");

        if (sender != owner()) {
            require(block.number - sniperStartBlock > sniperBlockDelta, "Sniper caught!");
        }

        TransferType transferType;

        if (_isExcludedFromReflections[sender] && !_isExcludedFromReflections[recipient]) {
            transferType = TransferType.FROM_EXCLUDED;
        } else if (!_isExcludedFromReflections[sender] && _isExcludedFromReflections[recipient]) {
            transferType = TransferType.TO_EXCLUDED;
        } else if (!_isExcludedFromReflections[sender] && !_isExcludedFromReflections[recipient]) {
            transferType = TransferType.STANDARD;
        } else if (_isExcludedFromReflections[sender] && _isExcludedFromReflections[recipient]) {
            transferType = TransferType.BOTH_EXCLUDED;
        } else {
            transferType = TransferType.STANDARD;
        }

        TransferHistory memory _transferHistory = TransferHistory(
            block.timestamp,
            recipient,
            amount
        );

        transferHistory[sender].push(_transferHistory);

        TransferHistory[] memory prevTransferHistoryForSender = transferHistory[sender];

        if (transferHistory[sender].length > 1) {
            for (uint i = 1; i < transferHistory[sender].length; i = unsafeInc(i)) {
                transferHistory[sender][i] = prevTransferHistoryForSender[i - 1];
            }

            transferHistory[sender][0] = _transferHistory;
        }

        _transfer(sender, recipient, amount, transferType);
    }

    function _transfer(address sender, address recipient, uint256 tAmount, TransferType transferType) private {
        (TValues memory _tValues, RValues memory _rValues) = _getValues(tAmount);

        if (transferType == TransferType.STANDARD) {
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        } else if (transferType == TransferType.TO_EXCLUDED) {
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount);

            _tOwned[recipient] = _tOwned[recipient].add(_tValues.tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        } else if (transferType == TransferType.FROM_EXCLUDED) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount);

            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        } else if (transferType == TransferType.BOTH_EXCLUDED) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount);

            _tOwned[recipient] = _tOwned[recipient].add(_tValues.tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        }

        _rOwned[devWallet] = _rOwned[devWallet].add(_rValues.rDevFee);
        _rOwned[burnWallet] = _rOwned[burnWallet].add(_rValues.rBurnFee);

        _reflectFee(_rValues.rReflectionFee, _tValues.reflectionFee);

        emit Transfer(sender, recipient, _tValues.tTransferAmount);

        if (_tValues.devFee != 0) {
            emit Transfer(sender, devWallet, _tValues.devFee);
        }

        if (_tValues.burnFee != 0) {
            emit Transfer(sender, burnWallet, _tValues.burnFee);
        }
    }

    function multiTransfer(address[] memory recipients, uint256[] memory amounts) public onlyAppWallet {
        for (uint i = 0; i < recipients.length; i = unsafeInc(i)) {
            _transfer(_msgSender(), recipients[i], amounts[i], TransferType.FROM_EXCLUDED);
        }
    }

    function _reflectFee(uint256 rReflectionFee, uint256 reflectionFee) private {
        _rTotal = _rTotal.sub(rReflectionFee);
        _tFeeTotal = _tFeeTotal.add(reflectionFee);
    }

    function _getValues(uint256 tAmount) private view returns (TValues memory, RValues memory) {
        TValues memory _tValues = _getTValues(tAmount);
        uint256 currentRate =  _getRate();

        RValues memory _rValues = _getRValues(
            _getRInputs(
                tAmount,
                _tValues.reflectionFee,
                _tValues.devFee,
                _tValues.burnFee,
                currentRate
            )
        );

        return (_tValues, _rValues);
    }

    function _getRInputs(
        uint256 tAmount,
        uint256 reflectionFee,
        uint256 devFee,
        uint256 burnFee, uint256 currentRate
        ) private pure returns (RInputs memory) {
        return RInputs(tAmount, reflectionFee, devFee, burnFee, currentRate);
    }

    function _getTValues(uint256 tAmount) private view returns (TValues memory) {
        uint256 reflectionFee = 0;
        uint256 devFee = 0;
        uint256 burnFee = 0;

        bool isNoFeeAddress = false;

        for (uint i = 0; i < _excludedFromFee.length; i = unsafeInc(i)) {
            if (_msgSender() == _excludedFromFee[i]) {
                isNoFeeAddress = true;
            }
        }

        if (!isNoFeeAddress) {
            reflectionFee = tAmount.mul(reflectionFeePercentage).div(100);
            devFee = tAmount.mul(devFeePercentage).div(100);
            burnFee = tAmount.mul(burnFeePercentage).div(100);
        }

        uint256 tTransferAmount = tAmount.sub(reflectionFee).sub(devFee).sub(burnFee);
        return TValues(tTransferAmount, reflectionFee, devFee, burnFee);
    }

    function _getRValues(RInputs memory rInputs) private pure returns (RValues memory) {
        uint256 rAmount = rInputs.tAmount.mul(rInputs.currentRate);
        uint256 rReflectionFee = rInputs.reflectionFee.mul(rInputs.currentRate);
        uint256 rDevFee = rInputs.devFee.mul(rInputs.currentRate);
        uint256 rBurnFee = rInputs.burnFee.mul(rInputs.currentRate);
        uint256 rTransferAmount = rAmount.sub(rReflectionFee).sub(rDevFee).sub(rBurnFee);
        return RValues(rAmount, rTransferAmount, rReflectionFee, rDevFee, rBurnFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;

        for (uint i = 0; i < _excludedFromReflections.length; i = unsafeInc(i)) {
            if (_rOwned[_excludedFromReflections[i]] > rSupply || _tOwned[_excludedFromReflections[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excludedFromReflections[i]]);
            tSupply = tSupply.sub(_tOwned[_excludedFromReflections[i]]);
        }

        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function txAmountSinceTimeLimit(address _from) private returns (uint256) {
        uint256 amount = 0;

        uint outOfTimeLimitIndex = UINT_MAX;

        for (uint i = 0; i < transferHistory[_from].length; i = unsafeInc(i)) {
            if (transferHistory[_from][i].timestamp > block.timestamp - txTimeLimit) {
                amount = amount + transferHistory[_from][i].amount;
            } else if (outOfTimeLimitIndex == UINT_MAX) {
                outOfTimeLimitIndex = i;

                break;
            }
        }

        if (outOfTimeLimitIndex != UINT_MAX) {
            uint transferHistoryLength = transferHistory[_from].length;

            for (uint i = 0; i < transferHistoryLength - outOfTimeLimitIndex; i = unsafeInc(i)) {
                transferHistory[_from].pop();
            }
        }

        return amount;
    }

    function getTransferHistory(address _from) public view returns (TransferHistory[] memory) {
        return transferHistory[_from];
    }

    modifier onlyAppWallet() {
        _checkAppWallet();
        _;
    }

    function _checkAppWallet() internal view virtual {
        require(_appWallet == _msgSender(), "Caller is not the app wallet");
    }

    function transferAppWallet(address newAppWallet) public virtual onlyOwner {
        require(newAppWallet != address(0), "New app wallet is the zero address");
        _transferAppWallet(newAppWallet);
    }

    function _transferAppWallet(address newAppWallet) internal virtual {
        address oldAppWallet = _appWallet;
        _appWallet = newAppWallet;
        _excludeAccountFromReflections(newAppWallet);
        emit AppWalletTransferred(oldAppWallet, newAppWallet);
    }

    function unsafeInc(uint x) private pure returns (uint) {
        unchecked { return x + 1; }
    }

    function unsafeDec(uint x) private pure returns (uint) {
        unchecked { return x - 1; }
    }
}