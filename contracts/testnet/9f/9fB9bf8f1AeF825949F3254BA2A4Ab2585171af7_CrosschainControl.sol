// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interface/CrosschainFunctionCallInterface.sol";
import "./common/CbcDecVer.sol";
import "./interface/NonAtomicHiddenAuthParameters.sol";
import "../common/ResponseProcessUtil.sol";
import "../messaging/eventrelay/EventRelayVerifier.sol";

contract CrosschainControl is
    CrosschainFunctionCallInterface,
    CbcDecVer,
    NonAtomicHiddenAuthParameters,
    ResponseProcessUtil,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    // 	0x77dab611
    bytes32 internal constant CROSS_CALL_EVENT_SIGNATURE =
    keccak256("CrossCall(bytes32,uint256,address,uint256,address,bytes)");

    // How old events can be before they are not accepted.
    // Also used as a time after which crosschain transaction ids can be purged from the
    // replayProvention map, thus reducing the cost of the crosschain transaction.
    // Measured in seconds.
    uint256 public timeHorizon;

    // Used to prevent replay attacks in transaction.
    // Mapping of txId to transaction expiry time.
    mapping(bytes32 => uint256) public replayPrevention;

    uint256 public myBlockchainId;

    // Use to determine different transactions but have same calldata, block timestamp
    uint256 txIndex;

    /**
   * Crosschain Transaction event.
   *
   * @param _txId Crosschain Transaction id.
   * @param _timestamp The time when the event was generated.
   * @param _caller Contract or EOA that submitted the crosschain call on the source blockchain.
   * @param _destBcId Destination blockchain Id.
   * @param _destContract Contract to be called on the destination blockchain.
   * @param _destFunctionCall The function selector and parameters in ABI packed format.
   */
    event CrossCall(
        bytes32 _txId,
        uint256 _timestamp,
        address _caller,
        uint256 _destBcId,
        address _destContract,
        bytes _destFunctionCall
    );

    event CallFailure(string _revertReason);

    /**
     * @param _myBlockchainId Blockchain identifier of this blockchain.
     * @param _timeHorizon How old crosschain events can be before they are
     *     deemed to be invalid. Measured in seconds.
     */
    function initialize(
        uint256 _myBlockchainId,
        uint256 _timeHorizon
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();

        myBlockchainId = _myBlockchainId;
        timeHorizon = _timeHorizon;
    }

    function crossBlockchainCall(
        // NOTE: can keep using _destBcId and _destContract to determine which blockchain is calling
        uint256 _destBcId,
        address _destContract,
        bytes calldata _destData
    ) external override {
        txIndex++;
        bytes32 txId = keccak256(
            abi.encodePacked(
                block.timestamp,
                myBlockchainId,
                _destBcId,
                _destContract,
                _destData,
                txIndex
            )
        );
        emit CrossCall(
            txId,
            block.timestamp,
            msg.sender,
            _destBcId,
            _destContract,
            _destData
        );
    }

    // For server
    function crossCallHandler(
        uint256 _sourceBcId,
        address _cbcAddress,
        bytes calldata _eventData,
        bytes calldata _signature
    ) public {
        revert("not available yet");
//        decodeAndVerifyEvent(
//            _sourceBcId,
//            _cbcAddress,
//            CROSS_CALL_EVENT_SIGNATURE,
//            _eventData,
//            _signature
//        );
//
//        // Decode _eventData
//        // Recall that the cross call event is:
//        // CrossCall(bytes32 _txId, uint256 _timestamp, address _caller,
//        //           uint256 _destBcId, address _destContract, bytes _destFunctionCall)
//        bytes32 txId;
//        uint256 timestamp;
//        address caller;
//        uint256 destBcId;
//        address destContract;
//        bytes memory functionCall;
//        (txId, timestamp, caller, destBcId, destContract, functionCall) = abi
//        .decode(
//            _eventData,
//            (bytes32, uint256, address, uint256, address, bytes)
//        );
//
//        require(replayPrevention[txId] == 0, "Transaction already exists");
//
//        require(
//            timestamp < block.timestamp,
//            "Event timestamp is in the future"
//        );
//        require(timestamp + timeHorizon > block.timestamp, "Event is too old");
//        replayPrevention[txId] = timestamp;
//
//        require(
//            destBcId == myBlockchainId,
//            "Incorrect destination blockchain id"
//        );
//
//        // Add authentication information to the function call.
//        bytes memory functionCallWithAuth = encodeNonAtomicAuthParams(
//            functionCall,
//            _sourceBcId,
//            caller
//        );
//
//        bool isSuccess;
//        bytes memory returnValueEncoded;
//        (isSuccess, returnValueEncoded) = destContract.call(
//            functionCallWithAuth
//        );
//
//        if (!isSuccess) {
//            emit CallFailure(getRevertMsg(returnValueEncoded));
//        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

/*
 * Copyright 2021 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

/**
 * Crosschain Function Call Interface allows applications to call functions on other blockchains
 * and to get information about the currently executing function call.
 *
 */
interface CrosschainFunctionCallInterface {
    /**
     * Call a function on another blockchain. All function call implementations must implement
     * this function.
     *
     * @param _bcId Blockchain identifier of blockchain to be called.
     * @param _contract The address of the contract to be called.
     * @param _functionCallData The function selector and parameter data encoded using ABI encoding rules.
     */
    function crossBlockchainCall(
        uint256 _bcId,
        address _contract,
        bytes calldata _functionCallData
    ) external;
}

/*
 * Copyright 2021 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../../messaging/interface/ILightClient.sol";
import "../../common/System.sol";

abstract contract CbcDecVer is OwnableUpgradeable{
    // Address of verifier contract to be used for a certain blockchain id.
    mapping(uint256 => ILightClient) private verifiers;

    // Address of Crosschain Control Contract on another blockchain.
    mapping(uint256 => address) internal remoteCrosschainControlContracts;

    function addVerifier(uint256 _blockchainId, address _verifier)
        external
        onlyOwner
    {
        require(_blockchainId != 0, "Invalid blockchain id");
        require(_verifier != address(0), "Invalid verifier address");
        verifiers[_blockchainId] = ILightClient(_verifier);
    }

    function addRemoteCrosschainControl(uint256 _blockchainId, address _cbc)
        external
        onlyOwner
    {
        remoteCrosschainControlContracts[_blockchainId] = _cbc;
    }

    /**
     * Decode signatures or proofs and use them to verify an event.
     *
     * @param _blockchainId The blockchain that the event was emitted on.
     * @param _cbcAddress The Crosschain Control Contract that emitted the event.
     * @param _eventFunctionSignature The function selector of the event that emitted the event.
     * @param _eventData The emitted event data.
     * @param _signature The signature of proof across the ABI encoded combination of:
     *            _blockchainId, _cbcAddress, _eventFunctionSignature, and _signature.
     */
    function decodeAndVerifyEvent(
        uint256 _blockchainId,
        address _cbcAddress,
        bytes32 _eventFunctionSignature,
        bytes calldata _eventData,
        bytes calldata _signature
    ) internal view {
        // This indirectly checks that _blockchainId is an authorised source blockchain
        // by checking that there is a verifier for the blockchain.
        // TODO implment when deploy production
//        ILightClient verifier = verifiers[_blockchainId];
//        require(
//            address(verifier) != address(0),
//            "No registered verifier for blockchain"
//        );
//
//        require(
//            _cbcAddress == remoteCrosschainControlContracts[_blockchainId],
//            "Data not emitted by approved contract"
//        );
//
//        bytes memory encodedEvent = abi.encodePacked(
//            _blockchainId,
//            _cbcAddress,
//            _eventFunctionSignature,
//            _eventData
//        );
//        verifier.decodeAndVerifyEvent(
//            _blockchainId,
//            _eventFunctionSignature,
//            encodedEvent,
//            _signature
//        );
    }
}

