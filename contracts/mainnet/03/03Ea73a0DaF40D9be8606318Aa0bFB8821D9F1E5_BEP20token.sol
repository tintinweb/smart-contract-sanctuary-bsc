/**
 *Submitted for verification at BscScan.com on 2022-11-22
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
        require(b <= a); c = a - b; } 
        
    function safeMul(uint a, uint b) public pure returns (uint c) {
         c = a * b; require(a == 0 || c / a == b); } 
    
    function safeDiv(uint a, uint b) public pure returns (uint c) { 
        require(b > 0);
        c = a / b;
    }
}


contract BEP20token is ERC20Interface, SafeMath {
    struct Contractminter{
        string MinterName;
        uint MinterStatus;
    }

    struct TokenLock{
        uint amount;
    }

    struct system{
        uint activ;
    }


    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;
    uint Mintstop = 0;
    uint allLockupday = 1703592000;
    uint startDay = 1677672000;
    address public owner;
    uint public finalMintfor = 0;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => Contractminter) public ContrMinters;
    mapping(address => TokenLock) public Lock;
    mapping(address => system) public systemic;

    event ownershipTransferred(address indexed previousowner, address indexed newowner);


    constructor() public {
        name = "TitanikTime";
        symbol = "TTT";
        decimals = 18;
        owner = msg.sender;

    }

    function addMinterAddress(address minter, string MinterName, uint MinterStatus) public onlyOwner{
        Contractminter memory newMinter;
        newMinter.MinterName = MinterName;
        newMinter.MinterStatus = MinterStatus;
        ContrMinters[minter] = newMinter;
    }

    function Addsystemic(address systems, uint activ) public onlyOwner{
        system memory newSystem;
        newSystem.activ = activ;
        systemic[systems] = newSystem;
    }

    modifier MinterWork() {
    require(ContrMinters[msg.sender].MinterStatus == 1);
    _;
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }

    function transferowner(address newowner) public onlyOwner {
    require(newowner != address(0));
    emit ownershipTransferred(owner, newowner);
    owner = newowner;
    }

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
        
        address from = msg.sender;
        if(now<=allLockupday){
        _transferFromLock( from,  to,  tokens);
        }else if(now>=allLockupday){
        _transferFrom( from,  to,  tokens);}
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        if(now<=allLockupday){
        _transferFromLock( from,  to,  tokens);
        }else if(now>=allLockupday){
        _transferFrom( from,  to,  tokens);}
        return true;
    }

    function _transferFrom(address from, address to, uint tokens) internal{
        balances[from] = safeSub(balances[from], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
    }
    function _transferFromLock(address from, address to, uint tokens) internal{
        if(systemic[msg.sender].activ >= 1){
        _transferFrom( from,  to,  tokens);
        }else{
        uint remainder = (Lock[from].amount/25920000) * (allLockupday - now);
        require(remainder <= (balances[from] - tokens));
        balances[from] = safeSub(balances[from], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);}
    }

    function Mint (address forholder, uint amount) public MinterWork{
    require(Mintstop == 0);
    balances[forholder] = safeAdd(balances[forholder], amount);
    _totalSupply = safeAdd(_totalSupply, amount);
    lockmint(forholder, amount);
    emit Transfer(address(0), forholder, amount);
    }

    function lockmint(address forholder, uint amount) internal {
        Lock[forholder].amount = safeAdd(Lock[forholder].amount, amount);
    }

    function burn(uint amountBurn) public onlyOwner{
    balances[msg.sender] = safeSub(balances[msg.sender], amountBurn);
    _totalSupply = safeSub(_totalSupply, amountBurn); 
    emit Transfer(msg.sender, address(0), amountBurn);
    }

    function finalmint(address liqvid) public onlyOwner{
        require(finalMintfor == 0);
        uint amountMint = _totalSupply/10;
        balances[liqvid] = safeAdd(balances[liqvid], amountMint);
        _totalSupply = safeAdd(_totalSupply, amountMint);
        finalMintfor = 1;
        emit Transfer(address(0), liqvid, amountMint);
    }

    function StopMint() public onlyOwner{
        Mintstop = 1;
    }
}