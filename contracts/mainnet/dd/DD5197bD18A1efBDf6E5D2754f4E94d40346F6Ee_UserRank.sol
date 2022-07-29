/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File contracts/librarys/Context.sol

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


// File contracts/librarys/Ownable.sol


pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/librarys/pod/IPodCore.sol

pragma solidity ^0.8.4;

interface IPodCore {
    enum TagFieldType {
        Bool,
        Uint256,
        Uint8,
        Uint16,
        Uint32,
        Uint64,
        Int256,
        Int8,
        Int16,
        Int32,
        Int64,
        Bytes1,
        Bytes2,
        Bytes3,
        Bytes4,
        Bytes8,
        Bytes20,
        Bytes32,
        Address,
        Bytes,
        String,
        //if a field is array, the must be followed by a filedType, and max elem of array is 65535
        //note that array type doest not support nested array!
        Array
    }

    enum AgentType {
        Address, // eoa address or ca address,
        TagClass // address has this TagClass Tag
    }

    //TagClassAgent can delegate tagClass owner permission to agent
    struct TagAgent {
        AgentType Type; //indicate the type of agent
        bytes20 Address; //EOA or CA Address or ClassId
    }

    struct TagClass {
        bytes18 ClassId;
        uint8 Version;
        address Owner; // EOA address or CA address
        bytes FieldTypes; //field types
        //TagClass Flags:
        //0x80:deprecated flag, if a TagClass is marked as deprecated, you cannot set Tag under this TagClass
        uint8 Flags;
        TagAgent Agent;
        address LogicContract; //Contract address of logic tagClass
    }

    struct TagClassInfo {
        bytes18 ClassId;
        uint8 Version;
        string TagName;
        bytes FieldNames; //name of fields
        string Desc;
        string Url; //Url of tagClass
    }

    enum ObjectType {
        Address, // eoa address or ca address
        NFT, // nft
        TagClass // tagClass
    }

    struct TagObject {
        ObjectType Type; //indicate the type of object
        bytes20 Address; //EOA address, CA address, or tagClassId
        uint256 TokenId; //NFT tokenId
    }

    struct Tag {
        bytes20 TagId;
        uint8 Version;
        bytes18 ClassId;
        uint32 ExpiredAt; //Expired time
        bytes Data;
    }
}


// File contracts/librarys/pod/ITag.sol

pragma solidity ^0.8.4;

interface ITag {
    event SetTag(
        bytes20 indexed id,
        bytes18 indexed tagClassId,
        IPodCore.TagObject object,
        bytes data,
        address issuer,
        uint32 expiredAt
    );

    event DeleteTag(
        bytes20 indexed id,
        bytes18 indexed tagClassId,
        IPodCore.TagObject object
    );

    function setTag(
        bytes18 tagClassId,
        IPodCore.TagObject calldata object,
        bytes calldata data,
        uint32 expiredTime //Expiration time of tag in seconds, 0 means never expires
    ) external;

    function setTagWithSig(
        bytes18 tagClassId,
        IPodCore.TagObject calldata object,
        bytes calldata data,
        uint32 expiredTime, //Expiration time of tag in seconds, 0 means never expires
        bytes calldata signature //Signature of owner or agent
    ) external;

    struct SetTagParams {
        bytes18 TagClassId;
        IPodCore.TagObject Object;
        bytes Data;
        uint32 ExpiredTime; //Expiration time of tag in seconds, 0 means never expires
    }

    function batchSetTags(ITag.SetTagParams[] calldata params) external;

    struct DeleteTagParams {
        bytes18 TagClassId;
        IPodCore.TagObject Object;
    }

    function deleteTag(bytes18 classId, IPodCore.TagObject calldata object)
        external;

    function deleteTagWithSig(
        bytes18 tagClassId,
        IPodCore.TagObject calldata object,
        bytes calldata signature //Signature of owner or agent
    ) external;

    function batchDeleteTags(DeleteTagParams[] calldata params) external;

    function hasTag(bytes18 tagClassId, IPodCore.TagObject calldata object)
        external
        view
        returns (bool valid);

    function getTagData(bytes18 tagClassId, IPodCore.TagObject calldata object)
        external
        view
        returns (bytes memory data);

    function getTag(bytes18 tagClassId, IPodCore.TagObject calldata object)
        external
        view
        returns (IPodCore.Tag memory tag, bool valid);
}


// File contracts/librarys/pod/WriteBuffer.sol

pragma solidity ^0.8.4;

/**
 * @dev A library for working with mutable byte buffers in Solidity.
 *
 * Byte buffers are mutable and expandable, and provide a variety of primitives
 * for writing to them. At any time you can fetch a bytes object containing the
 * current contents of the buffer. The bytes object should not be stored between
 * operations, as it may change due to resizing of the buffer.
 *
 * @author PodDB.
 */

