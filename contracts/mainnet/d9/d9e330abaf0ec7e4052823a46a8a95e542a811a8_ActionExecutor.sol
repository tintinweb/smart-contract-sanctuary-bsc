/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.17;


interface TokenBalance {
    function balanceOf(address _account) external view returns (uint256);
}


interface TokenMint {
    function mint(address _to, uint256 _amount) external returns (bool);
}


interface Vault {
    function asset() external view returns (address);

    function variableToken() external view returns (address);

    function requestAsset(uint256 _amount, address _to, bool _forVariableToken) external returns (address assetAddress);
}


interface Settings {
    struct LocalSettings {
        address router;
        uint256 systemFee;
        address feeCollector;
        bool isWhitelist;
    }

    struct SourceSettings {
        address gateway;
        bool useGatewayFallback;
        address router;
        address vault;
        uint256 sourceVaultDecimals;
        uint256 targetVaultDecimals;
        uint256 systemFee;
        address feeCollector;
        bool isWhitelist;
        uint256 swapAmountMin;
        uint256 swapAmountMax;
    }

    struct TargetSettings {
        address router;
        address vault;
    }

    struct FallbackSettings {
        uint256 sourceVaultDecimals;
        uint256 targetVaultDecimals;
    }

    struct VariableTokenClaimSettings {
        address vault;
        uint256 fallbackFee;
        address feeCollector;
    }

    struct MessageFeeEstimateSettings {
        address gateway;
    }

    struct LocalAmountCalculationSettings {
        uint256 systemFee;
        bool isWhitelist;
    }

    struct VaultAmountCalculationSettings {
        uint256 fromDecimals;
        uint256 toDecimals;
        uint256 systemFee;
        bool isWhitelist;
    }
}

interface Registry is Settings {
    function isGatewayAddress(address _account) external view returns (bool);

    function fallbackFee() external view returns (uint256);

    function localSettings(
        address _caller,
        uint256 _routerType
    )
        external
        view
        returns (LocalSettings memory)
    ;

    function sourceSettings(
        address _caller,
        uint256 _targetChainId,
        uint256 _gatewayType,
        uint256 _routerType,
        uint256 _vaultType
    )
        external
        view
        returns (SourceSettings memory)
    ;

    function targetSettings(
        uint256 _vaultType,
        uint256 _routerType
    )
        external
        view
        returns (TargetSettings memory)
    ;

    function fallbackSettings(
        uint256 _targetChainId,
        uint256 _vaultType
    )
        external
        view
        returns (FallbackSettings memory)
    ;

    function variableTokenClaimSettings(
        uint256 _vaultType
    )
        external
        view
        returns (VariableTokenClaimSettings memory)
    ;

    function messageFeeEstimateSettings(
        uint256 _gatewayType
    )
        external
        view
        returns (MessageFeeEstimateSettings memory)
    ;

    function localAmountCalculationSettings(
        address _caller
    )
        external
        view
        returns (LocalAmountCalculationSettings memory)
    ;

    function vaultAmountCalculationSettings(
        address _caller,
        uint256 _vaultType,
        uint256 _fromChainId,
        uint256 _toChainId
    )
        external
        view
        returns (VaultAmountCalculationSettings memory)
    ;

    function swapAmountLimits(
        uint256 _vaultType
    )
        external
        view
        returns (uint256 swapAmountMin, uint256 swapAmountMax)
    ;
}


interface Gateway {
    function sendMessage(
        uint256 _targetChainId,
        bytes calldata _message,
        bool _useFallback
    )
        external
        payable
    ;

    function messageFee(
        uint256 _targetChainId,
        uint256 _messageSizeInBytes
    )
        external
        view
        returns (uint256)
    ;
}


interface GatewayClient {
    function handleExecutionPayload(
        uint256 _messageSourceChainId,
        bytes calldata _payloadData
    )
        external
        returns (bool success, bytes memory result)
    ;

    function handleFallbackPayload(
        uint256 _messageTargetChainId,
        bytes calldata _payloadData
    )
        external
    ;
}


