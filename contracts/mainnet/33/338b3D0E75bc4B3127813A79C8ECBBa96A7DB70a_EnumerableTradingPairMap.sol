// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

/**
 *  @notice Library providing database functionality for trading pairs
 *  @author Sri Krishna Mannem
 */
library EnumerableTradingPairMap {
  struct TradingPairDetails {
    address baseAssetAddress;
    address quoteAssetAddress;
    address feedAddress;
  }
  struct Pair {
    string baseAsset;
    string quoteAsset;
  }

  struct EnumerableMap {
    Pair[] keyList;
    mapping(bytes32 => mapping(bytes32 => uint256)) keyPointers;
    mapping(bytes32 => mapping(bytes32 => TradingPairDetails)) values;
  }

  /**
   * @notice insert a key.
   * @dev duplicate keys are not permitted.
   * @param self storage space for pairs
   * @param base base asset to insert
   * @param quote quote asset to insert
   * @param value details of the pair to insert
   */
  function insert(
    EnumerableMap storage self,
    string memory base,
    string memory quote,
    TradingPairDetails memory value
  ) internal {
    require(!exists(self, base, quote), "Insert: Key already exists in the mapping");
    self.keyList.push(Pair(base, quote));
    self.keyPointers[toBytes32(base)][toBytes32(quote)] = self.keyList.length - 1;
    self.values[toBytes32(base)][toBytes32(quote)] = value;
  }

  /**
   * @notice remove a key
   * @dev key to remove must exist.
   * @param self storage space for pairs
   * @param base base asset to insert
   * @param quote quote asset to insert
   */
  function remove(
    EnumerableMap storage self,
    string memory base,
    string memory quote
  ) internal {
    require(exists(self, base, quote), "Remove: Key does not exist in the mapping");
    uint256 last = count(self) - 1;
    uint256 indexToReplace = self.keyPointers[toBytes32(base)][toBytes32(quote)];
    if (indexToReplace != last) {
      Pair memory keyToMove = self.keyList[last];
      self.keyPointers[toBytes32(keyToMove.baseAsset)][toBytes32(keyToMove.quoteAsset)] = indexToReplace;
      self.keyList[indexToReplace] = keyToMove;
    }
    delete self.keyPointers[toBytes32(base)][toBytes32(quote)];
    self.keyList.pop(); //Purge last element
    delete self.values[toBytes32(base)][toBytes32(quote)];
  }

  /**
   * @notice Get trading pair details
   * @param self storage space for pairs
   * @param base base asset of pair
   * @param quote quote asset of pair
   * @return trading pair details (base address, quote address, feedAdapter address)
   */
  function getTradingPair(
    EnumerableMap storage self,
    string memory base,
    string memory quote
  ) external view returns (TradingPairDetails memory) {
    require(exists(self, base, quote), "Get trading pair: Key does not exist in the mapping");
    return self.values[toBytes32(base)][toBytes32(quote)];
  }

  /*
   * @param self storage space for pairs
   * @return all the pairs in memory (base address, quote address)
   */
  function getAllPairs(EnumerableMap storage self) external view returns (Pair[] memory) {
    return self.keyList;
  }

  /*
   * @param self storage space for pairs
   * @return total number of available pairs
   */
  function count(EnumerableMap storage self) internal view returns (uint256) {
    return (self.keyList.length);
  }

  /**
   * @notice check if a key is in the Set.
   * @param self storage space for pairs
   * @param base base asset to insert
   * @param quote quote asset to insert
   * @return bool true if a pair exists
   */
  function exists(
    EnumerableMap storage self,
    string memory base,
    string memory quote
  ) internal view returns (bool) {
    if (self.keyList.length == 0) return false;
    return
      pairToBytes32(self.keyList[self.keyPointers[toBytes32(base)][toBytes32(quote)]]) ==
      pairToBytes32(Pair(base, quote));
  }

  /**
   * @dev Compute the hash of an asset string
   */
  function toBytes32(string memory s) private pure returns (bytes32) {
    return (keccak256(bytes(s)));
  }

  /**
   * @dev Compute the hash of a trading pair
   */
  function pairToBytes32(Pair memory p) private pure returns (bytes32) {
    return keccak256(abi.encode(p.baseAsset, "/", p.quoteAsset));
  }
}