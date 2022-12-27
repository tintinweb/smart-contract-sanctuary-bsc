/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: DINW.sol



pragma solidity ^0.8.7;




contract DINW is Initializable{
    address constant public TEAM_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant public SEED_ROUND_WALLET=0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address constant public PRIVATE_ROUND_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant public PUBLIC_SALE_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant public REWARDS_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant public DEV_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant public MARKETING_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant public TREASURY_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant public LIQUIDITY_WALLET=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

    address[] internal contract_wallets=[
        TEAM_WALLET,
        SEED_ROUND_WALLET,
        PRIVATE_ROUND_WALLET,
        PUBLIC_SALE_WALLET,
        REWARDS_WALLET, 
        DEV_WALLET,
        MARKETING_WALLET,
        TREASURY_WALLET,
        LIQUIDITY_WALLET
        ];

    mapping(address => uint256) internal _balances;
    mapping(address => uint256) internal _locked_balances;
    mapping(address=>uint[]) internal _unlock;
    mapping(address => uint256) internal _unlocked_balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint private date_start;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Unlock(address indexed spender, uint256 value);

    function initialize() initializer public {
        _name='DINO WARS';
        _symbol='DINW';
        _locked_balances[TEAM_WALLET]=5500000e18;
        _locked_balances[SEED_ROUND_WALLET]=3000000e18;
        _locked_balances[PRIVATE_ROUND_WALLET]=8500000e18;
        _locked_balances[PUBLIC_SALE_WALLET]=1500000e18;
        _locked_balances[REWARDS_WALLET]=17500000e18;
        _locked_balances[DEV_WALLET]=4000000e18;
        _locked_balances[MARKETING_WALLET]=1500000e18;
        _locked_balances[TREASURY_WALLET]=3500000e18;
        _locked_balances[LIQUIDITY_WALLET]=5000000e18;
        _unlock[TEAM_WALLET]=[
            0,          0,          0,          0,          0,          0,          0,          0,          0,          0,
            0,          0,          196429e18,  392857e18,  589286e18,  785714e18,  982143e18,  1178571e18, 1375000e18, 1571429e18,
            1767857e18,	1964286e18,	2160714e18, 2357143e18,	2553571e18,	2750000e18,	2946429e18,	3142857e18,	3339286e18,	3535714e18,
            3732143e18,	3928571e18,	4125000e18,	4321429e18,	4517857e18,	4714286e18,	4910714e18, 5107143e18, 5303571e18, 5500000e18
            ];
        _unlock[SEED_ROUND_WALLET]=[
            0, 	0, 	0, 	533333e18, 	766667e18, 	1000000e18, 1500000e18,	1750000e18,	2000000e18,	2500000e18,
            2750000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18, 3000000e18,	3000000e18,	3000000e18,	3000000e18,
            3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,
            3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18,	3000000e18, 3000000e18
            ];
        _unlock[PRIVATE_ROUND_WALLET]=[
            425000e18, 	1322222e18, 2219444e18,	3116667e18,	4013889e18,	4911111e18, 5808333e18, 6705556e18,	7602778e18,	8500000e18,
            8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18,
            8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18,
            8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18
            ];
        _unlock[PUBLIC_SALE_WALLET]=[
            375000e18, 	600000e18, 825000e18, 1050000e18, 1275000e18, 1500000e18, 1500000e18,  1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18
            ];
        _unlock[REWARDS_WALLET]=[
            525000e18, 	525000e18,	1090833e18, 1656667e18,	2109333e18, 2562000e18, 3354167e18, 3920000e18, 4485833e18, 5051667e18,
            5617500e18, 6183333e18, 6749167e18,	7315000e18, 7880833e18, 8446667e18, 9012500e18, 9578333e18, 10144167e18, 10710000e18,
            11275833e18, 11841667e18, 12407500e18, 12973333, 13539167e18, 14105000e18, 14670833e18, 15236667e18, 15802500e18, 16368333e18,
            16934167e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18
            ];
        _unlock[DEV_WALLET]=[
            0, 	         0,          0,          133333e18, 266667e18, 400000e18, 533333e18, 666667e18, 800000e18, 933333e18,
            1066667e18, 1200000e18, 1333333e18, 1466667e18, 1600000e18, 1733333e18, 1866667e18, 2000000e18, 2133333e18, 2266667e18,
            2400000e18, 2533333e18, 2666667e18, 2800000e18, 2933333e18, 3066667e18, 3200000e18, 3333333e18, 3466667e18, 3600000e18,
            3733333e18, 3866667e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18
            ];
        _unlock[MARKETING_WALLET]=[
            0,          125000e18, 250000e18, 375000e18, 500000e18, 625000e18, 750000e18, 875000e18, 1000000e18, 1125000e18,
            1250000e18, 1375000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1250000e18, 1375000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1250000e18, 1375000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18
            ];
        _unlock[TREASURY_WALLET]=[
            0,          0,         0,          0,          0,         0,         0,         0,        0,         0,
            0,          0,         125000e18, 250000e18,  375000e18, 500000e18, 625000e18, 750000e18, 875000e18, 1000000e18,
            1125000e18, 1250000e18, 1375000e18, 1500000e18, 1625000e18, 1750000e18, 1875000e18,	2000000e18, 2125000e18, 2250000e18,
            2375000e18, 2500000e18, 2625000e18, 2750000e18, 2875000e18, 3000000e18, 3125000e18, 3250000e18, 3375000e18, 3500000e18
            ];
        _unlock[LIQUIDITY_WALLET]=[
            750000e18, 750000e18, 750000e18, 1015625e18, 1148438e18, 1281250e18, 1546875e18, 1679688e18, 1812500e18, 1989583e18,
            2166667e18, 2343750e18, 2520833e18, 2697917e18, 2875000e18, 3052083e18, 3229167e18, 3406250e18, 3583333e18, 3760417e18,
            3937500e18, 4114583e18, 4291667e18, 4468750e18, 4645833e18, 4822917e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18,
            5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18
            ];
        date_start=block.timestamp;

    }

    function unlocked(address wallet, uint timestamp) internal view returns(uint amount){
        uint m=(timestamp - date_start) / (30 days);
        if (m>39) m=39;
        amount=_unlock[wallet][m];
    }
    function unlock(uint amount) external {
        require( unlocked(msg.sender, block.timestamp) - _unlocked_balances[msg.sender] >=amount, "No enough tokens");
        _unlocked_balances[msg.sender]+=amount;
        _balances[msg.sender]+=amount;
        emit Unlock(msg.sender, amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory) {
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
    function decimals() public pure returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account] + _locked_balances[account] - _unlocked_balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
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
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
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
    ) external returns (bool) {
        _spendAllowance(from, msg.sender, amount);
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
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
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
        
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
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
        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
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
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}