/*
 * Copyright 2021 ConsenSys AG.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

abstract contract NonAtomicHiddenAuthParameters {
    /**
     * Add authentication parameters to the end of an existing function call.
     *
     * @param _functionCall       Function selector and an arbitrary list of parameters.
     * @param _sourceBlockchainId Blockchain identifier of the blockchain that is calling the function.
     * @param _sourceContract     The address of the contract that is calling the function.
     */
    function encodeNonAtomicAuthParams(
        bytes memory _functionCall,
        uint256 _sourceBlockchainId,
        address _sourceContract
    ) internal pure returns (bytes memory) {
        return
            bytes.concat(
                _functionCall,
                abi.encodePacked(_sourceBlockchainId, _sourceContract)
            );
    }

    /**
     * Extract authentication values from the end of the call data. The parameters are expected to have been
     * added to the end of the function call using encodeNonAtomicAuthParams.
     *
     * @return _sourceBlockchainId Blockchain identifier of the blockchain that is calling the function.
     * @return _sourceContract     The address of the contract that is calling the function.
     */
    function decodeNonAtomicAuthParams()
        internal
        pure
        returns (uint256 _sourceBlockchainId, address _sourceContract)
    {
        bytes calldata allParams = msg.data;
        uint256 len = allParams.length;

        assembly {
            calldatacopy(0x0, sub(len, 52), 32)
            _sourceBlockchainId := mload(0)
            calldatacopy(12, sub(len, 20), 20)
            _sourceContract := mload(0)
        }
    }
}

