// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./InvitationCenterLayout.sol";
import "../dependant/ownable/OwnableLogic.sol";
import "../crownNameServiceRef/CrownNameServiceRefLogic.sol";
import "./InvitationCenterInterface.sol";

import "./InvitationCenterType.sol";

import "../dependant/helperLibrary/BytesLibrary.sol";
import "../dependant/helperLibrary/ConstantLibrary.sol";

contract InvitationCenterLogic is Delegate, InvitationCenterLayout,
OwnableLogic,
CrownNameServiceRefLogic,
InvitationCenterInterface {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    modifier onlyAuthPermitted{
        require(
            owner() == msg.sender ||
            _associatedOperators[msg.sender] ||
            manager() == msg.sender,
            "onlyAuthPermitted"
        );
        _;
    }

    function registerInviter(bytes32 inviterCode) override external {
        _registerInviter(msg.sender, inviterCode);
    }

    function registerInviterAuth(address registerApplier, bytes32 inviterCode) override external onlyAuthPermitted {
        _registerInviter(registerApplier, inviterCode);
    }

    function _registerInviter(address registerApplier, bytes32 inviterCode) internal {

        require(validateInvitationCode(inviterCode), "invalid inviter code");

        require(!_registeredAccount.contains(registerApplier), "you have been registered inviter");

        address inviter = InvitationCenterType._defaultInviter;

        if (inviterCode != InvitationCenterType._defaultInviterCode) {
            require(_registeredInvitationCode.contains(inviterCode), "inviter code belongs to nobody");
            inviter = _inviterCodeToAddress[inviterCode];
        }

        _registeredAccount.add(registerApplier);

        InvitationCenterType.Record storage record = _inviterRecords[registerApplier];
        record.who = registerApplier;
        record.inviter = inviter;

        //init
        for (uint256 i = 0; i < _inviterRecursiveLoop; i++) {
            record.inviteeAmounts.push(0);
        }

        bytes32 yourInvitationCode = generateInvitationCode(registerApplier);
        _registeredInvitationCode.add(yourInvitationCode);
        _inviterCodeToAddress[yourInvitationCode] = registerApplier;

        record.invitationCode = yourInvitationCode;

        //save registerApplier to inviter's direct invitee
        _inviteeRecords[inviter].add(registerApplier);


        //add inviter's invitee amount recursive
        address search = registerApplier;
        for (uint256 i = 0; i < _inviterRecursiveLoop; i++) {
            InvitationCenterType.Record storage inviteeRecord = _inviterRecords[search];

            if (inviteeRecord.inviter == InvitationCenterType._defaultInviter) {
                break;
            }

            InvitationCenterType.Record storage inviterRecord = _inviterRecords[inviteeRecord.inviter];

            inviterRecord.inviteeAmounts[i] = inviterRecord.inviteeAmounts[i].add(1);

            search = inviteeRecord.inviter;
        }
    }

    function isRegistered(address who) override view external returns (bool){
        return _registeredAccount.contains(who);
    }

    function generateInvitationCode(address requester) view internal returns (bytes32){

        bytes32 invitationCode = calcInvitationCode(uint256(keccak256(abi.encodePacked(requester))));

        while (_registeredInvitationCode.contains(invitationCode) || invitationCode == InvitationCenterType._defaultInviterCode) {
            invitationCode = calcInvitationCode(uint256(keccak256(abi.encodePacked(invitationCode, requester))));
        }

        require(validateInvitationCode(invitationCode), "generateInvitationCode error");

        return invitationCode;
    }

    //a !!!MODIFIED!!! base32 , 2^5
    function calcInvitationCode(uint256 random) pure internal returns (bytes32){

        bytes memory res = "";
        for (uint256 i = 0; i < InvitationCenterType._countOfBase58CharsOfInviterCode; i++) {
            //get endian 5 bytes
            uint256 endian = random.mod(2 ** 5);
            random = random.div(2 ** 5);

            if (endian == 0) {
                res = abi.encodePacked(res, "A");
            } else if (endian == 1) {
                res = abi.encodePacked(res, "B");
            } else if (endian == 2) {
                res = abi.encodePacked(res, "C");
            } else if (endian == 3) {
                res = abi.encodePacked(res, "D");
            } else if (endian == 4) {
                res = abi.encodePacked(res, "E");
            } else if (endian == 5) {
                res = abi.encodePacked(res, "F");
            } else if (endian == 6) {
                res = abi.encodePacked(res, "G");
            } else if (endian == 7) {
                res = abi.encodePacked(res, "H");
            } else if (endian == 8) {
                res = abi.encodePacked(res, "J");
            } else if (endian == 9) {
                res = abi.encodePacked(res, "K");
            } else if (endian == 10) {
                res = abi.encodePacked(res, "L");
            } else if (endian == 11) {
                res = abi.encodePacked(res, "M");
            } else if (endian == 12) {
                res = abi.encodePacked(res, "N");
            } else if (endian == 13) {
                res = abi.encodePacked(res, "P");
            } else if (endian == 14) {
                res = abi.encodePacked(res, "Q");
            } else if (endian == 15) {
                res = abi.encodePacked(res, "R");
            } else if (endian == 16) {
                res = abi.encodePacked(res, "S");
            } else if (endian == 17) {
                res = abi.encodePacked(res, "T");
            } else if (endian == 18) {
                res = abi.encodePacked(res, "U");
            } else if (endian == 19) {
                res = abi.encodePacked(res, "V");
            } else if (endian == 20) {
                res = abi.encodePacked(res, "W");
            } else if (endian == 21) {
                res = abi.encodePacked(res, "X");
            } else if (endian == 22) {
                res = abi.encodePacked(res, "Y");
            } else if (endian == 23) {
                res = abi.encodePacked(res, "Z");
            } else if (endian == 24) {
                res = abi.encodePacked(res, "2");
            } else if (endian == 25) {
                res = abi.encodePacked(res, "3");
            } else if (endian == 26) {
                res = abi.encodePacked(res, "4");
            } else if (endian == 27) {
                res = abi.encodePacked(res, "5");
            } else if (endian == 28) {
                res = abi.encodePacked(res, "6");
            } else if (endian == 29) {
                res = abi.encodePacked(res, "7");
            } else if (endian == 30) {
                res = abi.encodePacked(res, "8");
            } else if (endian == 31) {
                res = abi.encodePacked(res, "9");
            } else {
                revert("calcInvitationCode, calcInvitationCode error");
            }
        }

        bytes32 ret;
        assembly {
            ret := mload(add(res, 32))
        }

        require(validateInvitationCode(ret), "calcInvitationCode, calcInvitationCode then check failed");

        return ret;
    }

    function validateInvitationCode(bytes32 input) pure internal returns (bool){

        uint256 remainder = uint256(input).mod((2 ** 8) ** (uint256(32).sub(InvitationCenterType._countOfBase58CharsOfInviterCode)));

        return remainder == uint256(0);
    }

    //inviters chain
    //stuff with address(0) if ends
    function getInviters(address invitee) override view external returns (address[] memory){

        address[] memory ret = new address[](_inviterRecursiveLoop);

        if (!_registeredAccount.contains(invitee)) {
            ret;
        }

        address search = invitee;
        for (uint256 i = 0; i < _inviterRecursiveLoop; i++) {
            InvitationCenterType.Record storage inviteeRecord = _inviterRecords[search];

            if (inviteeRecord.inviter == InvitationCenterType._defaultInviter) {
                break;
            }

            //push the invitor
            ret[i] = inviteeRecord.inviter;

            search = inviteeRecord.inviter;
        }

        return ret;
    }

    //==

    function defaultInviter() override pure external returns (address){
        return InvitationCenterType._defaultInviter;
    }

    function defaultInviterCode() override pure external returns (bytes32){
        return InvitationCenterType._defaultInviterCode;
    }

    function registeredAccountLength() override view external returns (uint256){
        return _registeredAccount.length();
    }

    function registeredAccountAt(uint256 index) override view external returns (address){
        return _registeredAccount.at(index);
    }

    function registeredAccountContains(address who) override view external returns (bool){
        return _registeredAccount.contains(who);
    }

    function inviterRecords(address who) override view external returns (InvitationCenterType.Record memory){
        return _inviterRecords[who];
    }

    //-

    function inviteeRecordsLength(address who) override view external returns (uint256){
        return _inviteeRecords[who].length();
    }

    function inviteeRecordsAt(address who, uint256 index) override view external returns (address){
        return _inviteeRecords[who].at(index);
    }

    function inviteeRecordsContains(address who, address invitee) override view external returns (bool){
        return _inviteeRecords[who].contains(invitee);
    }

    //-

    function registeredInvitationCodeLength() override view external returns (uint256){
        return _registeredInvitationCode.length();
    }

    function registeredInvitationCodeAt(uint256 index) override view external returns (bytes32){
        return _registeredInvitationCode.at(index);
    }

    function registeredInvitationCodeContains(bytes32 input) override view external returns (bool){
        return _registeredInvitationCode.contains(input);
    }

    //-

    function inviterCodeToAddress(bytes32 input) override view external returns (address){
        return _inviterCodeToAddress[input];
    }

    function setRecursiveLoop(uint256 inviterRecursiveLoop) override external onlyOwner {
        _inviterRecursiveLoop = inviterRecursiveLoop;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../dependant/ownable/OwnableLayout.sol";
import "../crownNameServiceRef/CrownNameServiceRefLayout.sol";

import "./InvitationCenterType.sol";

contract InvitationCenterLayout is OwnableLayout, CrownNameServiceRefLayout {

    //an account must has his inviter
    EnumerableSet.AddressSet internal _registeredAccount;

    //who => record
    mapping(address => InvitationCenterType.Record) internal _inviterRecords;

    //who => his invitees
    mapping(address => EnumerableSet.AddressSet) internal _inviteeRecords;

    EnumerableSet.Bytes32Set internal _registeredInvitationCode;
    mapping(bytes32 => address) internal _inviterCodeToAddress;

    uint256 internal _inviterRecursiveLoop;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OwnableLayout.sol";
import "./OwnableInterface.sol";

contract OwnableLogic is OwnableLayout, OwnableInterface {

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAuth() {
        require(owner() == msg.sender || _associatedOperators[msg.sender], "Ownable: caller is un-authed");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() override public view returns (address) {
        return _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() override public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) override public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function setAssociatedOperator(address newAssociatedOperator, bool flag) override public onlyOwner {
        require(newAssociatedOperator != address(0), "Ownable: newAssociatedOperator is the zero address");

        _associatedOperators[newAssociatedOperator] = flag;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CrownNameServiceRefLayout.sol";
import "../dependant/nameServiceRef/NameServiceRefLogic.sol";
import "./CrownNameServiceRefInterface.sol";

import "../crownNameService/CrownNameServiceType.sol";

contract CrownNameServiceRefLogic is CrownNameServiceRefLayout, NameServiceRefLogic, CrownNameServiceRefInterface {

    function invitationCenter() view internal returns (address){
        return ns().getSingleSafe(CrownNameServiceType.S_InvitationCenter);
    }

    function feeCollector() view internal returns (address){
        return ns().getSingleSafe(CrownNameServiceType.S_FeeCollector);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../dependant/ownable/OwnableInterface.sol";
import "../crownNameServiceRef/CrownNameServiceRefInterface.sol";
import "./InvitationCenterEvent.sol";

interface InvitationCenterInterface is
OwnableInterface,
CrownNameServiceRefInterface,
InvitationCenterEvent {

    function registerInviter(bytes32 inviterCode) external;

    function registerInviterAuth(address registerApplier, bytes32 inviterCode) external;

    function isRegistered(address who) view external returns (bool);

    function getInviters(address invitee) view external returns (address[] memory);

    //==

    function defaultInviter() view external returns (address);

    function defaultInviterCode() pure external returns (bytes32);

    function registeredAccountLength() view external returns (uint256);

    function registeredAccountAt(uint256 index) view external returns (address);

    function registeredAccountContains(address who) view external returns (bool);

    function inviterRecords(address who) view external returns (InvitationCenterType.Record memory);

    function inviteeRecordsLength(address who) view external returns (uint256);

    function inviteeRecordsAt(address who, uint256 index) view external returns (address);

    function inviteeRecordsContains(address who, address invitee) view external returns (bool);

    function registeredInvitationCodeLength() view external returns (uint256);

    function registeredInvitationCodeAt(uint256 index) view external returns (bytes32);

    function registeredInvitationCodeContains(bytes32 input) view external returns (bool);

    function inviterCodeToAddress(bytes32 input) view external returns (address);

    function setRecursiveLoop(uint256 inviterRecursiveLoop) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library InvitationCenterType {

    address constant internal _defaultInviter = address(~uint160(0));
    //deadbeef
    bytes32 constant internal _defaultInviterCode = hex"6465616462656566000000000000000000000000000000000000000000000000";
    uint256 constant internal _countOfBase58CharsOfInviterCode = 8;

    struct Record {
        address who;
        uint256 avatar;
        string nickname;
        address inviter;
        //padding with 28 zero bytes
        bytes32 invitationCode;
        //invitee count of first, second, ..... layer
        uint256[] inviteeAmounts;
    }
}

// SPDX-License-Identifier: Unlicense
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <[email protected]>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;


library BytesLibrary {
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
            let fslot := sload(_preBytes.slot)
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
                _preBytes.slot,
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
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

            // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

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
                mstore(0x0, _preBytes.slot)
            // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

            // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

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
        uint256 _start,
        uint256 _length
    )
    internal
    pure
    returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

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
            //zero out the 32 bytes slice we are about to return
            //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1, "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
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
                // while(uint256(mc < end) + cb == 2)
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
            let fslot := sload(_preBytes.slot)
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
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                    // the next line is the loop condition:
                    // while(uint256(mc < end) + cb == 2)
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ConstantLibrary {

    uint256 constant internal PERCENT = 100;
    uint256 constant internal THOUSAND = 1000;
    uint256 constant internal MILLION = 1000000;
    uint256 constant internal UNIT = 10 ** 18;
    bytes32 constant internal ZERO_BYTES = hex"0000000000000000000000000000000000000000000000000000000000000000";
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

abstract contract OwnableLayout {

    address internal _owner;
    mapping(address => bool) internal _associatedOperators;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../dependant/nameServiceRef/NameServiceRefLayout.sol";

abstract contract CrownNameServiceRefLayout is NameServiceRefLayout {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/interfaces/IERC165.sol';

import '@openzeppelin/contracts/interfaces/IERC20.sol';
import '@openzeppelin/contracts/interfaces/IERC20Metadata.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import '@openzeppelin/contracts/interfaces/IERC721.sol';
import '@openzeppelin/contracts/interfaces/IERC721Metadata.sol';
import '@openzeppelin/contracts/interfaces/IERC721Enumerable.sol';
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";

import '@openzeppelin/contracts/interfaces/IERC1155.sol';
import '@openzeppelin/contracts/interfaces/IERC1155MetadataURI.sol';
import "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@openzeppelin/contracts/utils/math/Math.sol';
import "@openzeppelin/contracts/utils/Counters.sol";

import "../proxy/Proxy.sol";
import "../proxy/Delegate.sol";

//just import it in Layout and Interface contract if needed

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/extensions/IERC721Metadata.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/extensions/IERC721Enumerable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721Receiver.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/extensions/IERC1155MetadataURI.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155Receiver.sol";

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.0;

import "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Base.sol";
import "./EnhancedMap.sol";
import "./EnhancedUniqueIndexMap.sol";


contract Proxy is Base, EnhancedMap, EnhancedUniqueIndexMap {
    constructor (address admin) {
        require(admin != address(0));
        sysSaveSlotData(adminSlot, bytes32(uint256(uint160(admin))));
        sysSaveSlotData(userSigZeroSlot, bytes32(uint256(0)));
        sysSaveSlotData(outOfServiceSlot, bytes32(uint256(0)));
        sysSaveSlotData(revertMessageSlot, bytes32(uint256(1)));
        //sysSetDelegateFallback(address(0));
        sysSaveSlotData(transparentSlot, bytes32(uint256(1)));

    }

    bytes32 constant adminSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("adminSlot"))))));

    bytes32 constant revertMessageSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("revertMessageSlot"))))));

    bytes32 constant outOfServiceSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("outOfServiceSlot"))))));

    //address <===>  index EnhancedUniqueIndexMap
    //0x2f80e9a12a11b80d2130b8e7dfc3bb1a6c04d0d87cc5c7ea711d9a261a1e0764
    bytes32 constant delegatesSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("delegatesSlot"))))));

    //bytes4 abi ===> address, both not 0x00
    //0xba67a9e2b7b43c3c9db634d1c7bcdd060aa7869f4601d292a20f2eedaf0c2b1c
    bytes32 constant userAbiSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userAbiSlot"))))));

    bytes32 constant userAbiSearchSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userAbiSearchSlot"))))));

    //0xe2bb2e16cbb16a10fab839b4a5c3820d63a910f4ea675e7821846c4b2d3041dc
    bytes32 constant userSigZeroSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userSigZeroSlot"))))));

    bytes32 constant transparentSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("transparentSlot"))))));


    event DelegateSet(address delegate, bool activated);
    event AbiSet(bytes4 abi, address delegate, bytes32 slot);
    event PrintBytes(bytes data);
    //===================================================================================

    //
    function sysCountDelegate() view public returns (uint256){
        return sysUniqueIndexMapSize(delegatesSlot);
    }

    function sysGetDelegateAddress(uint256 index) view public returns (address){
        return address(uint160(uint256(sysUniqueIndexMapGetValue(delegatesSlot, index))));
    }

    function sysGetDelegateIndex(address addr) view public returns (uint256) {
        return uint256(sysUniqueIndexMapGetIndex(delegatesSlot, bytes32(uint256(uint160(addr)))));
    }

    function sysGetDelegateAddresses() view public returns (address[] memory){
        uint256 count = sysCountDelegate();
        address[] memory delegates = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            delegates[i] = sysGetDelegateAddress(i + 1);
        }
        return delegates;
    }

    //add delegates on current version
    function sysAddDelegates(address[] memory _inputs) external onlyAdmin {
        for (uint256 i = 0; i < _inputs.length; i ++) {
            sysUniqueIndexMapAdd(delegatesSlot, bytes32(uint256(uint160(_inputs[i]))));
            emit DelegateSet(_inputs[i], true);
        }
    }

    //delete delegates
    //be careful, if you delete a delegate, the index will change
    function sysDelDelegates(address[] memory _inputs) external onlyAdmin {
        for (uint256 i = 0; i < _inputs.length; i ++) {

            //travers all abis to delete those abis mapped to the given address
            uint256 j;
            uint256 k;
            /*bytes4[] memory toDeleteSelectors = new bytes4[](count + 1);
            uint256 pivot = 0;*/
            uint256 count = sysCountSelectors();

            /*for (j = 0; j < count; j ++) {
                bytes4 selector;
                address delegate;
                (selector, delegate) = sysGetUserSelectorAndDelegateByIndex(j + 1);
                if (delegate == _inputs[i]) {
                    toDeleteSelectors[pivot] = selector;
                    pivot++;
                }
            }
            pivot = 0;
            while (toDeleteSelectors[pivot] != bytes4(0x00)) {
                sysSetUserSelectorAndDelegate(toDeleteSelectors[pivot], address(0));
                pivot++;
            }*/
            k = 1;
            for (j = 0; j < count; j++) {
                bytes4 selector;
                address delegate;
                (selector, delegate) = sysGetSelectorAndDelegateByIndex(k);
                if (delegate == _inputs[i]) {
                    _sysSetSelectorAndDelegate(selector, address(0));
                }
                else {
                    k++;
                }
            }

            if (sysGetSigZero() == _inputs[i]) {
                _sysSetSigZero(address(0x00));
            }

            sysUniqueIndexMapDelArrange(delegatesSlot, bytes32(uint256(uint160(_inputs[i]))));
            emit DelegateSet(_inputs[i], false);
        }
    }

    //add and delete delegates
    function sysReplaceDelegates(address[] memory _delegatesToDel, address[] memory _delegatesToAdd) external onlyAdmin {
        require(_delegatesToDel.length == _delegatesToAdd.length, "sysReplaceDelegates, length does not match");
        for (uint256 i = 0; i < _delegatesToDel.length; i ++) {
            sysUniqueIndexMapReplace(delegatesSlot, bytes32(uint256(uint160(_delegatesToDel[i]))), bytes32(uint256(uint160(_delegatesToAdd[i]))));
            emit DelegateSet(_delegatesToDel[i], false);
            emit DelegateSet(_delegatesToAdd[i], true);
        }
    }

    //=============================================

    function sysGetSigZero() view public returns (address){
        return address(uint160(uint256(sysLoadSlotData(userSigZeroSlot))));
    }

    function sysSetSigZero(address _input) external onlyAdmin {
        _sysSetSigZero(_input);
    }

    function _sysSetSigZero(address _input) internal {
        sysSaveSlotData(userSigZeroSlot, bytes32(uint256(uint160(_input))));
    }

    function sysGetAdmin() view public returns (address){
        return address(uint160(uint256(sysLoadSlotData(adminSlot))));
    }

    function sysSetAdmin(address _input) external onlyAdmin {
        sysSaveSlotData(adminSlot, bytes32(uint256(uint160(_input))));
    }

    function sysGetRevertMessage() view public returns (uint256){
        return uint256(sysLoadSlotData(revertMessageSlot));
    }

    function sysSetRevertMessage(uint256 _input) external onlyAdmin {
        sysSaveSlotData(revertMessageSlot, bytes32(_input));
    }

    function sysGetOutOfService() view public returns (uint256){
        return uint256(sysLoadSlotData(outOfServiceSlot));
    }

    function sysSetOutOfService(uint256 _input) external onlyAdmin {
        sysSaveSlotData(outOfServiceSlot, bytes32(_input));
    }

    function sysGetTransparent() view public returns (uint256){
        return uint256(sysLoadSlotData(transparentSlot));
    }

    function sysSetTransparent(uint256 _input) external onlyAdmin {
        sysSaveSlotData(transparentSlot, bytes32(_input));
    }

    //=============================================

    //abi and delegates should not be 0x00 in mapping;
    //set delegate to 0x00 for delete the entry
    function sysSetSelectorsAndDelegates(bytes4[] memory selectors, address[] memory delegates) external onlyAdmin {
        require(selectors.length == delegates.length, "sysSetUserSelectorsAndDelegates, length does not matchs");
        for (uint256 i = 0; i < selectors.length; i ++) {
            _sysSetSelectorAndDelegate(selectors[i], delegates[i]);
        }
    }

    function _sysSetSelectorAndDelegate(bytes4 selector, address delegate) internal {

        require(selector != bytes4(0x00), "sysSetSelectorAndDelegate, selector should not be selector");
        //require(delegates[i] != address(0x00));
        address oldDelegate = address(uint160(uint256(sysEnhancedMapGet(userAbiSlot, bytes32(selector)))));
        if (oldDelegate == delegate) {
            //if oldDelegate == 0 & delegate == 0
            //if oldDelegate == delegate != 0
            //do nothing here
        }
        if (oldDelegate == address(0x00)) {
            //delegate != 0
            //adding new value
            sysEnhancedMapAdd(userAbiSlot, bytes32(selector), bytes32(uint256(uint160(delegate))));
            sysUniqueIndexMapAdd(userAbiSearchSlot, bytes32(selector));
        }
        if (delegate == address(0x00)) {
            //oldDelegate != 0
            //deleting new value
            sysEnhancedMapDel(userAbiSlot, bytes32(selector));
            sysUniqueIndexMapDel(userAbiSearchSlot, bytes32(selector));

        } else {
            //oldDelegate != delegate & oldDelegate != 0 & delegate !=0
            //updating
            sysEnhancedMapReplace(userAbiSlot, bytes32(selector), bytes32(uint256(uint160(delegate))));
        }
    }

    function sysGetDelegateBySelector(bytes4 selector) view public returns (address){
        return address(uint160(uint256(sysEnhancedMapGet(userAbiSlot, bytes32(selector)))));
    }

    function sysCountSelectors() view public returns (uint256){
        return sysEnhancedMapSize(userAbiSlot);
    }

    function sysGetSelector(uint256 index) view public returns (bytes4){
        bytes4 selector = bytes4(sysUniqueIndexMapGetValue(userAbiSearchSlot, index));
        return selector;
    }

    function sysGetSelectorAndDelegateByIndex(uint256 index) view public returns (bytes4, address){
        bytes4 selector = sysGetSelector(index);
        address delegate = sysGetDelegateBySelector(selector);
        return (selector, delegate);
    }

    function sysGetSelectorsAndDelegates() view public returns (bytes4[] memory selectors, address[] memory delegates){
        uint256 count = sysCountSelectors();
        selectors = new bytes4[](count);
        delegates = new address[](count);
        for (uint256 i = 0; i < count; i ++) {
            (selectors[i], delegates[i]) = sysGetSelectorAndDelegateByIndex(i + 1);
        }
    }

    function sysClearSelectorsAndDelegates() external onlyAdmin {
        uint256 count = sysCountSelectors();
        for (uint256 i = 0; i < count; i ++) {
            bytes4 selector;
            address delegate;
            //always delete the first, after 'count' times, it will clear all
            (selector, delegate) = sysGetSelectorAndDelegateByIndex(1);
            _sysSetSelectorAndDelegate(selector, address(0x00));
        }
    }

    //=====================internal functions=====================

    receive() payable external {
        process();
    }

    fallback() payable external {
        process();
    }


    //since low-level address.delegateCall is available in solidity,
    //we don't need to write assembly
    function process() internal outOfService {

        if (msg.sender == sysGetAdmin() && sysGetTransparent() == 1) {
            revert("admin cann't call normal function in Transparent mode");
        }

        /*
        the default transfer will set data to empty,
        so that the msg.data.length = 0 and msg.sig = bytes4(0x00000000),

        however some one can manually set msg.sig to 0x00000000 and tails more man-made data,
        so here we have to forward all msg.data to delegates
        */
        address targetDelegate;

        //for look-up table
        /*        if (msg.sig == bytes4(0x00000000)) {
                    targetDelegate = sysGetUserSigZero();
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }

                    targetDelegate = sysGetSystemSigZero();
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }
                } else {
                    targetDelegate = sysGetUserDelegate(msg.sig);
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }

                    //check system abi look-up table
                    targetDelegate = sysGetSystemDelegate(msg.sig);
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }
                }*/

        if (msg.sig == bytes4(0x00000000)) {
            targetDelegate = sysGetSigZero();
            if (targetDelegate != address(0x00)) {
                delegateCallExt(targetDelegate, msg.data);
            }

        } else {
            targetDelegate = sysGetDelegateBySelector(msg.sig);
            if (targetDelegate != address(0x00)) {
                delegateCallExt(targetDelegate, msg.data);
            }

        }

        //goes here means this abi is not in the system abi look-up table
        discover();

        //hit here means not found selector
        if (sysGetRevertMessage() == 1) {
            revert(string(abi.encodePacked(sysPrintAddressToHex(address(this)), ", function selector not found : ", sysPrintBytes4ToHex(msg.sig))));
        } else {
            revert();
        }

    }

    function discover() internal {
        bool found = false;
        bool error;
        bytes memory returnData;
        address targetDelegate;
        uint256 len = sysCountDelegate();
        for (uint256 i = 0; i < len; i++) {
            targetDelegate = sysGetDelegateAddress(i + 1);
            (found, error, returnData) = redirect(targetDelegate, msg.data);


            if (found) {
                /*if (msg.sig == bytes4(0x00000000)) {
                    sysSetSystemSigZero(targetDelegate);
                } else {
                    sysSetSystemSelectorAndDelegate(msg.sig, targetDelegate);
                }*/

                returnAsm(error, returnData);
            }
        }
    }

    function delegateCallExt(address targetDelegate, bytes memory callData) internal {
        bool found = false;
        bool error;
        bytes memory returnData;
        (found, error, returnData) = redirect(targetDelegate, callData);
        require(found, "delegateCallExt to a delegate in the map but finally not found, this shouldn't happen");
        returnAsm(error, returnData);
    }

    //since low-level ```<address>.delegatecall(bytes memory) returns (bool, bytes memory)``` can return returndata,
    //we use high-level solidity for better reading
    function redirect(address delegateTo, bytes memory callData) internal returns (bool found, bool error, bytes memory returnData){
        require(delegateTo != address(0), "delegateTo must not be 0x00");
        bool success;
        (success, returnData) = delegateTo.delegatecall(callData);
        if (success == true && keccak256(returnData) == keccak256(notFoundMark)) {
            //the delegate returns ```notFoundMark``` notFoundMark, which means invoke goes to wrong contract or function doesn't exist
            return (false, true, returnData);
        } else {
            return (true, !success, returnData);
        }

    }

    function sysPrintBytesToHex(bytes memory input) internal pure returns (string memory){
        bytes memory ret = new bytes(input.length * 2);
        bytes memory alphabet = "0123456789abcdef";
        for (uint256 i = 0; i < input.length; i++) {
            bytes32 t = bytes32(input[i]);
            bytes32 tt = t >> 31 * 8;
            uint256 b = uint256(tt);
            uint256 high = b / 0x10;
            uint256 low = b % 0x10;
            bytes1 highAscii = alphabet[high];
            bytes1 lowAscii = alphabet[low];
            ret[2 * i] = highAscii;
            ret[2 * i + 1] = lowAscii;
        }
        return string(ret);
    }

    function sysPrintAddressToHex(address input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    function sysPrintBytes4ToHex(bytes4 input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    function sysPrintUint256ToHex(uint256 input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    modifier onlyAdmin(){
        require(msg.sender == sysGetAdmin(), "only admin");
        _;
    }

    modifier outOfService(){
        if (sysGetOutOfService() == uint256(1)) {
            if (sysGetRevertMessage() == 1) {
                revert(string(abi.encodePacked("Proxy is out-of-service right now")));
            } else {
                revert();
            }
        }
        _;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Base.sol";

/*
For solidity, if you don't add modifier payable, compiler will add a piece of assembly code to make sure the
transaction or internal transaction get 0 value and will prevent use msg.value.

For named-function(which means all function except the sysSaveSlotData function), solidity generate perfect code.

However, if a proxy forward a
*/
contract Delegate is Base {
    constructor () {

    }

    /*
    THE FOLLOWING IS FIRST WRITTEN IN 0.3.X AND LAST UPDATED IN 0.4.X
    AND NOW IT IS OUT OF DATE IN 0.8.X
    */
    //Note that nonpayable is a term opposite to payable in solidity and solc
    //nonPayable with big letter P is a modifier in this framework
    //delegateCall will keep msg.sender and msg.value
    //function sig : 44409a82e623ed8da60bc4cd88253f204a87ae1a7e8937c1a0f9ec92fa753c71
    //function(), the fallback function, doesn't allow args and returns, and is nonpayable
    //but you can access calldata and set returndata by assembly by yourself :)
    //without modifier 'payable', you can't refer msg.value in public and external.that's a compiler protection;
    //but you can use msg.value freely in internal function
    //or you can access msg.value by assembly by yourself too :)
    //because defaultFallback is only called by function(), which is fallback, so it is payable.
    //thus if you wan't reject receiving ETH, just add nonPayable
    function defaultFallback() /*nonPayable*/ virtual internal {
        returnAsm(false, notFoundMark);
    }

    receive() payable external {
        //target function doesn't hit normal functions
        defaultFallback();
    }

    fallback() payable external {
        //target function doesn't hit normal functions
        defaultFallback();
    }

    /*function() payable external {
        //target function doesn't hit normal functions
        //check if it's sig is 0x00000000 to call sysSaveSlotData
        if (msg.sig == bytes4(0x00000000)) {
            defaultFallback();
        } else {
            //if goes here, the target function must not be found;
            returnAsm(false, notFoundMark);
        }
    }*/
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Base {
    constructor () {

    }

    //0x20 - length
    //0x53c6eaee8696e4c5200d3d231b29cc6a40b3893a5ae1536b0ac08212ffada877
    bytes constant notFoundMark = abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("404-method-not-found")))))));


    //return the payload of returnData, stripe the leading length
    function returnAsm(bool isRevert, bytes memory returnData) pure internal {
        assembly{
            let length := mload(returnData)
            switch isRevert
            case 0x00{
                return (add(returnData, 0x20), length)
            }
            default{
                revert (add(returnData, 0x20), length)
            }
        }
    }

    modifier nonPayable(){
        require(msg.value == 0, "nonPayable");
        _;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SlotData.sol";

//this is just a normal mapping, but which holds size and you can specify slot
/*
both key and value shouldn't be 0x00
the key must be unique, the value would be whatever

slot
  key --- value
    a --- 1
    b --- 2
    c --- 3
    c --- 4   X   not allowed
    d --- 3
    e --- 0   X   not allowed
    0 --- 9   X   not allowed

*/
contract EnhancedMap is SlotData {

    constructor() {}

    //set value to 0x00 to delete
    function sysEnhancedMapSet(bytes32 slot, bytes32 key, bytes32 value) internal {
        require(key != bytes32(0x00), "sysEnhancedMapSet, notEmptyKey");
        sysMapSet(slot, key, value);
    }

    function sysEnhancedMapAdd(bytes32 slot, bytes32 key, bytes32 value) internal {
        require(key != bytes32(0x00), "sysEnhancedMapAdd, notEmptyKey");
        require(value != bytes32(0x00), "EnhancedMap add, the value shouldn't be empty");
        require(sysMapGet(slot, key) == bytes32(0x00), "EnhancedMap, the key already has value, can't add duplicate key");
        sysMapSet(slot, key, value);
    }

    function sysEnhancedMapDel(bytes32 slot, bytes32 key) internal {
        require(key != bytes32(0x00), "sysEnhancedMapDel, notEmptyKey");
        require(sysMapGet(slot, key) != bytes32(0x00), "sysEnhancedMapDel, the key doesn't has value, can't delete empty key");
        sysMapSet(slot, key, bytes32(0x00));
    }

    function sysEnhancedMapReplace(bytes32 slot, bytes32 key, bytes32 value) public {
        require(key != bytes32(0x00), "sysEnhancedMapReplace, notEmptyKey");
        require(value != bytes32(0x00), "EnhancedMap replace, the value shouldn't be empty");
        require(sysMapGet(slot, key) != bytes32(0x00), "EnhancedMap, the key doesn't has value, can't replace it");
        sysMapSet(slot, key, value);
    }

    function sysEnhancedMapGet(bytes32 slot, bytes32 key) internal view returns (bytes32){
        require(key != bytes32(0x00), "sysEnhancedMapGet, notEmptyKey");
        return sysMapGet(slot, key);
    }

    function sysEnhancedMapSize(bytes32 slot) internal view returns (uint256){
        return sysMapLen(slot);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SlotData.sol";

//once you input a value, it will auto generate an index for that
//index starts from 1, 0 means this value doesn't exist
//the value must be unique, and can't be 0x00
//the index must be unique, and can't be 0x00
/*

slot
value --- index
    a --- 1
    b --- 2
    c --- 3
    c --- 4   X   not allowed
    d --- 3   X   not allowed
    e --- 0   X   not allowed

indexSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(slot))))));
index --- value
    1 --- a
    2 --- b
    3 --- c
    3 --- d   X   not allowed

*/

contract EnhancedUniqueIndexMap is SlotData {

    constructor() {}

    // slot : value => index
    function sysUniqueIndexMapAdd(bytes32 slot, bytes32 value) internal {

        require(value != bytes32(0x00));

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, value));
        require(index == 0, "sysUniqueIndexMapAdd, value already exist");

        uint256 last = sysUniqueIndexMapSize(slot);
        last ++;
        sysMapSet(slot, value, bytes32(last));
        sysMapSet(indexSlot, bytes32(last), value);
    }

    function sysUniqueIndexMapDel(bytes32 slot, bytes32 value) internal {

        //require(value != bytes32(0x00), "sysUniqueIndexMapDel, value must not be 0x00");

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, value));
        require(index != 0, "sysUniqueIndexMapDel, value doesn't exist");

        uint256 lastIndex = sysUniqueIndexMapSize(slot);
        require(lastIndex > 0, "sysUniqueIndexMapDel, lastIndex must be large than 0, this must not happen");
        if (index != lastIndex) {

            bytes32 lastValue = sysMapGet(indexSlot, bytes32(lastIndex));
            //move the last to the current place
            //this would be faster than move all elements forward after the deleting one, but not stable(the sequence will change)
            sysMapSet(slot, lastValue, bytes32(index));
            sysMapSet(indexSlot, bytes32(index), lastValue);
        }
        sysMapSet(slot, value, bytes32(0x00));
        sysMapSet(indexSlot, bytes32(lastIndex), bytes32(0x00));
    }

    function sysUniqueIndexMapDelArrange(bytes32 slot, bytes32 value) internal {

        require(value != bytes32(0x00), "sysUniqueIndexMapDelArrange, value must not be 0x00");

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, value));
        require(index != 0, "sysUniqueIndexMapDelArrange, value doesn't exist");

        uint256 lastIndex = (sysUniqueIndexMapSize(slot));
        require(lastIndex > 0, "sysUniqueIndexMapDelArrange, lastIndex must be large than 0, this must not happen");

        sysMapSet(slot, value, bytes32(0x00));

        while (index < lastIndex) {

            bytes32 nextValue = sysMapGet(indexSlot, bytes32(index + 1));
            sysMapSet(indexSlot, bytes32(index), nextValue);
            sysMapSet(slot, nextValue, bytes32(index));

            index ++;
        }

        sysMapSet(indexSlot, bytes32(lastIndex), bytes32(0x00));
    }

    function sysUniqueIndexMapReplace(bytes32 slot, bytes32 oldValue, bytes32 newValue) internal {
        require(oldValue != bytes32(0x00), "sysUniqueIndexMapReplace, oldValue must not be 0x00");
        require(newValue != bytes32(0x00), "sysUniqueIndexMapReplace, newValue must not be 0x00");

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, oldValue));
        require(index != 0, "sysUniqueIndexMapDel, oldValue doesn't exists");
        require(uint256(sysMapGet(slot, newValue)) == 0, "sysUniqueIndexMapDel, newValue already exists");

        sysMapSet(slot, oldValue, bytes32(0x00));
        sysMapSet(slot, newValue, bytes32(index));
        sysMapSet(indexSlot, bytes32(index), newValue);
    }

    //============================view & pure============================

    function sysUniqueIndexMapSize(bytes32 slot) internal view returns (uint256){
        return sysMapLen(slot);
    }

    //returns index, 0 mean not exist
    function sysUniqueIndexMapGetIndex(bytes32 slot, bytes32 value) internal view returns (uint256){
        return uint256(sysMapGet(slot, value));
    }

    function sysUniqueIndexMapGetValue(bytes32 slot, uint256 index) internal view returns (bytes32){
        bytes32 indexSlot = calcIndexSlot(slot);
        return sysMapGet(indexSlot, bytes32(index));
    }

    // index => value
    function calcIndexSlot(bytes32 slot) internal pure returns (bytes32){
        return calcNewSlot(slot, "index");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SlotData {

    constructor() {}

    // for map,  key could be 0x00, but value can't be 0x00;
    // if value == 0x00, it mean the key doesn't has any value
    function sysMapSet(bytes32 mappingSlot, bytes32 key, bytes32 value) internal returns (uint256 length){
        length = sysMapLen(mappingSlot);
        bytes32 elementOffset = sysCalcMapOffset(mappingSlot, key);
        bytes32 storedValue = sysLoadSlotData(elementOffset);
        if (value == storedValue) {
            //if value == 0 & storedValue == 0
            //if value == storedValue != 0
            //needn't set same value;
        } else if (value == bytes32(0x00)) {
            //storedValue != 0
            //deleting value
            sysSaveSlotData(elementOffset, value);
            length--;
            sysSaveSlotData(mappingSlot, bytes32(length));
        } else if (storedValue == bytes32(0x00)) {
            //value != 0
            //adding new value
            sysSaveSlotData(elementOffset, value);
            length++;
            sysSaveSlotData(mappingSlot, bytes32(length));
        } else {
            //value != storedValue & value != 0 & storedValue !=0
            //updating
            sysSaveSlotData(elementOffset, value);
        }
        return length;
    }

    function sysMapGet(bytes32 mappingSlot, bytes32 key) internal view returns (bytes32){
        bytes32 elementOffset = sysCalcMapOffset(mappingSlot, key);
        return sysLoadSlotData(elementOffset);
    }

    function sysMapLen(bytes32 mappingSlot) internal view returns (uint256){
        return uint256(sysLoadSlotData(mappingSlot));
    }

    function sysLoadSlotData(bytes32 slot) internal view returns (bytes32){
        //ask a stack position
        bytes32 ret;
        assembly{
            ret := sload(slot)
        }
        return ret;
    }

    function sysSaveSlotData(bytes32 slot, bytes32 data) internal {
        assembly{
            sstore(slot, data)
        }
    }

    function sysCalcMapOffset(bytes32 mappingSlot, bytes32 key) internal pure returns (bytes32){
        return bytes32(keccak256(abi.encodePacked(key, mappingSlot)));
    }

    function sysCalcSlot(bytes memory name) public pure returns (bytes32){
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(name))))));
    }

    function calcNewSlot(bytes32 slot, string memory name) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(slot, name))))));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../accessControlRef/AccessControlRefLayout.sol";

