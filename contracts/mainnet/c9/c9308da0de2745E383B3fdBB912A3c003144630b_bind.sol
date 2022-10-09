/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity >=0.5.0;

interface ERC20 {
function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);
function Agent(address _owner) external view returns (address agents);
function pledges(address _owner) external view returns (uint256,uint256,uint256,uint256);
function nft_pledge(address _owner) external view returns (uint256,uint256,uint256,uint256);
function usdt_user(address _owner) external view returns (uint256);
function is_receive_nft(address _owner) external view returns (uint256);
}
 interface WITNFT {
   function name() external view returns (string memory);
   function symbol() external view returns (string memory);
   function totalSupply() external view returns (uint256);
   function balanceOf(address _owner) external view returns (uint balance);
   function ownerOf(uint256 _tokenId) external view returns (address owner);
   function approve(address _to, uint256 _tokenId) external ;
   function transfer(address _to, uint256 _tokenId) external ;
   function tokenOfOwnerByIndex(address _recipient,uint256 index)external view returns (uint256 _tokenId);
   function mint(address _recipient,uint256 level) external ;

}
interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}
contract bind{

 
mapping(address => address)public Agent;
 mapping(address => address[]) public members;

address public owner; //拥有者地址


constructor() public {
owner = msg.sender;

}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function BindAgent(address _agent)public{
    require(Agent[msg.sender] == address(0x0));
    Agent[msg.sender] = _agent;
    members[_agent].push(msg.sender);
}
function getagent_length(address _address)public view returns(uint256){
    return members[_address].length;
}
function getsecond_length(address _address)public view returns(uint256){
    uint256 length;
    if(members[_address].length > 0){
         for(uint256 i = 0;i<members[_address].length; i++){
           length+= getagent_length(members[_address][i]);
         }
    }
    return length;
}
function get_team_number(address _address,uint256 _limit,uint256 _pageNumber)public view returns(address[] memory){
uint256 pageEnd = _limit * (_pageNumber + 1);
uint256 tokenSize = members[_address].length >= pageEnd ? _limit : members[_address].length - _limit *_pageNumber;
address[] memory tokenss = new address[](tokenSize);
if(members[_address].length > 0){
uint256 counter = 0;
 uint8 tokenIterator = 0;
 for(uint256 i = 0;i<members[_address].length && counter < pageEnd; i++){
   if(counter >= pageEnd - _limit){
     tokenss[tokenIterator] = members[_address][i];
     tokenIterator++;
   }
   counter++;
 }
 return tokenss;
}
}
function OwnerBind(address _agent,address _address)onlyOwner public{
    Agent[_address] = _agent;
}


//转币默认方法
}