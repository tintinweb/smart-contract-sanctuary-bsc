/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Obi {
    using SafeMath for uint256;

    struct Data {
        uint256 offset;
        bytes raw;
    }

    function from(bytes memory data) internal pure returns (Data memory) {
        return Data({offset: 0, raw: data});
    }

    modifier shift(Data memory data, uint256 size) {
        require(data.raw.length >= data.offset + size, "Obi: Out of range");
        _;
        data.offset += size;
    }

    function finished(Data memory data) internal pure returns (bool) {
        return data.offset == data.raw.length;
    }

    function decodeU8(Data memory data)
        internal
        pure
        shift(data, 1)
        returns (uint8 value)
    {
        value = uint8(data.raw[data.offset]);
    }

    function decodeI8(Data memory data)
        internal
        pure
        shift(data, 1)
        returns (int8 value)
    {
        value = int8(uint8(data.raw[data.offset]));
    }

    function decodeU16(Data memory data) internal pure returns (uint16 value) {
        value = uint16(decodeU8(data)) << 8;
        value |= uint16(decodeU8(data));
    }

    function decodeI16(Data memory data) internal pure returns (int16 value) {
        value = int16(decodeI8(data)) << 8;
        value |= int16(decodeI8(data));
    }

    function decodeU32(Data memory data) internal pure returns (uint32 value) {
        value = uint32(decodeU16(data)) << 16;
        value |= uint32(decodeU16(data));
    }

    function decodeI32(Data memory data) internal pure returns (int32 value) {
        value = int32(decodeI16(data)) << 16;
        value |= int32(decodeI16(data));
    }

    function decodeU64(Data memory data) internal pure returns (uint64 value) {
        value = uint64(decodeU32(data)) << 32;
        value |= uint64(decodeU32(data));
    }

    function decodeI64(Data memory data) internal pure returns (int64 value) {
        value = int64(decodeI32(data)) << 32;
        value |= int64(decodeI32(data));
    }

    function decodeU128(Data memory data)
        internal
        pure
        returns (uint128 value)
    {
        value = uint128(decodeU64(data)) << 64;
        value |= uint128(decodeU64(data));
    }

    function decodeI128(Data memory data) internal pure returns (int128 value) {
        value = int128(decodeI64(data)) << 64;
        value |= int128(decodeI64(data));
    }

    function decodeU256(Data memory data)
        internal
        pure
        returns (uint256 value)
    {
        value = uint256(decodeU128(data)) << 128;
        value |= uint256(decodeU128(data));
    }

    function decodeI256(Data memory data) internal pure returns (int256 value) {
        value = int256(decodeI128(data)) << 128;
        value |= int256(decodeI128(data));
    }

    function decodeBool(Data memory data) internal pure returns (bool value) {
        value = (decodeU8(data) != 0);
    }

    function decodeBytes(Data memory data)
        internal
        pure
        returns (bytes memory value)
    {
        value = new bytes(decodeU32(data));
        for (uint256 i = 0; i < value.length; i++) {
            value[i] = bytes1(decodeU8(data));
        }
    }


    function decodeAddress(Data memory data)
        internal
        pure
        returns (address addr)
    {
        bytes memory bys = decodeBytes(data);
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function decodeString(Data memory data)
        internal
        pure
        returns (string memory value)
    {
        return string(decodeBytes(data));
    }

    function decodeBytes32(Data memory data)
        internal
        pure
        shift(data, 32)
        returns (bytes1[32] memory value)
    {
        bytes memory raw = data.raw;
        uint256 offset = data.offset;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            mstore(value, mload(add(add(raw, 32), offset)))
        }
    }

    function decodeBytes64(Data memory data)
        internal
        pure
        shift(data, 64)
        returns (bytes1[64] memory value)
    {
        bytes memory raw = data.raw;
        uint256 offset = data.offset;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            mstore(value, mload(add(add(raw, 32), offset)))
            mstore(add(value, 32), mload(add(add(raw, 64), offset)))
        }
    }

    function decodeBytes65(Data memory data)
        internal
        pure
        shift(data, 65)
        returns (bytes1[65] memory value)
    {
        bytes memory raw = data.raw;
        uint256 offset = data.offset;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            mstore(value, mload(add(add(raw, 32), offset)))
            mstore(add(value, 32), mload(add(add(raw, 64), offset)))
        }
        value[64] = data.raw[data.offset + 64];
    }
}