library WriteBuffer {
    /**
     * @dev Represents a mutable buffer. Buffers have a current value (buf) and
     *      a capacity. The capacity may be longer than the current value, in
     *      which case it can be extended without the need to allocate more memory.
     */
    struct buffer {
        bytes buf;
        uint256 capacity;
    }

    /**
     * @dev Initializes a buffer with an initial capacity.
     * @param buf The buffer to initialize.
     * @param capacity The number of bytes of space to allocate the buffer.
     * @return The buffer, for chaining.
     */
    function init(buffer memory buf, uint256 capacity)
        internal
        pure
        returns (buffer memory)
    {
        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        // Allocate space for the buffer data
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(32, add(ptr, capacity)))
        }
        return buf;
    }

    /**
     * @dev Initializes a new buffer from an existing bytes object.
     *      Changes to the buffer may mutate the original value.
     * @param b The bytes object to initialize the buffer with.
     * @return A new buffer.
     */
    function fromBytes(bytes memory b) internal pure returns (buffer memory) {
        buffer memory buf;
        buf.buf = b;
        buf.capacity = b.length;
        return buf;
    }

    function resize(buffer memory buf, uint256 capacity) private pure {
        bytes memory oldBuf = buf.buf;
        init(buf, capacity);
        if (oldBuf.length == 0) {
            return;
        }
        writeFixedBytes(buf, oldBuf);
    }

    /**
     * @dev Sets buffer length to 0.
     * @param buf The buffer to truncate.
     * @return The original buffer, for chaining..
     */
    function truncate(buffer memory buf) internal pure returns (buffer memory) {
        assembly {
            let bufPtr := mload(buf)
            mstore(bufPtr, 0)
        }
        return buf;
    }

    /**
     * @dev Append the bytes to buffer, without write bytes length.
     *     Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bytes to write.
     * @return The original buffer, for chaining.
     */
    function writeFixedBytes(buffer memory buf, bytes memory data)
        internal
        pure
        returns (buffer memory)
    {
        uint256 dataLen = data.length;
        if (buf.buf.length + dataLen > buf.capacity) {
            resize(buf, (buf.buf.length + dataLen) * 2);
        }
        uint256 dest;
        uint256 src;
        assembly {
            //Memory address of buffer data
            let bufPtr := mload(buf)
            //Length of exiting buffer data
            let bufLen := mload(bufPtr)
            //Incr length of buffer
            mstore(bufPtr, add(bufLen, dataLen))
            //Start address
            dest := add(add(bufPtr, 32), bufLen)
            src := add(data, 32)
        }

        for (uint256 size = 0; size < dataLen; size += 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        return buf;
    }

    /**
     * @dev Append uint to buffer, according to Uint byte size.
     *     Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The uint to write.
     * @param len the byte size to write. For example: uint256 len is 32, uint128 len is 16, uint64 len is 8, and so on.
     * @return The original buffer, for chaining.
     */
    function writeVarUint(
        buffer memory buf,
        uint256 data,
        uint256 len
    ) internal pure returns (buffer memory) {
        require(len <= 32, "uint len cannot larger than 32");

        if (buf.buf.length + len > buf.capacity) {
            resize(buf, (buf.buf.length + len) * 2);
        }

        // Left-align data
        data = data << (8 * (32 - len));
        assembly {
            // Memory address of the buffer data
            let bufPtr := mload(buf)
            // Length of existing buffer data
            let bufLen := mload(bufPtr)
            let dest := add(add(bufPtr, 32), bufLen)
            mstore(dest, data)
            //Incr length of buffer
            mstore(bufPtr, add(bufLen, len))
        }
        return buf;
    }

    /**
     * @dev Write uint to buffer, according to Uint byte size.
     *     Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param offset The write position.
     * @param data The uint to write.
     * @param len the byte size to write. For example: uint256 len is 32, uint128 len is 16, uint64 len is 8, and so on.
     * @return The original buffer, for chaining.
     */
    function writeVarUintAt(
        buffer memory buf,
        uint256 offset,
        uint256 data,
        uint256 len
    ) internal pure returns (buffer memory) {
        require(offset <= buf.buf.length, "offset out of bound");
        require(len <= 32, "uint len cannot larger than 32");
        uint256 newLen = offset + len;
        if (newLen > buf.capacity) {
            resize(buf, newLen * 2);
        }

        uint256 tmp = len * 8;
        // Left-align data
        data = data << ((32 - len) * 8);
        bytes32 mask = (~bytes32(0) << tmp) >> tmp;
        assembly {
            // Memory address of the buffer data
            let bufPtr := mload(buf)
            // Length of existing buffer data
            let bufLen := mload(bufPtr)
            let dest := add(add(bufPtr, 32), offset)
            mstore(dest, or(data, and(mload(dest), mask)))

            //Update buffer length if we extended it
            if gt(newLen, bufLen) {
                mstore(bufPtr, newLen)
            }
        }
        return buf;
    }

    /**
     * @dev Append a uint8 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeUint8(buffer memory buf, uint8 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, data, 1);
    }

    /**
     * @dev Append a uint16 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeUint16(buffer memory buf, uint16 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, data, 2);
    }

    /**
     * @dev Append a uint32 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeUint32(buffer memory buf, uint32 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, data, 4);
    }

    /**
     * @dev Append a uint64 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeUint64(buffer memory buf, uint64 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, data, 8);
    }

    /**
     * @dev Append a uint256 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeUint256(buffer memory buf, uint256 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, data, 32);
    }

    /**
     * @dev Append an int8 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeInt8(buffer memory buf, int8 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, uint8(data), 1);
    }

    /**
     * @dev Append an int16 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeInt16(buffer memory buf, int16 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, uint16(data), 2);
    }

    /**
     * @dev Append an int32 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeInt32(buffer memory buf, int32 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, uint32(data), 4);
    }

    /**
     * @dev Append an int64 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeInt64(buffer memory buf, int64 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, uint64(data), 8);
    }

    /**
     * @dev Append an int256 number to the buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The number to append.
     * @return The original buffer, for chaining.
     */
    function writeInt256(buffer memory buf, int256 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, uint256(data), 32);
    }

    /**
     * @dev Append a length of a array or bytes to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param len The length of array or bytes.
     * @return The original buffer, for chaining.
     */
    function writeLength(buffer memory buf, uint256 len)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, len, 2);
    }

    /**
     * @dev Append a bytes to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer to append to
     * @param data The bytes to append. Before append the bytes, append the length to buffer first.
     * @return The original buffer, for chaining.
     */
    function writeBytes(buffer memory buf, bytes memory data)
        internal
        pure
        returns (buffer memory)
    {
        writeLength(buf, data.length);
        return writeFixedBytes(buf, data);
    }

    /**
     * @dev Write bytes32 to buffer, according to bytes32 byte size.
     *     Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bytes32 to write.
     * @param len the byte size to write. For example: bytes32 len is 32, bytes16 len is 16, bytes64 len is 8, and so on.
     * @return The original buffer, for chaining.
     */
    function writeVarBytes32(
        buffer memory buf,
        bytes32 data,
        uint256 len
    ) internal pure returns (buffer memory) {
        require(len <= 32, "bytes32 len cannot larger than 32");

        if (buf.buf.length + len > buf.capacity) {
            resize(buf, (buf.buf.length + len) * 2);
        }

        assembly {
            // Memory address of the buffer data
            let bufPtr := mload(buf)
            // Length of existing buffer data
            let bufLen := mload(bufPtr)
            let dest := add(add(bufPtr, 32), bufLen)
            mstore(dest, data)
            //Incr length of buffer
            mstore(bufPtr, add(bufLen, len))
        }
        return buf;
    }

    /**
     * @dev Write a byte to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The byte to write.
     * @return The original buffer, for chaining.
     */
    function writeBytes1(buffer memory buf, bytes1 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarBytes32(buf, data, 1);
    }

    /**
     * @dev Write bytes2 to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bytes2 to write.
     * @return The original buffer, for chaining.
     */
    function writeBytes2(buffer memory buf, bytes2 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarBytes32(buf, data, 2);
    }

    /**
     * @dev Write bytes4 to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bytes4 to write.
     * @return The original buffer, for chaining.
     */
    function writeBytes4(buffer memory buf, bytes4 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarBytes32(buf, data, 4);
    }

    /**
     * @dev Write bytes8 to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bytes8 to write.
     * @return The original buffer, for chaining.
     */
    function writeBytes8(buffer memory buf, bytes8 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarBytes32(buf, data, 8);
    }

    /**
     * @dev Write bytes20 to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bytes20 to write.
     * @return The original buffer, for chaining.
     */
    function writeBytes20(buffer memory buf, bytes20 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarBytes32(buf, data, 20);
    }

    /**
     * @dev Write bytes32 to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bytes32 to write.
     * @return The original buffer, for chaining.
     */
    function writeBytes32(buffer memory buf, bytes32 data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarBytes32(buf, data, 32);
    }

    /**
     * @dev Write a bool to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The bool to write.
     * @return The original buffer, for chaining.
     */
    function writeBool(buffer memory buf, bool data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarUint(buf, data ? 1 : 0, 1);
    }

    /**
     * @dev Write an address to buffer. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The address to write.
     * @return The original buffer, for chaining.
     */
    function writeAddress(buffer memory buf, address data)
        internal
        pure
        returns (buffer memory)
    {
        return writeVarBytes32(buf, bytes20(data), 20);
    }

    /**
     * @dev Write a string to buffer. The same to writeBytes in effect. Resizes if doing so would exceed the capacity of the buffer.
     * @param buf The buffer write to.
     * @param data The string to write.
     * @return The original buffer, for chaining.
     */
    function writeString(buffer memory buf, string memory data)
        internal
        pure
        returns (buffer memory)
    {
        return writeBytes(buf, bytes(data));
    }

    /**
     * @dev return the bytes in buffer. The bytes object should not be stored between
     *      operations, as it may change due to resizing of the buffer.
     * @param buf The buffer to read.
     * @return The bytes in buffer.
     */
    function getBytes(buffer memory buf) internal pure returns (bytes memory) {
        return buf.buf;
    }

    /**
     * @dev return the bytes size in buffer.
     * @param buf The buffer to read size.
     * @return The bytes size in buffer.
     */
    function length(buffer memory buf) internal pure returns (uint256) {
        return buf.buf.length;
    }
}


