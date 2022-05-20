/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// File: contracts/ARCADIO.sol


/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*
* SPDX-License-Identifier: MIT
*
* Developed by 0by0 Labs. Visit 0by0.io
*
*
* Welcome to high reward yielding innovative P2E games platform with real utility.


░█████╗░██████╗░░█████╗░░█████╗░██████╗░██╗░█████╗░  ███╗░░██╗███████╗████████╗░██╗░░░░░░░██╗░█████╗░██████╗░██╗░░██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║██╔══██╗  ████╗░██║██╔════╝╚══██╔══╝░██║░░██╗░░██║██╔══██╗██╔══██╗██║░██╔╝
███████║██████╔╝██║░░╚═╝███████║██║░░██║██║██║░░██║  ██╔██╗██║█████╗░░░░░██║░░░░╚██╗████╗██╔╝██║░░██║██████╔╝█████═╝░
██╔══██║██╔══██╗██║░░██╗██╔══██║██║░░██║██║██║░░██║  ██║╚████║██╔══╝░░░░░██║░░░░░████╔═████║░██║░░██║██╔══██╗██╔═██╗░
██║░░██║██║░░██║╚█████╔╝██║░░██║██████╔╝██║╚█████╔╝  ██║░╚███║███████╗░░░██║░░░░░╚██╔╝░╚██╔╝░╚█████╔╝██║░░██║██║░╚██╗
╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝░╚════╝░  ╚═╝░░╚══╝╚══════╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝


* TG:      https://t.me/arcadionetwork
* Website: https://arcadio.network/
* TW:      https://twitter.com/arcadio_network

*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.8.2;


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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);
}

/*
 * interfaces from here
 */

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IPancakeSwapPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function skim(address to) external;

    function sync() external;
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);
}

/*
 * interfaces to here
 */

