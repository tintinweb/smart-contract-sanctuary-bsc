pragma solidity 0.6.4;

import "./lib/BytesToTypes.sol";
import "./lib/Memory.sol";
import "./interface/IRelayerHub.sol";
import "./interface/IParamSubscriber.sol";
import "./System.sol";
import "./lib/SafeMath.sol";


contract RelayerHub is IRelayerHub, System, IParamSubscriber{
  using SafeMath for uint256;

  uint256 public constant INIT_REQUIRED_DEPOSIT =  1e20;
  uint256 public constant INIT_DUES =  1e17;

  uint256 public requiredDeposit;
  uint256 public dues;

  mapping(address =>relayer) relayers;
  mapping(address =>bool) relayersExistMap;

  struct relayer{
    uint256 deposit;
    uint256  dues;
  }

  modifier notContract() {
    require(!isContract(msg.sender), "contract is not allowed to be a relayer");
    _;
  }

  modifier noProxy() {
    require(msg.sender == tx.origin, "no proxy is allowed");
    _;
  }

  modifier noExist() {
    require(!relayersExistMap[msg.sender], "relayer already exist");
    _;
  }

  modifier exist() {
    require(relayersExistMap[msg.sender], "relayer do not exist");
    _;
  }

  event relayerRegister(address _relayer);
  event relayerUnRegister(address _relayer);
  event paramChange(string key, bytes value);


  function init() external onlyNotInit{
    requiredDeposit = INIT_REQUIRED_DEPOSIT;
    dues = INIT_DUES;
    alreadyInit = true;
  }

  function register() external payable noExist onlyInit notContract noProxy{
    // require(msg.value == requiredDeposit, "deposit value is not exactly the same");
    relayers[msg.sender] = relayer(requiredDeposit, dues);
    relayersExistMap[msg.sender] = true;
    emit relayerRegister(msg.sender);
  }

  function  unregister() external exist onlyInit{
    relayer memory r = relayers[msg.sender];
    msg.sender.transfer(r.deposit.sub(r.dues));
    address payable systemPayable = address(uint160(SYSTEM_REWARD_ADDR));
    systemPayable.transfer(r.dues);
    delete relayersExistMap[msg.sender];
    delete relayers[msg.sender];
    emit relayerUnRegister(msg.sender);
  }

  /*********************** Param update ********************************/
  function updateParam(string calldata key, bytes calldata value) external override onlyInit onlyGov{
    if (Memory.compareStrings(key,"requiredDeposit")) {
      require(value.length == 32, "length of requiredDeposit mismatch");
      uint256 newRequiredDeposit = BytesToTypes.bytesToUint256(32, value);
      require(newRequiredDeposit > 1 && newRequiredDeposit <= 1e21 && newRequiredDeposit > dues, "the requiredDeposit out of range");
      requiredDeposit = newRequiredDeposit;
    } else if (Memory.compareStrings(key,"dues")) {
      require(value.length == 32, "length of dues mismatch");
      uint256 newDues = BytesToTypes.bytesToUint256(32, value);
      require(newDues > 0 && newDues < requiredDeposit, "the dues out of range");
      dues = newDues;
    } else {
      require(false, "unknown param");
    }
    emit paramChange(key, value);
  }

  function isRelayer(address sender) external override view returns (bool) {
    return relayersExistMap[sender];
  }
}

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
    // length of the providd bytes array.
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

pragma solidity 0.6.4;

interface ISystemReward {
  function claimRewards(address payable to, uint256 amount) external returns(uint256 actualAmount);
}

pragma solidity 0.6.4;

interface IRelayerHub {
  function isRelayer(address sender) external view returns (bool);
}

pragma solidity 0.6.4;

interface IParamSubscriber {
    function updateParam(string calldata key, bytes calldata value) external;
}

pragma solidity 0.6.4;

interface ILightClient {

  function isHeaderSynced(uint64 height) external view returns (bool);

  function getAppHash(uint64 height) external view returns (bytes32);

  function getSubmitter(uint64 height) external view returns (address payable);

}

pragma solidity 0.6.4;

import "./interface/ISystemReward.sol";
import "./interface/IRelayerHub.sol";
import "./interface/ILightClient.sol";

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
  uint16 constant public bscChainID = 0x0060;

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