abstract contract NameServiceRefLayout is AccessControlRefLayout {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

abstract contract AccessControlRefLayout {

    address internal _accessControl;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "./OwnableEvent.sol";

interface OwnableInterface is OwnableEvent {

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function setAssociatedOperator(address newAssociatedOperator, bool flag) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface OwnableEvent {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NameServiceRefLayout.sol";
import "../accessControlRef/AccessControlRefLogic.sol";
import "./NameServiceRefInterface.sol";

import "../nameService/NameServiceInterface.sol";
import "../nameService/NameServiceType.sol";

contract NameServiceRefLogic is NameServiceRefLayout, AccessControlRefLogic, NameServiceRefInterface {

    function ns() view internal returns (NameServiceInterface){
        require(_accessControl != address(0), "ns(): address 0");
        return NameServiceInterface(_accessControl);
    }

    function nsUnsafe() view internal returns (NameServiceInterface){
        return NameServiceInterface(_accessControl);
    }

    function manager() view internal returns (address){
        return ns().getSingleSafe(NameServiceType.S_Manager);
    }

    function miner() view internal returns (address){
        return ns().getSingleSafe(NameServiceType.S_Miner);
    }

    function deputyCenter() view internal returns (address){
        return ns().getSingleSafe(NameServiceType.S_DeputyCenter);
    }

    function vrfCenter() view internal returns (address){
        return ns().getSingleSafe(NameServiceType.S_VRFCenter);
    }

    function vrfSigner() view internal returns (address){
        return ns().getSingleSafe(NameServiceType.S_VRFSigner);
    }

    function assetVault() view internal returns (address){
        return ns().getSingleSafe(NameServiceType.S_AssetVault);
    }

    function isServer(address input) view internal returns (bool){
        return ns().isMultiple(NameServiceType.M_Server, input);
    }

    function _setNameService(address ns_) internal {
        _setAccessControl(ns_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../dependant/nameServiceRef/NameServiceRefInterface.sol";
import "./CrownNameServiceRefEvent.sol";

interface CrownNameServiceRefInterface is NameServiceRefInterface, CrownNameServiceRefEvent {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library CrownNameServiceType {


    bytes32 constant S_InvitationCenter = "InvitationCenter";

    bytes32 constant S_FeeCollector = "FeeCollector";

    //**************************

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessControlRefLayout.sol";
import "./AccessControlRefInterface.sol";

import "../accessControl/AccessControlInterface.sol";

contract AccessControlRefLogic is AccessControlRefLayout, AccessControlRefInterface {

    function ac() view internal returns (AccessControlInterface){
        return AccessControlInterface(_accessControl);
    }

    function accessControl() override view external returns (address){
        return address(_accessControl);
    }

    function _setAccessControl(address accessControl_) internal {
        _accessControl = accessControl_;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../accessControlRef/AccessControlRefInterface.sol";
import "./NameServiceRefEvent.sol";

interface NameServiceRefInterface is AccessControlRefInterface, NameServiceRefEvent {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../accessControl/AccessControlInterface.sol";
import "./NameServiceEvent.sol";

import "./NameServiceType.sol";

interface NameServiceInterface is AccessControlInterface, NameServiceEvent {

    function isMultiple(bytes32 keyName, address which) view external returns (bool);

    function isMultipleSafe(bytes32 keyName, address which) view external returns (bool);

    function getSingle(bytes32 keyName) view external returns (address);

    function getSingleSafe(bytes32 keyName) view external returns (address);

    //==========

    function setMultiple(bytes32 keyName, address which, bool enable) external;

    function setMultipleEntries(bytes32[] memory keyName, address[] memory which, bool[] memory enable) external;

    function setSingle(bytes32 keyName, address which, bool enable) external;

    function setSingleEntries(bytes32[] memory keyName, address[] memory which, bool[] memory enable) external;

    function listSingleEntries() view external returns (NameServiceType.SingleEntryRet[] memory);

    function listMultipleEntries() view external returns (NameServiceType.MultipleEntryRet[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library NameServiceType {

    //copy the following declaration into new contract cause the compiler is not so smart for constant reference
    bytes32 constant SINGLE_REGISTRY_UNKNOWN = "";
    bytes32 constant S_Miner = "Miner";
    bytes32 constant S_Manager = "Manager";
    bytes32 constant S_DeputyCenter = "DeputyCenter";
    bytes32 constant S_VRFCenter = "VRFCenter";
    bytes32 constant S_VRFSigner = "VRFSigner";
    bytes32 constant S_AssetVault = "AssetVault";

    bytes32 constant MULTIPLE_REGISTRY_UNKNOWN = "";
    bytes32 constant M_Server = "Server";

    struct SingleEntryRet {
        bytes32 name;
        address addr;
    }

    struct MultipleEntryRet {
        bytes32 name;
        address[] addr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "./AccessControlRefEvent.sol";

interface AccessControlRefInterface is AccessControlRefEvent {

    function accessControl() view external returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../ownable/OwnableInterface.sol";
import "./AccessControlEvent.sol";

interface AccessControlInterface is OwnableInterface, AccessControlEvent {

    function isBlocked(address which) view external returns (bool);

    function isPrivileged(address which) view external returns (bool);

    //==========

    function setBlockList(address[] memory list, bool flag) external;

    function setPrivilegedList(address[] memory list, bool flag) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AccessControlRefEvent {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AccessControlEvent {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface NameServiceRefEvent {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface NameServiceEvent {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface CrownNameServiceRefEvent {

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./InvitationCenterType.sol";

interface InvitationCenterEvent {

}