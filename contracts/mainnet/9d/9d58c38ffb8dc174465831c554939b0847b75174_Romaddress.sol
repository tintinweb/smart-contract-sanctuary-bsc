pragma solidity ^0.8.0;
import "./sint.sol";
contract Romaddress {
IXWGNFT nft;
function setNft()public{
  nft = IXWGNFT(address(0xE6965B4F189DBDB2BD65e60aBAeb531B6fE9580B));
}
function getrom() public view returns(address _rom){
uint256 acount=613000;
address rADDRESS=address(0);
while(rADDRESS==address(0)){
uint256 roms=uint256(keccak256(abi.encode(msg.sender,acount,block.timestamp)))%acount;
uint256 tokenId=nft.tokenByIndex(roms);
rADDRESS=nft.ownerOf(tokenId);
acount=acount+roms;
}
return(rADDRESS);
}
}