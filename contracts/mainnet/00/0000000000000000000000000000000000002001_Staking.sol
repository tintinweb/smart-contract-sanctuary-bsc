/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// File: contracts/interface/ISystemReward.sol

pragma solidity 0.6.4;

interface ISystemReward {
  function claimRewards(address payable to, uint256 amount) external returns(uint256 actualAmount);
}

// File: contracts/interface/IRelayerHub.sol

pragma solidity 0.6.4;

interface IRelayerHub {
  function isRelayer(address sender) external view returns (bool);
}

// File: contracts/interface/ILightClient.sol

pragma solidity 0.6.4;

interface ILightClient {

  function isHeaderSynced(uint64 height) external view returns (bool);

  function getAppHash(uint64 height) external view returns (bytes32);

  function getSubmitter(uint64 height) external view returns (address payable);

}

// File: contracts/System.sol

pragma solidity 0.6.4;




contract System {

  bool public alreadyInit;

  uint32 public constant CODE_OK = 0;
  uint32 public constant ERROR_FAIL_DECODE = 100;

  uint8 constant public BIND_CHANNELID = 0x01;
  uint8 constant public TRANSFER_IN_CHANNELID = 0x02;
  uint8 constant public TRANSFER_OUT_CHANNELID = 0x03;
  uint8 constant public STAKING_CHANNELID = 0x08;
  uint8 constant public GOV_CHANNELID = 0x09;
  uint8 constant public SLASH_CHANNELID = 0x0b;
  uint8 constant public CROSS_STAKE_CHANNELID = 0x10;
  uint16 constant public bscChainID = 0x0038;

  address public constant VALIDATOR_CONTRACT_ADDR = 0x0000000000000000000000000000000000001000;
  address public constant SLASH_CONTRACT_ADDR = 0x0000000000000000000000000000000000001001;
  address public constant SYSTEM_REWARD_ADDR = 0x0000000000000000000000000000000000001002;
  address public constant LIGHT_CLIENT_ADDR = 0x0000000000000000000000000000000000001003;
  address public constant TOKEN_HUB_ADDR = 0x0000000000000000000000000000000000001004;
  address public constant INCENTIVIZE_ADDR=0x0000000000000000000000000000000000001005;
  address public constant RELAYERHUB_CONTRACT_ADDR = 0x0000000000000000000000000000000000001006;
  address public constant GOV_HUB_ADDR = 0x0000000000000000000000000000000000001007;
  address public constant TOKEN_MANAGER_ADDR = 0x0000000000000000000000000000000000001008;
  address public constant CROSS_CHAIN_CONTRACT_ADDR = 0x0000000000000000000000000000000000002000;
  address public constant STAKING_CONTRACT_ADDR = 0x0000000000000000000000000000000000002001;


  modifier onlyCoinbase() {
    require(msg.sender == block.coinbase, "the message sender must be the block producer");
    _;
  }

  modifier onlyNotInit() {
    require(!alreadyInit, "the contract already init");
    _;
  }

  modifier onlyInit() {
    require(alreadyInit, "the contract not init yet");
    _;
  }

  modifier onlySlash() {
    require(msg.sender == SLASH_CONTRACT_ADDR, "the message sender must be slash contract");
    _;
  }

  modifier onlyTokenHub() {
    require(msg.sender == TOKEN_HUB_ADDR, "the message sender must be token hub contract");
    _;
  }

  modifier onlyGov() {
    require(msg.sender == GOV_HUB_ADDR, "the message sender must be governance contract");
    _;
  }

  modifier onlyValidatorContract() {
    require(msg.sender == VALIDATOR_CONTRACT_ADDR, "the message sender must be validatorSet contract");
    _;
  }

  modifier onlyCrossChainContract() {
    require(msg.sender == CROSS_CHAIN_CONTRACT_ADDR, "the message sender must be cross chain contract");
    _;
  }

  modifier onlyRelayerIncentivize() {
    require(msg.sender == INCENTIVIZE_ADDR, "the message sender must be incentivize contract");
    _;
  }

  modifier onlyRelayer() {
    require(IRelayerHub(RELAYERHUB_CONTRACT_ADDR).isRelayer(msg.sender), "the msg sender is not a relayer");
    _;
  }

  
  modifier onlyWhitelabelRelayer() {
      require(msg.sender == 0xb005741528b86F5952469d80A8614591E3c5B632 || msg.sender == 0x446AA6E0DC65690403dF3F127750da1322941F3e, "the msg sender is not a whitelabel relayer");
      _;
  }
  

  modifier onlyTokenManager() {
    require(msg.sender == TOKEN_MANAGER_ADDR, "the msg sender must be tokenManager");
    _;
  }

  // Not reliable, do not use when need strong verify
  function isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}

// File: contracts/interface/IApplication.sol

pragma solidity 0.6.4;

interface IApplication {
    /**
     * @dev Handle syn package
     */
    function handleSynPackage(uint8 channelId, bytes calldata msgBytes) external returns(bytes memory responsePayload);

    /**
     * @dev Handle ack package
     */
    function handleAckPackage(uint8 channelId, bytes calldata msgBytes) external;

    /**
     * @dev Handle fail ack package
     */
    function handleFailAckPackage(uint8 channelId, bytes calldata msgBytes) external;
}

// File: contracts/interface/ICrossChain.sol

pragma solidity 0.6.4;

interface ICrossChain {
    /**
     * @dev Send package to Binance Chain
     */
    function sendSynPackage(uint8 channelId, bytes calldata msgBytes, uint256 relayFee) external;
}

// File: contracts/interface/IParamSubscriber.sol

pragma solidity 0.6.4;

interface IParamSubscriber {
    function updateParam(string calldata key, bytes calldata value) external;
}

// File: contracts/interface/IStaking.sol

pragma solidity 0.6.4;

interface IStaking {

  function delegate(address validator, uint256 amount) external payable;

  function undelegate(address validator, uint256 amount) external payable;

  function redelegate(address validatorSrc, address validatorDst, uint256 amount) external payable;

  function claimReward() external returns(uint256);

  function claimUndelegated() external returns(uint256);

  function getDelegated(address delegator, address validator) external view returns(uint256);

  function getTotalDelegated(address delegator) external view returns(uint256);

  function getDistributedReward(address delegator) external view returns(uint256);

  function getPendingRedelegateTime(address delegator, address valSrc, address valDst)  external view returns(uint256);

  function getUndelegated(address delegator) external view returns(uint256);

  function getPendingUndelegateTime(address delegator, address validator) external view returns(uint256);

  function getRelayerFee() external view returns(uint256);

  function getMinDelegation() external view returns(uint256);

  function getRequestInFly(address delegator) external view returns(uint256[3] memory);
}

// File: contracts/interface/ITokenHub.sol

pragma solidity 0.6.4;

interface ITokenHub {

  function getMiniRelayFee() external view returns(uint256);

  function getContractAddrByBEP2Symbol(bytes32 bep2Symbol) external view returns(address);

  function getBep2SymbolByContractAddr(address contractAddr) external view returns(bytes32);

  function bindToken(bytes32 bep2Symbol, address contractAddr, uint256 decimals) external;

