/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

pragma solidity >=0.5.0 <0.6.0;

 interface NFT {
   function name() external view returns (string memory);
   function symbol() external view returns (string memory);
   function totalSupply() external view returns (uint256);
   function balanceOf(address _owner) external view returns (uint balance);
   function ownerOf(uint256 _tokenId) external view returns (address owner);
   function approve(address _to, uint256 _tokenId) external ;
   function transfer(address _to, uint256 _tokenId) external ;
   function transferFrom(address _from,address _to, uint256 _tokenId) external ;
   function Receive_nft(address _address) external ;
    function token_nft(uint256 _id) external view returns(uint256, uint256,uint256);
    function mint(uint256 _level,address _address,uint256 is_nft)external ;

}


contract exchange{



address public MMGNFT; 
address public NEWMMGNFT;
address public owner; //拥有者地址
   constructor() public {
            owner = msg.sender;
           }
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function setMMGNFT(address _address)onlyOwner public returns(bool){
    MMGNFT = _address;
    return true;
}
function setNEWMMGNFT(address _address)onlyOwner public returns(bool){
    NEWMMGNFT = _address;
    return true;
}
function exchange_nft(uint256 _tokenId)public{
     require(NFT(MMGNFT).ownerOf(_tokenId) == msg.sender);
     NFT(MMGNFT).transferFrom(msg.sender,address(0x0),_tokenId);
     uint256 level;
      (,level,) = NFT(MMGNFT).token_nft(_tokenId);
      if(level > 0 ){
          NFT(NEWMMGNFT).mint(level,msg.sender,1);
      }
      if(level == 0){
         NFT(NEWMMGNFT).mint(level,msg.sender,0);
      }  
}
}