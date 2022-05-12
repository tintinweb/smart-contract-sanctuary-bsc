/**
 *Submitted for verification at BscScan.com on 2022-05-12
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


contract SUPLOToken is ERC20Interface, SafeMath {
    address public mainWallet;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public burn;
    uint public _tax;
    uint public _funds;
    uint public rewardRate = 100;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    uint256 public percentage;

    struct Stake {
        uint256 tokenId;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => uint) balances;
    mapping(address => uint) taxWallet;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => Stake) public stakes;
    mapping(address => uint256) public stakingTime;    

    constructor() public {
        symbol = "SUPLO";
        name = "Suplotopia";
        mainWallet = 0x95101C5ee956D091041Df3C818971D9dcd992D36;
        decimals = 18;
        _totalSupply = 1000000000000000000000000;
        balances[mainWallet] = _totalSupply; //This is my wallet, but when you want to deploy the token, you must enter yours wallet here
        taxWallet[mainWallet] = _tax; //Ftax wallet

        emit Transfer(address(0), mainWallet, _totalSupply); //And here.
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function antiWhale() private{
        if(balances[address(0)]>15){
            _tax += balances[0x95101C5ee956D091041Df3C818971D9dcd992D36]; //Fee wallet
        }
    }

    function transfer(address to, uint tokens) public returns (bool success) {
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

    function members(address spender, uint tokens) public returns (bool success){
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function stake(uint256 _tokenId, uint256 _amount) public {
        stakes[msg.sender] = Stake(_tokenId, _amount, block.timestamp); 
    }

    function unstake() public{
        stakingTime[msg.sender] += (block.timestamp - stakes[msg.sender].timestamp);
        delete stakes[msg.sender];
    }

    function group(address spender, uint tokens, address leader, uint _maxMembersPerGroup) public returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        _maxMembersPerGroup = 5000; //Define max members in the group
        return true;
    }

    function referrals(address spender, uint tokens) public returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function dailyROI(address spender, uint tokens, uint _roi) public returns (bool success){
        _roi = 1 * 100 / 100;
        emit Transfer(address(0), mainWallet, _roi);
        return true;
    }

    function gainPercentageOne(address spender, uint _percentage, uint tokens, uint256 percentageCantity) public returns (bool success){
        percentage = percentageCantity;
        uint256 calc = tokens * percentage / 100;
        allowed[msg.sender][spender] += calc;
        return true;
    }

    function gainPercentageTwo(address spender, uint _percentage, uint tokens, uint256 percentageCantity) public returns (bool success){
        percentageCantity = 1;
        percentage = percentageCantity;
        uint256 calc = tokens * percentage / 100;
        allowed[msg.sender][spender] += calc;
        return true;
    }
    function gainPercentageThree(address spender, uint _percentage, uint tokens, uint percentageCantity) public returns (bool success){
        percentage = percentageCantity;
        uint256 calc = tokens * percentage / 100;
        allowed[msg.sender][spender] += calc;
        return true;
    }
    function gainPercentageFive(address spender, uint _percentage, uint tokens, uint percentageCantity) public returns (bool success){
        percentage = percentageCantity;
        uint256 calc = tokens * percentage / 100;
        allowed[msg.sender][spender] += calc;
        return true;
    }
    function gainPercentageEight(address spender, uint _percentage, uint tokens, uint percentageCantity) public returns (bool success){
        percentage = percentageCantity;
        uint256 calc = tokens * percentage / 100;
        allowed[msg.sender][spender] += calc;
        return true;
    }
    function gainPercentageTen(address spender, uint _percentage, uint tokens, uint percentageCantity) public returns (bool success){
        percentage = percentageCantity;
        uint256 calc = tokens * percentage / 100;
        allowed[msg.sender][spender] += calc;
        return true;
    }
    function gainPercentageThirtyFive(address spender, uint _percentage, uint tokens, uint percentageCantity) public returns (bool success){
        percentage = percentageCantity;
        uint256 calc = tokens * percentage / 100;
        allowed[msg.sender][spender] += calc;
        return true;
    }


    function () public payable {
        revert();
    }
}