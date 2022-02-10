/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// File: @umb-network/toolbox/dist/contracts/lib/ValueDecoder.sol

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
}

// File: @umb-network/toolbox/dist/contracts/IRegistry.sol


pragma solidity >=0.6.8;

interface IRegistry {
  function registry(bytes32 _name) external view returns (address);

  function requireAndGetAddress(bytes32 _name) external view returns (address);

  function getAddress(bytes32 _bytes) external view returns (address);

  function getAddressByString(string memory _name) external view returns (address);

  function stringToBytes32(string memory _string) external pure returns (bytes32);
}

// File: @umb-network/toolbox/dist/contracts/IChain.sol


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

// File: contracts/priceFetch.sol


pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;



// include Chain interface from Umbrella SDK





contract EthUsdPriceFetch {
    using ValueDecoder for bytes;

    
    IRegistry public registry;

    
    constructor(address _registry) {
        require(_registry != address(0x0), "_registry is empty");

        
        registry = IRegistry(_registry);
    }

    
    

    function getEthUsdPrice(bytes32 _key) public view returns (uint256) {
        

        (uint256 value, uint256 timestamp) = _chain().getCurrentValue(_key);

        require(timestamp > 0, "value does not exists");

        

        return value / (10 ** 18);
    }

   

    function _chain() internal view returns (IChain umbChain) {
        umbChain = IChain(registry.getAddress("Chain"));
       
    }
}