/*
 * Copyright 2020 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.7.1;

import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract ResponseProcessUtil {
    function getRevertMsg(bytes memory _returnData)
        internal
        pure
        returns (string memory)
    {
        // A string will be 4 bytes for the function selector + 32 bytes for string length +
        // 32 bytes for first part of string. Hence, if the length is less than 68, then
        // this is a panic.
        // Another way of doing this would be to look for the function selectors for revert:
        // "0x08c379a0" = keccak256("Error(string)"
        // or panic:
        // "0x4e487b71" = keccak256("Panic(uint256)"
        if (_returnData.length < 36) {
            return
                string(
                    abi.encodePacked(
                        "Revert for unknown error. Error length: ",
                        Strings.toString(_returnData.length)
                    )
                );
        }
        bool isPanic = _returnData.length < 68;

        assembly {
            // Remove the function selector / sighash.
            _returnData := add(_returnData, 0x04)
        }
        if (isPanic) {
            uint256 errorCode = abi.decode(_returnData, (uint256));
            return
                string(
                    abi.encodePacked("Panic: ", Strings.toString(errorCode))
                );
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }
}

/*
 * Copyright 2021 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

import "../interface/ILightClient.sol";
import "../../common/BytesUtil.sol";
import "../common/MessagingRegistrar.sol";
import "../../functioncall/CrosschainControl.sol";

// NOTE: not used yet
contract EventRelayVerifier is ILightClient, BytesUtil {
    MessagingRegistrar registrar;
    CrosschainControl functionCall;

    // 	0x77dab611
    bytes32 internal constant CROSS_CALL_EVENT_SIGNATURE =
    keccak256("CrossCall(bytes32,uint256,address,uint256,address,bytes)");

    struct SignedEvents {
        // The event to be actioned.
        bytes encodedEvent;
        // Replay protection is the responsibility of the function call layer.
        // This variable ensures the signers who submit the event are recorded, even
        // if it is after the event is actioned.
        bool actioned;
        // List of which signers voted.
        address[] whoVoted;
        mapping(address => bool) whoVotedMap;
    }
    mapping(bytes32 => SignedEvents) private signedEvents;

    constructor(address _registrar, address _functionCall) {
        registrar = MessagingRegistrar(_registrar);
        functionCall = CrosschainControl(_functionCall);
    }

    uint256 constant LEN_OF_LEN = 4;
    uint256 constant LEN_OF_SIG = 20 + 32 + 32 + 1;

    /**
     * For this implementation, the signatures have already been checked in the
     * relayEvent function below.
     */
    function decodeAndVerifyEvent(
        uint256 _blockchainId,
        bytes32, /* _eventSig */
        bytes calldata _encodedEvent,
        bytes calldata /* _signature */
    ) external view override {
        bytes32 eventDigest = keccak256(_encodedEvent);
        uint256 threshold = registrar.getSigningThreshold(_blockchainId);
        require(
            signedEvents[eventDigest].whoVoted.length >= threshold,
            "Not enough signers"
        );
    }

    /**
     * Relay event from one or more relayers.
     *
     * Note that replay protection and time outs are handled by the function call layer.
     */
    // TODO: move step 1 to light client
    function relayEvent(
        uint256 _sourceBlockchainId,
        address _sourceCbcAddress,
        bytes calldata _eventData,
        bytes calldata _signature
    ) external {
        // Step 1: Check the signatures of signers.
        address[] memory signers;
        bytes32[] memory sigRs;
        bytes32[] memory sigSs;
        uint8[] memory sigVs;

        uint32 len = BytesUtil.bytesToUint32(_signature, 0);
        {
            require(
                _signature.length == LEN_OF_LEN + len * LEN_OF_SIG,
                "Signature incorrect length"
            );

            signers = new address[](len);
            sigRs = new bytes32[](len);
            sigSs = new bytes32[](len);
            sigVs = new uint8[](len);

            uint256 offset = LEN_OF_LEN;
            for (uint256 i = 0; i < len; i++) {
                signers[i] = BytesUtil.bytesToAddress2(_signature, offset);
                offset += 20;
                sigRs[i] = BytesUtil.bytesToBytes32(_signature, offset);
                offset += 32;
                sigSs[i] = BytesUtil.bytesToBytes32(_signature, offset);
                offset += 32;
                sigVs[i] = BytesUtil.bytesToUint8(_signature, offset);
                offset += 1;
            }
        }

        bytes memory encodedEvent = abi.encodePacked(
            _sourceBlockchainId,
            _sourceCbcAddress,
            CROSS_CALL_EVENT_SIGNATURE,
            _eventData
        );

        registrar.verify(
            _sourceBlockchainId,
            signers,
            sigRs,
            sigSs,
            sigVs,
            encodedEvent
        );

        // Step 2: Record who signed the event.
        bytes32 eventDigest = keccak256(encodedEvent);

        for (uint256 i = 0; i < len; i++) {
            if (signedEvents[eventDigest].whoVotedMap[signers[i]]) {
                // Ignore relayers inadvertently signing a second time.
                continue;
            }
            signedEvents[eventDigest].whoVotedMap[signers[i]] = true;
            signedEvents[eventDigest].whoVoted.push(signers[i]);
        }

        // Action the event if enough relayers have signed.
        if (signedEvents[eventDigest].actioned) {
            // There is no more to do. The signers have been recorded. This could
            // be important for determining who to pay.
            return;
        }
        uint256 threshold = registrar.getSigningThreshold(_sourceBlockchainId);
        if (signedEvents[eventDigest].whoVoted.length >= threshold) {
            signedEvents[eventDigest].actioned = true;
            // NOTE: In the call below, the _signature parameter isn't used. Could be cheaper to pass bytes("")
            functionCall.crossCallHandler(
                _sourceBlockchainId,
                _sourceCbcAddress,
                _eventData,
                _signature
            );
        }
    }
}

