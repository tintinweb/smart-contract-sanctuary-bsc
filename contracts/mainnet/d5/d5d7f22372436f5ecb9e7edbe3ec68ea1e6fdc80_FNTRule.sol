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
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
     return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
contract FNTRule{
    using SafeMath for uint256;
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
        uint256 tam = am.mul(rate).div(1000);
        if(all.add(tam)>alllimit){return false;}
        if(white[u]){
          if(tamount[u].add(tam)>wlimit){return false;}
        }else{
          if(tamount[u].add(tam)>ulimit){return false;}
        }
        if( usdttoken(usdtaddr).transferFrom(u,address(this),am)){
            if(token(tokenaddr).mint(u,tam)){
              tamount[u]=tamount[u].add(tam);
              return true;
            }
        }
        return false;

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