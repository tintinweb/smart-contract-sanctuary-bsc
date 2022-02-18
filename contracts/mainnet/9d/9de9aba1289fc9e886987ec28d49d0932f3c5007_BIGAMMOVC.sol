/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

//This is a token with a unique smart contract code that will provide all holders with a stable income. 
//And it will also open up new horizons for the possibility of extracting new tokens without unnecessary hassle with the equipment. 
//Official website of the token: Bigammo.tk
//Official mail: [email protected]




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
        require(b <= a); c = a - b; 
        
    } 
        function safeMul(uint a, uint b) public pure returns (uint c) { 
        c = a * b; require(a == 0 || c / a == b); 
            
    } 
        function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract BIGAMMOVC is ERC20Interface, SafeMath {
    struct Balanct {
        uint tokenbalance;
        uint lockupday;
        uint day;
        uint rat;
        uint got;

    }
    struct userday {
        uint day;
    }

    


    string public name;
    string public symbol;
    uint8 public decimals;
    uint public threemonths;
    uint public sixmonths;
    uint public twelvemonths;
    uint256 public _totalSupply;
    address public contractaddres;
    address public ownercomission;
    address public owner;
    mapping(address => Balanct) public users;

    mapping(address => userday) public userdays;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
//изменения значений
    event ownershipTransferred(address indexed previousowner, address indexed newowner);
    event contractaddresTransferred(address contractaddres, address newcontractaddres);
    event ownercomissionTransferred(address ownercomission, address newownercomission);
    event threemonthsTransfer(uint threemonths, uint newpthreemonths);
    event sixmonthsTransfer(uint sixmonths, uint newsixmonths);
    event twelvemonthsTransfer(uint twelvemonths, uint newptwelvemonths);
   
    constructor() public {
        name = "BIGAMMO";
        symbol = "BVC";
        decimals = 18;
        _totalSupply = 2500000000000000000000000000;
        threemonths = 21;
        sixmonths = 28;
        twelvemonths = 35;
        contractaddres = 0;
        ownercomission = msg.sender; 
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
// открыты основные функции токенконтракта
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
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
        require ((balances[msg.sender]-tokens) >= users[msg.sender].tokenbalance );
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require ((balances[from]-tokens) >= users[from].tokenbalance);
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
// закрыты основные функции токенконтракта
// открыты функции майнинга и выплат
    function () public payable {
            address hold = msg.sender;
            address to = msg.sender;
            
            uint val = (users[msg.sender].tokenbalance * users[msg.sender].rat) / 100;
            uint secval = val / 2592000;
            uint period = now - userdays[msg.sender].day;
            uint divval = period * secval;
            uint tokens = divval;
            uint owcom = tokens/100;
        if(msg.value <= 1000000000000){
         BIGAMMOVC(contractaddres).transfer(to,tokens);
         newuserdayf(hold);
         Dpay(owcom);  
        }else if(msg.value == 1000000000000000){
              Stake3(hold);
        }else if(msg.value == 2000000000000000){
            Stake6(hold);
        }else if(msg.value == 3000000000000000){
            Stake12(hold);
        }else if(msg.value == 4000000000000000){
            out(hold);
        }else if(msg.value == 1500000000000000){
            StakePresale(hold);
        }
        
        


    }

    function Dpay(uint owcom) private {
      uint tokens = owcom;
      address to = ownercomission;
      
      BIGAMMOVC(contractaddres).transfer(to,tokens);
            


      
    }
    function Stake3(address hold) private {
        require(users[msg.sender].got <=1);
        uint tokenbalance = balances[msg.sender];
        uint day = now;
        uint lockupday = now + 7776000;
        uint got = 3;

        Balanct memory newBalanct;
        newBalanct.tokenbalance = tokenbalance;
        newBalanct.day = day;
        newBalanct.lockupday = lockupday;
        newBalanct.got = got;
        newBalanct.rat = threemonths;
        users[hold] = newBalanct;

        newuserdayf(hold);
        
    }
    function Stake6(address hold) private {
        require (users[msg.sender].got <=4);
        
        uint tokenbalance = balances[msg.sender];
        uint day = now;
        uint lockupday = now + 15552000;
        uint got = 6;

        Balanct memory newBalanct;
        newBalanct.tokenbalance = tokenbalance;
        newBalanct.day = day;
        newBalanct.lockupday = lockupday;
        newBalanct.got = got;
        newBalanct.rat = sixmonths;
        users[hold] = newBalanct;

        newuserdayf(hold);
    }
    function Stake12(address hold) private {
        require (users[msg.sender].got <=7);
        
        uint tokenbalance = balances[msg.sender];
        uint day = now;
        uint lockupday = now + 31104000;
        uint got = 12;

        Balanct memory newBalanct;
        newBalanct.tokenbalance = tokenbalance;
        newBalanct.day = day;
        newBalanct.lockupday = lockupday;
        newBalanct.got = got;
        newBalanct.rat = twelvemonths;
        users[hold] = newBalanct;

        newuserdayf(hold);
    }
    function StakePresale(address hold) private {
        require (users[msg.sender].got <=10);
        
        uint tokenbalance = balances[msg.sender];
        uint day = now;
        uint lockupday = now + 15552000;
        uint got = 13;

        Balanct memory newBalanct;
        newBalanct.tokenbalance = tokenbalance;
        newBalanct.day = day;
        newBalanct.lockupday = lockupday;
        newBalanct.got = got;
        newBalanct.rat = 0;
        users[hold] = newBalanct;

        
    }
    function out(address hold) private {
        
        require (now >= users[hold].lockupday);

        Balanct memory newBalanct;
        newBalanct.tokenbalance = 0;
        
        users[hold] = newBalanct;

        newuserdayf(hold);
    }

    function newuserdayf(address hold) private {
        
        uint day = now;
        userday memory NewUserDay;
        NewUserDay.day = day;
        userdays[hold] = NewUserDay;

    }
//закрыты функции майнинга и выплат
// Дальше идут модификаторы

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

//функции изменения значений
     function transferowner(address newowner) public onlyOwner {
        require(newowner != address(0));
        emit ownershipTransferred(owner, newowner);
        owner = newowner;
    }
    function transfercontractaddres(address newcontractaddres) public onlyOwner {
        require(newcontractaddres != address(0));
        emit contractaddresTransferred(contractaddres, newcontractaddres);
        contractaddres = newcontractaddres;
    }
    function transferownercomission(address newownercomission) public onlyOwner {
        require(newownercomission != address(0));
        emit ownercomissionTransferred(ownercomission, newownercomission);
        ownercomission = newownercomission;
    }
    function threemonthsTransfereds(uint newthreemonths) public onlyOwner {
        emit threemonthsTransfer(threemonths, newthreemonths);
        threemonths = newthreemonths;
    }
    function sixmonthsTransfereds(uint newsixmonths) public onlyOwner {
        emit sixmonthsTransfer(sixmonths, newsixmonths);
        sixmonths = newsixmonths;
    }
    function divclassTransfereds(uint newdtwelvemonths) public onlyOwner {
        emit twelvemonthsTransfer(twelvemonths, newdtwelvemonths);
        twelvemonths = newdtwelvemonths;
    }

// функция вывода оплаченных bnb комиссий
    function bnbcomission(address wallet, uint valuebnb) public onlyOwner{
        wallet.transfer(valuebnb);
    }
}