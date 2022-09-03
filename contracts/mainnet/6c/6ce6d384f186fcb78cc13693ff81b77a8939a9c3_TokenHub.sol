/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// File: contracts/TokenHub.sol

/**
 *Submitted for verification at BscScan.com on 2021-03-01
*/

// File: contracts/interface/IBEP20.sol

pragma solidity 0.6.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

}

// File: contracts/interface/IParamSubscriber.sol

pragma solidity 0.6.4;

interface IParamSubscriber {
    function updateParam(string calldata key, bytes calldata value) external;
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

// File: contracts/interface/ISystemReward.sol

pragma solidity 0.6.4;

interface ISystemReward {
  function claimRewards(address payable to, uint256 amount) external returns(uint256 actualAmount);
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

// File: contracts/TokenHub.sol

pragma solidity 0.6.4;











contract TokenHub is ITokenHub, System, IParamSubscriber, IApplication, ISystemReward {

  using SafeMath for uint256;

  using RLPEncode for *;
  using RLPDecode for *;

  using RLPDecode for RLPDecode.RLPItem;
  using RLPDecode for RLPDecode.Iterator;

  // BSC to BC
  struct TransferOutSynPackage {
    bytes32 bep2TokenSymbol;
    address contractAddr;
    uint256[] amounts;
    address[] recipients;
    address[] refundAddrs;
    uint64  expireTime;
  }

  // BC to BSC
  struct TransferOutAckPackage {
    address contractAddr;
    uint256[] refundAmounts;
    address[] refundAddrs;
    uint32 status;
  }

  // BC to BSC
  struct TransferInSynPackage {
    bytes32 bep2TokenSymbol;
    address contractAddr;
    uint256 amount;
    address recipient;
    address refundAddr;
    uint64  expireTime;
  }

  // BSC to BC
  struct TransferInRefundPackage {
    bytes32 bep2TokenSymbol;
    uint256 refundAmount;
    address refundAddr;
    uint32 status;
  }

  // transfer in channel
  uint8 constant public   TRANSFER_IN_SUCCESS = 0;
  uint8 constant public   TRANSFER_IN_FAILURE_TIMEOUT = 1;
  uint8 constant public   TRANSFER_IN_FAILURE_UNBOUND_TOKEN = 2;
  uint8 constant public   TRANSFER_IN_FAILURE_INSUFFICIENT_BALANCE = 3;
  uint8 constant public   TRANSFER_IN_FAILURE_NON_PAYABLE_RECIPIENT = 4;
  uint8 constant public   TRANSFER_IN_FAILURE_UNKNOWN = 5;

  uint256 constant public MAX_BEP2_TOTAL_SUPPLY = 9000000000000000000;
  uint8 constant public   MINIMUM_BEP20_SYMBOL_LEN = 2;
  uint8 constant public   MAXIMUM_BEP20_SYMBOL_LEN = 8;
  uint8 constant public   BEP2_TOKEN_DECIMALS = 8;
  bytes32 constant public BEP2_TOKEN_SYMBOL_FOR_BNB = 0x424E420000000000000000000000000000000000000000000000000000000000; // "BNB"
  uint256 constant public MAX_GAS_FOR_CALLING_BEP20=50000;
  uint256 constant public MAX_GAS_FOR_TRANSFER_BNB=10000;

  uint256 constant public INIT_MINIMUM_RELAY_FEE =2e15;
  uint256 constant public REWARD_UPPER_LIMIT =1e18;
  uint256 constant public TEN_DECIMALS = 1e10;

  uint256 public relayFee;

  mapping(address => uint256) public bep20ContractDecimals;
  mapping(address => bytes32) private contractAddrToBEP2Symbol;
  mapping(bytes32 => address) private bep2SymbolToContractAddr;

  event transferInSuccess(address bep20Addr, address refundAddr, uint256 amount);
  event transferOutSuccess(address bep20Addr, address senderAddr, uint256 amount, uint256 relayFee);
  event refundSuccess(address bep20Addr, address refundAddr, uint256 amount, uint32 status);
  event refundFailure(address bep20Addr, address refundAddr, uint256 amount, uint32 status);
  event rewardTo(address to, uint256 amount);
  event receiveDeposit(address from, uint256 amount);
  event unexpectedPackage(uint8 channelId, bytes msgBytes);
  event paramChange(string key, bytes value);

  constructor() public {}

  function init() onlyNotInit external {
    relayFee = INIT_MINIMUM_RELAY_FEE;
    bep20ContractDecimals[address(0x0)] = 18; // BNB decimals is 18
    alreadyInit=true;
  }

  receive() external payable{
    if (msg.value>0) {
      emit receiveDeposit(msg.sender, msg.value);
    }
  }

  function claimRewards(address payable to, uint256 amount) onlyInit onlyRelayerIncentivize external override returns(uint256) {
    uint256 actualAmount = amount < address(this).balance ? amount : address(this).balance;
    if (actualAmount > REWARD_UPPER_LIMIT) {
      return 0;
    }
    if (actualAmount>0) {
      to.transfer(actualAmount);
      emit rewardTo(to, actualAmount);
    }
    return actualAmount;
  }

  function getMiniRelayFee() external view override returns(uint256) {
    return relayFee;
  }

  function handleSynPackage(uint8 channelId, bytes calldata msgBytes) onlyInit onlyCrossChainContract external override returns(bytes memory) {
    if (channelId == TRANSFER_IN_CHANNELID) {
      return handleTransferInSynPackage(msgBytes);
    } else {
      // should not happen
      require(false, "unrecognized syn package");
      return new bytes(0);
    }
  }

  function handleAckPackage(uint8 channelId, bytes calldata msgBytes) onlyInit onlyCrossChainContract external override {
    if (channelId == TRANSFER_OUT_CHANNELID) {
      handleTransferOutAckPackage(msgBytes);
    } else {
      emit unexpectedPackage(channelId, msgBytes);
    }
  }

  function handleFailAckPackage(uint8 channelId, bytes calldata msgBytes) onlyInit onlyCrossChainContract external override {
    if (channelId == TRANSFER_OUT_CHANNELID) {
      handleTransferOutFailAckPackage(msgBytes);
    } else {
      emit unexpectedPackage(channelId, msgBytes);
    }
  }

  function decodeTransferInSynPackage(bytes memory msgBytes) internal pure returns (TransferInSynPackage memory, bool) {
    TransferInSynPackage memory transInSynPkg;

    RLPDecode.Iterator memory iter = msgBytes.toRLPItem().iterator();
    bool success = false;
    uint256 idx=0;
    while (iter.hasNext()) {
      if (idx == 0) transInSynPkg.bep2TokenSymbol       = bytes32(iter.next().toUint());
      else if (idx == 1) transInSynPkg.contractAddr     = iter.next().toAddress();
      else if (idx == 2) transInSynPkg.amount           = iter.next().toUint();
      else if (idx == 3) transInSynPkg.recipient        = ((iter.next().toAddress()));
      else if (idx == 4) transInSynPkg.refundAddr       = iter.next().toAddress();
      else if (idx == 5) {
        transInSynPkg.expireTime       = uint64(iter.next().toUint());
        success = true;
      }
      else break;
      idx++;
    }
    return (transInSynPkg, success);
  }

  function encodeTransferInRefundPackage(TransferInRefundPackage memory transInAckPkg) internal pure returns (bytes memory) {
    bytes[] memory elements = new bytes[](4);
    elements[0] = uint256(transInAckPkg.bep2TokenSymbol).encodeUint();
    elements[1] = transInAckPkg.refundAmount.encodeUint();
    elements[2] = transInAckPkg.refundAddr.encodeAddress();
    elements[3] = uint256(transInAckPkg.status).encodeUint();
    return elements.encodeList();
  }

  function handleTransferInSynPackage(bytes memory msgBytes) internal returns(bytes memory) {
    (TransferInSynPackage memory transInSynPkg, bool success) = decodeTransferInSynPackage(msgBytes);
    require(success, "unrecognized transferIn package");
    uint32 resCode = doTransferIn(transInSynPkg);
    if (resCode != TRANSFER_IN_SUCCESS) {
      uint256 bep2Amount = convertToBep2Amount(transInSynPkg.amount, bep20ContractDecimals[transInSynPkg.contractAddr]);
      TransferInRefundPackage memory transInAckPkg = TransferInRefundPackage({
          bep2TokenSymbol: transInSynPkg.bep2TokenSymbol,
          refundAmount: bep2Amount,
          refundAddr: transInSynPkg.refundAddr,
          status: resCode
      });
      return encodeTransferInRefundPackage(transInAckPkg);
    } else {
      return new bytes(0);
    }
  }

  function doTransferIn(TransferInSynPackage memory transInSynPkg) internal returns (uint32) {
    if (transInSynPkg.contractAddr==address(0x0)) {
      if (block.timestamp > transInSynPkg.expireTime) {
        return TRANSFER_IN_FAILURE_TIMEOUT;
      }
      if (address(this).balance < transInSynPkg.amount) {
        return TRANSFER_IN_FAILURE_INSUFFICIENT_BALANCE;
      }
      (bool success, ) = transInSynPkg.recipient.call{gas: MAX_GAS_FOR_TRANSFER_BNB, value: transInSynPkg.amount}("");
      if (!success) {
        return TRANSFER_IN_FAILURE_NON_PAYABLE_RECIPIENT;
      }
      emit transferInSuccess(transInSynPkg.contractAddr, transInSynPkg.recipient, transInSynPkg.amount);
      return TRANSFER_IN_SUCCESS;
    } else {
      if (block.timestamp > transInSynPkg.expireTime) {
        return TRANSFER_IN_FAILURE_TIMEOUT;
      }
      if (contractAddrToBEP2Symbol[transInSynPkg.contractAddr]!= transInSynPkg.bep2TokenSymbol) {
        return TRANSFER_IN_FAILURE_UNBOUND_TOKEN;
      }
      uint256 actualBalance = IBEP20(transInSynPkg.contractAddr).balanceOf{gas: MAX_GAS_FOR_CALLING_BEP20}(address(this));
      if (actualBalance < transInSynPkg.amount) {
        return TRANSFER_IN_FAILURE_INSUFFICIENT_BALANCE;
      }
      bool success = IBEP20(transInSynPkg.contractAddr).transfer{gas: MAX_GAS_FOR_CALLING_BEP20}(transInSynPkg.recipient, transInSynPkg.amount);
      if (success) {
        emit transferInSuccess(transInSynPkg.contractAddr, transInSynPkg.recipient, transInSynPkg.amount);
        return TRANSFER_IN_SUCCESS;
      } else {
        return TRANSFER_IN_FAILURE_UNKNOWN;
      }
    }
  }

  function decodeTransferOutAckPackage(bytes memory msgBytes) internal pure returns(TransferOutAckPackage memory, bool) {
    TransferOutAckPackage memory transOutAckPkg;

    RLPDecode.Iterator memory iter = msgBytes.toRLPItem().iterator();
    bool success = false;
    uint256 idx=0;
    while (iter.hasNext()) {
        if (idx == 0) {
          transOutAckPkg.contractAddr = iter.next().toAddress();
        }
        else if (idx == 1) {
          RLPDecode.RLPItem[] memory list = iter.next().toList();
          transOutAckPkg.refundAmounts = new uint256[](list.length);
          for (uint256 index=0; index<list.length; index++) {
            transOutAckPkg.refundAmounts[index] = list[index].toUint();
          }
        }
        else if (idx == 2) {
          RLPDecode.RLPItem[] memory list = iter.next().toList();
          transOutAckPkg.refundAddrs = new address[](list.length);
          for (uint256 index=0; index<list.length; index++) {
            transOutAckPkg.refundAddrs[index] = list[index].toAddress();
          }
        }
        else if (idx == 3) {
          transOutAckPkg.status = uint32(iter.next().toUint());
          success = true;
        }
        else {
          break;
        }
        idx++;
    }
    return (transOutAckPkg, success);
  }

  function handleTransferOutAckPackage(bytes memory msgBytes) internal {
    (TransferOutAckPackage memory transOutAckPkg, bool decodeSuccess) = decodeTransferOutAckPackage(msgBytes);
    require(decodeSuccess, "unrecognized transferOut ack package");
    doRefund(transOutAckPkg);
  }

  function doRefund(TransferOutAckPackage memory transOutAckPkg) internal {
    if (transOutAckPkg.contractAddr==address(0x0)) {
      for (uint256 index = 0; index<transOutAckPkg.refundAmounts.length; index++) {
        (bool success, ) = transOutAckPkg.refundAddrs[index].call{gas: MAX_GAS_FOR_TRANSFER_BNB, value: transOutAckPkg.refundAmounts[index]}("");
        if (!success) {
          emit refundFailure(transOutAckPkg.contractAddr, transOutAckPkg.refundAddrs[index], transOutAckPkg.refundAmounts[index], transOutAckPkg.status);
        } else {
          emit refundSuccess(transOutAckPkg.contractAddr, transOutAckPkg.refundAddrs[index], transOutAckPkg.refundAmounts[index], transOutAckPkg.status);
        }
      }
    } else {
      for (uint256 index = 0; index<transOutAckPkg.refundAmounts.length; index++) {
        bool success = IBEP20(transOutAckPkg.contractAddr).transfer{gas: MAX_GAS_FOR_CALLING_BEP20}(transOutAckPkg.refundAddrs[index], transOutAckPkg.refundAmounts[index]);
        if (success) {
          emit refundSuccess(transOutAckPkg.contractAddr, transOutAckPkg.refundAddrs[index], transOutAckPkg.refundAmounts[index], transOutAckPkg.status);
        } else {
          emit refundFailure(transOutAckPkg.contractAddr, transOutAckPkg.refundAddrs[index], transOutAckPkg.refundAmounts[index], transOutAckPkg.status);
        }
      }
    }
  }

  function decodeTransferOutSynPackage(bytes memory msgBytes) internal pure returns (TransferOutSynPackage memory, bool) {
    TransferOutSynPackage memory transOutSynPkg;

    RLPDecode.Iterator memory iter = msgBytes.toRLPItem().iterator();
    bool success = false;
    uint256 idx=0;
    while (iter.hasNext()) {
      if (idx == 0) {
        transOutSynPkg.bep2TokenSymbol = bytes32(iter.next().toUint());
      } else if (idx == 1) {
        transOutSynPkg.contractAddr = iter.next().toAddress();
      } else if (idx == 2) {
        RLPDecode.RLPItem[] memory list = iter.next().toList();
        transOutSynPkg.amounts = new uint256[](list.length);
        for (uint256 index=0; index<list.length; index++) {
          transOutSynPkg.amounts[index] = list[index].toUint();
        }
      } else if (idx == 3) {
        RLPDecode.RLPItem[] memory list = iter.next().toList();
        transOutSynPkg.recipients = new address[](list.length);
        for (uint256 index=0; index<list.length; index++) {
          transOutSynPkg.recipients[index] = list[index].toAddress();
        }
      } else if (idx == 4) {
        RLPDecode.RLPItem[] memory list = iter.next().toList();
        transOutSynPkg.refundAddrs = new address[](list.length);
        for (uint256 index=0; index<list.length; index++) {
          transOutSynPkg.refundAddrs[index] = list[index].toAddress();
        }
      } else if (idx == 5) {
        transOutSynPkg.expireTime = uint64(iter.next().toUint());
        success = true;
      } else {
        break;
      }
      idx++;
    }
    return (transOutSynPkg, success);
  }

  function handleTransferOutFailAckPackage(bytes memory msgBytes) internal {
    (TransferOutSynPackage memory transOutSynPkg, bool decodeSuccess) = decodeTransferOutSynPackage(msgBytes);
    require(decodeSuccess, "unrecognized transferOut syn package");
    TransferOutAckPackage memory transOutAckPkg;
    transOutAckPkg.contractAddr = transOutSynPkg.contractAddr;
    transOutAckPkg.refundAmounts = transOutSynPkg.amounts;
    uint256 bep20TokenDecimals = bep20ContractDecimals[transOutSynPkg.contractAddr];
    for (uint idx=0;idx<transOutSynPkg.amounts.length;idx++) {
      transOutSynPkg.amounts[idx] = convertFromBep2Amount(transOutSynPkg.amounts[idx], bep20TokenDecimals);
    }
    transOutAckPkg.refundAddrs = transOutSynPkg.refundAddrs;
    transOutAckPkg.status = TRANSFER_IN_FAILURE_UNKNOWN;
    doRefund(transOutAckPkg);
  }

  function encodeTransferOutSynPackage(TransferOutSynPackage memory transOutSynPkg) internal pure returns (bytes memory) {
    bytes[] memory elements = new bytes[](6);

    elements[0] = uint256(transOutSynPkg.bep2TokenSymbol).encodeUint();
    elements[1] = transOutSynPkg.contractAddr.encodeAddress();

    uint256 batchLength = transOutSynPkg.amounts.length;

    bytes[] memory amountsElements = new bytes[](batchLength);
    for (uint256 index = 0; index< batchLength; index++) {
      amountsElements[index] = transOutSynPkg.amounts[index].encodeUint();
    }
    elements[2] = amountsElements.encodeList();

    bytes[] memory recipientsElements = new bytes[](batchLength);
    for (uint256 index = 0; index< batchLength; index++) {
       recipientsElements[index] = transOutSynPkg.recipients[index].encodeAddress();
    }
    elements[3] = recipientsElements.encodeList();

    bytes[] memory refundAddrsElements = new bytes[](batchLength);
    for (uint256 index = 0; index< batchLength; index++) {
       refundAddrsElements[index] = transOutSynPkg.refundAddrs[index].encodeAddress();
    }
    elements[4] = refundAddrsElements.encodeList();

    elements[5] = uint256(transOutSynPkg.expireTime).encodeUint();
    return elements.encodeList();
  }

  function transferOut(address contractAddr, address recipient, uint256 amount, uint64 expireTime) external override onlyInit payable returns (bool) {
    require(expireTime>=block.timestamp + 120, "expireTime must be two minutes later");
    require(msg.value%TEN_DECIMALS==0, "invalid received BNB amount: precision loss in amount conversion");
    bytes32 bep2TokenSymbol;
    uint256 convertedAmount;
    uint256 rewardForRelayer;
    if (contractAddr==address(0x0)) {
      require(msg.value>=amount.add(relayFee), "received BNB amount should be no less than the sum of transferOut BNB amount and minimum relayFee");
      require(amount%TEN_DECIMALS==0, "invalid transfer amount: precision loss in amount conversion");
      rewardForRelayer=msg.value.sub(amount);
      convertedAmount = amount.div(TEN_DECIMALS); // native bnb decimals is 8 on BBC, while the native bnb decimals on BSC is 18
      bep2TokenSymbol=BEP2_TOKEN_SYMBOL_FOR_BNB;
    } else {
      bep2TokenSymbol = contractAddrToBEP2Symbol[contractAddr];
      require(bep2TokenSymbol!=bytes32(0x00), "the contract has not been bound to any bep2 token");
      require(msg.value>=relayFee, "received BNB amount should be no less than the minimum relayFee");
      rewardForRelayer=msg.value;
      uint256 bep20TokenDecimals=bep20ContractDecimals[contractAddr];
      require(bep20TokenDecimals<=BEP2_TOKEN_DECIMALS || (bep20TokenDecimals>BEP2_TOKEN_DECIMALS && amount.mod(10**(bep20TokenDecimals-BEP2_TOKEN_DECIMALS))==0), "invalid transfer amount: precision loss in amount conversion");
      convertedAmount = convertToBep2Amount(amount, bep20TokenDecimals);// convert to bep2 amount
      if (isMiniBEP2Token(bep2TokenSymbol)) {
        require(convertedAmount >= 1e8 , "For miniToken, the transfer amount must not be less than 1");
      }
      require(bep20TokenDecimals>=BEP2_TOKEN_DECIMALS || (bep20TokenDecimals<BEP2_TOKEN_DECIMALS && convertedAmount>amount), "amount is too large, uint256 overflow");
      require(convertedAmount<=MAX_BEP2_TOTAL_SUPPLY, "amount is too large, exceed maximum bep2 token amount");
      require(IBEP20(contractAddr).transferFrom(msg.sender, address(this), amount));
    }
    TransferOutSynPackage memory transOutSynPkg = TransferOutSynPackage({
      bep2TokenSymbol: bep2TokenSymbol,
      contractAddr: contractAddr,
      amounts: new uint256[](1),
      recipients: new address[](1),
      refundAddrs: new address[](1),
      expireTime: expireTime
    });
    transOutSynPkg.amounts[0]=convertedAmount;
    transOutSynPkg.recipients[0]=recipient;
    transOutSynPkg.refundAddrs[0]=msg.sender;
    ICrossChain(CROSS_CHAIN_CONTRACT_ADDR).sendSynPackage(TRANSFER_OUT_CHANNELID, encodeTransferOutSynPackage(transOutSynPkg), rewardForRelayer.div(TEN_DECIMALS));
    emit transferOutSuccess(contractAddr, msg.sender, amount, rewardForRelayer);
    return true;
  }

  function batchTransferOutBNB(address[] calldata recipientAddrs, uint256[] calldata amounts, address[] calldata refundAddrs, uint64 expireTime) external override onlyInit payable returns (bool) {
    require(recipientAddrs.length == amounts.length, "Length of recipientAddrs doesn't equal to length of amounts");
    require(recipientAddrs.length == refundAddrs.length, "Length of recipientAddrs doesn't equal to length of refundAddrs");
    require(expireTime>=block.timestamp + 120, "expireTime must be two minutes later");
    require(msg.value%TEN_DECIMALS==0, "invalid received BNB amount: precision loss in amount conversion");
    uint256 batchLength = amounts.length;
    uint256 totalAmount = 0;
    uint256 rewardForRelayer;
    uint256[] memory convertedAmounts = new uint256[](batchLength);
    for (uint i = 0; i < batchLength; i++) {
      require(amounts[i]%TEN_DECIMALS==0, "invalid transfer amount: precision loss in amount conversion");
      totalAmount = totalAmount.add(amounts[i]);
      convertedAmounts[i] = amounts[i].div(TEN_DECIMALS);
    }
    require(msg.value>=totalAmount.add(relayFee.mul(batchLength)), "received BNB amount should be no less than the sum of transfer BNB amount and relayFee");
    rewardForRelayer = msg.value.sub(totalAmount);

    TransferOutSynPackage memory transOutSynPkg = TransferOutSynPackage({
      bep2TokenSymbol: BEP2_TOKEN_SYMBOL_FOR_BNB,
      contractAddr: address(0x00),
      amounts: convertedAmounts,
      recipients: recipientAddrs,
      refundAddrs: refundAddrs,
      expireTime: expireTime
    });
    ICrossChain(CROSS_CHAIN_CONTRACT_ADDR).sendSynPackage(TRANSFER_OUT_CHANNELID, encodeTransferOutSynPackage(transOutSynPkg), rewardForRelayer.div(TEN_DECIMALS));
    emit transferOutSuccess(address(0x0), msg.sender, totalAmount, rewardForRelayer);
    return true;
  }

  function updateParam(string calldata key, bytes calldata value) override external onlyGov{
    require(value.length == 32, "expected value length is 32");
    string memory localKey = key;
    bytes memory localValue = value;
    bytes32 bytes32Key;
    assembly {
      bytes32Key := mload(add(localKey, 32))
    }
    if (bytes32Key == bytes32(0x72656c6179466565000000000000000000000000000000000000000000000000)) { // relayFee
      uint256 newRelayFee;
      assembly {
        newRelayFee := mload(add(localValue, 32))
      }
      require(newRelayFee <= 1e18 && newRelayFee%(TEN_DECIMALS)==0, "the relayFee out of range");
      relayFee = newRelayFee;
    } else {
      require(false, "unknown param");
    }
    emit paramChange(key, value);
  }

  function getContractAddrByBEP2Symbol(bytes32 bep2Symbol) external view override returns(address) {
    return bep2SymbolToContractAddr[bep2Symbol];
  }

  function getBep2SymbolByContractAddr(address contractAddr) external view override returns(bytes32) {
    return contractAddrToBEP2Symbol[contractAddr];
  }

  function bindToken(bytes32 bep2Symbol, address contractAddr, uint256 decimals) external override onlyTokenManager {
    bep2SymbolToContractAddr[bep2Symbol] = contractAddr;
    contractAddrToBEP2Symbol[contractAddr] = bep2Symbol;
    bep20ContractDecimals[contractAddr] = decimals;
  }

  function unbindToken(bytes32 bep2Symbol, address contractAddr) external override onlyTokenManager {
    delete bep2SymbolToContractAddr[bep2Symbol];
    delete contractAddrToBEP2Symbol[contractAddr];
  }

  function isMiniBEP2Token(bytes32 symbol) internal pure returns(bool) {
     bytes memory symbolBytes = new bytes(32);
     assembly {
       mstore(add(symbolBytes, 32), symbol)
     }
     uint8 symbolLength = 0;
     for (uint8 j = 0; j < 32; j++) {
       if (symbolBytes[j] != 0) {
         symbolLength++;
       } else {
         break;
       }
     }
     if (symbolLength < MINIMUM_BEP20_SYMBOL_LEN + 5) {
       return false;
     }
     if (symbolBytes[symbolLength-5] != 0x2d) { // '-'
       return false;
     }
     if (symbolBytes[symbolLength-1] != 'M') { // ABC-XXXM
       return false;
     }
     return true;
  }

  function convertToBep2Amount(uint256 amount, uint256 bep20TokenDecimals) internal pure returns (uint256) {
    if (bep20TokenDecimals > BEP2_TOKEN_DECIMALS) {
      return amount.div(10**(bep20TokenDecimals-BEP2_TOKEN_DECIMALS));
    }
    return amount.mul(10**(BEP2_TOKEN_DECIMALS-bep20TokenDecimals));
  }

  function convertFromBep2Amount(uint256 amount, uint256 bep20TokenDecimals) internal pure returns (uint256) {
    if (bep20TokenDecimals > BEP2_TOKEN_DECIMALS) {
      return amount.mul(10**(bep20TokenDecimals-BEP2_TOKEN_DECIMALS));
    }
    return amount.div(10**(BEP2_TOKEN_DECIMALS-bep20TokenDecimals));
  }

  function getBoundContract(string memory bep2Symbol) public view returns (address) {
    bytes32 bep2TokenSymbol;
    assembly {
      bep2TokenSymbol := mload(add(bep2Symbol, 32))
    }
    return bep2SymbolToContractAddr[bep2TokenSymbol];
  }

  function getBoundBep2Symbol(address contractAddr) public view returns (string memory) {
    bytes32 bep2SymbolBytes32 = contractAddrToBEP2Symbol[contractAddr];
    bytes memory bep2SymbolBytes = new bytes(32);
    assembly {
      mstore(add(bep2SymbolBytes,32), bep2SymbolBytes32)
    }
    uint8 bep2SymbolLength = 0;
    for (uint8 j = 0; j < 32; j++) {
      if (bep2SymbolBytes[j] != 0) {
        bep2SymbolLength++;
      } else {
        break;
      }
    }
    bytes memory bep2Symbol = new bytes(bep2SymbolLength);
    for (uint8 j = 0; j < bep2SymbolLength; j++) {
        bep2Symbol[j] = bep2SymbolBytes[j];
    }
    return string(bep2Symbol);
  }
}