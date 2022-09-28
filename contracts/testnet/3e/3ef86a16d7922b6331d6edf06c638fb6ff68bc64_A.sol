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

    function WalletOfOwner() public  returns (address[] memory,uint256[] memory) {

  //  uint256[] memory tokenIds = new uint256[](ownerTokenCount);
 
for(uint i=1;i<=5;i++)
{
    address ownerTokenAddress = NFT.ownerOf(i);
  //  ownerTokenCounts.push(i);
    //ownerTokenAddresses.push(ownerTokenAddress);
}
return (ownerTokenAddresses,ownerTokenCounts);
  
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