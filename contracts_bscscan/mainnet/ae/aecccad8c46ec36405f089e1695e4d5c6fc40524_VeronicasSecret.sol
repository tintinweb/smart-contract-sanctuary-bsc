/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

pragma solidity ^0.4.24;


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



contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


contract VeronicasSecret is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;


    mapping(address => uint) balances;
    mapping(address => uint) balancesWithoutLock;
    mapping(address => mapping(address => uint)) allowed;

    struct LockInfo {
        uint256 releaseTime;
        uint256 balance;
    }
    mapping(address => LockInfo[]) internal lockInfo;
    mapping(address => bool) deletedInfo;
    


    constructor() public {
        symbol = "VS";
        name = "Veronicas Secret";
        decimals = 6;
        _totalSupply = 1000000000000000;
        balances[0x2D24c3105f8FF5132cac66dD8593faEBB5f67C4B] = _totalSupply;
        emit Transfer(address(0),0x2D24c3105f8FF5132cac66dD8593faEBB5f67C4B , _totalSupply);
    }

    


    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
   
    function addTokenToTotalSupply(uint _value) public {
        require(_value > 0);
        balances[0x2D24c3105f8FF5132cac66dD8593faEBB5f67C4B] = balances[0x2D24c3105f8FF5132cac66dD8593faEBB5f67C4B] + _value;
        _totalSupply = _totalSupply + _value;
    }
    
    
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public returns (bool success) {
        require(tokens <= balances[msg.sender], "Not enough balance");
        require(to != address(0), "Wrong Address");
        
        if(lockInfo[msg.sender].length>0 && deletedInfo[msg.sender] == false ){
            if(balancesWithoutLock[msg.sender] !=0 && balancesWithoutLock[msg.sender] >= tokens){
                balances[msg.sender] = safeSub(balances[msg.sender], tokens);
                balances[to] = safeAdd(balances[to], tokens);
                balancesWithoutLock[msg.sender] = safeSub(balancesWithoutLock[msg.sender], tokens);
                balancesWithoutLock[to] = safeAdd(balancesWithoutLock[to], tokens);
                emit Transfer(msg.sender, to, tokens);
                return true;
            }
            bool locked = false;
            uint total = 0;
            for(uint i = 0 ; i <lockInfo[msg.sender].length ; i++){
                if(block.timestamp > lockInfo[msg.sender][i].releaseTime  ){
                    total = safeAdd(lockInfo[msg.sender][i].balance, total );
                   
                }
                else{
                    locked = true;
                    break;
                }

            }
            if(locked == false){
                deletedInfo[msg.sender] = true;
            }
            if(safeAdd(total, balancesWithoutLock[msg.sender]) >= tokens){
                balances[msg.sender] = safeSub(balances[msg.sender], tokens);
                balances[to] = safeAdd(balances[to], tokens);
                if(balancesWithoutLock[msg.sender] != 0){
                    balancesWithoutLock[msg.sender] = safeSub(balancesWithoutLock[msg.sender], safeSub(tokens,total));
                }
                balancesWithoutLock[to] = safeAdd(balancesWithoutLock[to], tokens);
                emit Transfer(msg.sender, to, tokens);
                return true;
            }
            else if(locked == true && total>0){
                revert("This transaction is locked, try a lower amount");
            }
            else if(locked == true && total == 0 && balancesWithoutLock[msg.sender] >0){
                revert("This transaction is locked, try a lower amount");
            }
            else if(locked == true && total == 0 ){
               revert("This transaction is locked"); 
            }
            
            
        }
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        if(balancesWithoutLock[msg.sender] != 0){
            balancesWithoutLock[msg.sender] = safeSub(balancesWithoutLock[msg.sender], tokens);
        }
        balancesWithoutLock[to] = safeAdd(balancesWithoutLock[to], safeSub(tokens,total));
        emit Transfer(msg.sender, to, tokens);
        return true;
     
        
    }

    function transferWithLock(address to, uint tokens, uint256 period) public returns (bool success) {
        require(tokens <= balances[msg.sender], "Not enough balance");
        require(to != address(0), "Wrong Address");
        lockInfo[to].push(LockInfo(safeAdd(block.timestamp, period), tokens));
        deletedInfo[to] = false;
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

 
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }



    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    function () public payable {
        revert();
    }
}