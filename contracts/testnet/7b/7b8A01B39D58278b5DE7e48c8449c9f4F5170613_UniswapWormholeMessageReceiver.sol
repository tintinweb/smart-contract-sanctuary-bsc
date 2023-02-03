pragma solidity ^0.8.9;
import "./Structs.sol";

interface IWormhole {
    function parseAndVerifyVM(bytes calldata encodedVM) external view returns (Structs.VM memory vm, bool valid, string memory reason);
}

contract UniswapWormholeMessageReceiver {
    string public name = "Uniswap Wormhole Message Receiver";

    address public owner;
    bytes32 public messageSender;

    mapping(bytes32 => bool) public processedMessages;

    IWormhole private immutable wormhole;

    constructor(address bridgeAddress, bytes32 _messageSender) {
        wormhole = IWormhole(bridgeAddress);
        messageSender = _messageSender;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "sender not owner");
        _;
    }

    function receiveMessage(bytes[] memory whMessages) public {
        (Structs.VM memory vm, bool valid, string memory reason) = wormhole.parseAndVerifyVM(whMessages[0]);

        //validate
        require(valid, reason);
        
        // Ensure the emitterAddress of this VAA is the Uniswap message sender
        require(messageSender == vm.emitterAddress, "Invalid Emitter Address!");

        // Ensure the emitterChainId is Ethereum to prevent impersonation
        require(2 == vm.emitterChainId , "Invalid Emmiter Chain");

        //verify destination
        (address[] memory targets, uint256[] memory values, bytes[] memory datas, address messageReceiver) = abi.decode(vm.payload,(address[], uint256[], bytes[], address));
        require (messageReceiver == address(this), "Message not for this dest");

        // replay protection
        require(!processedMessages[vm.hash], "Message already processed");
        processedMessages[vm.hash] = true;

        //execute message
        require(targets.length == datas.length && targets.length == values.length, 'Inconsistent argument lengths');
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, ) = targets[i].call{value: values[i]}(datas[i]);
            require(success, 'Sub-call failed');
        }
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}

// contracts/Structs.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.9;

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