library OracleBDecoder {
    using Obi for Obi.Data;

    struct Params {
        uint16 srcChainId;
        uint16 dstChainId;
        uint16 outboundProofType;
        uint256 blockConfirmations;
        uint256 blockNumber;
    }

    struct Result {
        uint16 remoteChainId;
        bytes32 blockHash;
        uint256 confirmations;
        bytes32 data;
    }

    /// @notice Decodes the encoded request input parameters
    /// @param encodedParams Encoded paramter data
    function decodeParams(bytes memory encodedParams)
        internal
        pure
        returns (Params memory params)
    {
        Obi.Data memory decoder = Obi.from(encodedParams);
        params.srcChainId = decoder.decodeU16();
        params.dstChainId = decoder.decodeU16();
        params.outboundProofType = decoder.decodeU16();
        params.blockConfirmations = uint256(decoder.decodeU64());
        params.blockNumber = uint256(decoder.decodeU64());
        require(decoder.finished(), "DATA_DECODE_NOT_FINISHED");
    }

    /// @notice Decodes the encoded data request response result
    /// @param encodedResult Encoded result data
    function decodeResult(bytes memory encodedResult)
        internal
        pure
        returns (Result memory result)
    {
        Obi.Data memory decoder = Obi.from(encodedResult);
        result.remoteChainId = decoder.decodeU16();
        result.blockHash = bytes32(decoder.decodeBytes());
        result.confirmations = uint256(decoder.decodeU64());
        result.data = bytes32(decoder.decodeBytes());

        require(decoder.finished(), "DATA_DECODE_NOT_FINISHED");
    }
}

interface ILayerZeroOracle {
    // @notice query the oracle price for relaying block information to the destination chain
    // @param _dstChainId the destination endpoint identifier
    // @param _outboundProofType the proof type identifier to specify the data to be relayed
    function getPrice(uint16 _dstChainId, uint16 _outboundProofType) external view returns (uint price);

    // @notice Ultra-Light Node notifies the Oracle of a new block information relaying request
    // @param _dstChainId the destination endpoint identifier
    // @param _outboundProofType the proof type identifier to specify the data to be relayed
    // @param _outboundBlockConfirmations the number of source chain block confirmation needed
    function notifyOracle(uint16 _dstChainId, uint16 _outboundProofType, uint64 _outboundBlockConfirmations) external;

    // @notice query if the address is an approved actor for privileges like data submission and fee withdrawal etc.
    // @param _address the address to be checked
    function isApproved(address _address) external view returns (bool approved);
}

interface ILayerZeroUltraLightNodeV1 {
    /// an Oracle delivers the block data using updateBlockHeader()
    function updateHash(uint16 _remoteChainId, bytes32 _lookupHash, uint _confirmations, bytes32 _data) external;
    /// oracle can withdraw their fee from the ULN which accumulates native tokens per call
    function withdrawOracleFee(address _to, uint _amount) external;
}

interface IBridge {
    enum ResolveStatus {
        RESOLVE_STATUS_OPEN_UNSPECIFIED,
        RESOLVE_STATUS_SUCCESS,
        RESOLVE_STATUS_FAILURE,
        RESOLVE_STATUS_EXPIRED
    }
    /// Result struct is similar packet on Bandchain using to re-calculate result hash.
    struct Result {
        string clientID;
        uint64 oracleScriptID;
        bytes params;
        uint64 askCount;
        uint64 minCount;
        uint64 requestID;
        uint64 ansCount;
        uint64 requestTime;
        uint64 resolveTime;
        ResolveStatus resolveStatus;
        bytes result;
    }

