/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
interface IERC721{
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address owner) external view returns (uint256 balance);

}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

contract A {
    IERC721 public NFT;
    constructor (IERC721 NFT_) {
        NFT = NFT_;
    }
 uint256[] public ownerTokenCounts ;
 address[] public ownerTokenAddresses ;
    function WalletOfOwner() public view returns (address,uint256) {
  uint256 count=1;
  uint256 id=count;
  count++;
  //  uint256[] memory tokenIds = new uint256[](ownerTokenCount);
 
   
    address ownerTokenAddress = NFT.ownerOf(count);
  // ownerTokenCounts.push(i);
  //ownerTokenAddresses.push(ownerTokenAddress);

return (ownerTokenAddress,id);

    }


    function ViewAll() public view  returns (address[] memory addres,uint256[] memory id) {

for(uint i=0;i<=5;i++)
{
   addres[i]=ownerTokenAddresses[i];
    id[i]=ownerTokenCounts[i];
    return (addres,id);

}
  
    }


}