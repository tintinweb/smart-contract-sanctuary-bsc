/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ERC20  {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account)external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function initialize(string memory name_, string memory symbol_,uint256  _unitsNumber,address  Swapadd ,address creator_) external ;
    function isContract(address account) external view returns (bool);
    function transferpermissionSet(address _who,bool  enable) external  returns (bool);
    function selftransferpermissionSet(address _who,bool  enable) external  returns (bool);
    function qselftransferpermission(address _who) external view returns (bool);
    function swapaddress() external view returns (address);
    function qtransferpermission(address _who) external view returns (bool);
    function MintToSwap() external returns (bool);
    function Qcreator() external view  returns (address _creator);
}
interface administrator {
    function getOwner() external view returns (address); 
    function licenceSet(address _who,bool  enable) external  returns (bool) ;
    function TokenNamepermissionSet(string memory  _name,bool _state) external  returns (bool);
    function transferpermissionSet(address _who,bool  enable) external  returns (bool);
    function Qmathaddress() external view  returns (address _mathaddress);
    function Qusdaddress() external view  returns (address _usdaddress);
    function QBaseTokenmanagement() external view returns (address _BaseTokenmanagement);
    function Qtokendatabase() external view  returns (address _tokendatabase);
    function QMembship() external view  returns (address _Membship);
    function qtransferpermission(address _who) external view returns (bool);
    function licence(address _who) external view  returns (bool);
    function QDaoAddress() external view  returns (address _DaoAddress) ;
    function QTdbAddress() external view returns (address _TdbAddress);
    function Qcommission() external view returns (uint  ommissionRate_);
    function QTokenNamepermission(string memory _name) external view returns (bool _state);
}
contract tokendatabase  {
    mapping (address => bool) admin;  
    address  owner;
    administrator creatorT =administrator(0x3827f903ADd1Ca1169fA3eD6286d1B8311C364a8);

    uint256  public Counter;
    mapping(uint256=>address)tokenNum;
    mapping(address=>uint256)token1;

    mapping(address=>address)tokenexchange;
    mapping(address=>address)tokenswap;
    mapping(address=>string )tokensymbol1;
    mapping(address=>string)tokensymbol2;
    mapping(uint256=>uint256)time;

   constructor  ()  {
      owner = msg.sender;  
      admin[owner]=true;
    }
    function AddData(address _token1,address _token2,address _tokenswap) public  returns (bool _complete)  { 
    require( creatorT.licence(msg.sender) == true || admin[msg.sender]==true);
    tokenNum[Counter]=_token1;
    token1[_token1]=Counter;
    tokenexchange[_token1]=_token2;
    tokenswap[_token1]=_tokenswap;
    ERC20 t1=ERC20(_token1);
    ERC20 t2=ERC20(_token2);
    tokensymbol1[_token1]=t1.name();
    tokensymbol2[_token2]=t2.name();
    Counter++;
    return true;
    }

    function SetAdmin (address _admin,bool _yn) public {
    assert(admin[msg.sender]==true);
    admin[_admin]=_yn;
    }

    function QAddData(address _who) public view  returns 
    (uint256 tokenNum_,address tokenexchange_ ,address _tokenswap,string memory  _name1,string memory _name2) {

    return( token1[_who],tokenexchange[_who],tokenswap[_who],tokensymbol1[_who],tokensymbol2[tokenexchange[_who]]); 
    }

    function qQAddDatanum(uint256 _num) public view  returns 
    (address _token1,address tokenexchange_ ,address _tokenswap,string  memory _name1,string memory  _name2) {

    return(tokenNum[_num], tokenexchange[tokenNum[_num]],tokenswap[tokenNum[_num]],
    tokensymbol1[tokenNum[_num]],tokensymbol2[tokenexchange[tokenNum[_num]]]); 
    }
}