    /// Performs oracle state relay and oracle data verification in one go. The caller submits
    /// the encoded proof and receives back the decoded data, ready to be validated and used.
    /// @param data The encoded data for oracle state relay and data verification.
    function relayAndVerify(bytes calldata data)
        external
        returns (Result memory);

    /// Performs oracle state relay and many times of oracle data verification in one go. The caller submits
    /// the encoded proof and receives back the decoded data, ready to be validated and used.
    /// @param data The encoded data for oracle state relay and an array of data verification.
    function relayAndMultiVerify(bytes calldata data)
        external
        returns (Result[] memory);

    // Performs oracle state relay and requests count verification in one go. The caller submits
    /// the encoded proof and receives back the decoded data, ready tobe validated and used.
    /// @param data The encoded data for oracle state relay and requests count verification.
    function relayAndVerifyCount(bytes calldata data)
        external
        returns (uint64, uint64); // block time, requests count
}


contract Oracle is ILayerZeroOracle, Ownable {

    ILayerZeroUltraLightNodeV1 public ultraLightNode;
    IBridge public bridge;
    uint64 public oracleScriptID;
    uint64 public ansCount;

    mapping(address => bool) public approvedAddresses;

    event OracleNotified(uint16 dstChainId, uint16 _outboundProofType, uint blockConfirmations);

    constructor(
        ILayerZeroUltraLightNodeV1 _ultraLightNode,
        IBridge _brdige,
        uint64 _oracleScriptID,
        uint64 _ansCount
    ) {
        ultraLightNode = _ultraLightNode;
        bridge = _brdige;
        oracleScriptID = _oracleScriptID;
        ansCount = _ansCount;
    }

    // initiate the Oracle to perform its job
    function notifyOracle(uint16 _dstChainId, uint16 _outboundProofType, uint64 _outboundBlockConfirmations) external override {
        require(isApproved(msg.sender), "Oracle: requester is not approved");

        emit OracleNotified(_dstChainId, _outboundProofType, _outboundBlockConfirmations);
    }

    function relayBlock(bytes memory proof) external {
        // Verify input proof using the bridge contract's relayAndVerify method
        IBridge.Result memory res = bridge.relayAndVerify(proof);

        OracleBDecoder.Result memory result = OracleBDecoder.decodeResult(
            res.result
        );

        /// Security checking
        require(
            res.resolveStatus == IBridge.ResolveStatus.RESOLVE_STATUS_SUCCESS,
            "FAIL_REQUEST_IS_NOT_SUCCESSFULLY_RESOLVED"
        );
        require(
            res.oracleScriptID == oracleScriptID,
            "FAIL_INCORRECT_OS_ID"
        );
        require(
            res.ansCount >= ansCount,
            "FAIL_TOO_SMALL_ANS_COUNT"
        );

        ultraLightNode.updateHash(
            result.remoteChainId,
            result.blockHash,
            result.confirmations,
            result.data
        );
    }

    function getPrice(uint16 , uint16) external pure returns(uint256){
        revert("Oracle: not implemented");
    }

    // return whether this requester address is whitelisted
    function isApproved(address oracleAddress) public view override returns (bool approved){
        return approvedAddresses[oracleAddress];
    }

    // owner can approve a requester
    function setApprovedAddress(address _oracleAddress, bool _approve) external onlyOwner {
        approvedAddresses[_oracleAddress] = _approve;
    }

    function setUltraLightNode(ILayerZeroUltraLightNodeV1 _ultraLightNode) external onlyOwner {
        ultraLightNode = _ultraLightNode;
    }

    function setBridge(IBridge _brdige) external onlyOwner {
        bridge = _brdige;
    }

    function setOracleScript(uint64 _oracleScriptID) external onlyOwner {
        oracleScriptID = _oracleScriptID;
    }

    function setAnsCount(uint64 _ansCount) external onlyOwner {
        ansCount = _ansCount;
    }
}