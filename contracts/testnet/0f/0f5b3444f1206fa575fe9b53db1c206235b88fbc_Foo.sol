// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;
import "./wormhole/IWormhole.sol";

contract Foo {
    IWormhole public immutable endpoint;
    uint16 public immutable chainId; 
    enum MessageType {
        Call,
        Result
    }
    mapping(uint32 => bytes) public responses;

    constructor (address _endpoint, uint16 _chainId) {
        endpoint = IWormhole(_endpoint);
        chainId = _chainId;
    }

    function sendCall(uint32 _nonce, uint16 _destination, address _to, bytes calldata _data) external {
        bytes memory _payload = abi.encodePacked(MessageType.Call, _destination, _to, _data);
        endpoint.publishMessage(_nonce, _payload, 1);
    }

    function receiveCall(bytes memory _vm) external {
        (Structs.VM memory _dvm, MessageType _type, address _to, bytes memory _data) = parseAndVerifyVm(_vm);
        require(_type == MessageType.Call, "!type");
        (bool success, bytes memory _returndata) = _to.call(_data);
        require(success, "!call");
        sendResult(_dvm.nonce, _dvm.emitterChainId, bytes32ToAddress(_dvm.emitterAddress), _returndata);
    }

    function sendResult(uint32 _nonce, uint16 _destination, address _to, bytes memory _data) internal {
        bytes memory _payload = abi.encodePacked(MessageType.Result, _destination, _to, _data);
        endpoint.publishMessage(_nonce, _payload, 1);
    }

    function receiveResult(bytes memory _vm) external {
        (Structs.VM memory _dvm, MessageType _type, address _to, bytes memory _data) = parseAndVerifyVm(_vm);
        require(_type == MessageType.Result, "!type");
        require(_to == address(this), "!to");
        responses[_dvm.nonce] = _data;
    }

    function verifyVm(bytes memory _vm) public view returns (bool, string memory) {
        (Structs.VM memory _dvm, bool _valid, string memory _reason) = endpoint.parseAndVerifyVM(_vm);
        return (_valid, _reason);
    }

    function parseAndVerifyVm(bytes memory _vm) public view returns (Structs.VM memory, MessageType, address, bytes memory) {
        (Structs.VM memory _dvm, bool _valid, string memory _reason) = endpoint.parseAndVerifyVM(_vm);
        require(_valid, _reason);
        (MessageType _type, uint16 _destination, address _to, bytes memory _data) = abi.decode(_dvm.payload, (MessageType, uint16, address, bytes));
        require(_destination == chainId, "!destination");
        return (_dvm, _type, _to, _data);
    }

    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }

}

// contracts/Messages.sol
// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0;

import "./Structs.sol";

interface IWormhole is Structs {
    event LogMessagePublished(address indexed sender, uint64 sequence, uint32 nonce, bytes payload, uint8 consistencyLevel);

    function publishMessage(
        uint32 nonce,
        bytes memory payload,
        uint8 consistencyLevel
    ) external payable returns (uint64 sequence);

    function parseAndVerifyVM(bytes calldata encodedVM) external view returns (Structs.VM memory vm, bool valid, string memory reason);

    function verifyVM(Structs.VM memory vm) external view returns (bool valid, string memory reason);

    function verifySignatures(bytes32 hash, Structs.Signature[] memory signatures, Structs.GuardianSet memory guardianSet) external pure returns (bool valid, string memory reason) ;

    function parseVM(bytes memory encodedVM) external pure returns (Structs.VM memory vm);

    function getGuardianSet(uint32 index) external view returns (Structs.GuardianSet memory) ;

    function getCurrentGuardianSetIndex() external view returns (uint32) ;

    function getGuardianSetExpiry() external view returns (uint32) ;

    function governanceActionIsConsumed(bytes32 hash) external view returns (bool) ;

    function isInitialized(address impl) external view returns (bool) ;

    function chainId() external view returns (uint16) ;

    function governanceChainId() external view returns (uint16);

    function governanceContract() external view returns (bytes32);

    function messageFee() external view returns (uint256) ;
}

// contracts/Structs.sol
// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.4;

interface Structs {
	struct Provider {
		uint16 chainId;
		uint16 governanceChainId;
		bytes32 governanceContract;
	}

	struct GuardianSet {
		address[] keys;
		uint32 expirationTime;
	}

	struct Signature {
		bytes32 r;
		bytes32 s;
		uint8 v;
		uint8 guardianIndex;
	}

	struct VM {
		uint8 version;
		uint32 timestamp;
		uint32 nonce;
		uint16 emitterChainId;
		bytes32 emitterAddress;
		uint64 sequence;
		uint8 consistencyLevel;
		bytes payload;

		uint32 guardianSetIndex;
		Signature[] signatures;

		bytes32 hash;
	}
}