/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

library CREATE2 {
  error ContractNotCreated();

  function addressOf(address _creator, uint256 _salt, bytes32 _creationCodeHash) internal pure returns (address payable) {
    return payable(
      address(
        uint160(
          uint256(
            keccak256(
              abi.encodePacked(
                bytes1(0xff),
                _creator,
                _salt,
                _creationCodeHash
              )
            )
          )
        )
      )
    );
  }

  function deploy(uint256 _salt, bytes memory _creationCode) internal returns (address payable _contract) {
    assembly {
      _contract := create2(callvalue(), add(_creationCode, 32), mload(_creationCode), _salt)
    }

    if (_contract == address(0)) {
      revert ContractNotCreated();
    }
  }
}

/*
The MIT License (MIT)
Copyright (c) 2018 Murray Software, LLC.
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//solhint-disable max-line-length
//solhint-disable no-inline-assembly

library Proxy {
  function creationCode(address _target) internal pure returns (bytes memory result) {
    return abi.encodePacked(
      hex'3d602d80600a3d3981f3363d3d373d3d3d363d73',
      _target,
      hex'5af43d82803e903d91602b57fd5bf3'
    );
  }
}

library Array {
  error ArrNotSorted();

  function buildSet(address[] memory arr) internal pure {
    unchecked {
      uint256 size = arr.length;
      if (size == 0) return;

      address prev = arr[0];

      for (uint256 i = 1; i < size; i++) {
        address curr = arr[i];

        if (curr < prev) {
          revert ArrNotSorted();
        } else if (curr == prev) {
          for (uint256 z = i; z < size; z++) {
            arr[z - 1] = arr[z];
          }

          size--;
          i--;
        }

        prev = curr;
      }

      if (size != arr.length) {
        assembly { mstore(arr, size) }
      }
    }
  }

  function quickSort(address[] memory arr) internal pure {
    if (arr.length == 0) return;
    quickSort(arr, int(0), int(arr.length - 1));
  }

  function quickSort(address[] memory arr, int left, int right) internal pure {
    unchecked {
      int i = left;
      int j = right;
      if (i == j) return;

      address pivot = arr[uint(left + (right - left) / 2)];

      while (i <= j) {
        while (arr[uint(i)] < pivot) i++;
        while (pivot < arr[uint(j)]) j--;
        if (i <= j) {
          (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
          i++;
          j--;
        }
      }

      if (left < j) quickSort(arr, left, j);
      if (i < right) quickSort(arr, i, right); 
    }
  }
}

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1; // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.

    /*//////////////////////////////////////////////////////////////
                               WRITE LOGIC
    //////////////////////////////////////////////////////////////*/

    function write(bytes memory data) internal returns (address pointer) {
        // Prefix the bytecode with a STOP opcode to ensure it cannot be called.
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        bytes memory creationCode = abi.encodePacked(
            //---------------------------------------------------------------------------------------------------------------//
            // Opcode  | Opcode + Arguments  | Description  | Stack View                                                     //
            //---------------------------------------------------------------------------------------------------------------//
            // 0x60    |  0x600B             | PUSH1 11     | codeOffset                                                     //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset                                                   //
            // 0x81    |  0x81               | DUP2         | codeOffset 0 codeOffset                                        //
            // 0x38    |  0x38               | CODESIZE     | codeSize codeOffset 0 codeOffset                               //
            // 0x03    |  0x03               | SUB          | (codeSize - codeOffset) 0 codeOffset                           //
            // 0x80    |  0x80               | DUP          | (codeSize - codeOffset) (codeSize - codeOffset) 0 codeOffset   //
            // 0x92    |  0x92               | SWAP3        | codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset)   //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset) //
            // 0x39    |  0x39               | CODECOPY     | 0 (codeSize - codeOffset)                                      //
            // 0xf3    |  0xf3               | RETURN       |                                                                //
            //---------------------------------------------------------------------------------------------------------------//
            hex"60_0B_59_81_38_03_80_92_59_39_F3", // Returns all code in the contract except for the first 11 (0B in hex) bytes.
            runtimeCode // The bytecode we want the contract to have after deployment. Capped at 1 byte less than the code size limit.
        );

        assembly {
            // Deploy a new contract with the generated creation code.
            // We start 32 bytes into the code to avoid copying the byte length.
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        require(pointer != address(0), "DEPLOYMENT_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                               READ LOGIC
    //////////////////////////////////////////////////////////////*/

    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory) {
        start += DATA_OFFSET;

        return readBytecode(pointer, start, pointer.code.length - start);
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        require(pointer.code.length >= end, "OUT_OF_BOUNDS");

        return readBytecode(pointer, start, end - start);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(size, 32), 31), not(31))))

            // Store the size of the data in the first 32 byte chunk of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
    }
}

library Bytes {
  /**
   * @dev Reads an address value from a position in a byte array.
   * @param data Byte array to be read.
   * @param index Index in byte array of address value.
   * @return a address value of data at given index.
   * @return newIndex Updated index after reading the value.
   */
  function readAddress(
    bytes memory data,
    uint256 index
  ) internal pure returns (
    address a,
    uint256 newIndex
  ) {
    assembly {
      let word := mload(add(index, add(32, data)))
      a := and(shr(96, word), 0xffffffffffffffffffffffffffffffffffffffff)
      newIndex := add(index, 20)
    }

    require(newIndex <= data.length, "LibBytes#readAddress: OUT_OF_BOUNDS");
  }
}

