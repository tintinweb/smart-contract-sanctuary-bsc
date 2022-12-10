/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File contracts/interfaces/AutomationType.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface AutomationType {
    // INTERNAL TYPE TO DESCRIBE MINT TASK CONFIG INFO
    struct MintInfo {
        address member;
        uint256 term;
        uint256 maxGasPrice;
        uint256 targetValue;
        uint256 maxGasConsumedPerBatchMint;
        uint256 claimId;
        bool stopped;
    }

    // INTERNAL TYPE TO DESCRIBE MINT RESULT
    struct MintResult {
        uint256 gasConsumed;
        uint256 accountsMinted;
        uint256 valueLeft;
    }

    // INTERNAL TYPE TO DESCRIBE CLAIM TASK CONFIG INFO
    struct ClaimInfo {
        uint256 mintId;
        address member;
        uint256 maxGasPrice;
        uint256 targetValue;
        uint256 maxGasConsumedPerBatchClaim;
        bool stopped;
    }

    // INTERNAL TYPE TO DESCRIBE CLAIM RESULT
    struct ClaimResult {
        uint256 gasConsumed;
        uint256 accountsClaimed;
        uint256 valueLeft;
    }

    // INTERNAL TYPE TO DESCRIBE MULTIPLE MINT INFO
    struct MultiMintInfo {
        uint256 mintId;
        MintInfo info;
        MintResult result;
    }

    // INTERNAL TYPE TO DESCRIBE MULTIPLE CLAIM INFO
    struct MultiClaimInfo {
        uint256 claimId;
        ClaimInfo info;
        ClaimResult result;
    }
}

// File contracts/interfaces/FactoryType.sol

pragma solidity 0.8.17;

interface FactoryType {
    // INTERNAL TYPE TO DESCRIBE EACH BATCH INFO
    struct BatchInfo {
        uint256 batchId;
        uint256 count;
        uint256 unlockTime;
        bool claimed;
    }
}

// File contracts/interfaces/IFactory.sol

pragma solidity 0.8.17;

interface IFactory is FactoryType {
    function mintBatch(
        address receiver,
        uint256 term,
        uint256 count
    ) external returns (uint256 batchId);

    function claimBatch(address receiver, uint256 batchId) external;

    function getBatchInfo(
        address receiver,
        uint256 batchId
    ) external view returns (BatchInfo memory);

    function xen() external view returns (address);

    function automation() external view returns (address);

    function bytecodeHash() external view returns (bytes32);
}

// File contracts/protocols/automations/AutomationStorage.sol

pragma solidity 0.8.17;

/**
 * @title AutomationStorage
 * @author CryptoZ
 * @notice Define the storage variable and getter method of the automation contract
 */
