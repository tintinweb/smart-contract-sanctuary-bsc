/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface bonus {
    function issue (address _Who,uint256  _Number) external returns (bool success);
}

contract  deposit0 {
    address  owner;
    mapping (address => bool) admin;
    uint256  private total=150000000000000000000000000;
    uint256  private accumulation;
    //current total
    uint256  private ctotal;
    bool  private state;
    mapping (address =>uint256 ) number;
    mapping (address =>uint256 ) time;
    IERC20 token1 =IERC20(0x3D72cCA97537d8D3bED5ff36dEb63aB3f6Ca3775);
    bonus  b1=bonus(0xA598F66403E6B7F411eaB68b440655e1E3cD245D);

    constructor  ()  {
      owner = msg.sender;    
      admin[owner]=true;
    }
    function SetState (bool _yn) public {
    assert(admin[msg.sender]==true);
    state=_yn;
    }


   function deposit (uint256  _Number) public returns (bool success) {
    require (state==true);
    require(token1.balanceOf(msg.sender)>_Number);
    require ((ctotal+_Number)<=total); 
    require (number[msg.sender]==0);
    require (_Number>=100000000000000000000 && _Number<1000000000000000000000000);
    assert(token1.transferFrom(msg.sender,address(this),_Number));
    number[msg.sender]=_Number;
    time[msg.sender]=block.timestamp;
    ctotal+=_Number;
    accumulation+=_Number;
    return true;   
    }

   function withdraw() public returns (bool success) {
   require (number[msg.sender]>0);   
   token1.transfer(msg.sender,number[msg.sender]);
   uint256 n1;
   n1=interest(msg.sender);
   if(n1>0){
   b1.issue(msg.sender ,n1);   
   } 
    ctotal-=number[msg.sender];
    number[msg.sender]=0;
    time[msg.sender]=0;
    return true;  
   }

   function sparewithdraw(address _who) public returns (bool success) {
   require (admin[msg.sender]==true);    
   require (number[_who]>0);   
   token1.transfer(_who,number[_who]);
   uint256 n1;
   n1=interest(_who);
   if(n1>0){
   b1.issue(_who ,n1);   
   } 
   ctotal-=number[_who];
    number[_who]=0;
    time[_who]=0;
    return true;  
   }


    function interest(address _who) public view returns (uint256 _int) {
    uint64 d1 ;
    d1= (getNowDay()-getDay(time[_who]));   

    if( d1< 5  ){ 
     return 0;   
     } 
    if( d1> 5 && d1<361 ){ 
     return number[_who]*d1/10000;   
     } 
    if(  d1>360 ){ 
     return number[_who]*360/10000;   
     } 

    }

    function getDay(uint timestamp) public pure returns (uint64) {
        return uint64(timestamp / 60/60/24);
    }
    function getNowDay() public view returns (uint64) {
        return uint64(block.timestamp / 60/60/24);
    }
    function Qaddress() public view returns (uint256 _number,uint64 _day,uint256 interest_){
    uint64 t1;
    if(time[msg.sender]==0){t1=0;}
    if(time[msg.sender]>0){t1=getNowDay()-getDay(time[msg.sender]);}   
     return (number[msg.sender] , t1,interest(msg.sender) );    
    }
    function Qaddress2(address _who ) public view returns (uint256 _number,uint64 _day,uint256 interest_){
    uint64 t1;
    if(time[msg.sender]==0){t1=0;}
    if(time[msg.sender]>0){t1=getNowDay()-getDay(time[msg.sender]);}   
     return (number[_who] , t1,interest(_who) );    
    }

    function Qtotal() public view  returns(uint256 total_) {
    return( total); 
    }
    function Qaccumulation() public view  returns(uint256 accumulation_) {
    return( accumulation); 
    }
    function Qctotal() public view  returns(uint256 ctotal_) {
    return( ctotal); 
    }
    function Qstate() public view  returns(bool state_) {
    return( state); 
    }

}