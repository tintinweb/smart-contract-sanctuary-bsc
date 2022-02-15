/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity ^0.5.0;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
     function mint(address a,uint256 amount) external  returns (bool);
     function burn(address a,uint256 amount) external returns (bool);
} 
interface usdttoken{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 

contract FNTRule{
    address public tokenaddr ;
    address public usdtaddr ;
    address public owner;
    address public admin;
    uint256 public rate;
    uint256 public alllimit;
    uint256 public wlimit;
    uint256 public ulimit;
    uint256 public all;
    mapping (address => bool) public white;
    mapping (address => uint256) public tamount;
    constructor() public {
      owner = msg.sender;
      admin = msg.sender;
      rate=20000;
      alllimit=6500000*10**18;
      wlimit = 300000*10**18;
      ulimit = 15000*10**18;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
    function setAllLimit(uint256 a) public {
      require(msg.sender==owner);
      alllimit = a;
    }
     function setWLimit(uint256 a) public {
      require(msg.sender==owner);
      wlimit = a;
    }
     function setULimit(uint256 a) public {
      require(msg.sender==owner);
      ulimit = a;
    }
    function setUsdt(address a) public {
      require(msg.sender==owner);
      usdtaddr = a;
    }
    function setAdmin(address a) public {
      require(msg.sender==owner);
      admin = a;
    }
    function setWhite(address a,bool b) public {
       require(msg.sender==owner || msg.sender==admin);
       white[a]=b;
    }
    function settamount(address a,uint256 b) public {
       require(msg.sender==owner || msg.sender==admin);
       tamount[a]=b;
    }
    function setRate(uint256 r) public {
       require(msg.sender==owner || msg.sender==admin);
      rate = r;
    }
    function exchange(address u,uint256 am) public  returns (bool success)  {
        uint256 tam = am*rate/1000;
        if(all+tam>alllimit){return false;}
        if(white[u]){
          if(tamount[u]+tam>wlimit){return false;}
        }else{
          if(tamount[u]+tam>ulimit){return false;}
        }
        if( usdttoken(usdtaddr).transferFrom(u,address(this),am)){
            return token(tokenaddr).mint(u,tam);
        }else{
            return false;
        }
    }
    function getTamount(address u) public view  returns (uint256){
        return tamount[u];
     }
    function iswhite(address u) public view  returns (bool){
        return white[u];
     }
    function sendu(address u,uint256 am) public  returns (bool success){
        require(msg.sender==owner || msg.sender==admin);
        return usdttoken(usdtaddr).transfer(u,am);
     }
    function sendt(address u,uint256 am) public  returns (bool success){
        require(msg.sender==owner || msg.sender==admin);
        return token(tokenaddr).transfer(u,am);
     }
}