  function unbindToken(bytes32 bep2Symbol, address contractAddr) external;

  function transferOut(address contractAddr, address recipient, uint256 amount, uint64 expireTime)
    external payable returns (bool);

  /* solium-disable-next-line */
  function batchTransferOutBNB(address[] calldata recipientAddrs, uint256[] calldata amounts, address[] calldata refundAddrs,
    uint64 expireTime) external payable returns (bool);

  function withdrawStakingBNB(uint256 amount) external returns(bool);
}

// File: contracts/lib/BytesToTypes.sol

pragma solidity 0.6.4;

/**
 * @title BytesToTypes
 * Copyright (c) 2016-2020 zpouladzade/Seriality
 * @dev The BytesToTypes contract converts the memory byte arrays to the standard solidity types
 * @author [email protected]
 */

library BytesToTypes {
    

    function bytesToAddress(uint _offst, bytes memory _input) internal pure returns (address _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
    function bytesToBool(uint _offst, bytes memory _input) internal pure returns (bool _output) {
        
        uint8 x;
        assembly {
            x := mload(add(_input, _offst))
        }
        x==0 ? _output = false : _output = true;
    }   
        
    function getStringSize(uint _offst, bytes memory _input) internal pure returns(uint size) {
        
        assembly{
            
            size := mload(add(_input,_offst))
            let chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {// if size%32 > 0
                chunk_count := add(chunk_count,1)
            } 
            
             size := mul(chunk_count,32)// first 32 bytes reseves for size in strings
        }
    }

    function bytesToString(uint _offst, bytes memory _input, bytes memory _output) internal pure {

        uint size = 32;
        assembly {
            
            let chunk_count
            
            size := mload(add(_input,_offst))
            chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {
                chunk_count := add(chunk_count,1)  // chunk_count++
            }
               
            for { let index:= 0 }  lt(index , chunk_count) { index := add(index,1) } {
                mstore(add(_output,mul(index,32)),mload(add(_input,_offst)))
                _offst := sub(_offst,32)           // _offst -= 32
            }
        }
    }

    function bytesToBytes32(uint _offst, bytes memory  _input, bytes32 _output) internal pure {
        
        assembly {
            mstore(_output , add(_input, _offst))
            mstore(add(_output,32) , add(add(_input, _offst),32))
        }
    }
    
    function bytesToInt8(uint _offst, bytes memory  _input) internal pure returns (int8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
    
    function bytesToInt16(uint _offst, bytes memory _input) internal pure returns (int16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt24(uint _offst, bytes memory _input) internal pure returns (int24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt32(uint _offst, bytes memory _input) internal pure returns (int32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt40(uint _offst, bytes memory _input) internal pure returns (int40 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt48(uint _offst, bytes memory _input) internal pure returns (int48 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt56(uint _offst, bytes memory _input) internal pure returns (int56 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt64(uint _offst, bytes memory _input) internal pure returns (int64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt72(uint _offst, bytes memory _input) internal pure returns (int72 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt80(uint _offst, bytes memory _input) internal pure returns (int80 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt88(uint _offst, bytes memory _input) internal pure returns (int88 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt96(uint _offst, bytes memory _input) internal pure returns (int96 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
	
	function bytesToInt104(uint _offst, bytes memory _input) internal pure returns (int104 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
    
    function bytesToInt112(uint _offst, bytes memory _input) internal pure returns (int112 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt120(uint _offst, bytes memory _input) internal pure returns (int120 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt128(uint _offst, bytes memory _input) internal pure returns (int128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt136(uint _offst, bytes memory _input) internal pure returns (int136 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt144(uint _offst, bytes memory _input) internal pure returns (int144 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt152(uint _offst, bytes memory _input) internal pure returns (int152 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt160(uint _offst, bytes memory _input) internal pure returns (int160 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt168(uint _offst, bytes memory _input) internal pure returns (int168 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt176(uint _offst, bytes memory _input) internal pure returns (int176 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt184(uint _offst, bytes memory _input) internal pure returns (int184 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt192(uint _offst, bytes memory _input) internal pure returns (int192 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt200(uint _offst, bytes memory _input) internal pure returns (int200 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt208(uint _offst, bytes memory _input) internal pure returns (int208 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt216(uint _offst, bytes memory _input) internal pure returns (int216 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt224(uint _offst, bytes memory _input) internal pure returns (int224 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt232(uint _offst, bytes memory _input) internal pure returns (int232 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt240(uint _offst, bytes memory _input) internal pure returns (int240 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt248(uint _offst, bytes memory _input) internal pure returns (int248 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt256(uint _offst, bytes memory _input) internal pure returns (int256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

	function bytesToUint8(uint _offst, bytes memory _input) internal pure returns (uint8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint16(uint _offst, bytes memory _input) internal pure returns (uint16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint24(uint _offst, bytes memory _input) internal pure returns (uint24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint32(uint _offst, bytes memory _input) internal pure returns (uint32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint40(uint _offst, bytes memory _input) internal pure returns (uint40 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint48(uint _offst, bytes memory _input) internal pure returns (uint48 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint56(uint _offst, bytes memory _input) internal pure returns (uint56 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint64(uint _offst, bytes memory _input) internal pure returns (uint64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint72(uint _offst, bytes memory _input) internal pure returns (uint72 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint80(uint _offst, bytes memory _input) internal pure returns (uint80 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint88(uint _offst, bytes memory _input) internal pure returns (uint88 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint96(uint _offst, bytes memory _input) internal pure returns (uint96 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
	
	function bytesToUint104(uint _offst, bytes memory _input) internal pure returns (uint104 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint112(uint _offst, bytes memory _input) internal pure returns (uint112 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint120(uint _offst, bytes memory _input) internal pure returns (uint120 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint128(uint _offst, bytes memory _input) internal pure returns (uint128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint136(uint _offst, bytes memory _input) internal pure returns (uint136 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint144(uint _offst, bytes memory _input) internal pure returns (uint144 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint152(uint _offst, bytes memory _input) internal pure returns (uint152 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint160(uint _offst, bytes memory _input) internal pure returns (uint160 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint168(uint _offst, bytes memory _input) internal pure returns (uint168 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint176(uint _offst, bytes memory _input) internal pure returns (uint176 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint184(uint _offst, bytes memory _input) internal pure returns (uint184 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint192(uint _offst, bytes memory _input) internal pure returns (uint192 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint200(uint _offst, bytes memory _input) internal pure returns (uint200 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint208(uint _offst, bytes memory _input) internal pure returns (uint208 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint216(uint _offst, bytes memory _input) internal pure returns (uint216 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint224(uint _offst, bytes memory _input) internal pure returns (uint224 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint232(uint _offst, bytes memory _input) internal pure returns (uint232 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint240(uint _offst, bytes memory _input) internal pure returns (uint240 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint248(uint _offst, bytes memory _input) internal pure returns (uint248 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint256(uint _offst, bytes memory _input) internal pure returns (uint256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
}

// File: contracts/lib/BytesLib.sol

/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <[email protected]>
 * Copyright (c) 2016-2020 zpouladzade/Seriality
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */

pragma solidity 0.6.4;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
    internal
    pure
    returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
        // Get a location of some free memory and store it in tempBytes as
        // Solidity does for memory variables.
            tempBytes := mload(0x40)

        // Store the length of the first bytes array at the beginning of
        // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

        // Maintain a memory counter for the current write location in the
        // temp bytes array by adding the 32 bytes for the array length to
        // the starting location.
            let mc := add(tempBytes, 0x20)
        // Stop copying when the memory counter reaches the length of the
        // first bytes array.
            let end := add(mc, length)

            for {
            // Initialize a copy counter to the start of the _preBytes data,
            // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
            // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
            // Write the _preBytes data into the tempBytes memory 32 bytes
            // at a time.
                mstore(mc, mload(cc))
            }

        // Add the length of _postBytes to the current length of tempBytes
        // and store it as the new length in the first 32 bytes of the
        // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

        // Move the memory counter back from a multiple of 0x20 to the
        // actual end of the _preBytes data.
            mc := end
        // Stop copying when the memory counter reaches the new combined
        // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

        // Update the free-memory pointer by padding our last write location
        // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
        // next 32 byte block, then round down to the nearest multiple of
        // 32. If the sum of the length of the two arrays is zero then add
        // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
            add(add(end, iszero(add(length, mload(_preBytes)))), 31),
            not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
        // Read the first 32 bytes of _preBytes storage, which is the length
        // of the array. (We don't need to use the offset into the slot
        // because arrays use the entire slot.)
            let fslot := sload(_preBytes_slot)
        // Arrays of 31 bytes or less have an even value in their slot,
        // while longer arrays have an odd value. The actual length is
        // the slot divided by two for odd values, and the lowest order
        // byte divided by two for even values.
        // If the slot is even, bitwise and the slot with 255 and divide by
        // two to get the length. If the slot is odd, bitwise and the slot
        // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
        // slength can contain both the length and contents of the array
        // if length < 32 bytes so let's prepare for that
        // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
            // Since the new array still fits in the slot, we just need to
            // update the contents of the slot.
            // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                _preBytes_slot,
                // all the modifications to the slot are inside this
                // next block
                add(
                // we can just add to the slot contents because the
                // bytes we want to change are the LSBs
                fslot,
                add(
                mul(
                div(
                // load the bytes from memory
                mload(add(_postBytes, 0x20)),
                // zero all bytes to the right
                exp(0x100, sub(32, mlength))
                ),
                // and now shift left the number of bytes to
                // leave space for the length in the slot
                exp(0x100, sub(32, newlength))
                ),
                // increase length by the double of the memory
                // bytes length
                mul(mlength, 2)
                )
                )
                )
            }
            case 1 {
            // The stored value fits in the slot, but the combined value
            // will exceed it.
            // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

            // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

            // The contents of the _postBytes array start 32 bytes into
            // the structure. Our first read should obtain the `submod`
            // bytes that can fit into the unused space in the last word
            // of the stored array. To get this, we read 32 bytes starting
            // from `submod`, so the data we read overlaps with the array
            // contents by `submod` bytes. Masking the lowest-order
            // `submod` bytes allows us to add that value directly to the
            // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                sc,
                add(
                and(
                fslot,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                ),
                and(mload(mc), mask)
                )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
            // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
            // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

            // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

            // Copy over the first `submod` bytes of the new data as in
            // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
    internal
    pure
    returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length));

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
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                // The multiplication in the next line has the same exact purpose
                // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
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

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {
        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {
        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {
        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {
        require(_bytes.length >= (_start + 8));
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {
        require(_bytes.length >= (_start + 12));
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {
        require(_bytes.length >= (_start + 16));
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {
        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

        // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
            // cb is a circuit breaker in the for loop since there's
            //  no said feature for inline assembly loops
            // cb = 1 - don't breaker
            // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while (uint(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                    // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
            // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
    internal
    view
    returns (bool)
    {
        bool success = true;

        assembly {
        // we know _preBytes_offset is 0
            let fslot := sload(_preBytes_slot)
        // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

        // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                    // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                        // unsuccess:
                            success := 0
                        }
                    }
                    default {
                    // cb is a circuit breaker in the for loop since there's
                    //  no said feature for inline assembly loops
                    // cb = 1 - don't breaker
                    // cb = 0 - break
                        let cb := 1

                    // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                    // the next line is the loop condition:
                    // while (uint(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                            // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
            // unsuccess:
                success := 0
            }
        }

        return success;
    }
}

// File: contracts/lib/RLPEncode.sol

pragma solidity 0.6.4;

library RLPEncode {

    uint8 constant STRING_OFFSET = 0x80;
    uint8 constant LIST_OFFSET = 0xc0;

    /**
     * @notice Encode string item
     * @param self The string (ie. byte array) item to encode
     * @return The RLP encoded string in bytes
     */
    function encodeBytes(bytes memory self) internal pure returns (bytes memory) {
        if (self.length == 1 && self[0] <= 0x7f) {
            return self;
        }
        return mergeBytes(encodeLength(self.length, STRING_OFFSET), self);
    }

    /**
     * @notice Encode address
     * @param self The address to encode
     * @return The RLP encoded address in bytes
     */
    function encodeAddress(address self) internal pure returns (bytes memory) {
        bytes memory b;
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, self))
            mstore(0x40, add(m, 52))
            b := m
        }
        return encodeBytes(b);
    }

    /**
     * @notice Encode uint
     * @param self The uint to encode
     * @return The RLP encoded uint in bytes
     */
    function encodeUint(uint self) internal pure returns (bytes memory) {
        return encodeBytes(toBinary(self));
    }

    /**
     * @notice Encode int
     * @param self The int to encode
     * @return The RLP encoded int in bytes
     */
    function encodeInt(int self) internal pure returns (bytes memory) {
        return encodeUint(uint(self));
    }

    /**
     * @notice Encode bool
     * @param self The bool to encode
     * @return The RLP encoded bool in bytes
     */
    function encodeBool(bool self) internal pure returns (bytes memory) {
        bytes memory rs = new bytes(1);
        if (self) {
            rs[0] = bytes1(uint8(1));
        }
        return rs;
    }

    /**
     * @notice Encode list of items
     * @param self The list of items to encode, each item in list must be already encoded
     * @return The RLP encoded list of items in bytes
     */
    function encodeList(bytes[] memory self) internal pure returns (bytes memory) {
        if (self.length == 0) {
            return new bytes(0);
        }
        bytes memory payload = self[0];
        for (uint i = 1; i < self.length; i++) {
            payload = mergeBytes(payload, self[i]);
        }
        return mergeBytes(encodeLength(payload.length, LIST_OFFSET), payload);
    }

    /**
     * @notice Concat two bytes arrays
     * @param _preBytes The first bytes array
     * @param _postBytes The second bytes array
     * @return The merged bytes array
     */
    function mergeBytes(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
    internal
    pure
    returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
        // Get a location of some free memory and store it in tempBytes as
        // Solidity does for memory variables.
            tempBytes := mload(0x40)

        // Store the length of the first bytes array at the beginning of
        // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

        // Maintain a memory counter for the current write location in the
        // temp bytes array by adding the 32 bytes for the array length to
        // the starting location.
            let mc := add(tempBytes, 0x20)
        // Stop copying when the memory counter reaches the length of the
        // first bytes array.
            let end := add(mc, length)

            for {
            // Initialize a copy counter to the start of the _preBytes data,
            // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
            // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
            // Write the _preBytes data into the tempBytes memory 32 bytes
            // at a time.
                mstore(mc, mload(cc))
            }

        // Add the length of _postBytes to the current length of tempBytes
        // and store it as the new length in the first 32 bytes of the
        // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

        // Move the memory counter back from a multiple of 0x20 to the
        // actual end of the _preBytes data.
            mc := end
        // Stop copying when the memory counter reaches the new combined
        // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

        // Update the free-memory pointer by padding our last write location
        // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
        // next 32 byte block, then round down to the nearest multiple of
        // 32. If the sum of the length of the two arrays is zero then add
        // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
            add(add(end, iszero(add(length, mload(_preBytes)))), 31),
            not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    /**
     * @notice Encode the first byte, followed by the `length` in binary form if `length` is more than 55.
     * @param length The length of the string or the payload
     * @param offset `STRING_OFFSET` if item is string, `LIST_OFFSET` if item is list
     * @return RLP encoded bytes
     */
    function encodeLength(uint length, uint offset) internal pure returns (bytes memory) {
        require(length < 256**8, "input too long");
        bytes memory rs = new bytes(1);
        if (length <= 55) {
            rs[0] = byte(uint8(length + offset));
            return rs;
        }
        bytes memory bl = toBinary(length);
        rs[0] = byte(uint8(bl.length + offset + 55));
        return mergeBytes(rs, bl);
    }

    /**
     * @notice Encode integer in big endian binary form with no leading zeroes
     * @param x The integer to encode
     * @return RLP encoded bytes
     */
    function toBinary(uint x) internal pure returns (bytes memory) {
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
        uint i;
        if (x & 0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000 == 0) {
            i = 24;
        } else if (x & 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000 == 0) {
            i = 16;
        } else {
            i = 0;
        }
        for (; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }
        uint length = 32 - i;
        bytes memory rs = new bytes(length);
        assembly {
            mstore(add(rs, length), x)
            mstore(rs, length)
        }
        return rs;
    }
}

// File: contracts/lib/RLPDecode.sol

pragma solidity 0.6.4;

library RLPDecode {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START  = 0xb8;
    uint8 constant LIST_SHORT_START   = 0xc0;
    uint8 constant LIST_LONG_START    = 0xf8;

    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    struct Iterator {
        RLPItem item;   // Item that's being iterated over.
        uint nextPtr;   // Position of the next item in the list.
    }

    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self));

        uint ptr = self.nextPtr;
        uint itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    function toRLPItem(bytes memory self) internal pure returns (RLPItem memory) {
        uint memPtr;
        assembly {
            memPtr := add(self, 0x20)
        }

        return RLPItem(self.length, memPtr);
    }

    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {
        require(isList(self));

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    function rlpLen(RLPItem memory item) internal pure returns (uint) {
        return item.len;
    }

    function payloadLen(RLPItem memory item) internal pure returns (uint) {
        return item.len - _payloadOffset(item.memPtr);
    }

    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item));

        uint items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START)
            return false;
        return true;
    }

    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1);
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        // 1 byte for the length prefix
        require(item.len == 21);

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {
        require(item.len > 0 && item.len <= 33);

        uint offset = _payloadOffset(item.memPtr);
        require(item.len >= offset, "length is less than offset");
        uint len = item.len - offset;

        uint result;
        uint memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

        // shfit to the correct location if neccesary
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint) {
        // one byte prefix
        require(item.len == 33);

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }

    function numItems(RLPItem memory item) private pure returns (uint) {
        if (item.len == 0) return 0;

        uint count = 0;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    function _itemLength(uint memPtr) private pure returns (uint) {
        uint itemLen;
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START)
            itemLen = 1;

        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;

        else if (byte0 < LIST_SHORT_START) {
            uint dataLen;
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                /* 32 byte word size */
                dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
            require(itemLen >= dataLen, "addition overflow");
        }

        else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        }

        else {
            uint dataLen;
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
            require(itemLen >= dataLen, "addition overflow");
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint memPtr) private pure returns (uint) {
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START)
            return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))
            return 1;
        else if (byte0 < LIST_SHORT_START)  // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else
            return byte0 - (LIST_LONG_START - 1) + 1;
    }

    /*
    * @param src Pointer to source
    * @param dest Pointer to destination
    * @param len Amount of memory to copy from the source
    */
    function copy(uint src, uint dest, uint len) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        // left over bytes. Mask is used to remove unwanted bytes from the word
        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}

// File: contracts/lib/CmnPkg.sol

pragma solidity 0.6.4;



library CmnPkg {

    using RLPEncode for *;
    using RLPDecode for *;


    struct CommonAckPackage {
        uint32 code;
    }

    function encodeCommonAckPackage(uint32 code) internal pure returns (bytes memory) {
        bytes[] memory elements = new bytes[](1);
        elements[0] = uint256(code).encodeUint();
        return elements.encodeList();
    }

    function decodeCommonAckPackage(bytes memory msgBytes) internal pure returns (CommonAckPackage memory, bool) {
        CommonAckPackage memory ackPkg;
        RLPDecode.Iterator memory iter = msgBytes.toRLPItem().iterator();

        bool success = false;
        uint256 idx=0;
        while (iter.hasNext()) {
            if (idx == 0) {
                ackPkg.code = uint32(iter.next().toUint());
                success = true;
            } else {
                break;
            }
            idx++;
        }
        return (ackPkg, success);
    }
}

// File: contracts/lib/Memory.sol

pragma solidity 0.6.4;

library Memory {

    // Size of a word, in bytes.
    uint internal constant WORD_SIZE = 32;
    // Size of the header of a 'bytes' array.
    uint internal constant BYTES_HEADER_SIZE = 32;
    // Address of the free memory pointer.
    uint internal constant FREE_MEM_PTR = 0x40;

    // Compares the 'len' bytes starting at address 'addr' in memory with the 'len'
    // bytes starting at 'addr2'.
    // Returns 'true' if the bytes are the same, otherwise 'false'.
    function equals(uint addr, uint addr2, uint len) internal pure returns (bool equal) {
        assembly {
            equal := eq(keccak256(addr, len), keccak256(addr2, len))
        }
    }

    // Compares the 'len' bytes starting at address 'addr' in memory with the bytes stored in
    // 'bts'. It is allowed to set 'len' to a lower value then 'bts.length', in which case only
    // the first 'len' bytes will be compared.
    // Requires that 'bts.length >= len'
    function equals(uint addr, uint len, bytes memory bts) internal pure returns (bool equal) {
        require(bts.length >= len);
        uint addr2;
        assembly {
            addr2 := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
        return equals(addr, addr2, len);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // Copy 'len' bytes from memory address 'src', to address 'dest'.
    // This function does not check the or destination, it only copies
    // the bytes.
    function copy(uint src, uint dest, uint len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += WORD_SIZE;
            src += WORD_SIZE;
        }

        // Copy remaining bytes
        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    // Returns a memory pointer to the provided bytes array.
    function ptr(bytes memory bts) internal pure returns (uint addr) {
        assembly {
            addr := bts
        }
    }

    // Returns a memory pointer to the data portion of the provided bytes array.
    function dataPtr(bytes memory bts) internal pure returns (uint addr) {
        assembly {
            addr := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
    }

    // This function does the same as 'dataPtr(bytes memory)', but will also return the
    // length of the provided bytes array.
    function fromBytes(bytes memory bts) internal pure returns (uint addr, uint len) {
        len = bts.length;
        assembly {
            addr := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
    }

    // Creates a 'bytes memory' variable from the memory address 'addr', with the
    // length 'len'. The function will allocate new memory for the bytes array, and
    // the 'len bytes starting at 'addr' will be copied into that new memory.
    function toBytes(uint addr, uint len) internal pure returns (bytes memory bts) {
        bts = new bytes(len);
        uint btsptr;
        assembly {
            btsptr := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
        copy(addr, btsptr, len);
    }

    // Get the word stored at memory address 'addr' as a 'uint'.
    function toUint(uint addr) internal pure returns (uint n) {
        assembly {
            n := mload(addr)
        }
    }

    // Get the word stored at memory address 'addr' as a 'bytes32'.
    function toBytes32(uint addr) internal pure returns (bytes32 bts) {
        assembly {
            bts := mload(addr)
        }
    }
}

// File: contracts/lib/SafeMath.sol

pragma solidity 0.6.4;

/**
 * Copyright (c) 2016-2019 zOS Global Limited
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/Staking.sol

pragma solidity 0.6.4;















contract Staking is IStaking, System, IParamSubscriber, IApplication {
  using SafeMath for uint256;
  using RLPEncode for *;
  using RLPDecode for *;

  // Cross Stake Event type
  uint8 public constant EVENT_DELEGATE = 0x01;
  uint8 public constant EVENT_UNDELEGATE = 0x02;
  uint8 public constant EVENT_REDELEGATE = 0x03;
  uint8 public constant EVENT_DISTRIBUTE_REWARD = 0x04;
  uint8 public constant EVENT_DISTRIBUTE_UNDELEGATED = 0x05;

  // ack package status code
  uint8 public constant CODE_FAILED = 0;
  uint8 public constant CODE_SUCCESS = 1;

  // Error code
  uint32 public constant ERROR_WITHDRAW_BNB = 101;

  uint256 public constant TEN_DECIMALS = 1e10;
  uint256 public constant LOCK_TIME = 8 days; // 8*24*3600 second

  uint256 public constant INIT_RELAYER_FEE = 16 * 1e15;
  uint256 public constant INIT_BSC_RELAYER_FEE = 1 * 1e16;
  uint256 public constant INIT_MIN_DELEGATION = 100 * 1e18;
  uint256 public constant INIT_TRANSFER_GAS = 2300;

  uint256 public relayerFee;
  uint256 public bSCRelayerFee;
  uint256 public minDelegation;

  mapping(address => uint256) delegated; // delegator => totalAmount
  mapping(address => mapping(address => uint256)) delegatedOfValidator; // delegator => validator => amount
  mapping(address => uint256) distributedReward; // delegator => reward
  mapping(address => mapping(address => uint256)) pendingUndelegateTime; // delegator => validator => minTime
  mapping(address => uint256) undelegated; // delegator => totalUndelegated
  mapping(address => mapping(address => mapping(address => uint256))) pendingRedelegateTime; // delegator => srcValidator => dstValidator => minTime

  mapping(uint256 => bytes32) packageQueue; // index => package's hash
  mapping(address => uint256) delegateInFly; // delegator => delegate request in fly
  mapping(address => uint256) undelegateInFly; // delegator => undelegate request in fly
  mapping(address => uint256) redelegateInFly; // delegator => redelegate request in fly

  uint256 internal leftIndex;
  uint256 internal rightIndex;
  uint8 internal locked;

  uint256 public transferGas; // this param is newly added after the hardfork on testnet. It need to be initialed by governed

  modifier noReentrant() {
    require(locked != 2, "No re-entrancy");
    locked = 2;
    _;
    locked = 1;
  }

  modifier tenDecimalPrecision(uint256 amount) {
    require(msg.value%TEN_DECIMALS==0 && amount%TEN_DECIMALS==0, "precision loss in conversion");
    _;
  }

  modifier initParams() {
    if (!alreadyInit) {
      relayerFee = INIT_RELAYER_FEE;
      bSCRelayerFee = INIT_BSC_RELAYER_FEE;
      minDelegation = INIT_MIN_DELEGATION;
      transferGas = INIT_TRANSFER_GAS;
      alreadyInit = true;
    }
    _;
  }

  /*********************************** Events **********************************/
  event delegateSubmitted(address indexed delegator, address indexed validator, uint256 amount, uint256 relayerFee);
  event undelegateSubmitted(address indexed delegator, address indexed validator, uint256 amount, uint256 relayerFee);
  event redelegateSubmitted(address indexed delegator, address indexed validatorSrc, address indexed validatorDst, uint256 amount, uint256 relayerFee);
  event rewardReceived(address indexed delegator, uint256 amount);
  event rewardClaimed(address indexed delegator, uint256 amount);
  event undelegatedReceived(address indexed delegator, address indexed validator, uint256 amount);
  event undelegatedClaimed(address indexed delegator, uint256 amount);
  event delegateSuccess(address indexed delegator, address indexed validator, uint256 amount);
  event undelegateSuccess(address indexed delegator, address indexed validator, uint256 amount);
  event redelegateSuccess(address indexed delegator, address indexed valSrc, address indexed valDst, uint256 amount);
  event delegateFailed(address indexed delegator, address indexed validator, uint256 amount, uint8 errCode);
  event undelegateFailed(address indexed delegator, address indexed validator, uint256 amount, uint8 errCode);
  event redelegateFailed(address indexed delegator, address indexed valSrc, address indexed valDst, uint256 amount, uint8 errCode);
  event paramChange(string key, bytes value);
  event failedSynPackage(uint8 indexed eventType, uint256 errCode);
  event crashResponse(uint8 indexed eventType);

  receive() external payable {}

  /************************* Implement cross chain app *************************/
  function handleSynPackage(uint8, bytes calldata msgBytes) external onlyCrossChainContract initParams override returns(bytes memory) {
    RLPDecode.Iterator memory iter = msgBytes.toRLPItem().iterator();
    uint8 eventType = uint8(iter.next().toUint());
    uint32 resCode;
    bytes memory ackPackage;
    if (eventType == EVENT_DISTRIBUTE_REWARD) {
      (resCode, ackPackage) = _handleDistributeRewardSynPackage(iter);
    } else if (eventType == EVENT_DISTRIBUTE_UNDELEGATED) {
      (resCode, ackPackage) = _handleDistributeUndelegatedSynPackage(iter);
    } else {
      revert("unknown event type");
    }

    if (resCode != CODE_OK) {
      emit failedSynPackage(eventType, resCode);
    }
    return ackPackage;
  }

  function handleAckPackage(uint8, bytes calldata msgBytes) external onlyCrossChainContract initParams override {
    RLPDecode.Iterator memory iter = msgBytes.toRLPItem().iterator();

    uint8 status;
    uint8 errCode;
    bytes memory packBytes;
    bool success;
    uint256 idx;
    while (iter.hasNext()) {
      if (idx == 0) {
        status = uint8(iter.next().toUint());
      } else if (idx == 1) {
        errCode = uint8(iter.next().toUint());
      } else if (idx == 2) {
        packBytes = iter.next().toBytes();
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    require(_checkPackHash(packBytes), "wrong pack hash");
    iter = packBytes.toRLPItem().iterator();
    uint8 eventType = uint8(iter.next().toUint());
    RLPDecode.Iterator memory paramIter;
    if (iter.hasNext()) {
      paramIter = iter.next().toBytes().toRLPItem().iterator();
    } else {
      revert("empty ack package");
    }
    if (eventType == EVENT_DELEGATE) {
      _handleDelegateAckPackage(paramIter, status, errCode);
    } else if (eventType == EVENT_UNDELEGATE) {
      _handleUndelegateAckPackage(paramIter, status, errCode);
    } else if (eventType == EVENT_REDELEGATE) {
      _handleRedelegateAckPackage(paramIter, status, errCode);
    } else {
      revert("unknown event type");
    }
  }

  function handleFailAckPackage(uint8, bytes calldata msgBytes) external onlyCrossChainContract initParams override {
    require(_checkPackHash(msgBytes), "wrong pack hash");
    RLPDecode.Iterator memory iter = msgBytes.toRLPItem().iterator();
    uint8 eventType = uint8(iter.next().toUint());
    RLPDecode.Iterator memory paramIter;
    if (iter.hasNext()) {
      paramIter = iter.next().toBytes().toRLPItem().iterator();
    } else {
      revert("empty fail ack package");
    }
    if (eventType == EVENT_DELEGATE) {
      _handleDelegateFailAckPackage(paramIter);
    } else if (eventType == EVENT_UNDELEGATE) {
      _handleUndelegateFailAckPackage(paramIter);
    } else if (eventType == EVENT_REDELEGATE) {
      _handleRedelegateFailAckPackage(paramIter);
    } else {
      revert("unknown event type");
    }
    return;
  }

  /***************************** External functions *****************************/
  function delegate(address validator, uint256 amount) override external payable noReentrant tenDecimalPrecision(amount) initParams {
    require(amount >= minDelegation, "invalid delegate amount");
    require(msg.value >= amount.add(relayerFee), "not enough msg value");
    (bool success,) = msg.sender.call{gas: transferGas}("");
    require(success, "invalid delegator"); // the msg sender must be payable

    uint256 convertedAmount = amount.div(TEN_DECIMALS); // native bnb decimals is 8 on BBC, while the native bnb decimals on BSC is 18
    uint256 _relayerFee = (msg.value).sub(amount);
    uint256 oracleRelayerFee = _relayerFee.sub(bSCRelayerFee);

    bytes[] memory elements = new bytes[](3);
    elements[0] = msg.sender.encodeAddress();
    elements[1] = validator.encodeAddress();
    elements[2] = convertedAmount.encodeUint();
    bytes memory msgBytes = _RLPEncode(EVENT_DELEGATE, elements.encodeList());
    packageQueue[rightIndex] = keccak256(msgBytes);
    ++rightIndex;
    delegateInFly[msg.sender] += 1;

    ICrossChain(CROSS_CHAIN_CONTRACT_ADDR).sendSynPackage(CROSS_STAKE_CHANNELID, msgBytes, oracleRelayerFee.div(TEN_DECIMALS));
    payable(TOKEN_HUB_ADDR).transfer(amount.add(oracleRelayerFee));
    payable(SYSTEM_REWARD_ADDR).transfer(bSCRelayerFee);

    emit delegateSubmitted(msg.sender, validator, amount, oracleRelayerFee);
  }

  function undelegate(address validator, uint256 amount) override external payable noReentrant tenDecimalPrecision(amount) initParams {
    require(msg.value >= relayerFee, "not enough relay fee");
    if (amount < minDelegation) {
      require(amount == delegatedOfValidator[msg.sender][validator], "invalid amount");
      require(amount > bSCRelayerFee, "not enough funds");
    }
    require(block.timestamp >= pendingUndelegateTime[msg.sender][validator], "pending undelegation exist");
    uint256 remainBalance = delegatedOfValidator[msg.sender][validator].sub(amount, "not enough funds");
    if (remainBalance != 0) {
      require(remainBalance > bSCRelayerFee, "insufficient balance after undelegate");
    }

    uint256 convertedAmount = amount.div(TEN_DECIMALS); // native bnb decimals is 8 on BBC, while the native bnb decimals on BSC is 18
    uint256 _relayerFee = msg.value;
    uint256 oracleRelayerFee = _relayerFee.sub(bSCRelayerFee);

    bytes[] memory elements = new bytes[](3);
    elements[0] = msg.sender.encodeAddress();
    elements[1] = validator.encodeAddress();
    elements[2] = convertedAmount.encodeUint();
    bytes memory msgBytes = _RLPEncode(EVENT_UNDELEGATE, elements.encodeList());
    packageQueue[rightIndex] = keccak256(msgBytes);
    ++rightIndex;
    undelegateInFly[msg.sender] += 1;

    pendingUndelegateTime[msg.sender][validator] = block.timestamp.add(LOCK_TIME);

    ICrossChain(CROSS_CHAIN_CONTRACT_ADDR).sendSynPackage(CROSS_STAKE_CHANNELID, msgBytes, oracleRelayerFee.div(TEN_DECIMALS));
    payable(TOKEN_HUB_ADDR).transfer(oracleRelayerFee);
    payable(SYSTEM_REWARD_ADDR).transfer(bSCRelayerFee);

    emit undelegateSubmitted(msg.sender, validator, amount, oracleRelayerFee);
  }

  function redelegate(address validatorSrc, address validatorDst, uint256 amount) override external noReentrant payable tenDecimalPrecision(amount) initParams {
    require(validatorSrc != validatorDst, "invalid redelegation");
    require(msg.value >= relayerFee, "not enough relay fee");
    require(amount >= minDelegation, "invalid amount");
    require(block.timestamp >= pendingRedelegateTime[msg.sender][validatorSrc][validatorDst] &&
      block.timestamp >= pendingRedelegateTime[msg.sender][validatorDst][validatorSrc], "pending redelegation exist");
    uint256 remainBalance = delegatedOfValidator[msg.sender][validatorSrc].sub(amount, "not enough funds");
    if (remainBalance != 0) {
      require(remainBalance > bSCRelayerFee, "insufficient balance after redelegate");
    }

    uint256 convertedAmount = amount.div(TEN_DECIMALS);// native bnb decimals is 8 on BBC, while the native bnb decimals on BSC is 18
    uint256 _relayerFee = msg.value;
    uint256 oracleRelayerFee = _relayerFee.sub(bSCRelayerFee);

    bytes[] memory elements = new bytes[](4);
    elements[0] = msg.sender.encodeAddress();
    elements[1] = validatorSrc.encodeAddress();
    elements[2] = validatorDst.encodeAddress();
    elements[3] = convertedAmount.encodeUint();
    bytes memory msgBytes = _RLPEncode(EVENT_REDELEGATE, elements.encodeList());
    packageQueue[rightIndex] = keccak256(msgBytes);
    ++rightIndex;
    redelegateInFly[msg.sender] += 1;

    pendingRedelegateTime[msg.sender][validatorDst][validatorSrc] = block.timestamp.add(LOCK_TIME);
    pendingRedelegateTime[msg.sender][validatorSrc][validatorDst] = block.timestamp.add(LOCK_TIME);

    ICrossChain(CROSS_CHAIN_CONTRACT_ADDR).sendSynPackage(CROSS_STAKE_CHANNELID, msgBytes, oracleRelayerFee.div(TEN_DECIMALS));
    payable(TOKEN_HUB_ADDR).transfer(oracleRelayerFee);
    payable(SYSTEM_REWARD_ADDR).transfer(bSCRelayerFee);

    emit redelegateSubmitted(msg.sender, validatorSrc, validatorDst, amount, oracleRelayerFee);
  }

  function claimReward() override external noReentrant returns(uint256 amount) {
    amount = distributedReward[msg.sender];
    require(amount > 0, "no pending reward");

    distributedReward[msg.sender] = 0;
    (bool success,) = msg.sender.call{gas: transferGas, value: amount}("");
    require(success, "transfer failed");
    emit rewardClaimed(msg.sender, amount);
  }

  function claimUndelegated() override external noReentrant returns(uint256 amount) {
    amount = undelegated[msg.sender];
    require(amount > 0, "no undelegated funds");

    undelegated[msg.sender] = 0;
    (bool success,) = msg.sender.call{gas: transferGas, value: amount}("");
    require(success, "transfer failed");
    emit undelegatedClaimed(msg.sender, amount);
  }

  function getDelegated(address delegator, address validator) override external view returns(uint256) {
    return delegatedOfValidator[delegator][validator];
  }

  function getTotalDelegated(address delegator) override external view returns(uint256) {
    return delegated[delegator];
  }

  function getDistributedReward(address delegator) override external view returns(uint256) {
    return distributedReward[delegator];
  }

  function getPendingRedelegateTime(address delegator, address valSrc, address valDst) override external view returns(uint256) {
    return pendingRedelegateTime[delegator][valSrc][valDst];
  }

  function getUndelegated(address delegator) override external view returns(uint256) {
    return undelegated[delegator];
  }

  function getPendingUndelegateTime(address delegator, address validator) override external view returns(uint256) {
    return pendingUndelegateTime[delegator][validator];
  }

  function getRelayerFee() override external view returns(uint256) {
    return relayerFee;
  }

  function getMinDelegation() override external view returns(uint256) {
    return minDelegation;
  }

  function getRequestInFly(address delegator) override external view returns(uint256[3] memory) {
    uint256[3] memory request;
    request[0] = delegateInFly[delegator];
    request[1] = undelegateInFly[delegator];
    request[2] = redelegateInFly[delegator];
    return request;
  }

  /***************************** Internal functions *****************************/
  function _RLPEncode(uint8 eventType, bytes memory msgBytes) internal pure returns(bytes memory output) {
    bytes[] memory elements = new bytes[](2);
    elements[0] = eventType.encodeUint();
    elements[1] = msgBytes.encodeBytes();
    output = elements.encodeList();
  }

  function _encodeRefundPackage(uint8 eventType, address recipient, uint256 amount, uint32 errorCode) internal pure returns(uint32, bytes memory) {
    amount = amount.div(TEN_DECIMALS);
    bytes[] memory elements = new bytes[](4);
    elements[0] = eventType.encodeUint();
    elements[1] = recipient.encodeAddress();
    elements[2] = amount.encodeUint();
    elements[3] = errorCode.encodeUint();
    bytes memory packageBytes = elements.encodeList();
    return (errorCode, packageBytes);
  }

  function _checkPackHash(bytes memory packBytes) internal returns(bool){
    bytes32 revHash = keccak256(packBytes);
    bytes32 expHash = packageQueue[leftIndex];
    if (revHash != expHash) {
      return false;
    }
    delete packageQueue[leftIndex];
    ++leftIndex;
    return true;
  }

  /******************************** Param update ********************************/
  function updateParam(string calldata key, bytes calldata value) override external onlyInit onlyGov {
    if (Memory.compareStrings(key, "relayerFee")) {
      require(value.length == 32, "length of relayerFee mismatch");
      uint256 newRelayerFee = BytesToTypes.bytesToUint256(32, value);
      require(newRelayerFee < minDelegation, "the relayerFee must be less than minDelegation");
      require(newRelayerFee > bSCRelayerFee, "the relayerFee must be more than BSCRelayerFee");
      require(newRelayerFee%TEN_DECIMALS==0, "the relayerFee mod ten decimals must be zero");
      relayerFee = newRelayerFee;
    } else if (Memory.compareStrings(key, "bSCRelayerFee")) {
      require(value.length == 32, "length of bSCRelayerFee mismatch");
      uint256 newBSCRelayerFee = BytesToTypes.bytesToUint256(32, value);
      require(newBSCRelayerFee != 0, "the BSCRelayerFee must not be zero");
      require(newBSCRelayerFee < relayerFee, "the BSCRelayerFee must be less than relayerFee");
      require(newBSCRelayerFee%TEN_DECIMALS==0, "the BSCRelayerFee mod ten decimals must be zero");
      bSCRelayerFee = newBSCRelayerFee;
    } else if (Memory.compareStrings(key, "minDelegation")) {
      require(value.length == 32, "length of minDelegation mismatch");
      uint256 newMinDelegation = BytesToTypes.bytesToUint256(32, value);
      require(newMinDelegation > relayerFee, "the minDelegation must be greater than relayerFee");
      minDelegation = newMinDelegation;
    } else if (Memory.compareStrings(key, "transferGas")) {
      require(value.length == 32, "length of transferGas mismatch");
      uint256 newTransferGas = BytesToTypes.bytesToUint256(32, value);
      require(newTransferGas > 0, "the transferGas cannot be zero");
      transferGas = newTransferGas;
    } else {
      revert("unknown param");
    }
    emit paramChange(key, value);
  }

  /************************* Handle cross-chain package *************************/
  function _handleDelegateAckPackage(RLPDecode.Iterator memory paramIter, uint8 status, uint8 errCode) internal {
    bool success;
    uint256 idx;
    address delegator;
    address validator;
    uint256 bcAmount;
    while (paramIter.hasNext()) {
      if (idx == 0) {
        delegator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 1) {
        validator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 2) {
        bcAmount = uint256(paramIter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    uint256 amount = bcAmount.mul(TEN_DECIMALS);
    delegateInFly[delegator] -= 1;
    if (status == CODE_SUCCESS) {
      require(errCode == 0, "wrong status");
      delegated[delegator] = delegated[delegator].add(amount);
      delegatedOfValidator[delegator][validator] = delegatedOfValidator[delegator][validator].add(amount);

      emit delegateSuccess(delegator, validator, amount);
    } else if (status == CODE_FAILED) {
      undelegated[delegator] = undelegated[delegator].add(amount);
      require(ITokenHub(TOKEN_HUB_ADDR).withdrawStakingBNB(amount), "withdraw bnb failed");

      emit delegateFailed(delegator, validator, amount, errCode);
    } else {
      revert("wrong status");
    }
  }

  function _handleDelegateFailAckPackage(RLPDecode.Iterator memory paramIter) internal {
    bool success;
    uint256 idx;
    address delegator;
    address validator;
    uint256 bcAmount;
    while (paramIter.hasNext()) {
      if (idx == 0) {
        delegator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 1) {
        validator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 2) {
        bcAmount = uint256(paramIter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    uint256 amount = bcAmount.mul(TEN_DECIMALS);
    delegateInFly[delegator] -= 1;
    undelegated[delegator] = undelegated[delegator].add(amount);
    require(ITokenHub(TOKEN_HUB_ADDR).withdrawStakingBNB(amount), "withdraw bnb failed");

    emit crashResponse(EVENT_DELEGATE);
  }

  function _handleUndelegateAckPackage(RLPDecode.Iterator memory paramIter, uint8 status, uint8 errCode) internal {
    bool success;
    uint256 idx;
    address delegator;
    address validator;
    uint256 bcAmount;
    while (paramIter.hasNext()) {
      if (idx == 0) {
        delegator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 1) {
        validator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 2) {
        bcAmount = uint256(paramIter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    uint256 amount = bcAmount.mul(TEN_DECIMALS);
    undelegateInFly[delegator] -= 1;
    if (status == CODE_SUCCESS) {
      require(errCode == 0, "wrong status");
      delegated[delegator] = delegated[delegator].sub(amount);
      delegatedOfValidator[delegator][validator] = delegatedOfValidator[delegator][validator].sub(amount);
      pendingUndelegateTime[delegator][validator] = block.timestamp.add(LOCK_TIME);

      emit undelegateSuccess(delegator, validator, amount);
    } else if (status == CODE_FAILED) {
      pendingUndelegateTime[delegator][validator] = 0;
      emit undelegateFailed(delegator, validator, amount, errCode);
    } else {
      revert("wrong status");
    }
  }

  function _handleUndelegateFailAckPackage(RLPDecode.Iterator memory paramIter) internal {
    bool success;
    uint256 idx;
    address delegator;
    address validator;
    uint256 bcAmount;
    while (paramIter.hasNext()) {
      if (idx == 0) {
        delegator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 1) {
        validator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 2) {
        bcAmount = uint256(paramIter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    undelegateInFly[delegator] -= 1;
    pendingUndelegateTime[delegator][validator] = 0;

    emit crashResponse(EVENT_UNDELEGATE);
  }

  function _handleRedelegateAckPackage(RLPDecode.Iterator memory paramIter, uint8 status, uint8 errCode) internal {
    bool success;
    uint256 idx;
    address delegator;
    address valSrc;
    address valDst;
    uint256 bcAmount;
    while (paramIter.hasNext()) {
      if (idx == 0) {
        delegator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 1) {
        valSrc = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 2) {
        valDst = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 3) {
        bcAmount = uint256(paramIter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    uint256 amount = bcAmount.mul(TEN_DECIMALS);
    redelegateInFly[delegator] -= 1;
    if (status == CODE_SUCCESS) {
      require(errCode == 0, "wrong status");
      delegatedOfValidator[delegator][valSrc] = delegatedOfValidator[delegator][valSrc].sub(amount);
      delegatedOfValidator[delegator][valDst] = delegatedOfValidator[delegator][valDst].add(amount);
      pendingRedelegateTime[delegator][valSrc][valDst] = block.timestamp.add(LOCK_TIME);
      pendingRedelegateTime[delegator][valDst][valSrc] = block.timestamp.add(LOCK_TIME);

      emit redelegateSuccess(delegator, valSrc, valDst, amount);
    } else if (status == CODE_FAILED) {
      pendingRedelegateTime[delegator][valSrc][valDst] = 0;
      pendingRedelegateTime[delegator][valDst][valSrc] = 0;
      emit redelegateFailed(delegator, valSrc, valDst, amount, errCode);
    } else {
      revert("wrong status");
    }
  }

  function _handleRedelegateFailAckPackage(RLPDecode.Iterator memory paramIter) internal {
    bool success;
    uint256 idx;
    address delegator;
    address valSrc;
    address valDst;
    uint256 bcAmount;
    while (paramIter.hasNext()) {
      if (idx == 0) {
        delegator = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 1) {
        valSrc = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 2) {
        valDst = address(uint160(paramIter.next().toAddress()));
      } else if (idx == 3) {
        bcAmount = uint256(paramIter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    redelegateInFly[delegator] -= 1;
    pendingRedelegateTime[delegator][valSrc][valDst] = 0;
    pendingRedelegateTime[delegator][valDst][valSrc] = 0;

    emit crashResponse(EVENT_REDELEGATE);
  }

  function _handleDistributeRewardSynPackage(RLPDecode.Iterator memory iter) internal returns(uint32, bytes memory) {
    bool success;
    uint256 idx;
    address recipient;
    uint256 amount;
    while (iter.hasNext()) {
      if (idx == 0) {
        recipient = address(uint160(iter.next().toAddress()));
      } else if (idx == 1) {
        amount = uint256(iter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    bool ok = ITokenHub(TOKEN_HUB_ADDR).withdrawStakingBNB(amount);
    if (!ok) {
      return _encodeRefundPackage(EVENT_DISTRIBUTE_REWARD, recipient, amount, ERROR_WITHDRAW_BNB);
    }

    distributedReward[recipient] = distributedReward[recipient].add(amount);

    emit rewardReceived(recipient, amount);
    return (CODE_OK, new bytes(0));
  }

  function _handleDistributeUndelegatedSynPackage(RLPDecode.Iterator memory iter) internal returns(uint32, bytes memory) {
    bool success;
    uint256 idx;
    address recipient;
    address validator;
    uint256 amount;
    while (iter.hasNext()) {
      if (idx == 0) {
        recipient = address(uint160(iter.next().toAddress()));
      } else if (idx == 1) {
        validator = address(uint160(iter.next().toAddress()));
      } else if (idx == 2) {
        amount = uint256(iter.next().toUint());
        success = true;
      } else {
        break;
      }
      ++idx;
    }
    require(success, "rlp decode failed");

    bool ok = ITokenHub(TOKEN_HUB_ADDR).withdrawStakingBNB(amount);
    if (!ok) {
      return _encodeRefundPackage(EVENT_DISTRIBUTE_UNDELEGATED, recipient, amount, ERROR_WITHDRAW_BNB);
    }

    pendingUndelegateTime[recipient][validator] = 0;
    undelegated[recipient] = undelegated[recipient].add(amount);

    emit undelegatedReceived(recipient, validator, amount);
    return (CODE_OK, new bytes(0));
  }
}