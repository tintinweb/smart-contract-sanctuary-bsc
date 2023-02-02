// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/IMultiBridgeReceiver.sol";
import "../interfaces/DeBridge/IDeBridgeReceiverAdapter.sol";
import "../interfaces/DeBridge/IDeBridgeGate.sol";
import "../interfaces/DeBridge/ICallProxy.sol";
import "../MessageStruct.sol";

contract DeBridgeReceiverAdapter is Ownable, Pausable, IDeBridgeReceiverAdapter {
    
    /* ========== STATE VARIABLES ========== */
    
    mapping(uint256 => address) public senderAdapters;
    IDeBridgeGate public immutable deBridgeGate;
    address public multiBridgeReceiver;

    /* ========== ERRORS ========== */

    error CallProxyBadRole();
    error NativeSenderBadRole(address nativeSender, uint256 chainIdFrom);

    /* ========== EVENTS ========== */

    event SentMessage(bytes32 submissionId, MessageStruct.Message _message);
    event UpdatedSenderAdapter(uint256 srcChainId, address senderAdapter);

    /* ========== MODIFIERS ========== */

    modifier onlySenderAdapter() {
        ICallProxy callProxy = ICallProxy(deBridgeGate.callProxy());
        if (address(callProxy) != msg.sender) revert CallProxyBadRole();

        address nativeSender = toAddress(callProxy.submissionNativeSender(), 0);
        uint256 submissionChainIdFrom = callProxy.submissionChainIdFrom();
        
        if (senderAdapters[submissionChainIdFrom] != nativeSender) {
            revert NativeSenderBadRole(nativeSender, submissionChainIdFrom);
        }
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    constructor(IDeBridgeGate _deBridgeGate) {
        deBridgeGate = _deBridgeGate;
    }

    /* ========== PUBLIC METHODS ========== */

    // Called by DeBridge CallProxy on destination chain to receive cross-chain messages.
    function executeMessage(
        MessageStruct.Message memory _message
    ) external onlySenderAdapter whenNotPaused {
        IMultiBridgeReceiver(multiBridgeReceiver).receiveMessage(_message);
    }

    /* ========== ADMIN METHODS ========== */

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function updateSenderAdapter(uint256[] calldata _srcChainIds, address[] calldata _senderAdapters)
        external
        onlyOwner
    {
        require(_srcChainIds.length == _senderAdapters.length, "mismatch length");
        for (uint256 i = 0; i < _srcChainIds.length; i++) {
            senderAdapters[_srcChainIds[i]] = _senderAdapters[i];
        }
    }

    function setMultiBridgeReceiver(address _multiBridgeReceiver) external onlyOwner {
        multiBridgeReceiver = _multiBridgeReceiver;
    }

    /* ========== INTERNAL METHODS ========== */

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.17;

import "../MessageStruct.sol";

interface IMultiBridgeReceiver {
    /**
     * @notice Receive messages from allowed bridge receiver adapters.
     * If the accumulated power of a message has reached the power threshold,
     * this message will be executed immediately, which will invoke an external function call
     * according to the message content.
     *
     * @dev Every receiver adapter should call this function with decoded MessageStruct.Message
     * when receiver adapter receives a message produced by a corresponding sender adapter on the source chain.
     */
    function receiveMessage(MessageStruct.Message calldata _message) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../MessageStruct.sol";

interface IDeBridgeReceiverAdapter {

    function executeMessage(
        MessageStruct.Message memory _message
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IDeBridgeGate {
    /* ========== STRUCTS ========== */

    struct TokenInfo {
        uint256 nativeChainId;
        bytes nativeAddress;
    }

    struct DebridgeInfo {
        uint256 chainId; // native chain id
        uint256 maxAmount; // maximum amount to transfer
        uint256 balance; // total locked assets
        uint256 lockedInStrategies; // total locked assets in strategy (AAVE, Compound, etc)
        address tokenAddress; // asset address on the current chain
        uint16 minReservesBps; // minimal hot reserves in basis points (1/10000)
        bool exist;
    }

    struct DebridgeFeeInfo {
        uint256 collectedFees; // total collected fees
        uint256 withdrawnFees; // fees that already withdrawn
        mapping(uint256 => uint256) getChainFee; // whether the chain for the asset is supported
    }

    struct ChainSupportInfo {
        uint256 fixedNativeFee; // transfer fixed fee
        bool isSupported; // whether the chain for the asset is supported
        uint16 transferFeeBps; // transfer fee rate nominated in basis points (1/10000) of transferred amount
    }

    struct DiscountInfo {
        uint16 discountFixBps; // fix discount in BPS
        uint16 discountTransferBps; // transfer % discount in BPS
    }

    /// @param executionFee Fee paid to the transaction executor.
    /// @param fallbackAddress Receiver of the tokens if the call fails.
    struct SubmissionAutoParamsTo {
        uint256 executionFee;
        uint256 flags;
        bytes fallbackAddress;
        bytes data;
    }

    /// @param executionFee Fee paid to the transaction executor.
    /// @param fallbackAddress Receiver of the tokens if the call fails.
    struct SubmissionAutoParamsFrom {
        uint256 executionFee;
        uint256 flags;
        address fallbackAddress;
        bytes data;
        bytes nativeSender;
    }

    struct FeeParams {
        uint256 receivedAmount;
        uint256 fixFee;
        uint256 transferFee;
        bool useAssetFee;
        bool isNativeToken;
    }

    /* ========== PUBLIC VARS GETTERS ========== */

    /// @dev Returns whether the transfer with the submissionId was claimed.
    /// submissionId is generated in getSubmissionIdFrom
    function isSubmissionUsed(bytes32 submissionId) view external returns (bool);

    /// @dev Returns native token info by wrapped token address
    function getNativeInfo(address token) view external returns (
        uint256 nativeChainId,
        bytes memory nativeAddress);

    /// @dev Returns address of the proxy to execute user's calls.
    function callProxy() external view returns (address);

    /// @dev Fallback fixed fee in native asset, used if a chain fixed fee is set to 0
    function globalFixedNativeFee() external view returns (uint256);

    /// @dev Fallback transfer fee in BPS, used if a chain transfer fee is set to 0
    function globalTransferFeeBps() external view returns (uint16);

    /* ========== FUNCTIONS ========== */

    /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
    ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
    /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
    /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
    ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
    ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
    ///         a third party in return for successful claim transaction execution on the destination chain.
    /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
    ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
    /// @param _dstChainId ID of the destination chain.
    /// @param _targetContractAddress A contract address to be called on the destination chain
    /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
    function sendMessage(
        uint256 _dstChainId,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata
    ) external payable returns (bytes32 submissionId);

    /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
    ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
    /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
    /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
    ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
    ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
    ///         a third party in return for successful claim transaction execution on the destination chain.
    /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
    ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
    /// @param _dstChainId ID of the destination chain.
    /// @param _targetContractAddress A contract address to be called on the destination chain
    /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
    /// @param _flags A bitmask of toggles listed in the Flags library
    /// @param _referralCode Referral code to identify this submission
    function sendMessage(
        uint256 _dstChainId,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata,
        uint256 _flags,
        uint32 _referralCode
    ) external payable returns (bytes32 submissionId);

    /// @dev This method is used for the transfer of assets [from the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-native-chain).
    /// It locks an asset in the smart contract in the native chain and enables minting of deAsset on the secondary chain.
    /// @param _tokenAddress Asset identifier.
    /// @param _amount Amount to be transferred (note: the fee can be applied).
    /// @param _chainIdTo Chain id of the target chain.
    /// @param _receiver Receiver address.
    /// @param _permitEnvelope Permit for approving the spender by signature. bytes (amount + deadline + signature)
    /// @param _useAssetFee use assets fee for pay protocol fix (work only for specials token)
    /// @param _referralCode Referral code
    /// @param _autoParams Auto params for external call in target network
    function send(
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bytes memory _receiver,
        bytes memory _permitEnvelope,
        bool _useAssetFee,
        uint32 _referralCode,
        bytes calldata _autoParams
    ) external payable returns (bytes32 submissionId) ;

    /// @dev Is used for transfers [into the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-secondary-chain-to-native-chain)
    /// to unlock the designated amount of asset from collateral and transfer it to the receiver.
    /// @param _debridgeId Asset identifier.
    /// @param _amount Amount of the transferred asset (note: the fee can be applied).
    /// @param _chainIdFrom Chain where submission was sent
    /// @param _receiver Receiver address.
    /// @param _nonce Submission id.
    /// @param _signatures Validators signatures to confirm
    /// @param _autoParams Auto params for external call
    function claim(
        bytes32 _debridgeId,
        uint256 _amount,
        uint256 _chainIdFrom,
        address _receiver,
        uint256 _nonce,
        bytes calldata _signatures,
        bytes calldata _autoParams
    ) external;

    /// @dev Withdraw collected fees to feeProxy
    /// @param _debridgeId Asset identifier.
    function withdrawFee(bytes32 _debridgeId) external;

    /// @dev Returns asset fixed fee value for specified debridge and chainId.
    /// @param _debridgeId Asset identifier.
    /// @param _chainId Chain id.
    function getDebridgeChainAssetFixedFee(
        bytes32 _debridgeId,
        uint256 _chainId
    ) external view returns (uint256);

    /* ========== EVENTS ========== */

    /// @dev Emitted once the tokens are sent from the original(native) chain to the other chain; the transfer tokens
    /// are expected to be claimed by the users.
    event Sent(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        bytes receiver,
        uint256 nonce,
        uint256 indexed chainIdTo,
        uint32 referralCode,
        FeeParams feeParams,
        bytes autoParams,
        address nativeSender
        // bool isNativeToken //added to feeParams
    );

    /// @dev Emitted once the tokens are transferred and withdrawn on a target chain
    event Claimed(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        address indexed receiver,
        uint256 nonce,
        uint256 indexed chainIdFrom,
        bytes autoParams,
        bool isNativeToken
    );

    /// @dev Emitted when new asset support is added.
    event PairAdded(
        bytes32 debridgeId,
        address tokenAddress,
        bytes nativeAddress,
        uint256 indexed nativeChainId,
        uint256 maxAmount,
        uint16 minReservesBps
    );

    event MonitoringSendEvent(
        bytes32 submissionId,
        uint256 nonce,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    event MonitoringClaimEvent(
        bytes32 submissionId,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    /// @dev Emitted when the asset is allowed/disallowed to be transferred to the chain.
    event ChainSupportUpdated(uint256 chainId, bool isSupported, bool isChainFrom);
    /// @dev Emitted when the supported chains are updated.
    event ChainsSupportUpdated(
        uint256 chainIds,
        ChainSupportInfo chainSupportInfo,
        bool isChainFrom);

    /// @dev Emitted when the new call proxy is set.
    event CallProxyUpdated(address callProxy);
    /// @dev Emitted when the transfer request is executed.
    event AutoRequestExecuted(
        bytes32 submissionId,
        bool indexed success,
        address callProxy
    );

    /// @dev Emitted when a submission is blocked.
    event Blocked(bytes32 submissionId);
    /// @dev Emitted when a submission is unblocked.
    event Unblocked(bytes32 submissionId);

    /// @dev Emitted when fee is withdrawn.
    event WithdrawnFee(bytes32 debridgeId, uint256 fee);

    /// @dev Emitted when globalFixedNativeFee and globalTransferFeeBps are updated.
    event FixedNativeFeeUpdated(
        uint256 globalFixedNativeFee,
        uint256 globalTransferFeeBps);

    /// @dev Emitted when globalFixedNativeFee is updated by feeContractUpdater
    event FixedNativeFeeAutoUpdated(uint256 globalFixedNativeFee);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ICallProxy {

    /// @dev Chain from which the current submission is received
    function submissionChainIdFrom() external view returns (uint256);
    /// @dev Native sender of the current submission
    function submissionNativeSender() external view returns (bytes memory);

    /// @dev Used for calls where native asset transfer is involved.
    /// @param _reserveAddress Receiver of the tokens if the call to _receiver fails
    /// @param _receiver Contract to be called
    /// @param _data Call data
    /// @param _flags Flags to change certain behavior of this function, see Flags library for more details
    /// @param _nativeSender Native sender
    /// @param _chainIdFrom Id of a chain that originated the request
    function call(
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external payable returns (bool);

    /// @dev Used for calls where ERC20 transfer is involved.
    /// @param _token Asset address
    /// @param _reserveAddress Receiver of the tokens if the call to _receiver fails
    /// @param _receiver Contract to be called
    /// @param _data Call data
    /// @param _flags Flags to change certain behavior of this function, see Flags library for more details
    /// @param _nativeSender Native sender
    /// @param _chainIdFrom Id of a chain that originated the request
    function callERC20(
        address _token,
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.9;

library MessageStruct {
    /**
     * @dev Message indicates a remote call to target contract on destination chain.
     *
     * @param srcChainId is the id of chain where this message is sent from.
     * @param dstChainId is the id of chain where this message is sent to.
     * @param nonce is an incrementing number held by MultiBridgeSender to ensure msgId uniqueness
     * @param target is the contract to be called on dst chain.
     * @param callData is the data to be sent to target by low-level call(eg. address(target).call(callData)).
     * @param bridgeName is the message bridge name used for sending this message.
     */
    struct Message {
        uint64 srcChainId;
        uint64 dstChainId;
        uint32 nonce;
        address target;
        bytes callData;
        string bridgeName;
    }
}

// SPDX-License-Identifier: MIT
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}