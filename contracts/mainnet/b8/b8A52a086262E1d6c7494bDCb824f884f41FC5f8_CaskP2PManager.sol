// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../job_queue/CaskJobQueue.sol";
import "../interfaces/ICaskP2PManager.sol";
import "../interfaces/ICaskP2P.sol";
import "../interfaces/ICaskVault.sol";

contract CaskP2PManager is
Initializable,
ReentrancyGuardUpgradeable,
CaskJobQueue,
ICaskP2PManager
{
    using SafeERC20 for IERC20Metadata;

    uint8 private constant QUEUE_ID_P2P = 1;


    /** @dev Pointer to CaskP2P contract */
    ICaskP2P public caskP2P;

    /** @dev vault to use for P2P funding. */
    ICaskVault public caskVault;
    

    /************************** PARAMETERS **************************/

    /** @dev max number of failed P2P purchases before P2P is permanently canceled. */
    uint256 public maxSkips;

    /** @dev P2P transaction fee. */
    uint256 public paymentFee;



    function initialize(
        address _caskP2P,
        address _caskVault
    ) public initializer {
        caskP2P = ICaskP2P(_caskP2P);
        caskVault = ICaskVault(_caskVault);

        maxSkips = 0;
        paymentFee = 0;

        __CaskJobQueue_init(3600);
    }
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function registerP2P(
        bytes32 _p2pId
    ) override external nonReentrant whenNotPaused {
        processWorkUnit(QUEUE_ID_P2P, _p2pId);
    }

    function processWorkUnit(
        uint8 _queueId,
        bytes32 _p2pId
    ) override internal {

        ICaskP2P.P2P memory p2p = caskP2P.getP2P(_p2pId);

        if (p2p.status != ICaskP2P.P2PStatus.Active){
            return;
        }

        uint32 timestamp = uint32(block.timestamp);

        // not time to process yet, re-queue for processAt time
        if (p2p.processAt > timestamp) {
            scheduleWorkUnit(_queueId, _p2pId, bucketAt(p2p.processAt));
            return;
        }

        uint256 amount = p2p.amount;
        if (p2p.totalAmount > 0 && amount > p2p.totalAmount - p2p.currentAmount) {
            amount = p2p.totalAmount - p2p.currentAmount;
        }
        // did a transfer happen successfully?
        if (_processP2PTransfer(p2p, amount)) {

            if (p2p.totalAmount == 0 || p2p.currentAmount + amount < p2p.totalAmount) {
                scheduleWorkUnit(_queueId, _p2pId, bucketAt(p2p.processAt + p2p.period));
            }

            caskP2P.managerProcessed(_p2pId, amount, paymentFee);

        } else {
            if (maxSkips > 0 && p2p.numSkips >= maxSkips) {
                caskP2P.managerCommand(_p2pId, ICaskP2P.ManagerCommand.Pause);
            } else {
                scheduleWorkUnit(_queueId, _p2pId, bucketAt(p2p.processAt + p2p.period));

                caskP2P.managerCommand(_p2pId, ICaskP2P.ManagerCommand.Skip);
            }
        }

    }

    function _processP2PTransfer(
        ICaskP2P.P2P memory _p2p,
        uint256 _amount
    ) internal returns(bool) {
        try caskVault.protocolPayment(_p2p.user, _p2p.to, _amount, paymentFee) {
            return true;
        } catch (bytes memory) {
            return false;
        }
    }


    function setParameters(
        uint256 _maxSkips,
        uint256 _paymentFee,
        uint32 _queueBucketSize,
        uint32 _maxQueueAge
    ) external onlyOwner {
        maxSkips = _maxSkips;
        paymentFee = _paymentFee;
        queueBucketSize = _queueBucketSize;
        maxQueueAge = _maxQueueAge;

        emit SetParameters();
    }

    function recoverFunds(
        address _asset,
        address _dest
    ) external onlyOwner {
        IERC20Metadata(_asset).transfer(_dest, IERC20Metadata(_asset).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ICaskJobQueue.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


abstract contract CaskJobQueue is
Initializable,
OwnableUpgradeable,
PausableUpgradeable,
KeeperCompatibleInterface,
ReentrancyGuardUpgradeable,
ICaskJobQueue
{

    /** @dev size (in seconds) of buckets to group jobs into for processing */
    uint32 public queueBucketSize;

    /** @dev max age (in seconds) of a bucket before a processing is triggered */
    uint32 public maxQueueAge;

    /** @dev map used to track jobs in the queues */
    mapping(uint8 => mapping(uint32 => bytes32[])) private queue; // renewal bucket => workUnit[]
    mapping(uint8 => uint32) private queueBucket; // current bucket being processed


    function __CaskJobQueue_init(
        uint32 _queueBucketSize
    ) internal onlyInitializing {
        __Ownable_init();
        __Pausable_init();
        __ICaskJobQueue_init_unchained();
        __CaskJobQueue_init_unchained(_queueBucketSize);
    }

    function __CaskJobQueue_init_unchained(
        uint32 _queueBucketSize
    ) internal onlyInitializing {
        queueBucketSize = _queueBucketSize;
        maxQueueAge = queueBucketSize * 20;
    }


    function bucketAt(
        uint32 _timestamp
    ) internal view returns(uint32) {
        return _timestamp - (_timestamp % queueBucketSize) + queueBucketSize;
    }

    function currentBucket() internal view returns(uint32) {
        uint32 timestamp = uint32(block.timestamp);
        return timestamp - (timestamp % queueBucketSize);
    }

    function queueItem(
        uint8 _queueId,
        uint32 _bucket,
        uint256 _idx
    ) external override view returns(bytes32) {
        return queue[_queueId][_bucket][_idx];
    }

    function queueSize(
        uint8 _queueId,
        uint32 _bucket
    ) external override view returns(uint256) {
        return queue[_queueId][_bucket].length;
    }

    function queuePosition(
        uint8 _queueId
    ) external override view returns(uint32) {
        return queueBucket[_queueId];
    }

    function setQueuePosition(
        uint8 _queueId,
        uint32 _timestamp
    ) external override onlyOwner {
        queueBucket[_queueId] = bucketAt(_timestamp);
    }

    function checkUpkeep(
        bytes calldata checkData
    ) external view override returns(bool upkeepNeeded, bytes memory performData) {
        (
        uint256 limit,
        uint256 minDepth,
        uint8 queueId
        ) = abi.decode(checkData, (uint256, uint256, uint8));

        uint32 bucket = currentBucket();
        upkeepNeeded = false;

        uint32 checkBucket = queueBucket[queueId];
        if (checkBucket == 0) {
            checkBucket = bucket;
        }

        // if queue is over maxQueueAge and needs upkeep regardless of anything queued
        if (bucket >= checkBucket && bucket - checkBucket >= maxQueueAge) {
            upkeepNeeded = true;
        } else {
            while (checkBucket <= bucket) {
                if (queue[queueId][checkBucket].length > 0 &&
                    queue[queueId][checkBucket].length >= minDepth)
                {
                    upkeepNeeded = true;
                    break;
                }
                checkBucket += queueBucketSize;
            }
        }

        performData = abi.encode(limit, queue[queueId][checkBucket].length, queueId);
    }


    function performUpkeep(
        bytes calldata performData
    ) external override whenNotPaused nonReentrant {
        (
        uint256 limit,
        uint256 depth,
        uint8 queueId
        ) = abi.decode(performData, (uint256, uint256, uint8));

        uint32 bucket = currentBucket();
        uint256 jobsProcessed = 0;
        uint256 maxBucketChecks = limit * 5;

        if (queueBucket[queueId] == 0) {
            queueBucket[queueId] = bucket;
        }

        require(queueBucket[queueId] <= bucket, "!TOO_EARLY");

        while (jobsProcessed < limit && maxBucketChecks > 0 && queueBucket[queueId] <= bucket) {
            uint256 queueLen = queue[queueId][queueBucket[queueId]].length;
            if (queueLen > 0) {
                bytes32 workUnit = queue[queueId][queueBucket[queueId]][queueLen-1];
                queue[queueId][queueBucket[queueId]].pop();
                processWorkUnit(queueId, workUnit);
                emit WorkUnitProcessed(queueId, workUnit);
                jobsProcessed += 1;
            } else {
                if (queueBucket[queueId] < bucket) {
                    queueBucket[queueId] += queueBucketSize;
                    maxBucketChecks -= 1;
                } else {
                    break; // nothing left to do
                }
            }
        }

        emit QueueRunReport(limit, jobsProcessed, depth, queueId,
            queue[queueId][queueBucket[queueId]].length, queueBucket[queueId]);
    }


    function requeueWorkUnit(
        uint8 _queueId,
        bytes32 _workUnit
    ) internal override {
        uint32 bucket = currentBucket();
        queue[_queueId][bucket].push(_workUnit);
        emit WorkUnitQueued(_queueId, _workUnit, bucket);
    }

    function scheduleWorkUnit(
        uint8 _queueId,
        bytes32 _workUnit,
        uint32 _processAt
    ) internal override {
        // make sure we don't queue something in the past that will never get processed
        uint32 bucket = bucketAt(_processAt);
        if (bucket < queueBucket[_queueId]) {
            bucket = queueBucket[_queueId];
        }
        queue[_queueId][bucket].push(_workUnit);
        emit WorkUnitQueued(_queueId, _workUnit, bucket);
    }

    function setQueueBucketSize(
        uint32 _queueBucketSize
    ) external override onlyOwner {
        queueBucketSize = _queueBucketSize;
    }

    function setMaxQueueAge(
        uint32 _maxQueueAge
    ) external override onlyOwner {
        maxQueueAge = _maxQueueAge;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaskP2PManager {

    function registerP2P(bytes32 _p2pId) external;

    /** @dev Emitted when manager parameters are changed. */
    event SetParameters();

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaskP2P {

    enum P2PStatus {
        None,
        Active,
        Paused,
        Canceled,
        Complete
    }

    enum ManagerCommand {
        None,
        Cancel,
        Skip,
        Pause
    }

    struct P2P {
        address user;
        address to;
        uint256 amount;
        uint256 totalAmount;
        uint256 currentAmount;
        uint256 numPayments;
        uint256 numSkips;
        uint32 period;
        uint32 createdAt;
        uint32 processAt;
        P2PStatus status;
    }

    function createP2P(
        address _to,
        uint256 _amount,
        uint256 _totalAmount,
        uint32 _period
    ) external returns(bytes32);

    function getP2P(bytes32 _p2pId) external view returns (P2P memory);

    function getUserP2P(address _user, uint256 _idx) external view returns (bytes32);

    function getUserP2PCount(address _user) external view returns (uint256);

    function cancelP2P(bytes32 _p2pId) external;

    function pauseP2P(bytes32 _p2pId) external;

    function resumeP2P(bytes32 _p2pId) external;

    function managerCommand(bytes32 _p2pId, ManagerCommand _command) external;

    function managerProcessed(bytes32 _p2pId, uint256 amount, uint256 _fee) external;


    event P2PCreated(bytes32 indexed p2pId, address indexed user, address indexed to,
        uint256 amount, uint256 totalAmount, uint32 period);

    event P2PPaused(bytes32 indexed p2pId, address indexed user);

    event P2PResumed(bytes32 indexed p2pId, address indexed user);

    event P2PSkipped(bytes32 indexed p2pId, address indexed user);

    event P2PProcessed(bytes32 indexed p2pId, address indexed user, uint256 amount, uint256 fee);

    event P2PCanceled(bytes32 indexed p2pId, address indexed user);

    event P2PCompleted(bytes32 indexed p2pId, address indexed user);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

/**
 * @title  Interface for vault
  */

interface ICaskVault is IERC20MetadataUpgradeable {

    // whitelisted stablecoin assets supported by the vault
    struct Asset {
        address priceFeed;
        uint256 slippageBps;
        uint256 depositLimit;
        uint8 assetDecimals;
        uint8 priceFeedDecimals;
        bool allowed;
    }

    // sources for payments
    enum FundingSource {
        Cask,
        Personal
    }

    // funding profile for a given address
    struct FundingProfile {
        FundingSource fundingSource;
        address fundingAsset;
    }

    /**
      * @dev Get base asset of vault.
     */
    function getBaseAsset() external view returns (address);

    /**
      * @dev Get all the assets supported by the vault.
     */
    function getAllAssets() external view returns (address[] memory);

    /**
     * @dev Get asset details
     * @param _asset Asset address
     * @return Asset Asset details
     */
    function getAsset(address _asset) external view returns(Asset memory);

    /**
     * @dev Check if the vault supports an asset
     * @param _asset Asset address
     * @return bool `true` if asset supported, `false` otherwise
     */
    function supportsAsset(address _asset) external view returns (bool);

    /**
     * @dev Pay `_value` of `baseAsset` from `_from` to `_to` initiated by an authorized protocol
     * @param _from From address
     * @param _to To address
     * @param _value Amount of baseAsset value to transfer
     * @param _protocolFee Protocol fee to deduct from `_value`
     * @param _network Address of network fee collector
     * @param _networkFee Network fee to deduct from `_value`
     */
    function protocolPayment(
        address _from,
        address _to,
        uint256 _value,
        uint256 _protocolFee,
        address _network,
        uint256 _networkFee
    ) external;

    /**
     * @dev Pay `_value` of `baseAsset` from `_from` to `_to` initiated by an authorized protocol
     * @param _from From address
     * @param _to To address
     * @param _value Amount of baseAsset value to transfer
     * @param _protocolFee Protocol fee to deduct from `_value`
     */
    function protocolPayment(
        address _from,
        address _to,
        uint256 _value,
        uint256 _protocolFee
    ) external;

    /**
     * @dev Pay `_value` of `baseAsset` from `_from` to `_to` initiated by an authorized protocol
     * @param _from From address
     * @param _to To address
     * @param _value Amount of baseAsset value to transfer
     */
    function protocolPayment(
        address _from,
        address _to,
        uint256 _value
    ) external;

    /**
     * @dev Transfer the equivalent vault shares of base asset `value` to `_recipient`
     * @param _recipient To address
     * @param _value Amount of baseAsset value to transfer
     */
    function transferValue(
        address _recipient,
        uint256 _value
    ) external returns (bool);

    /**
     * @dev Transfer the equivalent vault shares of base asset `value` from `_sender` to `_recipient`
     * @param _sender From address
     * @param _recipient To address
     * @param _value Amount of baseAsset value to transfer
     */
    function transferValueFrom(
        address _sender,
        address _recipient,
        uint256 _value
    ) external returns (bool);

    /**
     * @dev Deposit `_assetAmount` of `_asset` into the vault and credit the equivalent value of `baseAsset`
     * @param _asset Address of incoming asset
     * @param _assetAmount Amount of asset to deposit
     */
    function deposit(address _asset, uint256 _assetAmount) external;

    /**
     * @dev Deposit `_assetAmount` of `_asset` into the vault and credit the equivalent value of `baseAsset`
     * @param _to Recipient of funds
     * @param _asset Address of incoming asset
     * @param _assetAmount Amount of asset to deposit
     */
    function depositTo(address _to, address _asset, uint256 _assetAmount) external;

    /**
     * @dev Withdraw an amount of shares from the vault in the form of `_asset`
     * @param _asset Address of outgoing asset
     * @param _shares Amount of shares to withdraw
     */
    function withdraw(address _asset, uint256 _shares) external;

    /**
     * @dev Withdraw an amount of shares from the vault in the form of `_asset`
     * @param _recipient Recipient who will receive the withdrawn assets
     * @param _asset Address of outgoing asset
     * @param _shares Amount of shares to withdraw
     */
    function withdrawTo(address _recipient, address _asset, uint256 _shares) external;

    /**
     * @dev Retrieve the funding source for an address
     * @param _address Address for lookup
     */
    function fundingSource(address _address) external view returns(FundingProfile memory);

    /**
     * @dev Set the funding source and, if using a personal wallet, the asset to use for funding payments
     * @param _fundingSource Funding source to use
     * @param _fundingAsset Asset to use for payments (if using personal funding source)
     */
    function setFundingSource(FundingSource _fundingSource, address _fundingAsset) external;

    /**
     * @dev Get current vault value of `_address` denominated in `baseAsset`
     * @param _address Address to check
     */
    function currentValueOf(address _address) external view returns(uint256);

    /**
     * @dev Get current vault value a vault share
     */
    function pricePerShare() external view returns(uint256);

    /**
     * @dev Get the number of vault shares that represents a given value of the base asset
     * @param _value Amount of value
     */
    function sharesForValue(uint256 _value) external view returns(uint256);

    /**
     * @dev Get total value in vault and managed by admin - denominated in `baseAsset`
     */
    function totalValue() external view returns(uint256);

    /**
     * @dev Get total amount of an asset held in vault and managed by admin
     * @param _asset Address of asset
     */
    function totalAssetBalance(address _asset) external view returns(uint256);


    /************************** EVENTS **************************/

    /** @dev Emitted when `sender` transfers `baseAssetValue` (denominated in vault baseAsset) to `recipient` */
    event TransferValue(address indexed from, address indexed to, uint256 baseAssetAmount, uint256 shares);

    /** @dev Emitted when an amount of `baseAsset` is paid from `from` to `to` within the vault */
    event Payment(address indexed from, address indexed to, uint256 baseAssetAmount, uint256 shares,
        uint256 protocolFee, uint256 protocolFeeShares,
        address indexed network, uint256 networkFee, uint256 networkFeeShares);

    /** @dev Emitted when `asset` is added as a new supported asset */
    event AllowedAsset(address indexed asset);

    /** @dev Emitted when `asset` is disallowed t */
    event DisallowedAsset(address indexed asset);

    /** @dev Emitted when `participant` deposits `asset` */
    event AssetDeposited(address indexed participant, address indexed asset, uint256 assetAmount,
        uint256 baseAssetAmount, uint256 shares);

    /** @dev Emitted when `participant` withdraws `asset` */
    event AssetWithdrawn(address indexed participant, address indexed asset, uint256 assetAmount,
        uint256 baseAssetAmount, uint256 shares);

    /** @dev Emitted when `participant` sets their funding source */
    event SetFundingSource(address indexed participant, FundingSource fundingSource, address fundingAsset);

    /** @dev Emitted when a new protocol is allowed to use the vault */
    event AddProtocol(address indexed protocol);

    /** @dev Emitted when a protocol is no longer allowed to use the vault */
    event RemoveProtocol(address indexed protocol);

    /** @dev Emitted when the vault fee distributor is changed */
    event SetFeeDistributor(address indexed feeDistributor);

    /** @dev Emitted when minDeposit is changed */
    event SetMinDeposit(uint256 minDeposit);

    /** @dev Emitted when maxPriceFeedAge is changed */
    event SetMaxPriceFeedAge(uint256 maxPriceFeedAge);

    /** @dev Emitted when the trustedForwarder address is changed */
    event SetTrustedForwarder(address indexed feeDistributor);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract ICaskJobQueue is Initializable {

    function __ICaskJobQueue_init() internal onlyInitializing {
        __ICaskJobQueue_init_unchained();
    }

    function __ICaskJobQueue_init_unchained() internal onlyInitializing {
    }


    function processWorkUnit(uint8 _queueId, bytes32 _workUnit) virtual internal;

    function requeueWorkUnit(uint8 _queueId, bytes32 _workUnit) virtual internal;

    function scheduleWorkUnit(uint8 _queueId, bytes32 _workUnit, uint32 _processAt) virtual internal;

    function queueItem(uint8 _queueId, uint32 _bucket, uint256 _idx) virtual external view returns(bytes32);

    function queueSize(uint8 _queueId, uint32 _bucket) virtual external view returns(uint256);

    function queuePosition(uint8 _queueId) virtual external view returns(uint32);

    function setQueuePosition(uint8 _queueId, uint32 _timestamp) virtual external;

    function setQueueBucketSize(uint32 _queueBucketSize) virtual external;

    function setMaxQueueAge(uint32 _maxQueueAge) virtual external;


    event WorkUnitProcessed(uint8 queueId, bytes32 workUnit);

    event WorkUnitQueued(uint8 queueId, bytes32 workUnit, uint32 processAt);

    /** @dev Emitted when a queue run is finished */
    event QueueRunReport(uint256 limit, uint256 jobsProcessed, uint256 depth, uint8 queueId,
        uint256 queueRemaining, uint32 currentBucket);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easilly be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
        __Context_init_unchained();
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}