contract AutomationStorage is AutomationType {
    uint256 public constant COUNT_PER_BATCH = 100;
    uint256 public constant GAS_USED_PER_BATCH_MINT = 17500000;
    uint256 public constant GAS_USED_PER_BATCH_CLAIM = 450000;

    address public factory;
    uint256 public joinFee;

    uint256 public joinFeeReceived;
    uint256 public globalMintIndex;
    uint256 public globalClaimIndex;

    uint256 public minGasPrice;

    mapping(address => bool) public isBot;

    mapping(uint256 => MintInfo) public mintInfo;
    mapping(uint256 => MintResult) public mintResult;
    mapping(uint256 => ClaimInfo) public claimInfo;
    mapping(uint256 => ClaimResult) public claimResult;

    mapping(uint256 => uint256) public claimedAccounts;
    mapping(uint256 => uint256[]) internal batchIds;

    mapping(address => uint256[]) internal mintTasks;
    mapping(address => uint256[]) internal claimTasks;

    /**
     * @dev get the batch info of a specific mint task and batch id
     */
    function getBatchInfo(
        uint256 mintId,
        uint256 batchId
    ) external view returns (IFactory.BatchInfo memory info) {
        address receiver = mintInfo[mintId].member;
        info = IFactory(factory).getBatchInfo(receiver, batchId);
    }

    /**
     * @dev get the batch info array of a specific mint task
     */
    function getBatchInfos(
        uint256 mintId
    ) external view returns (IFactory.BatchInfo[] memory infos) {
        uint256[] memory ids = batchIds[mintId];

        if (ids.length == 0) {
            return infos;
        }

        infos = new IFactory.BatchInfo[](ids.length);
        address receiver = mintInfo[mintId].member;

        for (uint256 i = 0; i < ids.length; i++) {
            infos[i] = IFactory(factory).getBatchInfo(receiver, ids[i]);
        }
    }

    /**
     * @dev get the batch info by index array of a specific mint task
     */
    function getBatchInfosByIndex(
        uint256 mintId,
        uint256 start,
        uint256 end
    )
        external
        view
        returns (uint256 totalCount, IFactory.BatchInfo[] memory infos)
    {
        uint256[] memory ids = batchIds[mintId];
        totalCount = ids.length;

        if (totalCount == 0) {
            return (totalCount, infos);
        }

        end = end < totalCount ? end : totalCount;

        require(start >= 0 && start < end, "invalid index");
        uint256 returnCount = end - start;

        infos = new IFactory.BatchInfo[](returnCount);
        address receiver = mintInfo[mintId].member;

        for (uint256 i = start; i < end; i++) {
            infos[i - start] = IFactory(factory).getBatchInfo(receiver, ids[i]);
        }
    }

    /**
     * @dev get multiple mint info array of member
     */
    function getMemberMultiMintInfo(
        address member
    ) external view returns (MultiMintInfo[] memory infos) {
        uint256[] memory memberMintTasks = mintTasks[member];
        infos = new MultiMintInfo[](memberMintTasks.length);

        for (uint256 i = 0; i < memberMintTasks.length; i++) {
            uint256 mintId = memberMintTasks[i];
            infos[i] = MultiMintInfo(
                mintId,
                mintInfo[mintId],
                mintResult[mintId]
            );
        }
    }

    /**
     * @dev get multiple claim info array of member
     */
    function getMemberMultiClaimInfo(
        address member
    ) external view returns (MultiClaimInfo[] memory infos) {
        uint256[] memory memberClaimTasks = claimTasks[member];
        infos = new MultiClaimInfo[](memberClaimTasks.length);

        for (uint256 i = 0; i < memberClaimTasks.length; i++) {
            uint256 claimId = memberClaimTasks[i];
            infos[i] = MultiClaimInfo(
                claimId,
                claimInfo[claimId],
                claimResult[claimId]
            );
        }
    }
}

// File contracts/utils/transferHelper.sol

pragma solidity 0.8.17;

contract transferHelper {
    function _transfer(address to, uint256 value) internal {
        if (value > 0) {
            (bool success, ) = payable(to).call{value: value, gas: 8000}("");
            require(success, "transfer native token failed");
        }
    }
}

// File contracts/protocols/automations/AutomationRobot.sol

pragma solidity 0.8.17;

/**
 * @title AutomationRobot
 * @author CryptoZ
 * @notice Define the method of automation contract that the robot calls
 */