// File contracts/librarys/pod/ReadBuffer.sol

pragma solidity ^0.8.4;

/**
 * @dev A library for reading bytes buffer in Solidity.
 * @author PodDB.
 */

library ReadBuffer {
    /**
     * @dev Represents a bytes buffer. Buffers have a value (buf) and
     *      an offset indicate the position to read.
     */
    struct buffer {
        bytes buf;
        uint256 off;
    }

    /**
     * @dev Initializes a new buffer from an existing bytes object.
     * @param b The bytes object to initialize the buffer with.
     * @return A new buffer.
     */
    function fromBytes(bytes memory b) internal pure returns (buffer memory) {
        buffer memory buf;
        buf.buf = b;
        return buf;
    }

    /**
     * @dev Forward offset according the specific size without read any bytes.
     * @param buf The buffer read from.
     * @param len The bytes size to skip.
     */
    function skip(buffer memory buf, uint256 len) internal pure {
        uint256 l = buf.off + len;
        require(l <= buf.buf.length, "skip out of bounds");
        buf.off = l;
    }

    /**
     * @dev Forward offset accord bytes type without read any bytes.
     *     The active skip size is zhe bytes size and the bytes self.
     * @param buf The buffer read from.
     */
    function skipBytes(buffer memory buf) internal pure returns (uint256) {
        uint256 len = readVarUint(buf, 2);
        skip(buf, len);
        return len;
    }

    /**
     * @dev Forward offset accord string type without read any bytes.
     *     The same to skipBytes in effect.
     * @param buf The buffer read from.
     */
    function skipString(buffer memory buf) internal pure returns (uint256) {
        return skipBytes(buf);
    }

    /**
     * @dev Read a bytes according the specific bytes size from buffer.
     * @param buf The buffer read from.
     * @param len The bytes size to read.
     * @return A bytes object.
     */
    function readFixedBytes(buffer memory buf, uint256 len)
        internal
        pure
        returns (bytes memory)
    {
        uint256 off = buf.off;
        uint256 l = buf.off + len;
        require(l <= buf.buf.length, "readFixedBytes out of bounds");

        bytes memory data = new bytes(len);
        uint256 dest;
        uint256 src;
        assembly {
            // Memory address of the buffer data
            let bufPtr := mload(buf)
            src := add(add(bufPtr, 32), off)
            dest := add(data, 32)
        }

        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        if (len > 0) {
            // Copy remaining bytes
            uint256 mask = 256**(32 - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }

        buf.off = l;
        return data;
    }

    /**
     * @dev Read a length of an array or a bytes in the buffer.
     * @param buf The buffer read from.
     * @return The bytes size of the next array or next bytes.
     */
    function readLength(buffer memory buf) internal pure returns (uint256) {
        return readUint16(buf);
    }

    /**
     * @dev Read a bytes from buffer. Read the bytes size first from buffer, and then read the bytes self.
     * @param buf The buffer read from.
     * @return A bytes object.
     */
    function readBytes(buffer memory buf) internal pure returns (bytes memory) {
        uint256 len = readLength(buf);
        return readFixedBytes(buf, len);
    }

    /**
     * @dev Read a string from buffer. Read the bytes size first from buffer, and then read the string self.
     *      The same to readBytes in effect.
     * @param buf The buffer read from.
     * @return A bytes object.
     */
    function readString(buffer memory buf)
        internal
        pure
        returns (string memory)
    {
        return string(readBytes(buf));
    }

    /**
     * @dev Read a uint256 number from buffer. According the specific bytes size.
     * @param buf The buffer read from.
     * @param len the bytes size of uint256 number. For example: uint256 is 32, uint128 is 16, uint64 is 8, an so on.
     * @return data A uint256 number.
     */
    function readVarUint(buffer memory buf, uint256 len)
        internal
        pure
        returns (uint256 data)
    {
        uint256 off = buf.off;
        uint256 l = buf.off + len;
        require(len <= 32, "readVarUint len cannot larger than 32");
        require(l <= buf.buf.length, "readVarUint out of bounds");
        assembly {
            // Memory address of the buffer data
            let bufPtr := mload(buf)
            let src := add(add(bufPtr, 32), off)
            data := mload(src)
        }
        data = data >> ((32 - len) * 8);
        buf.off = l;
        return data;
    }

    /**
     * @dev Read a uint8 number from buffer.
     * @param buf The buffer read from.
     * @return A uint8 number.
     */
    function readUint8(buffer memory buf) internal pure returns (uint8) {
        return uint8(readVarUint(buf, 1));
    }

    /**
     * @dev Read a uint16 number from buffer.
     * @param buf The buffer read from.
     * @return A uint16 number.
     */
    function readUint16(buffer memory buf) internal pure returns (uint16) {
        return uint16(readVarUint(buf, 2));
    }

    /**
     * @dev Read a uint32 number from buffer.
     * @param buf The buffer read from.
     * @return A uint32 number.
     */
    function readUint32(buffer memory buf) internal pure returns (uint32) {
        return uint32(readVarUint(buf, 4));
    }

    /**
     * @dev Read a uint64 number from buffer.
     * @param buf The buffer read from.
     * @return A uint64 number.
     */
    function readUint64(buffer memory buf) internal pure returns (uint64) {
        return uint64(readVarUint(buf, 8));
    }

    /**
     * @dev Read a uint256 number from buffer.
     * @param buf The buffer read from.
     * @return A uint256 number.
     */
    function readUint256(buffer memory buf) internal pure returns (uint256) {
        return readVarUint(buf, 32);
    }

    /**
     * @dev Read an int8 number from buffer.
     * @param buf The buffer read from.
     * @return An int8 number.
     */
    function readInt8(buffer memory buf) internal pure returns (int8) {
        return int8(uint8(readVarUint(buf, 1)));
    }

    /**
     * @dev Read an int16 number from buffer.
     * @param buf The buffer read from.
     * @return An int16 number.
     */
    function readInt16(buffer memory buf) internal pure returns (int16) {
        return int16(uint16(readVarUint(buf, 2)));
    }

    /**
     * @dev Read an int32 number from buffer.
     * @param buf The buffer read from.
     * @return An int32 number.
     */
    function readInt32(buffer memory buf) internal pure returns (int32) {
        return int32(uint32(readVarUint(buf, 4)));
    }

    /**
     * @dev Read an int64 number from buffer.
     * @param buf The buffer read from.
     * @return An int64 number.
     */
    function readInt64(buffer memory buf) internal pure returns (int64) {
        return int64(uint64(readVarUint(buf, 8)));
    }

    /**
     * @dev Read an int256 number from buffer.
     * @param buf The buffer read from.
     * @return An int256 number.
     */
    function readInt256(buffer memory buf) internal pure returns (int256) {
        return int256(readVarUint(buf, 32));
    }

    /**
     * @dev Read a bytes32 from buffer. According the specific bytes size.
     * @param buf The buffer read from.
     * @param len The bytes size of bytes32. For example: byte32 is 32, byte16 is 16, byte8 is 8, an so on.
     * @return data A bytes object.
     */
    function readVarBytes32(buffer memory buf, uint256 len)
        internal
        pure
        returns (bytes32 data)
    {
        uint256 off = buf.off;
        uint256 l = buf.off + len;
        require(len <= 32, "readVarBytes32 len cannot larger than 32");
        require(l <= buf.buf.length, "readVarBytes32 out of bounds");
        assembly {
            // Memory address of the buffer data
            let bufPtr := mload(buf)
            let src := add(add(bufPtr, 32), off)
            data := mload(src)
        }
        buf.off = l;
        bytes32 mask = bytes32(~uint256(0)) << ((32 - len) * 8);
        data = data & mask;
        return data;
    }

    /**
     * @dev Read a bytes1 from buffer.
     * @param buf The buffer read from.
     * @return A bytes1 object.
     */
    function readBytes1(buffer memory buf) internal pure returns (bytes1) {
        return bytes1(readVarBytes32(buf, 1));
    }

    /**
     * @dev Read a bytes2 from buffer.
     * @param buf The buffer read from.
     * @return A bytes2 object.
     */
    function readBytes2(buffer memory buf) internal pure returns (bytes2) {
        return bytes2(readVarBytes32(buf, 2));
    }

    /**
     * @dev Read a bytes4 from buffer.
     * @param buf The buffer read from.
     * @return A bytes4 object.
     */
    function readBytes4(buffer memory buf) internal pure returns (bytes4) {
        return bytes4(readVarBytes32(buf, 4));
    }

    /**
     * @dev Read a bytes8 from buffer.
     * @param buf The buffer read from.
     * @return A bytes8 object.
     */
    function readBytes8(buffer memory buf) internal pure returns (bytes8) {
        return bytes8(readVarBytes32(buf, 8));
    }

    /**
     * @dev Read a bytes20 from buffer.
     * @param buf The buffer read from.
     * @return A bytes20 object.
     */
    function readBytes20(buffer memory buf) internal pure returns (bytes20) {
        return bytes20(readVarBytes32(buf, 20));
    }

    /**
     * @dev Read a bytes32 from buffer.
     * @param buf The buffer read from.
     * @return A bytes32 object.
     */
    function readBytes32(buffer memory buf) internal pure returns (bytes32) {
        return readVarBytes32(buf, 32);
    }

    /**
     * @dev Read an address from buffer.
     * @param buf The buffer read from.
     * @return An address object.
     */
    function readAddress(buffer memory buf) internal pure returns (address) {
        return address(bytes20(readVarBytes32(buf, 20)));
    }

    /**
     * @dev Read bool from buffer.
     * @param buf The buffer read from.
     * @return A bool object.
     */
    function readBool(buffer memory buf) internal pure returns (bool) {
        return readVarUint(buf, 1) > 0 ? true : false;
    }

    /**
     * @dev Reset the read offset to a specific value.
     * @param buf The buffer read from.
     * @param newOffset The specific offset to set.
     */
    function resetOffset(buffer memory buf, uint256 newOffset) internal pure {
        require(buf.buf.length >= newOffset, "new offset out of bound");
        buf.off = newOffset;
    }

    /**
     * @dev Return the bytes size unread.
     * @param buf The buffer read from.
     * @return The unread bytes size.
     */
    function left(buffer memory buf) internal pure returns (uint256) {
        return buf.buf.length - buf.off;
    }
}


// File contracts/librarys/IERC20.sol


pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


// File contracts/librarys/pod/PodHelper.sol

pragma solidity ^0.8.4;



library PodHelper {
    using WriteBuffer for *;
    using ReadBuffer for *;

    struct TagClassFieldBuilder {
        WriteBuffer.buffer _nBuf;
        WriteBuffer.buffer _tBuf;
    }

    function init(TagClassFieldBuilder memory builder)
        internal
        pure
        returns (TagClassFieldBuilder memory)
    {
        builder._nBuf.init(64);
        builder._tBuf.init(32);
        return builder;
    }

    function put(
        TagClassFieldBuilder memory builder,
        string memory fieldName,
        IPodCore.TagFieldType fieldType,
        bool isArray
    ) internal pure returns (TagClassFieldBuilder memory) {
        builder._nBuf.writeString(fieldName);
        if (isArray) {
            builder._tBuf.writeUint8(uint8(IPodCore.TagFieldType.Array));
        }
        builder._tBuf.writeUint8(uint8(fieldType));
        return builder;
    }

    function getFieldNames(TagClassFieldBuilder memory builder)
        internal
        pure
        returns (bytes memory)
    {
        return builder._nBuf.getBytes();
    }

    function getFieldTypes(TagClassFieldBuilder memory builder)
        internal
        pure
        returns (bytes memory)
    {
        return builder._tBuf.getBytes();
    }
}


// File contracts/librarys/pod/ITagClass.sol

pragma solidity ^0.8.4;

interface ITagClass {
    event NewTagClass(
        bytes18 indexed classId,
        string name,
        address indexed owner,
        bytes fieldNames,
        bytes fieldTypes,
        string desc,
        string url,
        uint8 flags,
        IPodCore.TagAgent agent,
        address logicContract
    );

    event TransferTagClassOwner(
        bytes18 indexed classId,
        address indexed newOwner
    );

    event UpdateTagClass(
        bytes18 indexed classId,
        uint8 flags,
        IPodCore.TagAgent agent,
        address logicContract
    );

    event UpdateTagClassInfo(
        bytes18 indexed classId,
        string name,
        string desc,
        string url
    );

    struct NewValueTagClassParams {
        string TagName;
        bytes FieldNames;
        bytes FieldTypes;
        string Desc;
        string Url;
        uint8 Flags;
        IPodCore.TagAgent Agent;
    }

    function newValueTagClass(NewValueTagClassParams calldata params)
        external
        returns (bytes18);

    struct NewLogicTagClassParams {
        string TagName;
        bytes FieldNames;
        bytes FieldTypes;
        string Desc;
        string Url;
        uint8 Flags;
        address LogicContract;
    }

    function newLogicTagClass(NewLogicTagClassParams calldata params)
        external
        returns (bytes18 classId);

    function updateValueTagClass(
        bytes18 classId,
        uint8 newFlags,
        IPodCore.TagAgent calldata newAgent
    ) external;

    function updateLogicTagClass(
        bytes18 classId,
        uint8 newFlags,
        address newLogicContract
    ) external;

    function updateTagClassInfo(
        bytes18 classId,
        string calldata tagName,
        string calldata desc,
        string calldata url
    ) external;

    function transferTagClassOwner(bytes18 classId, address newOwner) external;

    function getTagClass(bytes18 tagClassId)
        external
        view
        returns (IPodCore.TagClass memory tagClass);

    function getTagClassInfo(bytes18 tagClassId)
        external
        view
        returns (IPodCore.TagClassInfo memory classInfo);
}


// File @openzeppelin/contracts/utils/structs/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// File contracts/UserRank.sol


pragma solidity ^0.8.0;









interface PLCToken {
    function burnByUser(uint256 amount, address account) external;
    function transferBatch(address[] memory accounts, uint256[] memory amounts, address payAddr) external;
}

/**
 * @dev UserRank contract use to manage the UserRank Tag
 */
contract UserRank is Ownable {
    using ReadBuffer for *;
    using WriteBuffer for *;
    using PodHelper for *;
    using EnumerableSet for EnumerableSet.AddressSet;

    ITag public TagContract;
    ITagClass public TagClassContract;
    bytes18 public UserRankTagClassId;

    mapping(address => uint256[10]) private rankPayTokenInfos;
    EnumerableSet.AddressSet _rankPayTokens;

    address public receiveAddress;

    address public plcToken;
    address[] public plcReceiveAddrs;
    uint256[] public plcPercents;
    uint256 public plcPercentBurn = 100;
    event UpgradeRank(address indexed user, uint8 oldRank, uint8 newRank, address[] payTokens, uint256[] tokenFees);
    event PlcDistribution(address indexed user, uint8 oldRank, uint8 newRank, address[] receivers, uint256[] amounts, uint256 burnAmount);
    
    event UserRankTagClassCreate(
        address indexed contractAddress,
        bytes18 indexed userRankTagClassId
    );

    event UpdateTokenFees(address token, uint256[10] oldFees, uint256[10] newFees);

    event UpdateUserRankTagClassOwner(address newOwner);

    event UpdateTagContract(
        address indexed oldTagContractAddress,
        address indexed newTagContractAddress
    );

    event UpdateTagClassContract(
        address indexed oldTagClassContractAddress,
        address indexed newTagClassContractAddress
    );

    constructor(
        address tagClassContractAddress,
        address tagContractAddress,
        address _receiveAddress,
        address[] memory tokenAddressList, uint256[10][] memory tokenFeesList, 
        address _plcToken, address[] memory _plcReceiveAddrs, uint256[] memory _plcPercents
    ) Ownable() {
        TagContract = ITag(tagContractAddress);
        TagClassContract = ITagClass(tagClassContractAddress);
        receiveAddress = _receiveAddress;
        
        require(tokenAddressList.length == tokenFeesList.length, "token fee length error");
        for(uint256 i = 0; i < tokenAddressList.length; ++i) {
            _rankPayTokens.add(tokenAddressList[i]);
            rankPayTokenInfos[tokenAddressList[i]] = tokenFeesList[i];
        }

        require(_plcReceiveAddrs.length == _plcPercents.length, "plc length error");
        plcReceiveAddrs = _plcReceiveAddrs;
        plcPercents = _plcPercents;
        plcToken = _plcToken;
        uint256 percents = 0;
        for (uint256 i = 0; i < _plcPercents.length; ++i) {
            percents += _plcPercents[i];
        }
        require(percents <= 100, "percent error");
        plcPercentBurn = plcPercentBurn - percents;

        PodHelper.TagClassFieldBuilder memory builder;
        builder.init().put("rank", IPodCore.TagFieldType.Uint8, false);

        ITagClass.NewValueTagClassParams memory params;
        params.TagName = "UserRank";
        params.Desc = "Using to manage user rank";
        params.FieldNames = builder.getFieldNames();
        params.FieldTypes = builder.getFieldTypes();
        params.Agent = IPodCore.TagAgent(
            IPodCore.AgentType.Address,
            bytes20(address(this))
        );

        UserRankTagClassId = TagClassContract.newValueTagClass(params);

        emit UserRankTagClassCreate(address(this), UserRankTagClassId);
    }
    function addRankPayToken(address[] calldata tokenList, uint256[10][] calldata feeList) external onlyOwner {
        require(tokenList.length == feeList.length, "length error");
        for(uint256 i = 0; i < tokenList.length; ++i) {
            _rankPayTokens.add(tokenList[i]);
            rankPayTokenInfos[tokenList[i]] = feeList[i];
        }
    }
    function removeRankPayToken(address [] calldata tokenList) external onlyOwner {
        for(uint256 i = 0; i < tokenList.length; ++i) {
            if (_rankPayTokens.contains(tokenList[i])) {
                _rankPayTokens.remove(tokenList[i]);
            }
        }
    }
    function isRankPayToken(address token) public view returns(bool) {
        return _rankPayTokens.contains(token);
    }
    function getRankPayTokens() view public returns(address[] memory) {
        address[] memory tokens = new address[](_rankPayTokens.length());
        for(uint256 i = 0; i < _rankPayTokens.length(); ++i) {
            tokens[i] = _rankPayTokens.at(i);
        }
        return tokens;
    }
    function getTokenFee(address token) view public returns(uint256[10] memory) {
        require(isRankPayToken(token), "not in support rank token list");
        return rankPayTokenInfos[token];
    }
    function transferReceiver(address receiver) external onlyOwner {
        receiveAddress = receiver;
    }
    
    /// plcToken percents
    function updatePlcReceiveAddrs(address[] memory receiveAddrs) external onlyOwner {
        require(receiveAddrs.length == plcPercents.length, "length error");
        plcReceiveAddrs = receiveAddrs;
    }
    function updatePlcPercents(uint256[] memory percents) external onlyOwner {
        require(percents.length == plcReceiveAddrs.length, "length error");
        plcPercents = percents;
        plcPercentBurn = 100;
        for (uint256 i = 0; i < percents.length; ++i) {
            plcPercentBurn -= percents[i];
        }
        require(plcPercentBurn >= 0, "percent error");
    }
    function getPlcPercentsInfo() view public returns(address[] memory, uint256[] memory) {
        address[] memory addrs = new address[](plcReceiveAddrs.length);
        uint256[] memory percents = new uint256[](plcReceiveAddrs.length);

        for(uint256 i = 0; i < plcReceiveAddrs.length; ++i) {
            addrs[i] = plcReceiveAddrs[i];
            percents[i] = plcPercents[i];
        }
        return (addrs, percents);
    }

    function upgradeRank() public {
        IPodCore.TagObject memory object;
        object.Type = IPodCore.ObjectType.Address;
        object.Address = bytes20(msg.sender);

        bytes memory data = TagContract.getTagData(UserRankTagClassId, object);
        uint8 oldRank = 0;
        if (data.length > 0) {
            ReadBuffer.buffer memory buffer = ReadBuffer.fromBytes(data);
            oldRank = buffer.readUint8();
        }
        uint8 newRank = oldRank + 1;

        require(newRank <= 10, "UserRank: rank cannot >= 10");

        for(uint256 i = 0; i < _rankPayTokens.length(); ++i) {
            uint256 tokenFee = rankPayTokenInfos[_rankPayTokens.at(i)][oldRank];
            if (tokenFee > 0) {
                require(IERC20(_rankPayTokens.at(i)).balanceOf(msg.sender) >= tokenFee, "no enough pay token");
            }
        }
        address[] memory payTokens = new address[](_rankPayTokens.length());
        uint256[] memory tokenFees = new uint256[](_rankPayTokens.length());
        for(uint256 i = 0; i < _rankPayTokens.length(); ++i) {
            uint256 tokenFee = rankPayTokenInfos[_rankPayTokens.at(i)][oldRank];
            payTokens[i] = _rankPayTokens.at(i);
            tokenFees[i] = tokenFee;
            if (tokenFee > 0) {
                if (payTokens[i] == plcToken) {     // PLCToken, distribute
                    uint256[] memory amounts = new uint256[](plcPercents.length);
                    for (uint256 j = 0; j < plcPercents.length; ++j) {
                        amounts[j] = tokenFee*plcPercents[j]/100;
                    }
                    PLCToken(plcToken).transferBatch(plcReceiveAddrs, amounts, msg.sender);
                    PLCToken(plcToken).burnByUser(tokenFee*plcPercentBurn/100, msg.sender);

                    emit PlcDistribution(msg.sender, oldRank, newRank, plcReceiveAddrs, amounts, tokenFee*plcPercentBurn/100);
                } else {
                    IERC20(_rankPayTokens.at(i)).transferFrom(msg.sender, receiveAddress, tokenFee);
                }
            }
        }

        WriteBuffer.buffer memory buf;
        data = buf.init(1).writeUint8(newRank).getBytes();
        TagContract.setTag(UserRankTagClassId, object, data, 0);

        emit UpgradeRank(msg.sender, oldRank, newRank, payTokens, tokenFees);
    }

    function getUserRank(address account) external view returns (uint8) {
        IPodCore.TagObject memory object;
        object.Type = IPodCore.ObjectType.Address;
        object.Address = bytes20(account);

        bytes memory data = TagContract.getTagData(UserRankTagClassId, object);
        if (data.length == 0) {
            return 0;
        }
        ReadBuffer.buffer memory buffer = ReadBuffer.fromBytes(data);
        return buffer.readUint8();
    }

    function transferUserRankTagClassOwner(address newOwner) public onlyOwner {
        TagClassContract.transferTagClassOwner(UserRankTagClassId, newOwner);
        emit UpdateUserRankTagClassOwner(newOwner);
    }

    function updateTagContract(address newTagContractAddress) public onlyOwner {
        address oldTagContractAddress = address(TagContract);
        TagContract = ITag(newTagContractAddress);
        emit UpdateTagContract(oldTagContractAddress, newTagContractAddress);
    }

    function updateTagClassContract(address newTagClassContractAddress)
        public
        onlyOwner
    {
        address oldTagClassContractAddress = address(TagClassContract);
        TagClassContract = ITagClass(newTagClassContractAddress);
        emit UpdateTagClassContract(
            oldTagClassContractAddress,
            newTagClassContractAddress
        );
    }

    function updateTokenFees(address token, uint256[10] calldata newFees) public onlyOwner {
        require(isRankPayToken(token), "not in support rank token list");

        uint256[10] memory oldFees = rankPayTokenInfos[token];
        rankPayTokenInfos[token] = newFees;
        emit UpdateTokenFees(token, oldFees, newFees);
    }
}