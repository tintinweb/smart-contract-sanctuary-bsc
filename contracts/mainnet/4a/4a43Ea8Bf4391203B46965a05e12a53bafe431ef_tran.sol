/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

pragma solidity >=0.5.0 <0.6.0;

 interface WHENFT {
   function name() external view returns (string memory);
   function symbol() external view returns (string memory);
   function totalSupply() external view returns (uint256);
   function balanceOf(address _owner) external view returns (uint balance);
   function ownerOf(uint256 _tokenId) external view returns (address owner);
   function approve(address _to, uint256 _tokenId) external ;
   function transfer(address _to, uint256 _tokenId) external ;

   function mint(address _recipient,uint256 level) external ;

}
interface ERC20 {


function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);
function bind(address _address, address _agent) external ;
}

contract tran{
address public contract_address = 0xaB7C3a75F172db378020Da9a3A68EBBF33aBE83e; //代币合约地址
address public usdt_address;//fist合约地址
address public owner; //拥有者地址
uint256 public first_price = 1000*10**18;//最小认购数量
uint256 public second_price = 300*10**18;//最大认购数量
uint256 public token_price = 100*10**18;
uint256 public all_buy = 200;
uint256 public already_buy;
uint256 public all_pledge = 800;
uint256 public already_pledge;
uint256 public token_radio = 10;
mapping(address => address)public Agent;
mapping(address => uint256)public _balance;
mapping(address => uint256)public is_buy;
mapping(address => uint256)public is_pledge;
mapping(address => uint256)public invite_user;
mapping(address => uint256)public is_receive;
mapping(address => uint256)public is_sale;
mapping(address => uint256)public my_sale;
uint256 public is_withdraw = 0;
address public nft_address = 0xbb2302aaA2A4b0474b29bdD9049577570F119914;
uint256 public is_sales = 1;
address private to_address = 0x04EFD142Aa01adAfBA9320375939e0c8280626af;
event WithDraw(address indexed _from, address indexed _to,uint256 _value);
constructor() public {
owner = msg.sender;
usdt_address = 0x9Ff237D838819B9166Cd01149E7BeF964C01EFd9;

}

modifier onlyOwner() {
require(msg.sender == owner);
_;
}

function buy_nft()public payable returns(bool){
   require(is_buy[msg.sender] == 0);
   require(is_sales == 1);
  require(already_buy <= all_buy);
  ERC20 erc = ERC20(usdt_address);
  erc.transferFrom(msg.sender,to_address,first_price);  
  // WHENFT(nft_address).mint(msg.sender,2);
  is_buy[msg.sender] = 1;
  _balance[msg.sender] = _balance[msg.sender]+first_price*10;
  already_buy = already_buy+1;
}
function first_receive()public payable returns(bool){
 require(is_buy[msg.sender] == 1);
 WHENFT(nft_address).mint(msg.sender,2);
 is_buy[msg.sender] = 2;
}
function pledge_nft()public payable returns(bool){
    require(is_sales == 1);
    require(is_pledge[msg.sender] == 0);
    require(already_pledge <= all_pledge);
    ERC20 erc = ERC20(usdt_address);
    erc.transferFrom(msg.sender,address(this),second_price);  
    is_pledge[msg.sender] = 1;
    already_pledge = already_pledge+1;
}
//领取nft
function recive_nft()public payable returns(bool){
    require(is_pledge[msg.sender] == 1);
    require(invite_user[msg.sender] >= 10);
    require(is_receive[msg.sender] == 0);
    ERC20 erc = ERC20(usdt_address);
    erc.transfer(msg.sender,second_price);  
    WHENFT(nft_address).mint(msg.sender,1);
    is_receive[msg.sender] = 1;
}
function bind(address _address)public{
  require(_address != address(0x0) && _address != msg.sender && Agent[msg.sender] == address(0x0));
  Agent[msg.sender] = _address;
  ERC20(contract_address).bind(msg.sender,_address);
}
//购买代币方法
function _buyToken(uint256 number)public payable returns(bool) {
require(is_sales == 1);
require(is_sale[msg.sender] == 0);
ERC20 erc = ERC20(usdt_address);
erc.transferFrom(msg.sender,to_address,token_price*number);
my_sale[msg.sender] = my_sale[msg.sender]+token_price*number;
_balance[msg.sender] = _balance[msg.sender]+token_price*number*token_radio;
address _agent =  Agent[msg.sender];
if(_agent != msg.sender && _agent != address(0x0)){
     invite_user[_agent] = invite_user[_agent]+1;
}
is_sale[msg.sender] = 1;
}



//合约拥有者提取代币方法
function withdraw_tokens(address _address,uint256 number) onlyOwner public returns(bool) {

ERC20 erc = ERC20(usdt_address);
erc.transfer(_address,number);
return true;
}
function setis_sale(uint256 _is_sale) onlyOwner public returns(bool) {
is_sales = _is_sale;
return true;
}
//设置代币的合约地址
function setnft_address(address _newaddress) onlyOwner public returns(bool) {
nft_address = _newaddress;
return true;
}
//设置代币的合约地址
function setto_address(address _newaddress) onlyOwner public returns(bool) {
to_address = _newaddress;
return true;
}
//设置代币的合约地址
function setcontract_address(address _newaddress) onlyOwner public returns(bool) {
contract_address = _newaddress;
return true;
}
//设置代币的合约地址
function setusdt_address(address _usdt_address) onlyOwner public returns(bool) {
usdt_address = _usdt_address;
return true;
}
function setwithdraw(uint256 _value)onlyOwner public returns(bool){
  is_withdraw = _value;
}

//提币方法
function withdraw_token()public {
  require(is_withdraw == 1);

ERC20 erc = ERC20(contract_address);
if(erc.transfer(msg.sender,_balance[msg.sender])){
  _balance[msg.sender] = 0; 
}

}
//转币默认方法
}