contract Funder {
  uint256 private constant ADDRESS_SIZE = 20;

  Owned immutable public creator;
  address public recipientsPointer;

  error DoubleSetup();
  error ErrorDeployingContract();
  error ErrorSendingTo(address _to);
  error ErrorSendingRemaining();
  error NotRecoveryAddress(address _sender);
  error ExecuteReverted(address _to, uint256 _val, bytes _req, bytes _res);

  constructor() {
    creator = Owned(msg.sender);
  }

  function setUp(address[] calldata _recipients) external {
    if (recipientsPointer != address(0)) revert DoubleSetup();

    bytes memory code;
    for (uint256 i = 0; i < _recipients.length; i++) {
      code = abi.encodePacked(code, _recipients[i]);
    }

    // Store the recipients and name
    recipientsPointer = SSTORE2.write(code);

    distribute();
  }

  function recipients() public view returns (address[] memory) {
    unchecked {
      bytes memory code = SSTORE2.read(recipientsPointer);
      uint256 total = code.length / ADDRESS_SIZE;

      address[] memory rec = new address[](total);

      for (uint256 i = 0; i < code.length;) {
        (rec[i / ADDRESS_SIZE], i) = Bytes.readAddress(code, i);
      }

      return rec;
    }
  }

  receive() external payable {
    distribute();
  }

  fallback() external payable {
    distribute();
  }

  function distribute() public {
    unchecked {
      uint256 distributing = address(this).balance;
      if (distributing == 0) return;

      // Read all recipients
      address[] memory _recipients = recipients();
      uint256 recipientsCount = _recipients.length;

      // Get all current balances
      uint256 totalBalance = 0;
      uint256[] memory balances = new uint256[](recipientsCount);
      for (uint256 i = 0; i < recipientsCount; i++) {
        uint256 balance = _recipients[i].balance;
        totalBalance += balance;
        balances[i] = balance;
      }

      // Old avg and new avg
      uint256 newAvg = (totalBalance + distributing) / recipientsCount;

      // Fill each address until we reach the new average
      uint256 sent = 0;
      for (uint256 i = 0; i < recipientsCount; i++) {
        uint256 remaining = (distributing - sent);
        if (balances[i] < newAvg) {
          uint256 diff = newAvg - balances[i];
          uint256 send = remaining < diff ? remaining : diff;
          if (send == 0) break;

          (bool succeed,) = _recipients[i].call{ value: send }("");
          if (!succeed) revert ErrorSendingTo(_recipients[i]);
          sent += send;
        }
      }
    }
  }

  function recoveryExecute(address payable _to, uint256 _value, bytes calldata _data) external {
    if (msg.sender != creator.owner()) revert NotRecoveryAddress(msg.sender);

    (bool suc, bytes memory res) = _to.call{ value: _value }(_data);
    if (!suc) {
      revert ExecuteReverted(_to, _value, _data, res);
    }
  }
}

contract FunderFactory is Owned {
  address public immutable funderImplementation;
  bytes32 private immutable proxyCreationCodeHash;
  
  error EmptyFunder();
  error ErrorCreatingFunder();

  constructor(address _owner) Owned(_owner) {
    funderImplementation = address(new Funder());
    proxyCreationCodeHash = keccak256(Proxy.creationCode(funderImplementation));
  }

  function _isSorted(address[] memory _addresses) internal pure returns (bool) {
    unchecked {
      uint256 addressesLength = _addresses.length;
      if (addressesLength == 0) return true;

      address prev = _addresses[0];
      for (uint256 i = 1; i < addressesLength; i++) {
        address next = _addresses[i];
        if (uint160(next) > uint160(prev)) {
          prev = next;
        } else {
          return false;
        }
      }

      return true; 
    }
  }

  function _saltFor(address[] memory _addresses) internal pure returns (uint256) {
    if (!_isSorted(_addresses)) {
      Array.quickSort(_addresses);
      Array.buildSet(_addresses);
    }

    return uint256(keccak256(abi.encode(_addresses)));
  }

  function funderFor(address[] calldata _addresses) external view returns (address) {
    if (_addresses.length == 0) revert EmptyFunder();
    return CREATE2.addressOf(address(this), _saltFor(_addresses), proxyCreationCodeHash);
  }

  function createFunder(address[] memory _addresses) external {
    if (_addresses.length == 0) revert EmptyFunder();

    uint256 salt = _saltFor(_addresses);
    address funder = CREATE2.addressOf(address(this), salt, proxyCreationCodeHash);

    if (funder.code.length == 0) {
      address created = CREATE2.deploy(salt, Proxy.creationCode(funderImplementation));
      if (created != funder || funder.code.length == 0) revert ErrorCreatingFunder();
      Funder(payable(created)).setUp(_addresses);
    } else {
      Funder(payable(funder)).distribute();
    }
  }

  function recipientsOf(address _funder) external view returns (address[] memory) {
    return Funder(payable(_funder)).recipients();
  }

  function isCreated(address _funder) external view returns (bool) {
    if (_funder.code.length == 0) return false;

    try Funder(payable(_funder)).recipients() returns (address[] memory recipients) {
      return recipients.length != 0 && FunderFactory(address(this)).funderFor(recipients) == _funder;
    } catch {
      return false;
    }
  }
}