abstract contract DataStructures {

    struct OptionalValue {
        bool isSet;
        uint256 value;
    }

    function uniqueAddressListAdd(
        address[] storage _list,
        mapping(address => OptionalValue) storage _indexMap,
        address _value
    )
        internal
        returns (bool isChanged)
    {
        isChanged = !_indexMap[_value].isSet;

        if (isChanged) {
            _indexMap[_value] = OptionalValue(true, _list.length);
            _list.push(_value);
        }
    }

    function uniqueAddressListRemove(
        address[] storage _list,
        mapping(address => OptionalValue) storage _indexMap,
        address _value
    )
        internal
        returns (bool isChanged)
    {
        OptionalValue storage indexItem = _indexMap[_value];

        isChanged = indexItem.isSet;

        if (isChanged) {
            uint256 itemIndex = indexItem.value;
            uint256 lastIndex = _list.length - 1;

            if (itemIndex != lastIndex) {
                address lastValue = _list[lastIndex];
                _list[itemIndex] = lastValue;
                _indexMap[lastValue].value = itemIndex;
            }

            _list.pop();
            delete _indexMap[_value];
        }
    }

    function uniqueAddressListUpdate(
        address[] storage _list,
        mapping(address => OptionalValue) storage _indexMap,
        address _value,
        bool _flag
    )
        internal
        returns (bool isChanged)
    {
        return _flag ?
            uniqueAddressListAdd(_list, _indexMap, _value) :
            uniqueAddressListRemove(_list, _indexMap, _value);
    }
}


abstract contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "only-owner"
        );

        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "owner-zero-address"
        );

        address previousOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(previousOwner, newOwner);
    }
}


abstract contract ManagerRole is Ownable, DataStructures {

    address[] public managerList;
    mapping(address => OptionalValue) public managerIndexMap;

    event SetManager(address indexed account, bool indexed value);

    modifier onlyManager {
        require(
            isManager(msg.sender),
            "only-manager"
        );

        _;
    }

    function setManager(address _account, bool _value) public virtual onlyOwner {
        uniqueAddressListUpdate(managerList, managerIndexMap, _account, _value);

        emit SetManager(_account, _value);
    }

    function isManager(address _account) public view virtual returns (bool) {
        return managerIndexMap[_account].isSet;
    }
}


abstract contract Pausable is ManagerRole {

    bool public paused = false;

    event Pause();
    event Unpause();

    modifier whenNotPaused() {
        require(
            !paused,
            "when-not-paused"
        );

        _;
    }

    modifier whenPaused() {
        require(
            paused,
            "when-paused"
        );

        _;
    }

    function pause() onlyManager whenNotPaused public {
        paused = true;

        emit Pause();
    }

    function unpause() onlyManager whenPaused public {
        paused = false;

        emit Unpause();
    }
}


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant {
        _nonReentrantBefore();

        _;

        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(
            _status != _ENTERED,
            "reentrant-call"
        );

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}


abstract contract SafeTransfer {

    function safeApprove(address _token, address _to, uint256 _value) internal {
        // 0x095ea7b3 is the selector for "approve(address,uint256)"
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x095ea7b3, _to, _value));

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "safe-approve"
        );
    }

    function safeTransfer(address _token, address _to, uint256 _value) internal {
        // 0xa9059cbb is the selector for "transfer(address,uint256)"
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0xa9059cbb, _to, _value));

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "safe-transfer"
        );
    }

    function safeTransferFrom(address _token, address _from, address _to, uint256 _value) internal {
        // 0x23b872dd is the selector for "transferFrom(address,address,uint256)"
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x23b872dd, _from, _to, _value));

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "safe-transfer-from"
        );
    }

    function safeTransferNative(address _to, uint256 _value) internal {
        (bool success, ) = _to.call{value: _value}(new bytes(0));

        require(
            success,
            "safe-transfer-native"
        );
    }
}


