/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view  returns (string memory);
    function symbol() external view returns (string memory);    
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
}
interface  administrator {
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
contract MemberManagement  {
   address  owner;
   administrator creatorT =administrator(0x44770B1fB49615fC137aA9Cb077471c405eE893f);
   IERC20 Usdt1;
    mapping (address => bool) admin;
    mapping (address =>bool) MsCx;
    uint256 ApNu ;
    uint256 public  Msnum;
    mapping (address => uint256) MsAdToN;
    mapping (uint256 => address) MsNToAd;

    mapping (address =>address) Community;
    mapping (address =>address) Ceo; 
    mapping (address =>address) Manager;
    mapping (address =>address) ExDi;
    mapping (address =>address) Agent; 
    mapping (address =>address) MsFa;

   uint256 Ua1=5000 ether;
   uint256 Ua2=25000 ether;
   uint256 Ua3=125000 ether;
   uint256 Ua4=625000 ether;
   uint256 Ua5=3125000 ether;  

   mapping(address => uint256) Achievement;
   mapping(address => uint256) Bonus;
   ///
   
   constructor  ()  {
     
 
      owner = msg.sender;    
      admin[owner]=true;
      MsCx[owner]=true;
      Msnum =1;
      MsNToAd [1]=msg.sender;// 
      MsAdToN [msg.sender]=1;// 

      Community[owner ]=owner ;
      Ceo[owner ]=owner ;
      Manager[owner ]=owner ;
      ExDi[owner ]=owner ;
      Agent[owner ]=owner ;
      MsFa[owner ]=owner ;      
      ApNu=2000 ether ;
    }
    ////////////////////////
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    //initialization
    function init(address _who) public  returns (bool _complete)  { 
    require( creatorT.licence(msg.sender) == true);
  
      Community[_who ]=owner ;
      Ceo[_who ]=owner ;
      Manager[_who ]=owner ;
      ExDi[_who ]=owner ;
      Agent[_who ]=owner ;
      MsFa[_who ]=owner ;  
    return (true);
    }
    function MemberMa(address _from,address _to) public  returns (bool _complete)  { 
    require( creatorT.licence(msg.sender) == true);

    if( MsAdToN[ _to]<1) {   
    Msnum++;
    MsNToAd [Msnum]= _to;// 
    MsAdToN [ _to]=Msnum;// 
    
    MsFa[ _to ]= _from ;
    
    Community[ _to ]=Community[ _from ] ;
    Ceo[ _to ]=Ceo[ _from ] ;
    Manager[ _to ]=Manager[ _from ] ;
    ExDi[_to ]=ExDi[ _from ] ;
    Agent[ _to ]=Agent[_from  ];

    }
    return (true);
    }
    
    function SetAdmin (uint8 _se,address _adcx,bool _yn) public {
    assert(admin[msg.sender]==true);
    if(_se==1){
    admin[_adcx]=_yn;
    }
    if(_se==2){
     MsCx[_adcx]=_yn;
    }    
    }
    ////////////////////////////////////////////
    function setMember (uint8 _se,address _f,address _s) public {
    require(admin[msg.sender]==true);
              
    if(_se==1){
    Community[_f]=_s ;
    }
    if(_se==2){
    Ceo[_f]=_s ;
    }                 
    if(_se==3){
    Manager[_f]=_s ;
    }       
    if(_se==4){
    ExDi[_f]=_s ;
    }       
    if(_se==5){
    Agent[_f]=_s ;
    }           
    if(_se==6){
     MsFa[_f]=_s ;
    }                
   }

   function setApNu (uint256 _u1) public {
    require(admin[msg.sender]==true);
    ApNu=_u1;
   }
    //////////
   function setUa (uint256 _u1,uint256 _u2,uint256 _u3,uint256 _u4,uint256 _u5) public {
    require(admin[msg.sender]==true);
    Ua1=_u1;
    Ua2=_u2;
    Ua3=_u3;
    Ua4=_u4;
    Ua5=_u5;
   }

    function SetCommunity () public {

     require(Community[msg.sender]== owner  ); 
     Usdt1=IERC20(creatorT.Qusdaddress()); 
     require(Usdt1.allowance(msg.sender,address(this)) >= ApNu); 
     Usdt1.transferFrom(msg.sender,address(this),ApNu);   
     Community[msg.sender]=  msg.sender; 

    }

    function SetCeo (address _who) public {
     require(Community[msg.sender]== msg.sender && Community[ _who]==msg.sender && MsFa[ _who ]==msg.sender && Ceo[_who]!=_who); //
     Community[ _who]= msg.sender;
     Ceo[_who]=_who ;
    }    
    
    function SetManager (address _who) public {
     require(Ceo[msg.sender]== msg.sender && Ceo[ _who]==msg.sender && MsFa[ _who ]==msg.sender && Manager[_who]!=_who); 
     Manager[_who]=_who ;
    }        
    //////Grade promotion
    function acceptUP  (address _who,uint256 _amo) public {
    require( creatorT.licence(msg.sender) == true); 
    

    if(!isContract(MsFa[ _who ])){
    Achievement[MsFa[ _who ]]+=_amo;
    Gradepromotion (MsFa[ _who ]);
    }
    
    if(!isContract(Agent[ _who ])){
    if(Agent[ _who ]!=MsFa[ _who ])
    {
    Achievement[Agent[ _who ]]+=_amo;
    Gradepromotion (Agent[ _who ]);
    }
    }
    
    if(!isContract(ExDi[ _who ])){
    if(ExDi[ _who ]!=MsFa[ _who ] && ExDi[ _who ]!=Agent[ _who ])
    {   
    Achievement[ExDi[ _who ]]+=_amo;
    Gradepromotion (ExDi[ _who ]);
    }
    }
    
    if(!isContract(Manager[ _who ])){
    if(Manager[ _who ]!=MsFa[ _who ] && Manager[ _who ]!=Agent[ _who ] && Manager[ _who ]!=ExDi[ _who ])
    {      
    Achievement[Manager[ _who ]]+=_amo;
    Gradepromotion (Manager[ _who ]);
    }
    }
    
    if(!isContract(Ceo[ _who ])){
    if(Ceo[ _who ]!=MsFa[ _who ] && Ceo[ _who ]!=Agent[ _who ] && Ceo[ _who ]!=ExDi[ _who ]  && Ceo[ _who ]!=Manager[ _who ])
    {      
    Achievement[Ceo[ _who ]]+=_amo;
    Gradepromotion  (Ceo[ _who ]);
    }
    }
    
    if(!isContract(Community[ _who ])){
    if(Community[ _who ]!=MsFa[ _who ] && Community[ _who ]!=Agent[ _who ] 
    && Community[ _who ]!=ExDi[ _who ]  && Community[ _who ]!=Manager[ _who ] && Community[ _who ]!= Ceo[ _who ])
    {      
    Achievement[Community[ _who ]]+=_amo;
    Gradepromotion (Community[ _who ]);
    }
    }
    
    }
    

    function Gradepromotion  (address _who) internal {

    if(Achievement[_who]>= Ua1 && Agent[_who]!=_who ){ Agent[ _who ]=_who; }
    if(Achievement[_who]>= Ua2 && ExDi[_who]!=_who ){ ExDi[ _who ]=_who; }
    if(Achievement[_who]>= Ua3 && Manager[_who]!=_who ){ Manager[ _who ]=_who; }
    if(Achievement[_who]>= Ua4 && Ceo[_who]!=_who ){Ceo[ _who ]=_who; }
    if(Achievement[_who]>= Ua5 && Community[_who]!=_who ){Community[ _who ]=_who; }
    }

    function Qaddress1(address _who) public view  returns 
    (uint256 _MsAdToN,address _MsFa,address _community,address _Ceo,address _Manager,address _ExDi,address _Agent) {
    return( MsAdToN[_who],MsFa[_who],Community[_who],Ceo[_who],Manager[_who],ExDi[ _who ],Agent[_who]); 
    }

    function Qnum(uint256 _num) public view  returns (address _who) {
    return( MsNToAd[_num]); 
    }

    function QAchievement(address _who) public view  returns (uint256 _num) {
    return( Achievement[_who]); 
    }    
    function QApNu() public view  returns (uint256 _num) {

    return(ApNu); 
    }
}