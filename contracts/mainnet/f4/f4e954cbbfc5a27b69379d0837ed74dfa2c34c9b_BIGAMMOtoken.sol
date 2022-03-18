/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

//The BIGAMMO token is a unique, conservative instrument focused on the global world market.
//The advantages of BIGAMMO will inevitably lead to changes in the entire crypto industry as a whole.

//Official site: Bigammo.tk
//Support email: [email protected]
//Founder and official representative: Timur Akhmedov
//email: [email protected]
//The source code was developed by the BIGAMMO token team and any copy of the project is just an imitation.
//Make sure that the address indicated on the official website matches the address of the contract of this token!
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
contract BIGAMMOtoken is ERC20Interface, SafeMath {
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

    struct Tekhnic{
        uint status;
        uint rang;
        uint lockups;
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
    address public partnercomission;
    address public owner;
    mapping(address => Balanct) public users;
    mapping(address => Tekhnic) public tekhnics;
    mapping(address => userday) public userdays;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
//изменения значений
//change values
    event ownershipTransferred(address indexed previousowner, address indexed newowner);
    event contractaddresTransferred(address contractaddres, address newcontractaddres);
    event ownercomissionTransferred(address ownercomission, address newownercomission);
    event partnercomissionTransferred(address partnercomission, address newpartnercomission);
    event threemonthsTransfer(uint threemonths, uint newpthreemonths);
    event sixmonthsTransfer(uint sixmonths, uint newsixmonths);
    event twelvemonthsTransfer(uint twelvemonths, uint newptwelvemonths);
   
    constructor() public {
        name = "BIGAMMO";
        symbol = "BVC";
        decimals = 18;
        _totalSupply = 2500000000000000000000000000;
        threemonths = 8;
        sixmonths = 14;
        twelvemonths = 21;
        contractaddres = 0;
        ownercomission = 0x9f18AaF86f106fCf5ba82Ad1e6EC30935fe1F953; 
        partnercomission = 0x7716286c539fF737e9c3DcD0145481C6AC63a69b;
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
// открыты основные функции токенконтракта
// the main functions of the token contract are open
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

// the main functions of the token contract are closed
// open mining and payout functions
    function () public payable {
            address hold = msg.sender;
            address to = msg.sender;
            
            uint val = (users[msg.sender].tokenbalance * users[msg.sender].rat) / 100;
            uint secval = val / 2592000;
            uint period = now - userdays[msg.sender].day;
            uint divval = period * secval;
            uint tokens = divval;
            uint owcom = tokens * 3/100;
        if(msg.value <= 1000000000000){
         require(tokens >= 0);
         BIGAMMOtoken(contractaddres).transfer(to,tokens);
         newuserdayf(hold);
         Dpay(owcom); 
         Dpay2(owcom);  
        }else if(msg.value == 1000000000000000){
              Stake3(hold);
        }else if(msg.value == 2000000000000000){
            Stake6(hold);
        }else if(msg.value == 3000000000000000){
            Stake12(hold);
        }else if(msg.value == 4000000000000000){
            out(hold);
        }

    }

    function Dpay(uint owcom) private {
      uint tokens = owcom/2;
      address to = ownercomission;
      
      BIGAMMOtoken(contractaddres).transfer(to,tokens);
    }

    function Dpay2(uint owcom) private {
      uint tokens = owcom/2;
      address to = partnercomission;
      
      BIGAMMOtoken(contractaddres).transfer(to,tokens);
    }

    function addTekhniks(address newt, uint rang, uint lockups) public onlyOwner{
        uint status = 2;

        Tekhnic memory NewTekhnic;
        NewTekhnic.status = status;
        NewTekhnic.rang = rang;
        NewTekhnic.lockups = lockups;
        tekhnics[newt] = NewTekhnic;
    }

    function privattransfer(address to, uint tokens) public onlyTekhnik{
        require (tekhnics[msg.sender].status >= 1);
        require (users[to].got <=7);

        address hold = to;
        uint day = now;
        uint lockupday = now + tekhnics[msg.sender].lockups;
        uint got = 8;
        uint rat = tekhnics[msg.sender].rang;
        
        Balanct memory newBalanct;
        newBalanct.tokenbalance = tokens;
        newBalanct.day = day;
        newBalanct.lockupday = lockupday;
        newBalanct.got = got;
        newBalanct.rat = rat;
        users[to] = newBalanct;

        newuserdayf(hold);
        BIGAMMOtoken(contractaddres).transfer(to,tokens);
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
//mining and payout functions are closed
// Modifiers follow

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyPartner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyTekhnik() {
        require(tekhnics[msg.sender].status >= 1);
        _;
    }

//функции изменения значений
//functions for changing values
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
    function transferpartnercomission(address newpartnercomission) public onlyPartner {
        require(newpartnercomission != address(0));
        emit partnercomissionTransferred(partnercomission, newpartnercomission);
        partnercomission = newpartnercomission;
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
// function to display paid bnb commissions
    function bnbcomission(address wallet, uint valuebnb) public onlyOwner{
        wallet.transfer(valuebnb);
    }

}