contract ActionExecutor is Pausable, ReentrancyGuard, SafeTransfer, GatewayClient, Settings {

    struct LocalAction {
        address fromTokenAddress;
        address toTokenAddress;
        SwapInfo swapInfo;
        address recipient;
    }

    struct Action {
        uint256 gatewayType;
        uint256 vaultType;
        address sourceTokenAddress;
        SwapInfo sourceSwapInfo;
        uint256 targetChainId;
        address targetTokenAddress;
        SwapInfo[] targetSwapInfoOptions;
        address targetRecipient;
    }

    struct SwapInfo {
        uint256 fromAmount;
        uint256 routerType;
        bytes routerData;
    }

    struct TargetMessage {
        uint256 actionId;
        address sourceSender;
        uint256 vaultType;
        address targetTokenAddress;
        SwapInfo targetSwapInfo;
        address targetRecipient;
    }

    address public constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    Registry public registry;

    // Keys: account address, vault type
    mapping(address => mapping(uint256 => uint256)) public variableTokenBalanceTable;
    mapping(address => mapping(uint256 => uint256)) public fallbackCountTable;

    uint256 private constant DECIMALS_DEFAULT = 18;
    uint256 private constant INFINITY = type(uint256).max;
    uint256 private constant MILLIPERCENT_FACTOR = 1e5;

    uint256 private lastActionId = block.chainid * 1e7 + 555 ** 2;

    event ActionDataSent(uint256 indexed actionId, uint256 indexed targetChainId);
    event ActionDataReceived(uint256 indexed actionId, uint256 indexed sourceChainId);

    event SourceProcessed(
        uint256 indexed actionId,
        address indexed sender,
        uint256 indexed routerType,
        address fromTokenAddress,
        address toTokenAddress,
        uint256 fromAmount,
        uint256 resultAmount
    );

    event TargetProcessed(
        uint256 indexed actionId,
        address indexed recipient,
        uint256 indexed routerType,
        address fromTokenAddress,
        address toTokenAddress,
        uint256 fromAmount,
        uint256 resultAmount
    );

    event TargetStopped(uint256 indexed actionId, bytes data);

    event FallbackProcessed(uint256 indexed actionId, uint256 indexed targetChainId);

    event VariableTokenAllocated(
        uint256 indexed actionId,
        bool indexed isTargetChain,
        address indexed tokenRecipient,
        uint256 vaultType,
        uint256 tokenAmount
    );

    constructor(
        address _registryAddress,
        address _ownerAddress,
        bool _grantManagerRoleToOwner
    ) {
        _setRegistry(_registryAddress);

        _initRoles(_ownerAddress, _grantManagerRoleToOwner);
    }

    modifier onlyGateway {
        require(
            registry.isGatewayAddress(msg.sender),
            "only-gateway"
        );

        _;
    }

    modifier onlySelf {
        require(
            msg.sender == address(this),
            "only-self"
        );

        _;
    }

    receive() external payable {
    }

    fallback() external {
    }

    function setRegistry(address _registryAddress) external onlyManager {
        _setRegistry(_registryAddress);
    }

    function cleanup(address _tokenAddress, uint256 _tokenAmount) external onlyManager {
        if (_tokenAddress == NATIVE_TOKEN_ADDRESS) {
            safeTransferNative(msg.sender, _tokenAmount);
        } else {
            safeTransfer(_tokenAddress, msg.sender, _tokenAmount);
        }
    }

    function executeLocal(LocalAction calldata _localAction)
        external
        payable
        nonReentrant
        whenNotPaused
        returns (uint256 actionId)
    {
        LocalSettings memory settings = registry.localSettings(
            msg.sender,
            _localAction.swapInfo.routerType
        );

        lastActionId++;
        actionId = lastActionId;
        
        uint256 initialBalance = address(this).balance - msg.value;
        uint256 initialResultTokenBalance = TokenBalance(_localAction.toTokenAddress).balanceOf(address(this));

        uint256 processedAmount = _processSource(
            actionId,
            _localAction.fromTokenAddress,
            _localAction.toTokenAddress,
            _localAction.swapInfo,
            settings.router,
            initialResultTokenBalance
        );

        address recipient =
            _localAction.recipient == address(0) ?
                msg.sender :
                _localAction.recipient;

        uint256 resultAmount = _calculateLocalAmount(
            processedAmount,
            true,
            settings.systemFee,
            settings.isWhitelist
        );

        if (_localAction.toTokenAddress == NATIVE_TOKEN_ADDRESS) {
            safeTransferNative(recipient, resultAmount);
        } else {
            safeTransfer(_localAction.toTokenAddress, recipient, resultAmount);
        }

        // - - - System fee transfer - - -

        uint256 systemFeeAmount =
            TokenBalance(_localAction.toTokenAddress).balanceOf(address(this)) -
            initialResultTokenBalance;

        if (systemFeeAmount > 0 && settings.feeCollector != address(0)) {
            if (_localAction.toTokenAddress == NATIVE_TOKEN_ADDRESS) {
                safeTransferNative(settings.feeCollector, systemFeeAmount);
            } else {
                safeTransfer(_localAction.toTokenAddress, settings.feeCollector, systemFeeAmount);
            }
        }

        // - - -

        // - - - Extra balance transfer - - -

        uint256 extraBalance = address(this).balance - initialBalance;

        if (extraBalance > 0) {
            safeTransferNative(msg.sender, extraBalance);
        }

        // - - -
    }

    function execute(Action calldata _action)
        external
        payable
        nonReentrant
        whenNotPaused
        returns (uint256 actionId)
    {
        require(
            _action.targetChainId != block.chainid,
            "same-chain-id"
        );

        SourceSettings memory settings = registry.sourceSettings(
            msg.sender,
            _action.targetChainId,
            _action.gatewayType,
            _action.sourceSwapInfo.routerType,
            _action.vaultType
        );

        require(
            settings.vault != address(0),
            "vault-type"
        );

        address vaultAsset = Vault(settings.vault).asset();

        lastActionId++;
        actionId = lastActionId;

        uint256 initialBalance = address(this).balance - msg.value;
        uint256 initialVaultAssetBalance = TokenBalance(vaultAsset).balanceOf(address(this));

        uint256 processedAmount = _processSource(
            actionId,
            _action.sourceTokenAddress,
            vaultAsset,
            _action.sourceSwapInfo,
            settings.router,
            initialVaultAssetBalance
        );

        _checkSwapAmountLimits(
            settings.sourceVaultDecimals,
            processedAmount,
            settings.swapAmountMin,
            settings.swapAmountMax
        );

        uint256 targetVaultAmountMax = _calculateVaultAmount(
            settings.sourceVaultDecimals,
            settings.targetVaultDecimals,
            processedAmount,
            true,
            settings.systemFee,
            settings.isWhitelist
        );

        SwapInfo memory targetSwapInfo;

        uint256 targetOptionsLength = _action.targetSwapInfoOptions.length;

        if (targetOptionsLength == 0) {
            targetSwapInfo = SwapInfo({
                fromAmount: targetVaultAmountMax,
                routerType: uint256(0),
                routerData: new bytes(0)
            });
        } else {
            for (uint256 index; index < targetOptionsLength; index++) {
                SwapInfo memory targetSwapInfoOption = _action.targetSwapInfoOptions[index];

                if (targetSwapInfoOption.fromAmount <= targetVaultAmountMax) {
                    targetSwapInfo = targetSwapInfoOption;
                    break;
                }
            }

            require(
                targetSwapInfo.fromAmount != 0,
                "target-swap-info"
            );
        }

        uint256 sourceVaultAmount = _convertDecimals(
            settings.targetVaultDecimals,
            settings.sourceVaultDecimals,
            targetSwapInfo.fromAmount
        );

        // - - - Transfer to vault - - -

        safeTransfer(vaultAsset, settings.vault, sourceVaultAmount);

        // - - -

        address targetRecipient =
            _action.targetRecipient == address(0) ?
                msg.sender :
                _action.targetRecipient;

        bytes memory targetMessageData = abi.encode(
            TargetMessage({
                actionId: actionId,
                sourceSender: msg.sender,
                vaultType: _action.vaultType,
                targetTokenAddress: _action.targetTokenAddress,
                targetSwapInfo: targetSwapInfo,
                targetRecipient: targetRecipient
            })
        );

        _sendMessage(
            settings,
            _action.targetChainId,
            targetMessageData
        );

        emit ActionDataSent(actionId, _action.targetChainId);

        // - - - System fee transfer - - -

        uint256 systemFeeAmount =
            TokenBalance(vaultAsset).balanceOf(address(this)) -
            initialVaultAssetBalance;

        if (systemFeeAmount > 0 && settings.feeCollector != address(0)) {
            safeTransfer(vaultAsset, settings.feeCollector, systemFeeAmount);
        }

        // - - -

        // - - - Extra balance transfer - - -

        uint256 extraBalance = address(this).balance - initialBalance;

        if (extraBalance > 0) {
            safeTransferNative(msg.sender, extraBalance);
        }

        // - - -
    }

    function claimVariableToken(uint256 _vaultType) external payable {
        _processVariableTokenClaim(_vaultType, false);
    }

    function convertVariableTokenToVaultAsset(uint256 _vaultType) external payable {
        _processVariableTokenClaim(_vaultType, true);
    }

    function messageFeeEstimate(
        uint256 _gatewayType,
        uint256 _targetChainId,
        bytes[] calldata _targetRouterDataOptions
    )
        external
        view
        returns (uint256)
    {
        if (_targetChainId == block.chainid) {
            return 0;
        }

        MessageFeeEstimateSettings memory settings = registry.messageFeeEstimateSettings(_gatewayType);

        require(
            settings.gateway != address(0),
            "gateway-type"
        );

        uint256 result = 0;

        for (uint256 index; index < _targetRouterDataOptions.length; index++) {
            bytes calldata targetRouterData = _targetRouterDataOptions[index];

            bytes memory messageData = abi.encode(
                TargetMessage({
                    actionId: uint256(0),
                    sourceSender: address(0),
                    vaultType: uint256(0),
                    targetTokenAddress: address(0),
                    targetSwapInfo: SwapInfo({
                        fromAmount: uint256(0),
                        routerType: uint256(0),
                        routerData: targetRouterData
                    }),
                    targetRecipient: address(0)
                })
            );

            uint256 value = Gateway(settings.gateway).messageFee(_targetChainId, messageData.length);

            if (value > result) {
                result = value;
            }
        }

        return result;
    }

    function variableTokenFeeAmount(address _account, uint256 _vaultType) external view returns (uint256) {
        return _variableTokenFeeAmount(
            _account,
            _vaultType,
            registry.fallbackFee()
        );
    }

    function calculateLocalAmount(uint256 _fromAmount, bool _isForward) external view returns (uint256 result) {
        LocalAmountCalculationSettings memory settings =
            registry.localAmountCalculationSettings(msg.sender);

        return _calculateLocalAmount(
            _fromAmount,
            _isForward,
            settings.systemFee,
            settings.isWhitelist
        );
    }

    function calculateVaultAmount(
        uint256 _vaultType,
        uint256 _fromChainId,
        uint256 _toChainId,
        uint256 _fromAmount,
        bool _isForward
    )
        external
        view
        returns (uint256 result)
    {
        VaultAmountCalculationSettings memory settings =
            registry.vaultAmountCalculationSettings(
                msg.sender,
                _vaultType,
                _fromChainId,
                _toChainId
            );

        return _calculateVaultAmount(
            settings.fromDecimals,
            settings.toDecimals,
            _fromAmount,
            _isForward,
            settings.systemFee,
            settings.isWhitelist
        );
    }

    function variableTokenBalance(address _account, uint256 _vaultType) public view returns (uint256) {
        return variableTokenBalanceTable[_account][_vaultType];
    }

    function tokenBalance(address _tokenAddress) public view returns (uint256) {
        if (_tokenAddress == NATIVE_TOKEN_ADDRESS) {
            return address(this).balance;
        } else {
            return TokenBalance(_tokenAddress).balanceOf(address(this));
        }
    }

    function handleExecutionPayload(
        uint256 _messageSourceChainId,
        bytes calldata _payloadData
    )
        external
        onlyGateway
        whenNotPaused
        returns (bool success, bytes memory result)
    {
        TargetMessage memory targetMessage = abi.decode(_payloadData, (TargetMessage));

        emit ActionDataReceived(targetMessage.actionId, _messageSourceChainId);

        TargetSettings memory settings =
            registry.targetSettings(
                targetMessage.vaultType,
                targetMessage.targetSwapInfo.routerType
            );

        bool selfCallSuccess;
        bytes memory selfCallResult;

        try this.selfCallTarget(settings, targetMessage) {
            selfCallSuccess = true;
        } catch Error(string memory reason) {
            (selfCallSuccess, selfCallResult) = (false, bytes(reason));
        } catch {
            (selfCallSuccess, selfCallResult) = (false, "target-message-call");
        }

        if (!selfCallSuccess) {
            _targetAllocateVariableToken(targetMessage);

            emit TargetStopped(targetMessage.actionId, selfCallResult);

            return (false, selfCallResult);
        }

        return (true, "");
    }

    function handleFallbackPayload(
        uint256 _messageTargetChainId,
        bytes calldata _payloadData
    )
        external
        onlyGateway
        whenNotPaused
    {
        TargetMessage memory targetMessage = abi.decode(_payloadData, (TargetMessage));

        FallbackSettings memory settings = registry.fallbackSettings(_messageTargetChainId, targetMessage.vaultType);

        _fallbackAllocateVariableToken(settings, targetMessage);

        emit FallbackProcessed(targetMessage.actionId, _messageTargetChainId);
    }

    function selfCallTarget(TargetSettings calldata settings, TargetMessage calldata _targetMessage) external onlySelf {
        require(
            settings.vault != address(0),
            "vault-type"
        );

        // - - - Transfer from vault - - -

        address assetAddress =
            Vault(settings.vault).requestAsset(
                _targetMessage.targetSwapInfo.fromAmount,
                address(this),
                false
            );

        // - - -

        _processTarget(
            settings,
            _targetMessage.actionId,
            assetAddress,
            _targetMessage.targetTokenAddress,
            _targetMessage.targetSwapInfo,
            _targetMessage.targetRecipient
        );
    }

    function _processSource(
        uint256 _actionId,
        address _sourceTokenAddress,
        address _resultTokenAddress,
        SwapInfo memory _sourceSwapInfo,
        address _routerAddress,
        uint256 _initialResultTokenBalance
    )
        private
        returns (uint256 resultAmount)
    {
        if (_sourceTokenAddress == NATIVE_TOKEN_ADDRESS) {
            require(
                _routerAddress != address(0),
                "source-router-type"
            );

            // - - - Source swap (native token) - - -

            (bool routerCallSuccess, ) =
                payable(_routerAddress).call{value: _sourceSwapInfo.fromAmount}(_sourceSwapInfo.routerData);

            require(
                routerCallSuccess,
                "source-swap"
            );

            // - - -
        } else {
            safeTransferFrom(_sourceTokenAddress, msg.sender, address(this), _sourceSwapInfo.fromAmount);

            if (_sourceTokenAddress != _resultTokenAddress) {
                require(
                    _routerAddress != address(0),
                    "source-router-type"
                );

                // - - - Source swap (non-native token) - - -

                safeApprove(_sourceTokenAddress, _routerAddress, _sourceSwapInfo.fromAmount);

                (bool routerCallSuccess, ) = _routerAddress.call(_sourceSwapInfo.routerData);

                require(
                    routerCallSuccess,
                    "source-swap"
                );

                safeApprove(_sourceTokenAddress, _routerAddress, 0);

                // - - -
            }
        }

        resultAmount =
            TokenBalance(_resultTokenAddress).balanceOf(address(this)) -
            _initialResultTokenBalance;

        emit SourceProcessed(
            _actionId,
            msg.sender,
            _sourceSwapInfo.routerType,
            _sourceTokenAddress,
            _resultTokenAddress,
            _sourceSwapInfo.fromAmount,
            resultAmount
        );
    }

    function _processTarget(
        TargetSettings memory settings,
        uint256 _actionId,
        address _vaultAssetAddress,
        address _targetTokenAddress,
        SwapInfo memory _targetSwapInfo,
        address _targetRecipient
    )
        private
    {
        uint256 resultAmount;

        if (_targetTokenAddress == _vaultAssetAddress) {
            resultAmount = _targetSwapInfo.fromAmount;

            safeTransfer(_targetTokenAddress, _targetRecipient, resultAmount);
        } else {
            require(
                settings.router != address(0),
                "target-router-type"
            );

            uint256 targetTokenBalanceBefore = tokenBalance(_targetTokenAddress);

            // - - - Target swap - - -

            safeApprove(_vaultAssetAddress, settings.router, _targetSwapInfo.fromAmount);

            (bool success, ) = settings.router.call(_targetSwapInfo.routerData);

            require(
                success,
                "target-swap"
            );

            safeApprove(_vaultAssetAddress, settings.router, 0);

            // - - -

            uint256 targetTokenBalanceAfter = tokenBalance(_targetTokenAddress);
            resultAmount = targetTokenBalanceAfter - targetTokenBalanceBefore;

            if (_targetTokenAddress == NATIVE_TOKEN_ADDRESS) {
                safeTransferNative(_targetRecipient, resultAmount);
            } else {
                safeTransfer(_targetTokenAddress, _targetRecipient, resultAmount);
            }
        }

        emit TargetProcessed(
            _actionId,
            _targetRecipient,
            _targetSwapInfo.routerType,
            _vaultAssetAddress,
            _targetTokenAddress,
            _targetSwapInfo.fromAmount,
            resultAmount
        );
    }

    function _targetAllocateVariableToken(TargetMessage memory _targetMessage) private {
        address tokenRecipient = _targetMessage.targetRecipient;
        uint256 vaultType = _targetMessage.vaultType;
        uint256 tokenAmount = _targetMessage.targetSwapInfo.fromAmount;

        variableTokenBalanceTable[tokenRecipient][vaultType] += tokenAmount;

        emit VariableTokenAllocated(
            _targetMessage.actionId,
            true,
            tokenRecipient,
            vaultType,
            tokenAmount
        );
    }

    function _fallbackAllocateVariableToken(FallbackSettings memory _settings, TargetMessage memory _targetMessage) private {
        address tokenRecipient = _targetMessage.sourceSender;
        uint256 vaultType = _targetMessage.vaultType;

        uint256 tokenAmount = _convertDecimals(
            _settings.targetVaultDecimals,
            _settings.sourceVaultDecimals,
            _targetMessage.targetSwapInfo.fromAmount
        );

        fallbackCountTable[tokenRecipient][vaultType]++;
        variableTokenBalanceTable[tokenRecipient][vaultType] += tokenAmount;

        emit VariableTokenAllocated(
            _targetMessage.actionId,
            false,
            tokenRecipient,
            vaultType,
            tokenAmount
        );
    }

    function _processVariableTokenClaim(uint256 _vaultType, bool _convertToVaultAsset) private {
        VariableTokenClaimSettings memory settings = registry.variableTokenClaimSettings(_vaultType);

        require(
            settings.vault != address(0),
            "vault-type"
        );

        uint256 feeAmount = _variableTokenFeeAmount(msg.sender, _vaultType, settings.fallbackFee);

        require(
            msg.value >= feeAmount,
            "fee-amount"
        );

        uint256 initialBalance = address(this).balance - msg.value;

        // - - - Fallback fee transfer

        if (feeAmount > 0) {
            address feeCollector = settings.feeCollector;

            if (feeCollector != address(0)) {
                safeTransferNative(feeCollector, feeAmount);
            } else {
                initialBalance += feeAmount; // Keep at the contract address
            }
        }

        // - - -

        uint256 tokenAmount = variableTokenBalance(msg.sender, _vaultType);

        if (tokenAmount > 0) {
            variableTokenBalanceTable[msg.sender][_vaultType] = 0;

            if (_convertToVaultAsset) {
                Vault(settings.vault).requestAsset(
                    tokenAmount,
                    msg.sender,
                    true
                );
            } else {
                address variableTokenAddress = Vault(settings.vault).variableToken();

                TokenMint(variableTokenAddress).mint(msg.sender, tokenAmount);
            }
        }

        // - - - Extra balance transfer - - -

        uint256 extraBalance = address(this).balance - initialBalance;

        if (extraBalance > 0) {
            safeTransferNative(msg.sender, extraBalance);
        }

        // - - -

        fallbackCountTable[msg.sender][_vaultType] = 0;
    }

    function _setRegistry(address _registryAddress) private {
        require(
            _registryAddress != address(0),
            "registry-zero-address"
        );

        registry = Registry(_registryAddress);
    }

    function _initRoles(address _ownerAddress, bool _grantManagerRoleToOwner) private {
        address ownerAddress =
            _ownerAddress == address(0) ?
                msg.sender :
                _ownerAddress;

        if (_grantManagerRoleToOwner) {
            setManager(ownerAddress, true);
        }

        if (ownerAddress != msg.sender) {
            transferOwnership(ownerAddress);
        }
    }

    function _sendMessage(SourceSettings memory settings, uint256 _targetChainId, bytes memory _messageData) private {
        require(
            settings.gateway != address(0),
            "gateway-type"
        );

        uint256 messageFee = Gateway(settings.gateway).messageFee(_targetChainId, _messageData.length);

        Gateway(settings.gateway).sendMessage{value: messageFee}(
            _targetChainId,
            _messageData,
            settings.useGatewayFallback
        );
    }

    function _variableTokenFeeAmount(address _account, uint256 _vaultType, uint256 _fallbackFee) private view returns (uint256) {
        return fallbackCountTable[_account][_vaultType] * _fallbackFee;
    }

    function _checkSwapAmountLimits(uint256 _vaultDecimals, uint256 _amount, uint256 _swapAmountMin, uint256 _swapAmountMax) private pure {
        uint256 normalizedAmount = _convertDecimals(
             _vaultDecimals,
             DECIMALS_DEFAULT,
             _amount
        );

        require(
            normalizedAmount >= _swapAmountMin,
            "swap-amount-min"
        );

        require(
            normalizedAmount <= _swapAmountMax,
            "swap-amount-max"
        );
    }

    function _calculateLocalAmount(
        uint256 _fromAmount,
        bool _isForward,
        uint256 _systemFee,
        bool _isWhitelist
    )
        private
        pure
        returns (uint256 result)
    {
        if (_isWhitelist || _systemFee == 0) {
            return _fromAmount;
        }

        return _isForward ?
            _fromAmount * (MILLIPERCENT_FACTOR - _systemFee) / MILLIPERCENT_FACTOR :
            _fromAmount *  MILLIPERCENT_FACTOR / (MILLIPERCENT_FACTOR - _systemFee);
    }

    function _calculateVaultAmount(
        uint256 _fromDecimals,
        uint256 _toDecimals,
        uint256 _fromAmount,
        bool _isForward,
        uint256 _systemFee,
        bool _isWhitelist
    )
        private
        pure
        returns (uint256 result)
    {
        bool isZeroFee = _isWhitelist || _systemFee == 0;

        uint256 amountToConvert =
            (!_isForward || isZeroFee) ?
                _fromAmount :
                _fromAmount * (MILLIPERCENT_FACTOR - _systemFee) / MILLIPERCENT_FACTOR;

        uint256 convertedAmount = _convertDecimals(
            _fromDecimals,
            _toDecimals,
            amountToConvert
        );

        result =
            (_isForward || isZeroFee) ?
                convertedAmount :
                convertedAmount * MILLIPERCENT_FACTOR / (MILLIPERCENT_FACTOR - _systemFee);
    }

    function _convertDecimals(
        uint256 _fromDecimals,
        uint256 _toDecimals,
        uint256 _fromAmount
    )
        private
        pure
        returns (uint256)
    {
        if (_toDecimals == _fromDecimals) {
            return _fromAmount;
        } else if (_toDecimals > _fromDecimals) {
            return _fromAmount * 10 ** (_toDecimals - _fromDecimals);
        } else {
            return _fromAmount / 10 ** (_fromDecimals - _toDecimals);
        }
    }
}