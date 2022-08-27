/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

pragma solidity >=0.5.0 <0.6.0;

 interface FHNFT {
   function name() external view returns (string memory);
   function symbol() external view returns (string memory);
   function totalSupply() external view returns (uint256);
   function balanceOf(address _owner) external view returns (uint balance);
   function ownerOf(uint256 _tokenId) external view returns (address owner);
   function approve(address _to, uint256 _tokenId) external ;
   function transfer(address _to, uint256 _tokenId) external ;
   function mint(address _recipient,uint256 level) external;
   function MintBox(address _recipient,uint256 level) external ;
   function Complimentary_box(address _address,uint256 radio) external ;
}
interface ERC20 {


function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);
function bindInvitor(address account, address invitor)external;

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
contract FHifo{
address public contract_address; //代币合约地址
address public usdt_address=0x9Ff237D838819B9166Cd01149E7BeF964C01EFd9;//usdt合约地址
address public Fhpg_address;//Fhpg合约地址
address public Hpg_address=0x1A076D401A824F591Fa5753EAF5d6edBace9D7dF;//hpg合约地址
address public fist_address=0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;//
address public osk_address=0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da;//
address public FistLp=0x703f1C0B4399A51704e798002281bf26D6f9c2E6;
address public OskLp=0x2CD7CA738e568589BC1c0875c0D6DEC867f41bfA;
address public HpgLp=0x7A1568aE0Dc0D6621933790e7c2f03A0A72da664;
address public box_nft = 0x9995c137Bd391d0D2A60FCE7eA502d3ea2C63e22;
uint256 public Fhpg_radio;
address public owner; //拥有者地址
uint256 public u_radio = 1000;
uint256 public first_price = 28*10**18;//最小认购数量
uint256 public second_price = 98*10**18;//最大认购数量
uint256 public token_price = 298*10**18;

uint256 public token_radio = 10;
mapping(address => uint256)public is_first;
mapping(address => uint256)public is_second;
mapping(address => uint256)public is_token;
mapping(address => uint256)public Recommended_proportion;
mapping(address => address)public Agents;
mapping(address => uint256)public _balance;
mapping(address => uint256)public recommend_balance;
mapping(address => uint256)public Valid_address;
mapping(address => uint256)public direct_push;
mapping(address => uint256)public is_receive;
mapping(address => address[])public push_address;

mapping(address =>uint256)public airdrop;
uint256 public is_withdraw = 0;
address public nft_address;
address private to_address = 0x04EFD142Aa01adAfBA9320375939e0c8280626af;
event WithDraw(address indexed _from, address indexed _to,uint256 _value);
constructor() public {
owner = msg.sender;

}

modifier onlyOwner() {
require(msg.sender == owner);
_;
}

function check_address(address _agent,address _account)public view returns(bool){
    if(push_address[_agent].length > 0){
      for(uint i;i<push_address[_agent].length;i++){
        if(_account == push_address[_agent][i]){
          return false;
        }
      }
    }
    return true;
}
//赠送百分之1概率的盲盒 type 1usdt 预售 type 2 FIST预售   3OSK预售   4 HPG预售   5 FHPG预售
function buy_first(uint256 _type)public{
    require(_type> 0 && _type <= 5);
    require(is_first[msg.sender] == 0);
    uint256 token_number = 0;
    if(_type == 1){
        ERC20(usdt_address).transferFrom(msg.sender,to_address,first_price);

    }else if(_type == 2){
        uint256 fist_number = getFist_number(first_price);
        ERC20(fist_address).transferFrom(msg.sender,to_address,fist_number);
    }else if(_type == 3){
        uint256 osk_number = getOsk_number(first_price);
        ERC20(osk_address).transferFrom(msg.sender,to_address,osk_number);
    }else if(_type == 4){
        uint256 hpg_number = getHpg_number(first_price);
        ERC20(Hpg_address).transferFrom(msg.sender,to_address,hpg_number);
    }

    FHNFT(box_nft).MintBox(msg.sender,1);
    token_number = first_price*u_radio;
    _balance[msg.sender] = _balance[msg.sender]+token_number; 
    if(Agents[msg.sender] != address(0x0)){
        inviter(token_number,Agents[msg.sender],msg.sender);
    }

    is_first[msg.sender] = 1;
}
function getFist_number(uint256 u_price)public view returns(uint256){
      uint256 fist_number = u_price/getExchangeCountOfOneUsdt(FistLp,fist_address);
      return fist_number;
}
function getOsk_number(uint256 u_price)public view returns(uint256){
      uint256 fist_number = getFist_number(u_price);
      uint256 Osk_number = fist_number*1e18/getOskprice(OskLp,osk_address);
      return Osk_number;
}
function getHpg_number(uint256 u_price)public view returns(uint256){
      uint256 fist_number = getFist_number(u_price);
      uint256 hpg_number = fist_number*1e18/getHpgprice(HpgLp,Hpg_address);
      return hpg_number;
}
function inviter(uint256 _token_number,address _agent,address _account)private{
      if(_agent != address(0x0) && Recommended_proportion[_agent] >0){
             recommend_balance[_agent] = recommend_balance[_agent] + _token_number * Recommended_proportion[msg.sender]/100;
                  if(check_address(_agent,_account)){
                      push_address[Agents[msg.sender]].push(msg.sender);
                      Valid_address[_agent] = Valid_address[_agent]+1;
                      direct_push[_agent] = direct_push[_agent]-1;
                   }
         }
}
function buy_second(uint256 _type)public{
   require(_type> 0 && _type <= 5);
   require(is_second[msg.sender] == 0);
    uint256 token_number = 0;
      if(_type == 1){
        ERC20(usdt_address).transferFrom(msg.sender,to_address,second_price);
         
     }else if(_type == 2){
         uint256 fist_number = getFist_number(second_price);
        ERC20(fist_address).transferFrom(msg.sender,to_address,fist_number);
     }else if(_type == 3){
        uint256 osk_number = getOsk_number(second_price);
         ERC20(osk_address).transferFrom(msg.sender,to_address,osk_number);
     }else if(_type == 4){
         uint256 hpg_number = getHpg_number(second_price);
        ERC20(Hpg_address).transferFrom(msg.sender,to_address,hpg_number);
     }
       FHNFT(box_nft).MintBox(msg.sender,5);
          token_number = second_price*u_radio;
         _balance[msg.sender] = _balance[msg.sender]+token_number;
         Recommended_proportion[msg.sender] = 5;
     if(Agents[msg.sender] != address(0x0)){
     inviter(token_number,Agents[msg.sender],msg.sender);
     }
     is_second[msg.sender] = 1;
}
function buy_token(uint256 _type)public{
   require(_type> 0 && _type <= 5);
   require(is_token[msg.sender] == 0);
    uint256 token_number = 0;
      if(_type == 1){
         ERC20(usdt_address).transferFrom(msg.sender,to_address,token_price);
     }else if(_type == 2){
         uint256 fist_number = getFist_number(token_price);
         ERC20(fist_address).transferFrom(msg.sender,to_address,fist_number);
     }else if(_type == 3){
        uint256 osk_number = getOsk_number(token_price);
      ERC20(osk_address).transferFrom(msg.sender,to_address,osk_number);
     }else if(_type == 4){
         uint256 hpg_number = getHpg_number(token_price);
    ERC20(Hpg_address).transferFrom(msg.sender,to_address,hpg_number);
     }
          FHNFT(box_nft).MintBox(msg.sender,15);
         token_number = token_price*u_radio;
         _balance[msg.sender] = _balance[msg.sender]+token_number;
         Recommended_proportion[msg.sender] = 10;
    if(Agents[msg.sender] != address(0x0)){
     inviter(token_number,Agents[msg.sender],msg.sender);
     }
     is_token[msg.sender] = 1;
}

function bind(address _agent)public{
  require(_agent != address(0x0));
  require(Agents[msg.sender] == address(0x0));
  ERC20(contract_address).bindInvitor(msg.sender,_agent);
  Agents[msg.sender] = _agent;
  airdrop[msg.sender] = 1;
  direct_push[_agent] = direct_push[_agent]+1;
}
function receive_nft()public{
  require(is_token[msg.sender] == 1);
  require(Valid_address[msg.sender] >= 10);
  require(is_receive[msg.sender] == 0);
   FHNFT(nft_address).mint(msg.sender,1);
  is_receive[msg.sender] = 1;
}

//合约拥有者提取代币方法
function withdraw_tokens(address _address,uint256 number) onlyOwner public returns(bool) {

ERC20 erc = ERC20(usdt_address);
erc.transfer(_address,number);
return true;
}
function setosk_address(address _newaddress) onlyOwner public returns(bool) {
osk_address = _newaddress;
return true;
}
function setFistLp(address _newaddress) onlyOwner public returns(bool) {
FistLp = _newaddress;
return true;
}
function setOskLp(address _newaddress) onlyOwner public returns(bool) {
OskLp = _newaddress;
return true;
}
function setHpglp(address _newaddress) onlyOwner public returns(bool) {
HpgLp = _newaddress;
return true;
}
function setfist_address(address _newaddress) onlyOwner public returns(bool) {
fist_address = _newaddress;
return true;
}
function setbox_nft(address _newaddress) onlyOwner public returns(bool) {
box_nft = _newaddress;
return true;
}

function setnft_address(address _newaddress) onlyOwner public returns(bool) {
nft_address = _newaddress;
return true;
}

function setto_address(address _newaddress) onlyOwner public returns(bool) {
to_address = _newaddress;
return true;
}

function setcontract_address(address _newaddress) onlyOwner public returns(bool) {
contract_address = _newaddress;
return true;
}
function sethpg_address(address _newaddress) onlyOwner public returns(bool) {
Hpg_address = _newaddress;
return true;
}
function setusdt_address(address _usdt_address) onlyOwner public returns(bool) {
usdt_address = _usdt_address;
return true;
}
function setwithdraw(uint256 _value)onlyOwner public returns(bool){
  is_withdraw = _value;
}
 function getExchangeCountOfOneUsdt(address _lp,address _token_address) public view returns (uint256)
    {
        if(_lp == address(0)) {return 0;}

        IPancakePair pair = IPancakePair(_lp);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;

        if(pair.token0() == _token_address)
        {
            a = _reserve0;
            b = _reserve1;
        }

        return b/a;
    }
     function getOskprice(address _lp,address _token_address) public view returns (uint256)
    {
        if(_lp == address(0)) {return 0;}

        IPancakePair pair = IPancakePair(_lp);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;

        // if(pair.token0() == _token_address)
        // {
        //     a = _reserve0;
        //     b = _reserve1;
        // }

        return a*1e18/b;
    }
       function getHpgprice(address _lp,address _token_address) public view returns (uint256)
    {
        if(_lp == address(0)) {return 0;}

        IPancakePair pair = IPancakePair(_lp);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;

        // if(pair.token0() == _token_address)
        // {
        //     a = _reserve0;
        //     b = _reserve1;
        // }

        return a*1e18/b;
    }
     function getExchangeFIst(address _lp,address _token_address) public view returns (uint256,uint256)
    {

        IPancakePair pair = IPancakePair(_lp);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;
        return (a,b);
    }
    function claim()public{
      require(airdrop[msg.sender] == 1);
      ERC20 erc = ERC20(contract_address);
      if(erc.transfer(msg.sender,10*10**18)){
           airdrop[msg.sender] == 2;
      }
    }
//提币方法
function withdraw_token()public {
  require(is_withdraw == 1);

ERC20 erc = ERC20(contract_address);
if(erc.transfer(msg.sender,_balance[msg.sender])){
  _balance[msg.sender] = 0; 
}

}
function withdraw_recommand_token()public {
  require(is_withdraw == 1);

ERC20 erc = ERC20(contract_address);
if(erc.transfer(msg.sender,recommend_balance[msg.sender])){
  recommend_balance[msg.sender] = 0; 
}

}
//转币默认方法
}