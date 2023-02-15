/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

pragma solidity ^0.8.16;
//SPDX-License-Identifier: UNLICENSED

contract testNFT {
  //using Strings for uint256;
  //using SafeMath for uint256;
  //using Counters for Counters.Counter;

  // Supply
  uint256 public maxSupply = 1000;
  uint256 public lastSupply = maxSupply;
  uint256 public maxMintAmount = 10;

  // Lists 
  uint256[3000] public remainingIds;
  //mapping(uint256 => uint256) public lastDividendAt;
  mapping(uint256 => address) public minters;
  uint256[] mintedIDs;

    function increaseMaxSupply() public{
        uint256 alreadyMinted = maxSupply-lastSupply;
        maxSupply += 1000;
        lastSupply = maxSupply - alreadyMinted;
    }

    function mint() public{
        _randomMint(msg.sender);
    }

    // Random mint
    function _randomMint(address _target) internal returns (uint256) {
        // Get Random id to mint
        uint256 _index = _getRandom() % lastSupply;
        uint256 _realIndex = getValue(_index) + 1;
        mintedIDs.push(_realIndex);
        // Reduce supply
        lastSupply--;
        // Replace used id by last
        remainingIds[_index] = getValue(lastSupply);
        // Mint
        //_safeMint(_target, _realIndex);
        // Save Original minters
        minters[_realIndex] = _target;
        // Save dividend
        //lastDividendAt[_realIndex] = totalDividend;
        return _realIndex;
    }

    function getMintedIds() public view returns (uint256[] memory){
        return mintedIDs;
    }

    // Get value from a remaining id node
    function getValue(uint _index) internal view returns(uint256){
        if(remainingIds[_index] != 0) return remainingIds[_index];
        else return _index;
    }

    // Create a random id for minting
    function _getRandom() internal view returns (uint256) {
        return
        uint256(
            keccak256(
            abi.encodePacked(block.prevrandao, block.timestamp, lastSupply)
            )
        );
    }
}