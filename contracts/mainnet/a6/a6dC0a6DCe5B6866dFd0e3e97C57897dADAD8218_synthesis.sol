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
    function nfts(uint256 _level)external view returns(uint256, uint256,uint256,uint256,uint256,uint256,uint256,uint256,string memory) ;
}
interface ERC20 {
function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);
}

contract synthesis{
    address public MMGNFT; 
     address public owner; //拥有者地址
     uint256 probability = 100;
     address token;
     address P_address;
   constructor() public {
            owner = msg.sender;
    P_address = msg.sender;

           }
modifier onlyOwner() {
require(msg.sender == owner);
_;

}
function setP_address(address _P_address)onlyOwner public returns(bool){
    P_address = _P_address;
    return true;
}
function setprobability(uint256 _probability)onlyOwner public returns(bool){
    probability = _probability;
    return true;
}
function setToken(address _token)onlyOwner public returns(bool){
     token = _token;
     return true;
}
function setMMGNFT(address _address)onlyOwner public returns(bool){
    MMGNFT = _address;
    return true;
}
 function rand(address _to,uint256 tokenId) private view returns(uint256) {
    uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,_to,tokenId,block.number)));
    return random%1000;
   }
   function getNft(uint256 level)public view returns(uint256,uint256,uint256){
       uint256 _synthesis = 0;
       uint256 cooling_time = 0;
       uint256 consume_number = 0;
       (,,,,_synthesis,cooling_time,consume_number,,) = NFT(MMGNFT).nfts(level);
       return (_synthesis,cooling_time,consume_number);
   }
function submits(uint256[] memory tokenIds)public returns(uint256){
      require(tokenIds.length >= 2);
      uint256 level;
        (,level,) = NFT(MMGNFT).token_nft(tokenIds[0]);  
        uint256 newlevel = level+1;
        uint256 newconsume_number;
        uint256 newcooling_time;
        uint256 new_synthesis;
        (new_synthesis,newcooling_time,newconsume_number) = getNft(newlevel);
      for(uint i=0;i<tokenIds.length;i++){
          require(NFT(MMGNFT).ownerOf(tokenIds[i]) == msg.sender);
            uint256 levels;
           (,level,) = NFT(MMGNFT).token_nft(tokenIds[i]);  
           if(i > 1){
               new_synthesis = new_synthesis + probability;
           }
           uint256 create_time;
           (,,create_time) = NFT(MMGNFT).token_nft(tokenIds[i]);  
           require(create_time+newcooling_time <= block.timestamp);
            require(level == levels,"level not");
      }
       require(new_synthesis <= 1000);
        ERC20(token).transferFrom(msg.sender,P_address,newconsume_number);
        uint256 number = rand(msg.sender,tokenIds[0]);
        if(number <= new_synthesis){
               for(uint k=0;k<tokenIds.length;k++){
              NFT(MMGNFT).transferFrom(msg.sender,address(0x0),tokenIds[k]);      
            }
           NFT(MMGNFT).mint(newlevel,msg.sender,1);
        }
      
}
}