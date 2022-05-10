/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ERC721Interface {
  function transferFrom(address _from, address _to, uint256 _tokenId) external ;
}

contract DeesseGameNFTPool {

  address public deesseNftContract;

  constructor(address _deesseNftContract){
    deesseNftContract = _deesseNftContract;
  }

  function batchImport (uint256[] memory tokenIds) public{

    for( uint i = 0 ; i < tokenIds.length ; i++ ) {
        uint tokenId = tokenIds[i];
        ERC721Interface(deesseNftContract).transferFrom(msg.sender,address(this),tokenId);
    }
  }
}