// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@umb-network/toolbox/dist/contracts/IChain.sol";
import "@umb-network/toolbox/dist/contracts/IRegistry.sol";
import "@umb-network/toolbox/dist/contracts/lib/ValueDecoder.sol";
import "./interfaces/IDatumReceiver.sol";

/// @title Datum Receiver example implementation
/// @notice This is only an example implementation, and can be entirely rewriten 
/// by the needs of the consumer as long as it uses the IDatumReceiver interface. 
contract StandardDatumReceiver is IDatumReceiver, Ownable {
  using ValueDecoder for bytes;

  struct Record {
    uint32 timestamp;
    bytes28 value;
  }

  struct LastUpdate {
    bytes32 updateHash;
    uint32 timestamp;
    uint32 minTimeBetweenUpdates;
  }

  IRegistry public immutable contractRegistry;
  LastUpdate public lastUpdate;

  bytes32 public immutable datumRegistry = bytes32("DatumRegistry");

  mapping(bytes32 => Record) public recordForKey;

  /// @notice Makes sure the caller is a trusted source, like DatumRegistry
  modifier onlyFromDatumRegistry(address _msgSender) {
    require(
      contractRegistry.getAddress(datumRegistry) == _msgSender,
        string(abi.encodePacked("caller is not ", datumRegistry))
    );
    _;
  }

  constructor(address _contractRegistry) {
    contractRegistry = IRegistry(_contractRegistry);
  }

  /// @notice Sets the minimum time threshold between approvals
  /// @dev Specified in seconds.
  function setMinTimeBetweenUpdates(uint32 _timeInSeconds) external onlyOwner {
    lastUpdate.minTimeBetweenUpdates = _timeInSeconds;
  }

  /// @notice Apply the rules of storage or data usage here. In this case it
  /// checks if the received data is stored and if not, stores it. 
  function receivePallet(Pallet calldata _pallet) 
    external
    virtual
    override
    onlyFromDatumRegistry(msg.sender)
  {
    IChain oracle = IChain(contractRegistry.getAddressByString("Chain"));
    IChain.Block memory _block = oracle.blocks(_pallet.blockId);

    bytes32 thisUpdateHash = keccak256(abi.encodePacked(_block.dataTimestamp, _pallet.key));
    require(lastUpdate.updateHash != thisUpdateHash, "update already received");

    lastUpdate.timestamp = _block.dataTimestamp;
    lastUpdate.updateHash = thisUpdateHash;

    Record storage record = recordForKey[_pallet.key];

    record.timestamp = _block.dataTimestamp;
    record.value = bytes28(_pallet.value << 32);
  }

  /// @notice This function shall be view and will be called with a staticcall 
  /// so receiver can preview the content and decide if you wanna pay for it.
  function approvePallet(Pallet calldata _pallet) external view virtual override returns (bool) {
    IChain oracle = IChain(contractRegistry.getAddressByString("Chain"));
    IChain.Block memory _block = oracle.blocks(_pallet.blockId);

    // revert if block is too new given the desired threshold
    require(_block.dataTimestamp > lastUpdate.timestamp + lastUpdate.minTimeBetweenUpdates, 
      "delivery refused: block too old or not needed yet"
    );

    return true;  
  }

  /// @notice Gets Records of keys.
  function getStoredRecords(bytes32[] calldata keys) external view returns (Record[] memory records) {
    records = new Record[](keys.length);

    for (uint256 i = 0; i < keys.length; i++) {
      records[i] = recordForKey[keys[i]];
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.8;
pragma abicoder v2;

interface IChain {
  struct Block {
    bytes32 root;
    uint32 dataTimestamp;
  }

  struct FirstClassData {
    uint224 value;
    uint32 dataTimestamp;
  }

  function isForeign() external pure returns (bool);

  function blocks(uint256) external view returns (Block memory);

  function fcds(bytes32) external view returns (FirstClassData memory);

  function blocksCount() external view returns (uint32);

  function blocksCountOffset() external view returns (uint32);

  function padding() external view returns (uint16);

  function getName() external pure returns (bytes32);

  function recoverSigner(bytes32 affidavit, uint8 _v, bytes32 _r, bytes32 _s) external pure returns (address);

  function getStatus() external view returns(
    uint256 blockNumber,
    uint16 timePadding,
    uint32 lastDataTimestamp,
    uint32 lastBlockId,
    address nextLeader,
    uint32 nextBlockId,
    address[] memory validators,
    uint256[] memory powers,
    string[] memory locations,
    uint256 staked
  );

  function getBlockId() external view returns (uint32);

  // this function does not works for past timestamps
  function getBlockIdAtTimestamp(uint256 _timestamp) external view returns (uint32);

  function getLatestBlockId() external view returns (uint32);

  function getLeaderIndex(uint256 _numberOfValidators, uint256 _timestamp) external view returns (uint256);

  function getNextLeaderAddress() external view returns (address);

  function getLeaderAddress() external view returns (address);

  function getLeaderAddressAtTime(uint232 _timestamp) external view returns (address);

  function hashLeaf(bytes calldata _key, bytes calldata _value) external pure returns (bytes32);

  function verifyProof(bytes32[] calldata _proof, bytes32 _root, bytes32 _leaf) external pure returns (bool);

  function verifyProofForBlock(
    uint256 _blockId,
    bytes32[] calldata _proof,
    bytes calldata _key,
    bytes calldata _value
  ) external view returns (bool);

  function bytesToBytes32Array(
    bytes calldata _data,
    uint256 _offset,
    uint256 _items
  ) external pure returns (bytes32[] memory);

  function verifyProofs(
    uint32[] memory _blockIds,
    bytes memory _proofs,
    uint256[] memory _proofItemsCounter,
    bytes32[] memory _leaves
  ) external view returns (bool[] memory results);
  
  function getBlockRoot(uint256 _blockId) external view returns (bytes32);

  function getBlockTimestamp(uint32 _blockId) external view returns (uint32);

  function getCurrentValues(bytes32[] calldata _keys)
  external view returns (uint256[] memory values, uint32[] memory timestamps);

  function getCurrentValue(bytes32 _key) external view returns (uint256 value, uint256 timestamp);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.8;

interface IRegistry {
  function registry(bytes32 _name) external view returns (address);

  function requireAndGetAddress(bytes32 _name) external view returns (address);

  function getAddress(bytes32 _bytes) external view returns (address);

  function getAddressByString(string memory _name) external view returns (address);

  function stringToBytes32(string memory _string) external pure returns (bytes32);
}

//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.8;

library ValueDecoder {
  function toUint(bytes memory _bytes) internal pure returns (uint256 value) {
    assembly {
      value := mload(add(_bytes, 32))
    }
  }

  function toUint(bytes32 _bytes) internal pure returns (uint256 value) {
    assembly {
      value := _bytes
    }
  }

  function toInt(uint224 u) internal pure returns (int256) {
    int224 i;
    uint224 max = type(uint224).max;

    if (u <= (max - 1) / 2) { // positive values
      assembly {
        i := add(u, 0)
      }

      return i;
    } else { // negative values
      assembly {
        i := sub(sub(u, max), 1)
      }
    }

    return i;
  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "../lib/PassportStructs.sol";

interface IDatumReceiver {
  /// @notice This function will hold the parameters or business rules that consumer
  /// wants to do with the received data structure, here called Pallet.
  /// @param _pallet the structure sent by DatumRegistry, containing proof, key and value
  function receivePallet(Pallet calldata _pallet) external;

  /// @notice This function holds rules that consumer may need to check before accepting
  /// the Pallet. Rules like how old is the block, or how many blocks have passed since 
  /// last storage. Deliverer will check if approvePallet reverted this call or returned true.
  /// @param _pallet The exact same Pallet that will arrive at the receivePallet endpoint.
  /// @return true if wants pallet or should REVERT if Contract does not want the pallet.
  /// @dev DO NOT RETURN false.
  function approvePallet(Pallet calldata _pallet) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

/// @notice Holds the information of the Contract interested on receiving data
/// @param receiver The address of the receiver contract
/// @param keys The array of bytes32 encoded keys. Encode with Umbrella's Toolbox to match the correct length.
/// @param funder The address of the wallet that will be allowed to manage funds of this Datum.
/// @param balance The balance in UMB this Datum holds.
/// @param enabled True if the Datum is enabled and eligible to receive data, false if owner doesn't want data.
struct Datum {
  address receiver;
  bytes32[] keys;
  address funder;
  // total supply of UMB can be saved using 89bits, so we good with 128
  uint128 balance;
  bool enabled;
}

/// @notice Holds the information pertinent to that piece of data.
/// @param blockId Umbrella Network sidechain's blockId.
/// @param key Key encoded in bytes32
/// @param value Value encoded in bytes32
/// @param proof Merkle proof to verify that the data was really minted by Umbrella's sidechain. 
struct Pallet {
  uint32 blockId;
  bytes32 key;
  bytes32 value;
  bytes32[] proof; 
}

/// @notice Holds the relation between Datum and the data it's interested on.
/// @param datumId The keccack256 hash that indexes the Datum the delivery goes to.
/// @param indexes With a Pallet[], represents the position on the array that the Pallets this Datum wants is.  
struct Delivery {
  bytes32 datumId;
  uint256[] indexes;
}