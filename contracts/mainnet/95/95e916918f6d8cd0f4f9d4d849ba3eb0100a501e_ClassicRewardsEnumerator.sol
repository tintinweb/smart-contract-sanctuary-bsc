/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

pragma solidity ^0.8.4;



contract ClassicRewardsEnumerator {
    address ClassicRewards = 0x288F79cd26AaebCB3dd80f8FDb6904c8b1dBea74;


    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = CRN(ClassicRewards).balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
         tokenIds[i] = CRN(ClassicRewards).tokenOfOwnerByIndex(_owner, i);
         }
        return tokenIds;
  }



}

interface CRN{
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}