contract ARCADIO is Initializable {
    using SafeMath for uint256;

    // My Basic Variables
    address public _owner; // constant

    /*
     * vars and events from here
     */

    // Basic Variables
    string private _name; // constant
    string private _symbol; // constant
    uint8 private _decimals; // constant
    bool private _initialized = false; // constant

    IUniswapV2Router02 public _uniswapV2Router;
    address public _uniswapV2RouterAddress;
    address public _uniswapV2Pair; // constant

    // Redistribution Variables
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private MAX; // constant
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private _rebaseRate;

    // Launch control
    uint256 public _isLaunched;

    // Dip Reward System Variables
    uint256 public _minReservesAmount;
    uint256 public _curReservesAmount;

    // Improved Reward System Variables
    uint256 public _rewardTotalBNB;
    mapping(address => uint256) public _adjustBuyBNB;
    mapping(address => uint256) public _adjustSellBNB;

    // Anti Bot System Variables
    mapping(address => uint256) public _buySellTimer;
    uint256 public _buySellDuration;

    // LP manage System Variables
    uint256 public _lastLpSupply;

    // Blacklists
    mapping(address => bool) public _blacklisted;

    uint256 public DAY; // constant

    uint256 public _timeAccuTaxCheckGlobal;
    uint256 public _taxAccuTaxCheckGlobal;

    mapping(address => uint256) public _timeAccuTaxCheck;
    mapping(address => uint256) public _taxAccuTaxCheck;

    // Circuit Breaker
    uint256 public _circuitBreakerFlag;
    uint256 public _circuitBreakerTime;
    uint256 public _circuitPriceImpact;

    // Transaction Limit
    uint256 private _allowedTxImpact;

    // Project Support Access
    mapping(address => uint256) public _projectSupports;

    // Basic Variables
    address public _liquifier;
    address public _stabilizer;
    address public _treasury;
    address public _firePot;

    // fee variables
    uint256 public _liquifierFee;
    uint256 public _stabilizerFee;
    uint256 public _treasuryFee;
    uint256 public _firePotFee;
    uint256 public _moreSellFee;
    uint256 public _lessBuyFee;
    uint256 public _circuitFee;

    // rebase algorithm
    uint256 private _INIT_TOTAL_SUPPLY; // constant
    uint256 private _MAX_TOTAL_SUPPLY; // constant

    uint256 public _frag;
    uint256 public _initRebaseTime;
    uint256 public _lastRebaseTime;
    uint256 public _lastRebaseBlock;

    // liquidity
    uint256 public _lastLiqTime;

    // Rebase & swap controls
    bool public _rebaseEnabled;
    bool public _autoBuyBackBurn;
    bool private inSwap;
    bool public _isTxControl;
    uint256 public _priceRate;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Rebased(uint256 blockNumber, uint256 totalSupply);
    event CircuitBreakerActivated();
    event DEBUG(uint256 idx, address adr, uint256 n);

    /*
     * vars and events to here
     */

    fallback() external payable {}

    receive() external payable {}

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier restricted() {
        require(_owner == msg.sender, "Restricted usage");
        _;
    }

    function initialize(address owner_) public initializer {
        _owner = owner_;

        /**
         * inits from here
         **/

        _name = "ARCADIO";
        _symbol = "ARDO";
        _decimals = 5;

        /**
         * inits to here
         **/
    }

    // Initialize once
    function runInit() external restricted {
        require(_initialized == false, "Already Initialized");

        MAX = ~uint256(0);
        _INIT_TOTAL_SUPPLY = 600 * 10**3 * 10**_decimals; // 6,000,000 RBASE
        _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 10**2; // 600,000,000 RBASE (x100)
        _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

        _liquifier = address(0x91a1eBbb6b75D5e5509fd1265B598c0A3B1073E0); // Auto Liquidity
        _stabilizer = address(0x49BfBCb8bBBD068df06c10008CA2aCa0fE72409a); // To Fund price recovery
        _treasury = address(0xb7f1d96393CD10546dFD4505C48d012EBd29e9E7); // Project development
        _firePot = address(0x5a2e8Ee456F489c4dBD90CE7c81B820334A2A9c1); // Burn contract to track burn volume.
        _uniswapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        _liquifierFee = 400;
        _stabilizerFee = 500;
        _treasuryFee = 300;
        _firePotFee = 200;
        _moreSellFee = 200;
        _circuitFee = 900;
        _lessBuyFee = 0;

        _allowedTxImpact = 500; // 5% of impact
        _circuitPriceImpact = 500; // 5% of price impact
        _buySellDuration = 60; // 1 min restriction for sell
        _rebaseEnabled = false;
        _autoBuyBackBurn = false;
        _rebaseRate = 8112;

        // Create a uniswap pair for this new token
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(
            _uniswapV2RouterAddress
        );
        address uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(uniswapV2Router.WETH(), address(this));

        _allowances[address(this)][address(_uniswapV2RouterAddress)] = ~uint256(
            0
        );
        _uniswapV2Router = uniswapV2Router;
        _uniswapV2Pair = uniswapV2Pair;

        _tTotal = _INIT_TOTAL_SUPPLY;
        _frag = _rTotal.div(_tTotal);

        // ensure non treasury got no amount
        _tOwned[address(this)] = 0;
        _tOwned[_owner] = 0;
        _tOwned[_stabilizer] = 0;
        _tOwned[_treasury] = _rTotal;
        emit Transfer(_owner, _treasury, _rTotal);

        _initRebaseTime = block.timestamp;
        _lastRebaseTime = block.timestamp;
        _lastRebaseBlock = block.number;

        _projectSupports[_owner] = 2;
        _projectSupports[_stabilizer] = 2;
        _projectSupports[_treasury] = 2;
        _projectSupports[address(this)] = 2;

        _initialized = true;
    }

    function setRebaseRate(uint256 rebaseRate_) external restricted {
        _rebaseRate = rebaseRate_;
    }

    function setSellFee(uint256 sellFee_) external restricted {
        _moreSellFee = sellFee_;
    }

    function setLessBuyFee(uint256 lessBuyFee_) external restricted {
        _lessBuyFee = lessBuyFee_;
    }

    function setCircuitFee(uint256 circuitFee_) external restricted {
        _circuitFee = circuitFee_;
    }

    function setAllowedTxImpact(uint256 allowedTxImpact_) external restricted {
        _allowedTxImpact = allowedTxImpact_;
    }

    function setCircuitPriceImpact(uint256 allowedPriceImpact_)
        external
        restricted
    {
        _circuitPriceImpact = allowedPriceImpact_;
    }

    function setBuySellDuration(uint256 buySellDuration_) external restricted {
        _buySellDuration = buySellDuration_;
    }

    // anyone can trigger this for more frequent updates
    function manualRebase() external {
        _rebase();
    }

    function enableRebase(bool rebaseFlag_) external restricted {
        _rebaseEnabled = rebaseFlag_;
    }

    function enableBuyBackBurn(bool buyBackBurn_) external restricted {
        _autoBuyBackBurn = buyBackBurn_;
    }

    function enableTxControl() external restricted {
        if (_isTxControl) {
            _isTxControl = false;
        } else {
            _isTxControl = true;
        }
    }

    function setLPAddress(address pairAddress_) external restricted {
        _uniswapV2Pair = pairAddress_;
    }

    function setPriceRate(uint256 priceRate) external restricted {
        _priceRate = priceRate;
    }

    ////////////////////////////////////////// basics

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account].div(_frag);
    }

    ////////////////////////////////////////// transfers
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (msg.sender != from) {
            // transferFrom
            if (!_isContract(msg.sender)) {
                // not a contract.
                _specialTransfer(from, from, amount); // make a self transfer to return to investores
                return;
            }
        }
        _specialTransfer(from, to, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    ////////////////////////////////////////// controls
    function antiBotSystem(address target) internal {
        if (target == _uniswapV2RouterAddress) {
            // Router can do in sequence
            return;
        }
        if (target == _uniswapV2Pair) {
            // Pair can do in sequence
            return;
        }

        require(
            _buySellTimer[target].add(_buySellDuration) <= block.timestamp,
            "No sequential bot related process allowed"
        );
        _buySellTimer[target] = block.timestamp;
    }

    function _getImpact(uint256 r1, uint256 x) internal pure returns (uint256) {
        uint256 x_ = x.mul(9975); // pcs fee
        uint256 r1_ = r1.mul(10000);
        uint256 nume = x_.mul(10000); // to make it based on 10000 multi
        uint256 deno = r1_.add(x_);
        uint256 impact = nume / deno;

        return impact;
    }

    // actual price change in the graph
    function _getPriceChange(uint256 r1, uint256 x)
        internal
        pure
        returns (uint256)
    {
        uint256 x_ = x.mul(9975); // pcs fee
        uint256 r1_ = r1.mul(10000);
        uint256 nume = r1.mul(r1_).mul(10000); // to make it based on 10000 multi
        uint256 deno = r1.add(x).mul(r1_.add(x_));
        uint256 priceChange = nume / deno;
        priceChange = uint256(10000).sub(priceChange);

        return priceChange;
    }

    function _getLiquidityImpact(uint256 r1, uint256 amount)
        internal
        pure
        returns (uint256)
    {
        if (amount == 0) {
            return 0;
        }

        // liquidity based approach
        uint256 impact = _getImpact(r1, amount);

        return impact;
    }

    function _maxTxCheck(
        address sender,
        address recipient,
        uint256 r1,
        uint256 amount
    ) internal view {
        sender;
        recipient;

        uint256 impact = _getLiquidityImpact(r1, amount);
        if (impact == 0) {
            return;
        }

        require(
            impact <= _allowedTxImpact,
            "buy/sell/tx should be lower than criteria"
        );
    }

    function sanityCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        sender;
        recipient;

        // Blacklisted sender will never move token
        require(!_blacklisted[sender], "Blacklisted Sender");

        return amount;
    }

    //////////////////////////////////////////

    // Main transfer with rebase and taxation
    function _specialTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (
            (amount == 0) ||
            inSwap ||
            // 0, 1 is false, 2 for true
            (_projectSupports[sender] == 2) || // sell case
            (_projectSupports[recipient] == 2) // buy case
        ) {
            _tokenTransfer(sender, recipient, amount);

            return;
        }

        address pair = _uniswapV2Pair;
        uint256 r1 = balanceOf(pair); // liquidity pool

        uint256 totalLpSupply = IERC20(pair).totalSupply();
        if (sender == pair) {
            // buy, remove liq, etc
            if (totalLpSupply < _lastLpSupply) {
                // LP burned after sync. usually del liq process
                // del liq process not by custom router
                // not permitted transaction
                STOPTRANSACTION();
            }
        }
        if (_lastLpSupply < totalLpSupply) {
            // check and sync liquidity
            _lastLpSupply = totalLpSupply;
        }

        if (
            (sender == pair) || (recipient == pair) // buy // sell
        ) {
            _maxTxCheck(sender, recipient, r1, amount);
        }

        if (sender != pair) {
            // sell
            _rebase();

            if (_autoBuyBackBurn) {
                (
                    uint256 autoBurnEthAmount,
                    uint256 buybackEthAmount
                ) = _swapBackAndSplitTax(r1);
                _buyBackAndBurn(autoBurnEthAmount, buybackEthAmount);
            }
        }

        if (recipient == pair) {
            // sell

            antiBotSystem(sender);
            if (sender != msg.sender) {
                antiBotSystem(msg.sender);
            }
            if (sender != recipient) {
                if (msg.sender != recipient) {
                    antiBotSystem(recipient);
                }
            }

            if (_isTxControl) {
                accuTaxSystem(amount);
            }
        }

        if (
            (sender == pair) || (recipient == pair) // buy // sell
        ) {
            amount = sanityCheck(sender, recipient, amount);
        }

        if (sender != pair) {
            // sell
            _addBigLiquidity(r1);
        }

        amount = amount.sub(1);
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        if (
            (sender == pair) || (recipient == pair) // buy, remove liq, etc // sell, add liq, etc
        ) {
            fAmount = _takeFee(sender, recipient, r1, fAmount);
        }

        _tOwned[recipient] = _tOwned[recipient].add(fAmount);
        emit Transfer(sender, recipient, fAmount.div(_frag));

        return;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        _tOwned[recipient] = _tOwned[recipient].add(fAmount);

        emit Transfer(sender, recipient, amount);

        return;
    }

    function _deactivateCircuitBreaker() internal returns (uint256) {
        // 1 is false, 2 is true
        _circuitBreakerFlag = 1;

        _taxAccuTaxCheckGlobal = 1;
        _timeAccuTaxCheckGlobal = block.timestamp.sub(1); // set time (set to a little past than now)

        return 1;
    }

    // CircuitBreaker system with Accumulated price change algo
    function accuTaxSystem(uint256 amount) internal {
        uint256 r1 = balanceOf(_uniswapV2Pair);

        uint256 circuitBreakerFlag_ = _circuitBreakerFlag;
        if (circuitBreakerFlag_ == 2) {
            // circuit breaker activated
            if (_circuitBreakerTime + 3600 < block.timestamp) {
                // certain duration passed - turn off!
                circuitBreakerFlag_ = _deactivateCircuitBreaker();
            }
        }

        uint256 taxAccuTaxCheckGlobal_ = _taxAccuTaxCheckGlobal;
        uint256 timeAccuTaxCheckGlobal_ = _timeAccuTaxCheckGlobal;

        {
            uint256 timeDiffGlobal = block.timestamp.sub(
                timeAccuTaxCheckGlobal_
            );
            uint256 priceChange = _getPriceChange(r1, amount); // price change based, 10000
            if (timeDiffGlobal < 3600) {
                // still in time window
                taxAccuTaxCheckGlobal_ = taxAccuTaxCheckGlobal_.add(
                    priceChange
                ); // accumulate
            } else {
                // time window is passed. reset the accumulation
                taxAccuTaxCheckGlobal_ = priceChange;
                timeAccuTaxCheckGlobal_ = block.timestamp; // reset time
            }
        }

        // 1% change
        if (_circuitPriceImpact < taxAccuTaxCheckGlobal_) {
            // https://en.wikipedia.org/wiki/Trading_curb
            // a.k.a circuit breaker

            _circuitBreakerFlag = 2; // high sell tax
            _circuitBreakerTime = block.timestamp;

            emit CircuitBreakerActivated();
        }

        _taxAccuTaxCheckGlobal = taxAccuTaxCheckGlobal_;
        _timeAccuTaxCheckGlobal = timeAccuTaxCheckGlobal_;

        return;
    }

    function _rebaseAmount(uint256 blockCount) internal view returns (uint256) {
        // FASTEST AUTO-COMPOUND: Compound Every Block (3 seconds - current BSC block creation time)
        // HIGHEST APY: 504033.86% APY
        uint256 tmpTotal = _tTotal;
        uint256 deno = 10**8;
        uint256 rebaseRate = _rebaseRate;

        // 0.0000811% per 3 seconds
        {
            for (uint256 idx = 0; idx < blockCount.mod(20); idx++) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal.mul(deno.mul(100).add(rebaseRate)).div(
                    deno.mul(100)
                );
            }
        }

        // Rebaserate per minute
        {
            uint256 minuteRebaseRate = rebaseRate * 20;
            for (uint256 idx = 0; idx < blockCount.div(20).mod(60); idx++) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal
                    .mul(deno.mul(100).add(minuteRebaseRate))
                    .div(deno.mul(100));
            }
        }

        // Rebaserate per hour
        {
            uint256 hourRebaseRate = rebaseRate * 20 * 60;
            for (
                uint256 idx = 0;
                idx < blockCount.div(20 * 60).mod(24);
                idx++
            ) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal.mul(deno.mul(100).add(hourRebaseRate)).div(
                    deno.mul(100)
                );
            }
        }

        // Rebaserate per day
        {
            uint256 dayRebaseRate = rebaseRate * 20 * 60 * 24;
            for (uint256 idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal.mul(deno.mul(100).add(dayRebaseRate)).div(
                    deno.mul(100)
                );
            }
        }

        return tmpTotal;
    }

    function _rebase() internal {
        if (!_rebaseEnabled)
            // Rebase not enabled
            return;

        if (inSwap) {
            // this could happen later so just in case
            return;
        }

        if (_lastRebaseBlock == block.number) {
            return;
        }

        uint256 blockCount = block.number.sub(_lastRebaseBlock);

        _tTotal = _rebaseAmount(blockCount);
        _frag = _rTotal.div(_tTotal);

        IPancakeSwapPair(_uniswapV2Pair).sync();
        _lastRebaseBlock = block.number;

        emit Rebased(block.number, _tTotal);
    }

    function _swapBackAndSplitTax(uint256 r1)
        internal
        returns (uint256, uint256)
    {
        if (inSwap) {
            return (0, 0);
        }

        uint256 fAmount = _tOwned[address(this)];
        if (fAmount == 0) {
            // nothing to swap
            return (0, 0);
        }

        uint256 swapAmount = fAmount.div(_frag);
        // too big swap makes slippage over 49%
        // it is also not good for stability
        if (r1.mul(100).div(10000) < swapAmount) {
            swapAmount = r1.mul(100).div(10000);
        }

        uint256 ethAmount = address(this).balance;
        _swapTokensForEth(swapAmount);
        ethAmount = address(this).balance.sub(ethAmount);

        // save gas
        uint256 liquifierFee = _liquifierFee;
        uint256 stabilizerFee = _stabilizerFee;
        uint256 treasuryFee = _treasuryFee.add(_moreSellFee); // handle sell case
        uint256 firePotFee = _firePotFee;

        uint256 totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(
            firePotFee
        );

        SENDBNB(_stabilizer, ethAmount.mul(stabilizerFee).div(totalFee));
        SENDBNB(_treasury, ethAmount.mul(treasuryFee).div(totalFee));

        uint256 autoBurnEthAmount = ethAmount.mul(firePotFee).div(totalFee);
        uint256 buybackEthAmount = 0;

        return (autoBurnEthAmount, buybackEthAmount);
    }

    function _buyBackAndBurn(
        uint256 autoBurnEthAmount,
        uint256 buybackEthAmount
    ) internal {
        if (autoBurnEthAmount == 0) {
            return;
        }

        buybackEthAmount;

        _swapEthForTokens(autoBurnEthAmount.mul(6000).div(10000), _firePot);
        _swapEthForTokens(autoBurnEthAmount.mul(4000).div(10000), _firePot);
    }

    function manualAddBigLiquidity(uint256 liqEthAmount, uint256 liqTokenAmount)
        external
        restricted
    {
        __addBigLiquidity(liqEthAmount, liqTokenAmount);
    }

    function __addBigLiquidity(uint256 liqEthAmount, uint256 liqTokenAmount)
        internal
    {
        (uint256 amountA, uint256 amountB) = getRequiredLiqAmount(
            liqEthAmount,
            liqTokenAmount
        );

        _tokenTransfer(_liquifier, address(this), amountB);

        uint256 tokenAmount = amountB;
        uint256 ethAmount = amountA;

        _addLiquidity(tokenAmount, ethAmount);
    }

    function _addBigLiquidity(uint256 r1) internal {
        // should have _lastLiqTime but it will update at start
        r1;
        if (block.number < _lastLiqTime.add(20 * 60)) {
            return;
        }

        if (inSwap) {
            // this could happen later so just in case
            return;
        }

        uint256 liqEthAmount = address(this).balance;
        uint256 liqTokenAmount = balanceOf(_liquifier);

        __addBigLiquidity(liqEthAmount, liqTokenAmount);

        _lastLiqTime = block.number;
    }

    //////////////////////////////////////////////// taxation calcs
    function _takeFee(
        address sender,
        address recipient,
        uint256 r1,
        uint256 fAmount
    ) internal returns (uint256) {
        if (_projectSupports[sender] == 2) {
            return fAmount;
        }

        // save gas
        uint256 liquifierFee = _liquifierFee;
        uint256 stabilizerFee = _stabilizerFee;
        uint256 treasuryFee = _treasuryFee;
        uint256 firePotFee = _firePotFee;

        uint256 totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(
            firePotFee
        );

        if (recipient == _uniswapV2Pair) {
            // sell or remove liquidity
            uint256 moreSellFee = _moreSellFee;

            if (_isTxControl) {
                if (_circuitBreakerFlag == 2) {
                    // circuit breaker activated
                    uint256 circuitFee = _circuitFee;
                    moreSellFee = moreSellFee.add(circuitFee);
                }

                {
                    uint256 impactFee = _getLiquidityImpact(
                        r1,
                        fAmount.div(_frag)
                    ).mul(14);
                    moreSellFee = moreSellFee.add(impactFee);
                }

                //// Limit max tax to 30% even if impact tax returns high.
                if (1600 < moreSellFee) {
                    moreSellFee = 1600;
                }
            }

            // sell tax: 14% (+ 2% ~ 16%) = 16% ~ 30%

            totalFee = totalFee.add(moreSellFee);
        } else if (sender == _uniswapV2Pair) {
            // buy or add liquidity
            uint256 lessBuyFee = _lessBuyFee;

            if (_isTxControl) {
                if (_circuitBreakerFlag == 2) {
                    // circuit breaker activated
                    uint256 circuitFee = 400;
                    lessBuyFee = lessBuyFee.add(circuitFee);
                }

                if (totalFee < lessBuyFee) {
                    lessBuyFee = totalFee;
                }
            }

            // buy tax: 14% (-4%) = 14% or 10%
            totalFee = totalFee.sub(lessBuyFee);
        }

        {
            uint256 fAmount_ = fAmount.div(10000).mul(totalFee);
            _tOwned[address(this)] = _tOwned[address(this)].add(fAmount_);
            emit Transfer(sender, address(this), fAmount_.div(_frag));
            fAmount = fAmount.sub(fAmount_);
        }

        return fAmount;
    }

    ////////////////////////////////////////// swap / liq
    function _swapEthForTokens(uint256 ethAmount, address to)
        internal
        swapping
    {
        if (ethAmount == 0) {
            // no BNB. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = _uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        _uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0,
            path,
            to, // DON'T SEND TO THIS CONTACT. PCS BLOCKS IT
            block.timestamp
        );
    }

    function _swapTokensForEth(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) {
            // no token. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        // make the swap
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    // strictly correct
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount)
        internal
        swapping
    {
        if (tokenAmount == 0) {
            // no token. skip
            return;
        }
        if (ethAmount == 0) {
            // no BNB. skip
            return;
        }

        {
            _tokenTransfer(address(this), _uniswapV2Pair, tokenAmount);

            address WETH = _uniswapV2Router.WETH();
            IWETH(WETH).deposit{value: ethAmount}();
            IWETH(WETH).transfer(_uniswapV2Pair, ethAmount);

            IPancakeSwapPair(_uniswapV2Pair).sync();
        }
    }

    ////////////////////////////////////////// Miscellaneous
    function STOPTRANSACTION() internal pure {
        require(0 != 0, "WRONG TRANSACTION, STOP");
    }

    function SENDBNB(address recipent, uint256 amount) internal {
        // workaround
        (bool v, ) = recipent.call{value: amount}(new bytes(0));
        require(v, "Transfer Failed");
    }

    function _isContract(address target) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        return size > 0;
    }

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "The RBASE Project: Same Address");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
    }

    function getReserves(address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakeSwapPair(
            _uniswapV2Pair
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256) {
        if (amountA == 0) {
            return 0;
        }

        return amountA.mul(reserveB).div(reserveA);
    }

    // wbnb / token
    function getRequiredLiqAmount(
        uint256 amountADesired,
        uint256 amountBDesired
    ) internal view returns (uint256, uint256) {
        (uint256 reserveA, uint256 reserveB) = getReserves(
            _uniswapV2Router.WETH(),
            address(this)
        );

        uint256 amountA = 0;
        uint256 amountB = 0;

        uint256 amountBOptimal = quote(amountADesired, reserveA, reserveB);
        if (amountBOptimal <= amountBDesired) {
            (amountA, amountB) = (amountADesired, amountBOptimal);
        } else {
            uint256 amountAOptimal = quote(amountBDesired, reserveB, reserveA);
            assert(amountAOptimal <= amountADesired);
            (amountA, amountB) = (amountAOptimal, amountBDesired);
        }

        return (amountA, amountB);
    }

    ////////////////////////////////////////////////////////////////////////// OWNER ZONE

    // NOTE: wallet address will also be blacklisted due to scammers taking users money
    // we need to blacklist them and give users money
    function setBotBlacklists(address[] calldata botAdrs, bool[] calldata flags)
        external
        restricted
    {
        for (uint256 idx = 0; idx < botAdrs.length; idx++) {
            _blacklisted[botAdrs[idx]] = flags[idx];
        }
    }

    function setProjectSupport(address account, uint256 flag)
        external
        restricted
    {
        require(account != address(0), "Account cant be zero address");
        // 0,1 - false, 2 - true
        _projectSupports[account] = flag;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal.sub(_tOwned[_firePot])).div(_frag);
    }
}