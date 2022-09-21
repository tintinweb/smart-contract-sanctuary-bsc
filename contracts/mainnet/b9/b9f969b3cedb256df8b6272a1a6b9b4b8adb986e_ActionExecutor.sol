/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.17;


interface TokenBalance {
    function balanceOf(address _account) external view returns (uint256);
}


interface TokenMint {
    function mint(address _to, uint256 _amount) external returns (bool);
}


interface CallProxy {
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags
    ) external payable;

    function executor() external view returns (CallExecutor executor);

    function srcDefaultFees(uint256 _targetChainId) external view returns (uint256 baseFees, uint256 feesPerByte);

    function executionBudget(address _account) external view returns (uint256 amount);

    function deposit(address _account) external payable;

    function withdraw(uint256 _amount) external;
}


interface CallExecutor {
    function context() external view returns (address from, uint256 fromChainID, uint256 nonce);
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


abstract contract CallProxyInteraction is ReentrancyGuard {

    CallProxy public immutable callProxy;
    CallExecutor public immutable callExecutor;

    uint256 internal constant CALL_PAY_FEE_ON_SOURCE_CHAIN = 0x1 << 1;
    address internal callFallbackAddress;

    event SetUseCallFallback(bool indexed value);

    constructor (address _callProxyAddress, bool _useCallFallback) {
        require(
            _callProxyAddress != address(0),
            "call-proxy-zero-address"
        );

        callProxy = CallProxy(_callProxyAddress);
        callExecutor = callProxy.executor();

        _setUseCallFallback(_useCallFallback);
    }

    modifier onlyCallExecutor {
        require(
            msg.sender == address(callExecutor),
            "only-call-executor"
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

    function anyExecute(bytes calldata _data) external nonReentrant onlyCallExecutor returns (bool success, bytes memory result) {
        bytes4 selector = bytes4(_data[:4]);

        if (selector == this.anyExecute.selector) {
            (address from, uint256 fromChainID, ) = callExecutor.context();

            handleAnyExecutePayload(fromChainID, from, _data[4:]);
        } else if (selector == this.anyFallback.selector) {
            (address fallbackTo, bytes memory fallbackData) = abi.decode(_data[4:], (address, bytes));

            this.anyFallback(fallbackTo, fallbackData);
        } else {
            return (false, "call-selector");
        }

        return (true, "");
    }

    function anyFallback(address _to, bytes calldata _data) external onlySelf {
        (address from, uint256 fromChainID, ) = callExecutor.context();

        require(
            from == address(this),
            "fallback-context-from"
        );

        require(
            bytes4(_data[:4]) == this.anyExecute.selector,
            "fallback-data-selector"
        );

        handleAnyFallbackPayload(fromChainID, _to, _data[4:]);
    }

    function _setUseCallFallback(bool _value) internal {
        callFallbackAddress = _value ?
            address(this) :
            address(0);

        emit SetUseCallFallback(_value);
    }

    function handleAnyExecutePayload(uint256 _callFromChainId, address _callFromAddress, bytes calldata _payloadData) internal virtual;

    function handleAnyFallbackPayload(uint256 _callToChainId, address _callToAddress, bytes calldata _payloadData) internal virtual;
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

    function renounceOwnership() public virtual onlyOwner {
        address previousOwner = owner;
        owner = address(0);

        emit OwnershipTransferred(previousOwner, address(0));
    }
}


abstract contract ManagerRole {

    mapping(address => bool) public managers;

    event SetManager(address indexed managerAddress, bool indexed value);

    modifier onlyManager {
        require(
            managers[msg.sender],
            "only-manager"
        );

        _;
    }

    function _setManager(address _managerAddress, bool _value) internal virtual {
        managers[_managerAddress] = _value;

        emit SetManager(_managerAddress, _value);
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


abstract contract DataStructures {

    struct OptionalValue {
        bool isSet;
        uint256 value;
    }

    struct KeyValuePair {
        uint256 key;
        uint256 value;
    }

    function mapWithKeyListSet(
        mapping(uint256 => address) storage _map,
        uint256[] storage _keyList,
        uint256 _key,
        address _value
    ) internal returns (bool isNewKey) {
        require(
            _value != address(0),
            "value-zero-address"
        );

        isNewKey = (_map[_key] == address(0));

        if (isNewKey) {
            _keyList.push(_key);
        }

        _map[_key] = _value;
    }

    function mapWithKeyListRemove(
        mapping(uint256 => address) storage _map,
        uint256[] storage _keyList,
        uint256 _key
    ) internal returns (bool isChanged) {
        isChanged = (_map[_key] != address(0));

        if (isChanged) {
            delete _map[_key];
            arrayRemoveValue(_keyList, _key);
        }
    }

    function arrayRemoveValue(uint256[] storage _array, uint256 _value) internal returns (bool isChanged) {
        uint256 arrayLength = _array.length;

        for (uint256 index; index < arrayLength; index++) {
            if (_array[index] == _value) {
                _array[index] = _array[arrayLength - 1];
                _array.pop();

                return true;
            }
        }

        return false;
    }
}


contract ActionExecutor is CallProxyInteraction, Ownable, ManagerRole, SafeTransfer, DataStructures {

    struct Action {
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
    uint256 public constant CHAIN_ID_WILDCARD = 0;

    uint256[] public vaultTypes;
    mapping(uint256 => address) public vaults;
    mapping(uint256 => address) public vaultAssets;
    mapping(uint256 => address) public vaultVTokens;
    mapping(uint256 => mapping(uint256 => OptionalValue)) vaultDecimalsTable; // keys: vault type, chain id

    uint256[] public peerChainIds;
    mapping(uint256 => address) public peers;

    uint256[] public routerTypes;
    mapping(uint256 => address) public routers;

    mapping(address => bool) public whitelist;

    uint256 public systemFee;

    uint256 private constant systemFeeFactor = 1e5;

    uint256 private lastActionId = 5e4;

    event SetVault(uint256 indexed vaultType, address indexed vaultAddress, address indexed vaultAssetAddress, address vaultVTokenAddress);
    event RemoveVault(uint256 indexed vaultType);
    event SetVaultCustomDecimals(uint256 indexed vaultType, KeyValuePair[] customDecimals);
    event UnsetVaultCustomDecimals(uint256 indexed vaultType, uint256[] chainIds);
    event SetPeer(uint256 indexed chainId, address indexed peerAddress);
    event RemovePeer(uint256 indexed chainId);
    event SetRouter(uint256 indexed routerType, address indexed routerAddress);
    event RemoveRouter(uint256 indexed routerType);
    event SetWhitelist(address indexed whitelistAddress, bool indexed value);
    event SetSystemFee(uint256 systemFee);
    event DepositToCallProxy(uint256 amount);
    event WithdrawFromCallProxy(uint256 amount);

    event SourceProcessed(
        uint256 indexed actionId,
        address indexed sender,
        uint256 indexed routerType,
        address fromTokenAddress,
        address toVaultAssetAddress,
        uint256 fromAmount,
        uint256 resultAmount
    );

    event TargetProcessed(
        uint256 indexed actionId,
        address indexed recipient,
        uint256 indexed routerType,
        address fromVaultAssetAddress,
        address toTokenAddress,
        uint256 fromAmount,
        uint256 resultAmount
    );

    constructor(address _callProxy, bool _setOwnerAsManager) CallProxyInteraction(_callProxy, true) {
        if (_setOwnerAsManager) {
            _setManager(owner, true);
        }
    }

    receive() external payable {
    }

    fallback() external {
    }

    function setManager(address _managerAddress, bool _value) external onlyOwner {
        _setManager(_managerAddress, _value);
    }

    function setVault(
        uint256 _vaultType,
        address _vaultAddress,
        address _vaultAssetAddress,
        address _vaultVTokenAddress
    ) external onlyManager {
        require(
            _vaultAddress != address(0),
            "vault-zero-address"
        );

        require(
            _vaultAssetAddress != address(0),
            "vault-asset-zero-address"
        );

        mapWithKeyListSet(vaults, vaultTypes, _vaultType, _vaultAddress);

        vaultAssets[_vaultType] = _vaultAssetAddress;
        vaultVTokens[_vaultType] = _vaultVTokenAddress;

        emit SetVault(_vaultType, _vaultAddress, _vaultAssetAddress, _vaultVTokenAddress);
    }

    function removeVault(uint256 _vaultType) external onlyManager {
        mapWithKeyListRemove(vaults, vaultTypes, _vaultType);

        delete vaultAssets[_vaultType];
        delete vaultVTokens[_vaultType];

        delete vaultDecimalsTable[_vaultType][CHAIN_ID_WILDCARD];

        uint256 peerChainIdsLength = peerChainIds.length;

        for (uint256 index; index < peerChainIdsLength; index++) {
            uint256 peerChainId = peerChainIds[index];

            delete vaultDecimalsTable[_vaultType][peerChainId];
        }

        emit RemoveVault(_vaultType);
    }

    function setVaultCustomDecimals(uint256 _vaultType, KeyValuePair[] calldata _customDecimals) external onlyManager {
        require(
            vaults[_vaultType] != address(0),
            "vault-type"
        );

        for (uint256 index; index < _customDecimals.length; index++) {
            KeyValuePair calldata customDecimalsItem = _customDecimals[index];
            vaultDecimalsTable[_vaultType][customDecimalsItem.key] = OptionalValue(true, customDecimalsItem.value);
        }

        emit SetVaultCustomDecimals(_vaultType, _customDecimals);
    }

    function unsetVaultCustomDecimals(uint256 _vaultType, uint256[] calldata _chainIds) external onlyManager {
        require(
            vaults[_vaultType] != address(0),
            "vault-type"
        );

        for (uint256 index; index < _chainIds.length; index++) {
            uint256 chainId = _chainIds[index];
            delete vaultDecimalsTable[_vaultType][chainId];
        }

        emit UnsetVaultCustomDecimals(_vaultType, _chainIds);
    }

    function setPeer(uint256 _chainId, address _peerAddress) external onlyManager {
        require(
            _chainId != CHAIN_ID_WILDCARD &&_chainId != block.chainid,
            "chain-id"
        );

        require(
            _peerAddress != address(0),
            "peer-zero-address"
        );

        mapWithKeyListSet(peers, peerChainIds, _chainId, _peerAddress);

        emit SetPeer(_chainId, _peerAddress);
    }

    function removePeer(uint256 _chainId) external onlyManager {
        require(
            _chainId != CHAIN_ID_WILDCARD,
            "chain-id"
        );

        mapWithKeyListRemove(peers, peerChainIds, _chainId);

        uint256 vaultTypesLength = vaultTypes.length;

        for (uint256 index; index < vaultTypesLength; index++) {
            uint256 vaultType = vaultTypes[index];

            delete vaultDecimalsTable[vaultType][_chainId];
        }

        emit RemovePeer(_chainId);
    }

    function setRouter(uint256 _routerType, address _routerAddress) external onlyManager {
        require(
            _routerAddress != address(0),
            "router-zero-address"
        );

        mapWithKeyListSet(routers, routerTypes, _routerType, _routerAddress);

        emit SetRouter(_routerType, _routerAddress);
    }

    function removeRouter(uint256 _routerType) external onlyManager {
        mapWithKeyListRemove(routers, routerTypes, _routerType);

        emit RemoveRouter(_routerType);
    }

    function setWhitelist(address _whitelistAddress, bool _value) external onlyManager {
        whitelist[_whitelistAddress] = _value;

        emit SetWhitelist(_whitelistAddress, _value);
    }

    function setSystemFee(uint256 _systemFee) external onlyManager {
        require(
            _systemFee <= systemFeeFactor,
            "system-fee-value"
        );

        systemFee = _systemFee;

        emit SetSystemFee(_systemFee);
    }

    function setUseCallFallback(bool _value) external onlyManager {
        _setUseCallFallback(_value);
    }

    function depositToCallProxy() external payable onlyManager {
        uint256 amount = msg.value;

        callProxy.deposit{value: amount}(address(this));

        emit DepositToCallProxy(amount);
    }

    function withdrawFromCallProxy(uint256 _amount) external onlyManager {
        callProxy.withdraw(_amount);

        emit WithdrawFromCallProxy(_amount);

        safeTransferNative(msg.sender, _amount);
    }

    function cleanup(address _tokenAddress, uint256 _tokenAmount) external onlyManager {
        if (_tokenAddress == NATIVE_TOKEN_ADDRESS) {
            safeTransferNative(msg.sender, _tokenAmount);
        } else {
            safeTransfer(_tokenAddress, msg.sender, _tokenAmount);
        }
    }

    function execute(Action calldata _action) external payable nonReentrant returns (uint256 actionId) {
        lastActionId++;
        actionId = lastActionId;

        address vaultAddress = vaults[_action.vaultType];
        address vaultAssetAddress = vaultAssets[_action.vaultType];

        require(
            vaultAddress != address(0) && vaultAssetAddress != address(0),
            "vault-type"
        );

        uint256 initialBalance = address(this).balance - msg.value;

        uint256 processedAmount = _processSource(
            actionId,
            _action.sourceTokenAddress,
            vaultAssetAddress,
            _action.sourceSwapInfo
        );

        uint256 targetVaultAmountMax = targetVaultAmount(
            _action.vaultType,
            _action.targetChainId,
            processedAmount
        );

        SwapInfo memory targetSwapInfo;

        uint256 targetOptionsLength = _action.targetSwapInfoOptions.length;

        if (targetOptionsLength != 0) {
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
        } else {
            targetSwapInfo = SwapInfo({
                fromAmount: targetVaultAmountMax,
                routerType: uint256(0),
                routerData: new bytes(0)
            });
        }

        if (_action.targetChainId == block.chainid) {
            _processTarget(
                actionId,
                vaultAssetAddress,
                _action.targetTokenAddress,
                targetSwapInfo,
                _action.targetRecipient
            );
        } else {
            uint256 sourceVaultAmount = _convertVaultDecimals(
                _action.vaultType,
                targetSwapInfo.fromAmount,
                _action.targetChainId,
                block.chainid
            );

            safeTransfer(vaultAssetAddress, vaultAddress, sourceVaultAmount);

            TargetMessage memory targetMessage = TargetMessage({
                actionId: actionId,
                sourceSender: msg.sender,
                vaultType: _action.vaultType,
                targetTokenAddress: _action.targetTokenAddress,
                targetSwapInfo: targetSwapInfo,
                targetRecipient: _action.targetRecipient
            });

            _notifyTarget(
                _action.targetChainId,
                abi.encodeWithSelector(
                    this.anyExecute.selector,
                    targetMessage
                )
            );
        }

        uint256 extraBalance = address(this).balance - initialBalance;

        if (extraBalance > 0) {
            safeTransferNative(msg.sender, extraBalance);
        }
    }

    function targetVaultAmount(
        uint256 _vaultType,
        uint256 _targetChainId,
        uint256 _sourceVaultAmount
    ) public view returns (uint256) {
        uint256 amount = whitelist[msg.sender] ?
            _sourceVaultAmount :
            _sourceVaultAmount * (systemFeeFactor - systemFee) / systemFeeFactor;

        return _convertVaultDecimals(
            _vaultType,
            amount,
            block.chainid,
            _targetChainId
        );
    }

    function tokenBalance(address _tokenAddress) public view returns (uint256) {
        if (_tokenAddress == NATIVE_TOKEN_ADDRESS) {
            return address(this).balance;
        } else {
            return TokenBalance(_tokenAddress).balanceOf(address(this));
        }
    }

    function messageFeeEstimate(uint256 _targetChainId, bytes[] calldata _targetRouterDataOptions) public view returns (uint256) {
        if (_targetChainId == block.chainid) {
            return 0;
        }

        uint256 result = 0;

        for (uint256 index; index < _targetRouterDataOptions.length; index++) {
            bytes calldata targetRouterData = _targetRouterDataOptions[index];

            bytes memory messageData = abi.encodeWithSelector(
                this.anyExecute.selector,
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

            uint256 value = _messageFeeInternal(_targetChainId, messageData.length);

            if (value > result) {
                result = value;
            }
        }

        return result;
    }

    function executionBudgetAtCallProxy() external view returns (uint256 amount) {
        return callProxy.executionBudget(address(this));
    }

    function vaultDecimals(uint256 _vaultType, uint256 _chainId) public view returns (uint256) {
        OptionalValue storage optionalValue = vaultDecimalsTable[_vaultType][_chainId];

        if (optionalValue.isSet) {
            return optionalValue.value;
        }

        OptionalValue storage wildcardOptionalValue = vaultDecimalsTable[_vaultType][CHAIN_ID_WILDCARD];

        if (wildcardOptionalValue.isSet) {
            return wildcardOptionalValue.value;
        }

        return 18;
    }

    function handleAnyExecutePayload(uint256 _callFromChainId, address _callFromAddress, bytes calldata _payloadData) internal override {
        require(
            _callFromChainId != CHAIN_ID_WILDCARD && _callFromAddress == peers[_callFromChainId],
            "call-from-address"
        );

        TargetMessage memory targetMessage = abi.decode(_payloadData, (TargetMessage));

        address vaultAddress = vaults[targetMessage.vaultType];
        address vaultAssetAddress = vaultAssets[targetMessage.vaultType];

        require(
            vaultAddress != address(0) && vaultAssetAddress != address(0),
            "vault-type"
        );

        safeTransferFrom(vaultAssetAddress, vaultAddress, address(this), targetMessage.targetSwapInfo.fromAmount);

        _processTarget(
            targetMessage.actionId,
            vaultAssetAddress,
            targetMessage.targetTokenAddress,
            targetMessage.targetSwapInfo,
            targetMessage.targetRecipient
        );
    }

    function handleAnyFallbackPayload(uint256 _callToChainId, address _callToAddress, bytes calldata _payloadData) internal override {
        require(
            _callToChainId != CHAIN_ID_WILDCARD && _callToAddress == peers[_callToChainId],
            "fallback-call-to-address"
        );

        TargetMessage memory targetMessage = abi.decode(_payloadData, (TargetMessage));

        address vTokenAddress = vaultVTokens[targetMessage.vaultType];

        if (vTokenAddress != address(0)) {
            uint256 vTokenAmount = _convertVaultDecimals(
                targetMessage.vaultType,
                targetMessage.targetSwapInfo.fromAmount,
                _callToChainId,
                block.chainid
            );

            TokenMint(vTokenAddress).mint(targetMessage.sourceSender, vTokenAmount);
        }
    }

    function _processSource(
        uint256 _actionId,
        address _sourceTokenAddress,
        address _vaultAssetAddress,
        SwapInfo memory _sourceSwapInfo
    ) private returns (uint256 resultAmount) {
        uint256 vaultAssetBalanceBefore = TokenBalance(_vaultAssetAddress).balanceOf(address(this));

        if (_sourceTokenAddress == NATIVE_TOKEN_ADDRESS) {
            address router = routers[_sourceSwapInfo.routerType];

            require(
                router != address(0),
                "source-router-type"
            );

            (bool success, ) = payable(router).call{value: _sourceSwapInfo.fromAmount}(_sourceSwapInfo.routerData);

            require(
                success,
                "source-swap"
            );
        } else {
            safeTransferFrom(_sourceTokenAddress, msg.sender, address(this), _sourceSwapInfo.fromAmount);

            if (_sourceTokenAddress != _vaultAssetAddress) {
                address router = routers[_sourceSwapInfo.routerType];

                require(
                    router != address(0),
                    "source-router-type"
                );

                safeApprove(_sourceTokenAddress, router, 0);
                safeApprove(_sourceTokenAddress, router, _sourceSwapInfo.fromAmount);

                (bool success, ) = router.call(_sourceSwapInfo.routerData);

                require(
                    success,
                    "source-swap"
                );

                safeApprove(_sourceTokenAddress, router, 0);
            }
        }

        uint256 vaultAssetBalanceAfter = TokenBalance(_vaultAssetAddress).balanceOf(address(this));
        resultAmount = vaultAssetBalanceAfter - vaultAssetBalanceBefore;

        emit SourceProcessed(
            _actionId,
            msg.sender,
            _sourceSwapInfo.routerType,
            _sourceTokenAddress,
            _vaultAssetAddress,
            _sourceSwapInfo.fromAmount,
            resultAmount
        );
    }

    function _processTarget(
        uint256 _actionId,
        address _vaultAssetAddress,
        address _targetTokenAddress,
        SwapInfo memory _targetSwapInfo,
        address _targetRecipient
    ) private {
        uint256 resultAmount;

        if (_targetTokenAddress == _vaultAssetAddress) {
            resultAmount = _targetSwapInfo.fromAmount;

            safeTransfer(_targetTokenAddress, _targetRecipient, resultAmount);
        } else {
            uint256 targetTokenBalanceBefore = tokenBalance(_targetTokenAddress);

            address router = routers[_targetSwapInfo.routerType];

            require(
                router != address(0),
                "target-router-type"
            );

            safeApprove(_vaultAssetAddress, router, 0);
            safeApprove(_vaultAssetAddress, router, _targetSwapInfo.fromAmount);

            (bool success, ) = router.call(_targetSwapInfo.routerData);

            require(
                success,
                "target-swap"
            );

            safeApprove(_vaultAssetAddress, router, 0);

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

    function _notifyTarget(uint256 _targetChainId, bytes memory _message) private {
        address peer = peers[_targetChainId];

        require(
            peer != address(0),
            "peer-chain-id"
        );

        uint256 callFee = _messageFeeInternal(_targetChainId, _message.length);

        callProxy.anyCall{value: callFee}(
            peer,
            _message,
            callFallbackAddress,
            _targetChainId,
            CALL_PAY_FEE_ON_SOURCE_CHAIN
        );
    }

    function _messageFeeInternal(uint256 _targetChainId, uint256 _messageSizeInBytes) private view returns (uint256) {
        (uint256 baseFees, uint256 feesPerByte) = callProxy.srcDefaultFees(_targetChainId);

        return baseFees + feesPerByte * _messageSizeInBytes;
    }

    function _convertVaultDecimals(
        uint256 _vaultType,
        uint256 _amount,
        uint256 _fromChainId,
        uint256 _toChainId
    ) private view returns (uint256) {
        if (_toChainId == _fromChainId) {
            return _amount;
        }

        uint256 fromDecimals = vaultDecimals(_vaultType, _fromChainId);
        uint256 toDecimals = vaultDecimals(_vaultType, _toChainId);

        if (toDecimals == fromDecimals) {
            return _amount;
        }

        return _amount * 10 ** toDecimals / 10 ** fromDecimals;
    }
}