// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../../interfaces/ICCMPGateway.sol";
import "../../interfaces/ICCMPRouterAdaptor.sol";
import "../../interfaces/ICCMPExecutor.sol";
import "../../structures/CrossChainMessage.sol";
import "../../structures/Constants.sol";
import "../../libraries/LibDiamond.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title CCMPSendMessageFacet
/// @author [email protected]
/// @notice This facet is used to send cross chain messages
contract CCMPSendMessageFacet is ICCMPGatewaySender, Constants {
    using CCMPMessageUtils for CCMPMessage;
    using SafeERC20 for IERC20;

    /// @param _destinationChainId The chain id of the destination chain.
    /// @param _adaptorName The name of the router adaptor to use. Currently "axelar", "wormhole" and "abacus" are supported.
    /// @param _gasFeePaymentArgs Contains details for the fee quoted by the relayer.
    /// @param _routerArgs Contains abi encoded router specific arguments. For ex, CONSISTENCY_LEVEL when sending message via wormhole.
    /// @return sent The hash of the message sent.
    function sendMessage(
        uint256 _destinationChainId,
        string calldata _adaptorName,
        CCMPMessagePayload[] calldata _payloads,
        GasFeePaymentArgs calldata _gasFeePaymentArgs,
        bytes calldata _routerArgs
    ) external payable returns (bool) {
        LibDiamond._enforceIsContractNotPaused();

        LibDiamond.CCMPDiamondStorage storage ds = LibDiamond._diamondStorage();

        // Check Adaptor
        ICCMPRouterAdaptor adaptor = ds.adaptors[_adaptorName];
        if (adaptor == ICCMPRouterAdaptor(address(0))) {
            revert UnsupportedAdapter(_adaptorName);
        }

        // Check Chain ID
        if (_destinationChainId == block.chainid) {
            revert UnsupportedDestinationChain(_destinationChainId);
        }
        ICCMPGateway destinationGateway = ds.gateways[_destinationChainId];
        if (destinationGateway == ICCMPGateway(address(0))) {
            revert UnsupportedDestinationChain(_destinationChainId);
        }

        // Check Payload
        if (_payloads.length == 0) {
            revert InvalidPayload("No payload");
        }

        CCMPMessage memory message = CCMPMessage({
            sender: msg.sender,
            sourceGateway: ICCMPGateway(address(this)),
            sourceAdaptor: adaptor,
            sourceChainId: block.chainid,
            destinationGateway: destinationGateway,
            destinationChainId: _destinationChainId,
            // Global nonce, chainid is included to prevent coliision with messages from different chain but same index
            nonce: (block.chainid << 128) + ds.nextNonce++,
            routerAdaptor: _adaptorName,
            gasFeePaymentArgs: _gasFeePaymentArgs,
            payload: _payloads
        });

        _handleFee(message);

        adaptor.routePayload(message, _routerArgs);

        emit CCMPMessageRouted(
            message.hash(),
            message.sender,
            message.sourceGateway,
            message.sourceAdaptor,
            message.sourceChainId,
            message.destinationGateway,
            message.destinationChainId,
            message.nonce,
            message.routerAdaptor,
            message.gasFeePaymentArgs,
            message.payload
        );

        return true;
    }

    /// @notice Handles fee payment
    function _handleFee(CCMPMessage memory _message) internal {
        uint256 feeAmount = _message.gasFeePaymentArgs.feeAmount;
        address relayer = _message.gasFeePaymentArgs.relayer;
        address tokenAddress = _message.gasFeePaymentArgs.feeTokenAddress;

        if (feeAmount >= 0) {
            if (_message.gasFeePaymentArgs.feeTokenAddress == NATIVE_ADDRESS) {
                if (msg.value != feeAmount) {
                    revert NativeAmountMismatch();
                }
                (bool success, bytes memory returndata) = relayer.call{
                    value: msg.value
                }("");
                if (!success) {
                    revert NativeTransferFailed(relayer, returndata);
                }
            } else {
                IERC20(_message.gasFeePaymentArgs.feeTokenAddress)
                    .safeTransferFrom(
                        _message.sender,
                        relayer,
                        _message.gasFeePaymentArgs.feeAmount
                    );
            }
        }

        emit FeePaid(tokenAddress, feeAmount, relayer);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
}