contract AutomationRobot is AutomationStorage, transferHelper {
    /**
     * @dev Batch mint for a specific mint task, only robot can call this function
     * @param mintId The specific mint task
     */
    function mint(uint256 mintId) external {
        require(isBot[msg.sender], "caller is not bot");
        require(mintId <= globalMintIndex, "invalid mint id");

        MintInfo memory info = mintInfo[mintId];
        require(!info.stopped, "stopped");
        require(tx.gasprice <= info.maxGasPrice, "gas price exceeds the limit");

        MintResult memory result = mintResult[mintId];
        require(
            result.valueLeft >= info.maxGasConsumedPerBatchMint,
            "task done"
        );

        uint256 batchId = IFactory(factory).mintBatch(
            info.member,
            info.term,
            COUNT_PER_BATCH
        );

        uint256 gasConsumed;
        unchecked {
            gasConsumed = GAS_USED_PER_BATCH_MINT * tx.gasprice;
            result.gasConsumed += gasConsumed;
            result.valueLeft -= gasConsumed;
            result.accountsMinted += COUNT_PER_BATCH;
        }

        uint256 returnValue;
        if (result.valueLeft < info.maxGasConsumedPerBatchMint) {
            returnValue = result.valueLeft;
            result.valueLeft = 0;
            info.stopped = true;
            mintInfo[mintId] = info;
        }

        mintResult[mintId] = result;
        batchIds[mintId].push(batchId);

        _transfer(msg.sender, gasConsumed);
        _transfer(info.member, returnValue);

        emit Mint(mintId, batchId, gasConsumed, msg.sender);
    }

    /**
     * @dev Batch claim for a specific mint task, only robot can call this function
     * @param mintId The specific mint task
     * @param batchId The batch id was obtained during batch mint
     */
    function claim(uint256 mintId, uint256 batchId) external {
        require(isBot[msg.sender], "caller is not bot");
        require(mintId <= globalMintIndex, "invelid mint id");

        MintInfo memory minfo = mintInfo[mintId];
        uint256 claimId = minfo.claimId;
        require(claimId > 0, "no claim task");

        ClaimInfo memory info = claimInfo[claimId];
        require(!info.stopped, "stopped");
        require(tx.gasprice <= info.maxGasPrice, "gas price exceeds the limit");

        ClaimResult memory result = claimResult[claimId];
        require(
            result.valueLeft >= info.maxGasConsumedPerBatchClaim,
            "task done"
        );

        IFactory(factory).claimBatch(info.member, batchId);

        uint256 gasConsumed;
        unchecked {
            gasConsumed = GAS_USED_PER_BATCH_CLAIM * tx.gasprice;
            result.accountsClaimed += COUNT_PER_BATCH;
            result.valueLeft -= gasConsumed;
            result.gasConsumed += gasConsumed;
        }

        uint256 returnValue;
        if (result.valueLeft < info.maxGasConsumedPerBatchClaim) {
            returnValue = result.valueLeft;
            result.valueLeft = 0;
            info.stopped = true;
            claimInfo[claimId] = info;
        }

        claimResult[claimId] = result;

        _transfer(msg.sender, gasConsumed);
        _transfer(info.member, returnValue);

        emit Claim(mintId, claimId, batchId, gasConsumed, msg.sender);
    }

    // ==================== Events ====================
    event Mint(
        uint256 indexed mintId,
        uint256 batchId,
        uint256 gasConsumed,
        address bot
    );
    event Claim(
        uint256 indexed mintId,
        uint256 claimId,
        uint256 batchId,
        uint256 gasConsumed,
        address bot
    );
}

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

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
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
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

    function _revert(
        bytes memory returndata,
        string memory errorMessage
    ) private pure {
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

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

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
            (isTopLevelCall && _initialized < 1) ||
                (!AddressUpgradeable.isContract(address(this)) &&
                    _initialized == 1),
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
        require(
            !_initializing && _initialized < version,
            "Initializable: contract is already initialized"
        );
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

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

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

// File @openzeppelin/contracts-upgradeable/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File contracts/protocols/automations/AutomationConfig.sol

pragma solidity 0.8.17;

contract AutomationConfig is
    OwnableUpgradeable,
    AutomationStorage,
    transferHelper
{
    /**
     * @dev Set bot address and send start value from join fee received
     */
    function setBot(address bot, uint256 startValue) external onlyOwner {
        isBot[bot] = true;

        require(joinFeeReceived >= startValue, "insufficient bot start fee");
        joinFeeReceived -= startValue;

        _transfer(bot, startValue);
        emit SetBot(bot, startValue);
    }

    function setMinGasPrice(uint256 newMinGasPrice) external onlyOwner {
        minGasPrice = newMinGasPrice;
        emit SetMinGasPrice(newMinGasPrice);
    }

    function setJoinFee(uint256 newJoinFee) external onlyOwner {
        joinFee = newJoinFee;
        emit SetJoinFee(newJoinFee);
    }

    function withdrawJoinFee(
        address receiver,
        uint256 amount
    ) external onlyOwner {
        amount = amount < joinFeeReceived ? amount : joinFeeReceived;
        require(address(this).balance >= amount, "insufficient balance");

        joinFeeReceived -= amount;
        _transfer(receiver, amount);

        emit WithdrawJoinFee(receiver, amount);
    }

    // ==================== Events ====================
    event SetBot(address bot, uint256 startValue);
    event SetMinGasPrice(uint256 minGasPrice);
    event SetJoinFee(uint256 joinFee);
    event WithdrawJoinFee(address receiver, uint256 fee);
}

// File contracts/protocols/automations/AutomationMember.sol

pragma solidity 0.8.17;

/**
 * @title AutomationMember
 * @author CryptoZ
 * @notice Define the method of automation contract that the member calls

 */
contract AutomationMember is AutomationStorage, transferHelper {
    /**
     * @dev start a mint task with a specefic value
     * @param term The lock days in xen contract
     * @param maxGasPrice The max gas price you can accept when minting xen
     */
    function startMintTask(uint256 term, uint256 maxGasPrice) external payable {
        require(msg.value > joinFee, "insufficient task fee");
        uint256 target_value = msg.value - joinFee;
        joinFeeReceived += joinFee;

        require(term >= 1, "invalid term");
        require(maxGasPrice >= minGasPrice, "max gas price is too small");

        uint256 maxGasConsumedPerBatchMint = maxGasPrice *
            GAS_USED_PER_BATCH_MINT;
        require(
            target_value >= maxGasConsumedPerBatchMint,
            "insufficient value"
        );

        uint256 mintId = ++globalMintIndex;
        mintTasks[msg.sender].push(mintId);

        mintInfo[mintId] = MintInfo(
            msg.sender,
            term,
            maxGasPrice,
            target_value,
            maxGasConsumedPerBatchMint,
            0,
            false
        );
        mintResult[mintId] = MintResult(0, 0, target_value);

        emit StartMintTask(msg.sender, mintId);
    }

    /**
     * @dev Reset the max gas price of the specific mint task
     * you can accept when minting xen
     */
    function setMintMaxGasPrice(uint256 mintId, uint256 maxGasPrice) external {
        require(maxGasPrice >= minGasPrice, "max gas price is too small");

        MintInfo memory info = mintInfo[mintId];
        require(msg.sender == info.member, "invalid caller");
        require(!info.stopped, "stopped");

        info.maxGasPrice = maxGasPrice;
        info.maxGasConsumedPerBatchMint = maxGasPrice * GAS_USED_PER_BATCH_MINT;

        MintResult memory result = mintResult[mintId];
        require(
            result.valueLeft >= info.maxGasConsumedPerBatchMint,
            "value left is less than fee of one batch mint"
        );

        mintInfo[mintId] = info;

        emit SetMintMaxGasPrice(mintId, maxGasPrice);
    }

    /**
     * @dev Stop the specific mint task and get back the task balance
     */
    function stopMintTask(uint256 mintId) external {
        MintInfo memory info = mintInfo[mintId];
        require(msg.sender == info.member, "invalid caller");
        require(!info.stopped, "stopped");

        info.stopped = true;
        mintInfo[mintId] = info;

        MintResult memory result = mintResult[mintId];
        uint256 valueLeft = result.valueLeft;
        result.valueLeft = 0;
        mintResult[mintId] = result;

        _transfer(msg.sender, valueLeft);

        emit StopMintTask(mintId, valueLeft);
    }

    /**
     * @dev start a claim task with a specefic value for a mint task
     * @param mintId The specific mint task id
     * @param maxGasPrice The max gas price you can accept when minting xen
     */
    function startClaimTask(
        uint256 mintId,
        uint256 maxGasPrice
    ) external payable {
        require(msg.value > joinFee, "insufficient task fee");
        uint256 target_value = msg.value - joinFee;
        joinFeeReceived += joinFee;

        require(maxGasPrice >= minGasPrice, "max gas price is too small");

        MintInfo memory info = mintInfo[mintId];
        require(info.member == msg.sender, "invalid caller");

        if (info.claimId > 0) {
            require(
                claimInfo[info.claimId].stopped,
                "The last claim task hasn't stopped yet"
            );
            claimedAccounts[mintId] += claimResult[info.claimId]
                .accountsClaimed;
        }

        uint256 maxGasConsumedPerBatchClaim = maxGasPrice *
            GAS_USED_PER_BATCH_CLAIM;
        require(
            target_value >= maxGasConsumedPerBatchClaim,
            "insufficient value"
        );

        uint256 claimId = ++globalClaimIndex;
        claimTasks[msg.sender].push(claimId);

        info.claimId = claimId;
        mintInfo[mintId] = info;

        claimInfo[claimId] = ClaimInfo(
            mintId,
            info.member,
            maxGasPrice,
            target_value,
            maxGasConsumedPerBatchClaim,
            false
        );
        claimResult[claimId] = ClaimResult(0, 0, target_value);

        emit StartClaimTask(mintId, claimId);
    }

    /**
     * @dev Reset the max gas price of the specific claim task
     * you can accept when minting xen
     */
    function setClaimMaxGasPrice(uint256 mintId, uint256 maxGasPrice) external {
        require(maxGasPrice >= minGasPrice, "max gas price is too small");

        MintInfo memory minfo = mintInfo[mintId];
        require(minfo.member == msg.sender, "invalid caller");

        uint256 claimId = minfo.claimId;
        require(claimId > 0, "no claim task");

        ClaimInfo memory info = claimInfo[claimId];
        require(!info.stopped, "stopped");

        info.maxGasPrice = maxGasPrice;
        info.maxGasConsumedPerBatchClaim =
            maxGasPrice *
            GAS_USED_PER_BATCH_CLAIM;

        ClaimResult memory result = claimResult[claimId];
        require(
            result.valueLeft >= info.maxGasConsumedPerBatchClaim,
            "value left is less than fee of one batch claim fee"
        );

        claimInfo[claimId] = info;

        emit SetClaimMaxGasPrice(mintId, claimId, maxGasPrice);
    }

    /**
     * @dev Stop the specific claim task and get back the task balance
     */
    function stopClaimTask(uint256 mintId) external {
        MintInfo memory minfo = mintInfo[mintId];
        require(minfo.member == msg.sender, "invalid caller");

        uint256 claimId = minfo.claimId;
        require(claimId > 0, "no claim task");

        minfo.claimId = 0;
        mintInfo[mintId] = minfo;

        ClaimInfo memory info = claimInfo[claimId];
        require(!info.stopped, "stopped");

        info.stopped = true;
        claimInfo[claimId] = info;

        ClaimResult memory result = claimResult[claimId];
        uint256 valueLeft = result.valueLeft;
        result.valueLeft = 0;
        claimResult[claimId] = result;

        claimedAccounts[mintId] += result.accountsClaimed;

        _transfer(msg.sender, valueLeft);

        emit StopClaimTask(mintId, claimId, valueLeft);
    }

    // ==================== Events ====================
    event StartMintTask(address indexed member, uint256 mintId);
    event StopMintTask(uint256 indexed mintId, uint256 valueLeft);
    event SetMintMaxGasPrice(uint256 indexed mintId, uint256 maxGsPrice);
    event StartClaimTask(uint256 indexed mintId, uint256 claimId);
    event StopClaimTask(
        uint256 indexed mintId,
        uint256 claimId,
        uint256 valueLeft
    );
    event SetClaimMaxGasPrice(
        uint256 indexed mintId,
        uint256 claimId,
        uint256 maxGsPrice
    );
}

// File contracts/protocols/Automation.sol

pragma solidity 0.8.17;

contract Automation is AutomationConfig, AutomationMember, AutomationRobot {
    receive() external payable {
        joinFeeReceived += msg.value;
    }

    /**
     * @dev Initialize the Automation contract
     */
    function initialize(address _factory) external initializer {
        __Ownable_init();

        factory = _factory;
        minGasPrice = 1000000000;
    }
}