// SPDX-License-Identifier: MIT

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

pragma solidity ^0.8.0;

interface ILightClient {
    /**
     * Decode and verify event information. Use require to fail the transaction
     * if any of the information is invalid.
     *
     * @param _blockchainId The blockchain that emitted the event. This could be
     *    used to determine which sets of signing keys are valid.
     * @param _eventSig The event function selector. This will be for a Start event,
     *    a Segment event, or a Root event. Not all implementations will need to
     *    use this value. Others may need this to allow then to find the event in a
     *    transaction receipt.
     * @param _payload The abi.encodePacked of the blockchain id, the Crosschain
     *    Control contract's address, the event function selector, and the event data.
     * @param _signature Signatures or proof information that an implementation can
     *    use to check that _signedEventInfo is valid.
     */
    function decodeAndVerifyEvent(
        uint256 _blockchainId,
        bytes32 _eventSig,
        bytes calldata _payload,
        bytes calldata _signature
    ) external view;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

abstract contract System {

    bool public alreadyInit;

    // TODO CHANGE GENESIS ADDRESS
    address public constant POSITION_ADMIN_ADDR = 0x0000000000000000000000000000000000001001;
    address public constant GOVERNANCE_HUB_ADDR = 0x0000000000000000000000000000000000001002;
    address public constant SYSTEM_REWARD_ADDR = 0x0000000000000000000000000000000000001003;
    address public constant RELAYER_HUB_ADDR = 0x0000000000000000000000000000000000001004;
    address public constant RELAYER_INCENTIVE_ADDR = 0x0000000000000000000000000000000000001005;

    // NOTE: only init those two address on Posi chain
    address public constant TOKEN_HUB_ADDR = 0x0000000000000000000000000000000000001006;
    address public constant CROSS_CHAIN_ADDR = 0x0000000000000000000000000000000000001007;

    modifier onlyPositionAdmin() {
        require(
            msg.sender == POSITION_ADMIN_ADDR,
            "Only Position Admin Address"
        );
        _;
    }

    modifier onlyGovernmentHub() {
        require(
            msg.sender == GOVERNANCE_HUB_ADDR,
            "Only Governance Hub Contract"
        );
        _;
    }

    modifier onlySystemReward() {
        require(
            msg.sender == SYSTEM_REWARD_ADDR,
            "Only System Reward Contract"
        );
        _;
    }

    modifier onlyRelayerHub() {
        require(
            msg.sender == RELAYER_HUB_ADDR,
            "Only Relayer Hub Contract"
        );
        _;
    }

    modifier onlyRelayerIncentive() {
        require(
            msg.sender == RELAYER_INCENTIVE_ADDR,
            "Only Relayer Incentive Contract"
        );
        _;
    }

    modifier onlyTokenHub() {
        require(
            msg.sender == TOKEN_HUB_ADDR,
            "Only Token Hub Contract"
        );
        _;
    }

    modifier onlyCrosschain() {
        require(
            msg.sender == CROSS_CHAIN_ADDR,
            "Only Cross-chain Contract"
        );
        _;
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

/*
 * Copyright 2020 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.7.1;

abstract contract BytesUtil {
    // Based on stack overflow here: https://ethereum.stackexchange.com/questions/15350/how-to-convert-an-bytes-to-address-in-solidity
    function bytesToAddress1(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(_b, add(32, _startOffset)))
        }
    }

    function bytesToAddress2(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(_b, add(20, _startOffset)))
        }
    }

    function bytesToAddress(bytes memory _b)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(_b, 20))
        }
    }

    // TODO find something faster than this.
    // From stack overflow here: https://ethereum.stackexchange.com/questions/7702/how-to-convert-byte-array-to-bytes32-in-solidity
    function bytesToBytes32CallData(bytes calldata b, uint256 offset)
        internal
        pure
        returns (bytes32)
    {
        bytes32 out;

        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function bytesToBytes32(bytes memory b, uint256 offset)
        internal
        pure
        returns (bytes32)
    {
        bytes32 out;

        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    // Starting point was this, but with some modifications.
    // https://ethereum.stackexchange.com/questions/49185/solidity-conversion-bytes-memory-to-uint
    function bytesToUint256(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (uint256)
    {
        require(
            _b.length >= _startOffset + 32,
            "slicing out of range (uint256)"
        );
        uint256 x;
        assembly {
            x := mload(add(_b, add(32, _startOffset)))
        }
        return x;
    }

    function bytesToUint64(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (uint64)
    {
        require(_b.length >= _startOffset + 8, "slicing out of range (uint64)");
        uint256 x;
        assembly {
            x := mload(add(_b, add(8, _startOffset)))
        }
        return uint64(x);
    }

    function bytesToUint32(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (uint32)
    {
        require(_b.length >= _startOffset + 4, "slicing out of range (uint32)");
        uint256 x;
        assembly {
            x := mload(add(_b, add(4, _startOffset)))
        }
        return uint32(x);
    }

    function bytesToUint16(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (uint16)
    {
        require(_b.length >= _startOffset + 2, "slicing out of range (uint16)");
        uint256 x;
        assembly {
            x := mload(add(_b, add(2, _startOffset)))
        }
        return uint16(x);
    }

    function bytesToUint8(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (uint8)
    {
        require(_b.length >= _startOffset + 1, "slicing out of range (uint8)");
        uint256 x;
        assembly {
            x := mload(add(_b, add(1, _startOffset)))
        }
        return uint8(x);
    }

    // From https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol
    function sliceAsm(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_bytes.length >= (_start + _length), "Read out of bounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    // https://ethereum.stackexchange.com/questions/78559/how-can-i-slice-bytes-strings-and-arrays-in-solidity
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        bytes memory a = new bytes(_length);
        for (uint256 i = 0; i < _length; i++) {
            a[i] = _bytes[_start + i];
        }
        return a;
    }

    function slice(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (bytes memory)
    {
        return slice(_bytes, _start, (_bytes.length - _start));
    }

    function compare(bytes memory _a, bytes memory _b)
        internal
        pure
        returns (bool)
    {
        if (_a.length != _b.length) {
            return false;
        } else {
            return keccak256(_a) == keccak256(_b);
        }
    }
}

/*
 * Copyright 2021 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

import "../../common/EcdsaSignatureVerification.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// NOTE: not used yet
contract MessagingRegistrar is EcdsaSignatureVerification, Ownable {
    struct BlockchainRecord {
        uint256 signingThreshold;
        uint256 numSigners;
        mapping(address => bool) signers;
    }
    mapping(uint256 => BlockchainRecord) private blockchains;

    function addSigner(uint256 _bcId, address _signer) external onlyOwner {
        require(
            blockchains[_bcId].signingThreshold != 0,
            "Can not add signer for blockchain with zero threshold"
        );
        internalAddSigner(_bcId, _signer);
        blockchains[_bcId].numSigners++;
    }

    function addSignerSetThreshold(
        uint256 _bcId,
        address _signer,
        uint256 _newSigningThreshold
    ) external onlyOwner {
        internalAddSigner(_bcId, _signer);
        uint256 newNumSigners = blockchains[_bcId].numSigners + 1;
        blockchains[_bcId].numSigners = newNumSigners;
        internalSetThreshold(_bcId, newNumSigners, _newSigningThreshold);
    }

    function addSignersSetThreshold(
        uint256 _bcId,
        address[] calldata _signers,
        uint256 _newSigningThreshold
    ) external onlyOwner {
        for (uint256 i = 0; i < _signers.length; i++) {
            internalAddSigner(_bcId, _signers[i]);
        }
        uint256 newNumSigners = blockchains[_bcId].numSigners + _signers.length;
        blockchains[_bcId].numSigners = newNumSigners;
        internalSetThreshold(_bcId, newNumSigners, _newSigningThreshold);
    }

    function removeSigner(uint256 _bcId, address _signer) external onlyOwner {
        internalRemoveSigner(_bcId, _signer);
        uint256 newNumSigners = blockchains[_bcId].numSigners - 1;
        require(
            newNumSigners >= blockchains[_bcId].signingThreshold,
            "Proposed new number of signers is less than threshold"
        );
        blockchains[_bcId].numSigners = newNumSigners;
    }

    function removeSignerSetThreshold(
        uint256 _bcId,
        address _signer,
        uint256 _newSigningThreshold
    ) external onlyOwner {
        internalRemoveSigner(_bcId, _signer);
        uint256 newNumSigners = blockchains[_bcId].numSigners - 1;
        blockchains[_bcId].numSigners = newNumSigners;
        internalSetThreshold(_bcId, newNumSigners, _newSigningThreshold);
    }

    function setThreshold(uint256 _bcId, uint256 _newSigningThreshold)
        external
        onlyOwner
    {
        internalSetThreshold(
            _bcId,
            blockchains[_bcId].numSigners,
            _newSigningThreshold
        );
    }

    function verifyAndCheckThreshold(
        uint256 _blockchainId,
        address[] calldata _signers,
        bytes32[] calldata _sigR,
        bytes32[] calldata _sigS,
        uint8[] calldata _sigV,
        bytes calldata _plainText
    ) external view returns (bool) {
        checkThreshold(_blockchainId, _signers);
        return verify(_blockchainId, _signers, _sigR, _sigS, _sigV, _plainText);
    }

    function verify(
        uint256 _blockchainId,
        address[] calldata _signers,
        bytes32[] calldata _sigR,
        bytes32[] calldata _sigS,
        uint8[] calldata _sigV,
        bytes calldata _plainText
    ) public view returns (bool) {
        uint256 signersLength = _signers.length;
        require(signersLength == _sigR.length, "sigR length mismatch");
        require(signersLength == _sigS.length, "sigS length mismatch");
        require(signersLength == _sigV.length, "sigV length mismatch");

        for (uint256 i = 0; i < signersLength; i++) {
            // Check that signer is a signer for this blockchain
            require(
                blockchains[_blockchainId].signers[_signers[i]],
                "Signer not signer for this blockchain"
            );
            // Verify the signature
            require(
                verifySigComponents(
                    _signers[i],
                    _plainText,
                    _sigR[i],
                    _sigS[i],
                    _sigV[i]
                ),
                "Signature did not verify"
            );
        }
        return true;
    }

    function checkThreshold(uint256 _blockchainId, address[] calldata _signers)
        public
        view
        returns (bool)
    {
        uint256 signersLength = _signers.length;
        require(
            signersLength >= blockchains[_blockchainId].signingThreshold,
            "Not enough signers"
        );
        return true;
    }

    function getSigningThreshold(uint256 _blockchainId)
        external
        view
        returns (uint256)
    {
        return blockchains[_blockchainId].signingThreshold;
    }

    function numSigners(uint256 _blockchainId) external view returns (uint256) {
        return blockchains[_blockchainId].numSigners;
    }

    function isSigner(uint256 _blockchainId, address _mightBeSigner)
        external
        view
        returns (bool)
    {
        return blockchains[_blockchainId].signers[_mightBeSigner];
    }

    /************************************* PRIVATE FUNCTIONS BELOW HERE *************************************/
    /************************************* PRIVATE FUNCTIONS BELOW HERE *************************************/
    /************************************* PRIVATE FUNCTIONS BELOW HERE *************************************/

    function internalAddSigner(uint256 _bcId, address _signer) private {
        require(
            blockchains[_bcId].signers[_signer] == false,
            "Signer already exists"
        );
        blockchains[_bcId].signers[_signer] = true;
    }

    function internalRemoveSigner(uint256 _bcId, address _signer) private {
        require(blockchains[_bcId].signers[_signer], "Signer does not exist");
        blockchains[_bcId].signers[_signer] = false;
    }

    function internalSetThreshold(
        uint256 _bcId,
        uint256 _currentNumSigners,
        uint256 _newThreshold
    ) private {
        require(
            _currentNumSigners >= _newThreshold,
            "Number of signers less than threshold"
        );
        require(_newThreshold != 0, "Threshold can not be zero");
        blockchains[_bcId].signingThreshold = _newThreshold;
    }
}

/*
 * Copyright 2020 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.7.1;

/**
 * Signature verification for ECDSA / KECCAK256 using secp256k1 curve.
 */
contract EcdsaSignatureVerification {
    /**
     * Verify a signature.
     *
     * @param _signer Address that corresponds to the public key of the signer.
     * @param _message Message to be verified.
     * @param _signature Signature to be verified.
     *
     */
    function verify(
        address _signer,
        bytes calldata _message,
        bytes calldata _signature
    ) internal pure returns (bool) {
        // Check the signature length
        if (_signature.length != 65) {
            return false;
        }

        bytes memory sig = _signature;
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Split the signature into components r, s and v variables with inline assembly.
        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }

        return verifySigComponents(_signer, _message, r, s, v);
    }

    /**
     * Verify a signature.
     *
     * @param _signer Address that corresponds to the public key of the signer.
     * @param _message Message to be verified.
     * @param _sigR Component of the signature to be verified.
     * @param _sigS Component of the signature to be verified.
     * @param _sigV Component of the signature to be verified.
     *
     */
    function verifySigComponents(
        address _signer,
        bytes calldata _message,
        bytes32 _sigR,
        bytes32 _sigS,
        uint8 _sigV
    ) internal pure returns (bool) {
        bytes32 digest = keccak256(_message);

        if (_sigV != 27 && _sigV != 28) {
            return false;
        } else {
            // The signature is verified if the address recovered from the signature matches
            // the signer address (which maps to the public key).
            return _signer == ecrecover(digest, _sigV, _sigR, _sigS);
        }
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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