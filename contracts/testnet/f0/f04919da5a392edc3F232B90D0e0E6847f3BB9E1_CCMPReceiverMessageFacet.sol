// TODO: Implement ReentrancyGuard, Pausibility

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../../interfaces/ICCMPGateway.sol";
import "../../interfaces/ICCMPRouterAdaptor.sol";
import "../../interfaces/ICCMPExecutor.sol";
import "../../structures/CrossChainMessage.sol";
import "../../structures/Constants.sol";
import "../../libraries/LibDiamond.sol";

/// @title CCMPReceiveMessageFacet
/// @author [email protected]
/// @notice This facet receives cross chain messages from relayers
contract CCMPReceiverMessageFacet is ICCMPGatewayReceiver, Constants {
    using CCMPMessageUtils for CCMPMessage;

    /// @notice Function called by the relayer on the destination chain to execute the sent message on the exit chain.
    /// @param _message The message to be executed.
    /// @param _verificationData Adaptor specific abi-encoded data required to verify the message's validity on the exit chain. For example, commandId for Axelar.
    /// @param _allowPartialExecution Whether to allow partial execution of the message.
    /// @return status The status of the execution.
    function receiveMessage(
        CCMPMessage calldata _message,
        bytes calldata _verificationData,
        bool _allowPartialExecution
    ) external returns (bool) {
        LibDiamond._enforceIsContractNotPaused();

        LibDiamond.CCMPDiamondStorage storage ds = LibDiamond._diamondStorage();

        // Check Source
        if (_message.sourceGateway != ds.gateways[_message.sourceChainId]) {
            revert InvalidSource(
                _message.sourceChainId,
                _message.sourceGateway
            );
        }

        // Check Destination
        if (
            address(_message.destinationGateway) != address(this) ||
            _message.destinationChainId != block.chainid
        ) {
            revert WrongDestination(
                _message.destinationChainId,
                _message.destinationGateway
            );
        }

        // Check Replay
        if (ds.nonceUsed[_message.nonce]) {
            revert AlreadyExecuted(_message.nonce);
        }
        ds.nonceUsed[_message.nonce] = true;

        // Verify from underlying protocol
        ICCMPRouterAdaptor adaptor = ds.adaptors[_message.routerAdaptor];
        if (adaptor == ICCMPRouterAdaptor(address(0))) {
            revert UnsupportedAdapter(_message.routerAdaptor);
        }

        {
            (bool verified, string memory reason) = adaptor.verifyPayload(
                _message,
                _verificationData
            );
            if (!verified) {
                revert VerificationFailed(reason);
            }
        }

        _executeCCMPMessage(_message, _allowPartialExecution);

        emit CCMPMessageExecuted(
            _message.hash(),
            _message.sender,
            _message.sourceGateway,
            _message.sourceAdaptor,
            _message.sourceChainId,
            _message.destinationGateway,
            _message.destinationChainId,
            _message.nonce,
            _message.routerAdaptor,
            _message.gasFeePaymentArgs,
            _message.payload
        );

        return true;
    }

    /// @notice Handles Execution of the received message from CCMP Gateway on destination chain.
    /// @param _message The message received from CCMP Gateway.
    /// @param _allowPartialExecution Whether to allow partial execution of the message.
    function _executeCCMPMessage(
        CCMPMessage calldata _message,
        bool _allowPartialExecution
    ) internal {
        LibDiamond.CCMPDiamondStorage storage ds = LibDiamond._diamondStorage();

        // Execute CCMP Message Content
        uint256 length = _message.payload.length;

        for (uint256 i = 0; i < length; ) {
            CCMPMessagePayload memory _payload = _message.payload[i];

            (bool success, bytes memory returndata) = ds.ccmpExecutor.execute(
                _payload.to,
                // Append sender and source chain id to the calldata
                // This can be used in the target contract for verification
                abi.encodePacked(
                    _payload._calldata,
                    _message.sourceChainId,
                    _message.sender
                )
            );

            if (!(_allowPartialExecution || success)) {
                revert ExternalCallFailed(i, _payload.to, returndata);
            }

            emit CCMPPayloadExecuted(i, _payload.to, success, returndata);

            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../structures/CrossChainMessage.sol";
import "../interfaces/ICCMPRouterAdaptor.sol";
import "./ICCMPExecutor.sol";

interface ICCMPGatewayBase {
    error UnsupportedAdapter(string adaptorName);
}

interface ICCMPGatewaySender is ICCMPGatewayBase {
    // Errors
    error UnsupportedDestinationChain(uint256 destinationChainId);
    error InvalidPayload(string reason);
    error AmountIsZero();
    error NativeAmountMismatch();
    error NativeTransferFailed(address relayer, bytes data);
    error AmountExceedsBalance(uint256 _amount, uint256 balance);
    error InsufficientNativeAmount(
        uint256 requiredAmount,
        uint256 actualAmount
    );

    // Events
    event CCMPMessageRouted(
        bytes32 indexed hash,
        address indexed sender,
        ICCMPGateway sourceGateway,
        ICCMPRouterAdaptor sourceAdaptor,
        uint256 sourceChainId,
        ICCMPGateway destinationGateway,
        uint256 indexed destinationChainId,
        uint256 nonce,
        string routerAdaptor,
        GasFeePaymentArgs gasFeePaymentArgs,
        CCMPMessagePayload[] payload
    );
    event FeePaid(
        address indexed _tokenAddress,
        uint256 indexed _amount,
        address indexed _relayer
    );

    // Functions
    function sendMessage(
        uint256 _destinationChainId,
        string calldata _adaptorName,
        CCMPMessagePayload[] calldata _payloads,
        GasFeePaymentArgs calldata _gasFeePaymentArgs,
        bytes calldata _routerArgs
    ) external payable returns (bool sent);
}

interface ICCMPGatewayReceiver is ICCMPGatewayBase {
    // Errors
    error InvalidSource(uint256 sourceChainId, ICCMPGateway sourceGateway);
    error WrongDestination(
        uint256 destinationChainId,
        ICCMPGateway destinationGateway
    );
    error AlreadyExecuted(uint256 nonce);
    error VerificationFailed(string reason);
    error ExternalCallFailed(
        uint256 index,
        address contractAddress,
        bytes returndata
    );

    // Events
    event CCMPMessageExecuted(
        bytes32 indexed hash,
        address indexed sender,
        ICCMPGateway sourceGateway,
        ICCMPRouterAdaptor sourceAdaptor,
        uint256 sourceChainId,
        ICCMPGateway destinationGateway,
        uint256 indexed destinationChainId,
        uint256 nonce,
        string routerAdaptor,
        GasFeePaymentArgs gasFeePaymentArgs,
        CCMPMessagePayload[] payload
    );

    event CCMPPayloadExecuted(
        uint256 indexed index,
        address indexed contractAddress,
        bool success,
        bytes returndata
    );

    // Functions
    function receiveMessage(
        CCMPMessage calldata _message,
        bytes calldata _verificationData,
        bool _allowPartialCompletion
    ) external returns (bool received);
}

interface ICCMPConfiguration {
    // Events
    event GatewayUpdated(
        uint256 indexed destinationChainId,
        ICCMPGateway indexed gateway
    );
    event CCMPExecutorUpdated(ICCMPExecutor indexed _ccmpExecutor);
    event AdaptorUpdated(string indexed adaptorName, address indexed adaptor);
    event ContractPaused();
    event ContractUnpaused();
    event PauserUpdated(address indexed pauser);

    // Functions
    function setGateway(uint256 _chainId, ICCMPGateway _gateway) external;

    function setRouterAdaptor(string calldata name, ICCMPRouterAdaptor adaptor)
        external;

    function setCCMPExecutor(ICCMPExecutor _ccmpExecutor) external;

    function setPauser(address _pauser) external;

    function gateway(uint256 _chainId)
        external
        view
        returns (ICCMPGateway gateway_);

    function routerAdator(string calldata name)
        external
        view
        returns (ICCMPRouterAdaptor adaptor);

    function ccmpExecutor() external view returns (ICCMPExecutor executor);

    function transferOwnership(address _newOwner) external;

    function owner() external view returns (address owner_);

    function pauser() external view returns (address pauser_);

    function pause() external;

    function unpause() external;
}

interface ICCMPGateway is
    ICCMPGatewaySender,
    ICCMPGatewayReceiver,
    ICCMPConfiguration
{}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../structures/CrossChainMessage.sol";

interface ICCMPRouterAdaptor {
    function verifyPayload(
        CCMPMessage calldata _ccmpMessage,
        bytes calldata _verificationData
    ) external returns (bool, string memory);

    function routePayload(
        CCMPMessage calldata _ccmpMessage,
        bytes calldata _routeArgs
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface ICCMPExecutor {
    function execute(address _to, bytes calldata _calldata)
        external
        returns (bool success, bytes memory returndata);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ICCMPGateway.sol";
import "../interfaces/ICCMPRouterAdaptor.sol";

// TODO: Optimize Structs for Packing

struct CCMPMessagePayload {
    address to;
    bytes _calldata;
}

struct GasFeePaymentArgs {
    address feeTokenAddress;
    uint256 feeAmount;
    address relayer;
}

/*
    {
        "sender": "0xUSER",
        "sourceGateway": "0xGATEWAY",
        "sourceAdaptor": "0xADAPTOR",
        "sourceChainId: 80001,
        "destinationChainGateway": "0xGATEWAY2",
        "destinationChainId": "1",
        "nonce": 1,
        "routerAdaptor": "wormhole",
        "gasFeePaymentArgs": GasFeePaymentArgs,
        "payload": [
            {
                "to": 0xCONTRACT,
                "_calldata": "0xabc"
            }
        ]
    }
*/
struct CCMPMessage {
    address sender;
    ICCMPGateway sourceGateway;
    ICCMPRouterAdaptor sourceAdaptor;
    uint256 sourceChainId;
    ICCMPGateway destinationGateway;
    uint256 destinationChainId;
    uint256 nonce;
    string routerAdaptor;
    GasFeePaymentArgs gasFeePaymentArgs;
    CCMPMessagePayload[] payload;
}

library CCMPMessageUtils {
    // TODO: Optimize function to cache value somehow
    function hash(CCMPMessage memory message) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    message.sender,
                    address(message.sourceGateway),
                    address(message.sourceAdaptor),
                    message.sourceChainId,
                    address(message.destinationGateway),
                    message.destinationChainId,
                    message.nonce,
                    message.routerAdaptor,
                    message.gasFeePaymentArgs.feeTokenAddress,
                    message.gasFeePaymentArgs.feeAmount,
                    message.gasFeePaymentArgs.relayer,
                    message.payload
                )
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

abstract contract Constants {
    address internal constant NATIVE_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/
import {IDiamond} from "../interfaces/IDiamond.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {ICCMPExecutor} from "../interfaces/ICCMPExecutor.sol";
import {ICCMPRouterAdaptor} from "../interfaces/ICCMPRouterAdaptor.sol";
import {ICCMPGateway} from "../interfaces/ICCMPGateway.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

error NoSelectorsGivenToAdd();
error NotContractOwner(address _user, address _contractOwner);
error NoSelectorsProvidedForFacetForCut(address _facetAddress);
error CannotAddSelectorsToZeroAddress(bytes4[] _selectors);
error NoBytecodeAtAddress(address _contractAddress, string _message);
error IncorrectFacetCutAction(uint8 _action);
error CannotAddFunctionToDiamondThatAlreadyExists(bytes4 _selector);
error CannotReplaceFunctionsFromFacetWithZeroAddress(bytes4[] _selectors);
error CannotReplaceImmutableFunction(bytes4 _selector);
error CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(
    bytes4 _selector
);
error CannotReplaceFunctionThatDoesNotExists(bytes4 _selector);
error RemoveFacetAddressMustBeZeroAddress(address _facetAddress);
error CannotRemoveFunctionThatDoesNotExist(bytes4 _selector);
error CannotRemoveImmutableFunction(bytes4 _selector);
error InitializationFunctionReverted(
    address _initializationContractAddress,
    bytes _calldata
);
error ContractIsPaused();
error NotContractPauser(address _user, address _contractPauser);

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndSelectorPosition {
        address facetAddress;
        uint16 selectorPosition;
    }

    struct CCMPDiamondStorage {
        // function selector => facet address and selector position in selectors array
        mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
        bytes4[] selectors;
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
        // CCMP Executor
        ICCMPExecutor ccmpExecutor;
        // Adaptor Name => Adaptor Address
        mapping(string => ICCMPRouterAdaptor) adaptors;
        // Global Nonce (when used, it's prefixe with block.chainid)
        uint128 nextNonce;
        // Destination Chain ID => Gateway Address.
        // This is set in the outbound message and is verified on the destination chain
        mapping(uint256 => ICCMPGateway) gateways;
        // Whether a message with nonce N has been executed or not
        mapping(uint256 => bool) nonceUsed;
        // Contract pausibility
        address pauser;
        bool paused;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event DiamondCut(
        IDiamondCut.FacetCut[] _diamondCut,
        address _init,
        bytes _calldata
    );

    function _diamondStorage()
        internal
        pure
        returns (CCMPDiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    // Ownable
    function _setContractOwner(address _newOwner) internal {
        CCMPDiamondStorage storage ds = _diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function _contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = _diamondStorage().contractOwner;
    }

    function _enforceIsContractOwner() internal view {
        if (msg.sender != _diamondStorage().contractOwner) {
            revert NotContractOwner(
                msg.sender,
                _diamondStorage().contractOwner
            );
        }
    }

    // Pauser
    function _setContractPauser(address _newPauser) internal {
        _diamondStorage().pauser = _newPauser;
    }

    function _contractPauser() internal view returns (address pauser_) {
        pauser_ = _diamondStorage().pauser;
    }

    function _enforceIsContractNotPaused() internal view {
        if (_diamondStorage().paused) {
            revert ContractIsPaused();
        }
    }

    function _enforceIsContractPauser() internal view {
        if (msg.sender != _diamondStorage().pauser) {
            revert NotContractPauser(msg.sender, _diamondStorage().pauser);
        }
    }

    function _pauseContract() internal {
        _diamondStorage().paused = true;
    }

    function _unpauseContract() internal {
        _diamondStorage().paused = false;
    }

    // Internal function version of diamondCut
    function _diamondCut(
        IDiamondCut.FacetCut[] memory __diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (
            uint256 facetIndex;
            facetIndex < __diamondCut.length;
            facetIndex++
        ) {
            bytes4[] memory functionSelectors = __diamondCut[facetIndex]
                .functionSelectors;
            address facetAddress = __diamondCut[facetIndex].facetAddress;
            if (functionSelectors.length == 0) {
                revert NoSelectorsProvidedForFacetForCut(facetAddress);
            }
            IDiamondCut.FacetCutAction action = __diamondCut[facetIndex].action;
            if (action == IDiamond.FacetCutAction.Add) {
                _addFunctions(facetAddress, functionSelectors);
            } else if (action == IDiamond.FacetCutAction.Replace) {
                _replaceFunctions(facetAddress, functionSelectors);
            } else if (action == IDiamond.FacetCutAction.Remove) {
                _removeFunctions(facetAddress, functionSelectors);
            } else {
                revert IncorrectFacetCutAction(uint8(action));
            }
        }
        emit DiamondCut(__diamondCut, _init, _calldata);
        _initializeDiamondCut(_init, _calldata);
    }

    function _addFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        if (_facetAddress == address(0)) {
            revert CannotAddSelectorsToZeroAddress(_functionSelectors);
        }
        CCMPDiamondStorage storage ds = _diamondStorage();
        uint16 selectorCount = uint16(ds.selectors.length);
        _enforceHasContractCode(
            _facetAddress,
            "LibDiamondCut: Add facet has no code"
        );
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .facetAddressAndSelectorPosition[selector]
                .facetAddress;
            if (oldFacetAddress != address(0)) {
                revert CannotAddFunctionToDiamondThatAlreadyExists(selector);
            }
            ds.facetAddressAndSelectorPosition[
                    selector
                ] = FacetAddressAndSelectorPosition(
                _facetAddress,
                selectorCount
            );
            ds.selectors.push(selector);
            selectorCount++;
        }
    }

    function _replaceFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        CCMPDiamondStorage storage ds = _diamondStorage();
        if (_facetAddress == address(0)) {
            revert CannotReplaceFunctionsFromFacetWithZeroAddress(
                _functionSelectors
            );
        }
        _enforceHasContractCode(
            _facetAddress,
            "LibDiamondCut: Replace facet has no code"
        );
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .facetAddressAndSelectorPosition[selector]
                .facetAddress;
            // can't replace immutable functions -- functions defined directly in the diamond in this case
            if (oldFacetAddress == address(this)) {
                revert CannotReplaceImmutableFunction(selector);
            }
            if (oldFacetAddress == _facetAddress) {
                revert CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(
                    selector
                );
            }
            if (oldFacetAddress == address(0)) {
                revert CannotReplaceFunctionThatDoesNotExists(selector);
            }
            // replace old facet address
            ds
                .facetAddressAndSelectorPosition[selector]
                .facetAddress = _facetAddress;
        }
    }

    function _removeFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        CCMPDiamondStorage storage ds = _diamondStorage();
        uint256 selectorCount = ds.selectors.length;
        if (_facetAddress != address(0)) {
            revert RemoveFacetAddressMustBeZeroAddress(_facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            FacetAddressAndSelectorPosition
                memory oldFacetAddressAndSelectorPosition = ds
                    .facetAddressAndSelectorPosition[selector];
            if (oldFacetAddressAndSelectorPosition.facetAddress == address(0)) {
                revert CannotRemoveFunctionThatDoesNotExist(selector);
            }

            // can't remove immutable functions -- functions defined directly in the diamond
            if (
                oldFacetAddressAndSelectorPosition.facetAddress == address(this)
            ) {
                revert CannotRemoveImmutableFunction(selector);
            }
            // replace selector with last selector
            selectorCount--;
            if (
                oldFacetAddressAndSelectorPosition.selectorPosition !=
                selectorCount
            ) {
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[
                    oldFacetAddressAndSelectorPosition.selectorPosition
                ] = lastSelector;
                ds
                    .facetAddressAndSelectorPosition[lastSelector]
                    .selectorPosition = oldFacetAddressAndSelectorPosition
                    .selectorPosition;
            }
            // delete last selector
            ds.selectors.pop();
            delete ds.facetAddressAndSelectorPosition[selector];
        }
    }

    function _initializeDiamondCut(address _init, bytes memory _calldata)
        internal
    {
        if (_init == address(0)) {
            return;
        }
        _enforceHasContractCode(
            _init,
            "LibDiamondCut: _init address has no code"
        );
        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up error
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error)
                    revert(add(32, error), returndata_size)
                }
            } else {
                revert InitializationFunctionReverted(_init, _calldata);
            }
        }
    }

    function _enforceHasContractCode(
        address _contract,
        string memory _errorMessage
    ) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert NoBytecodeAtAddress(_contract, _errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDiamond {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

import {IDiamond} from "./IDiamond.sol";

interface IDiamondCut is IDiamond {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;
}