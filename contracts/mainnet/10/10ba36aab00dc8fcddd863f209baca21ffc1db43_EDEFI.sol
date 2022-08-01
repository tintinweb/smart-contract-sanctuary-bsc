/**
 *Submitted for verification at BscScan.com on 2022-08-01
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

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract EDEFI is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    mapping (address => bool) private _whitelisted;
    mapping (address => bool) private _blocklisted;
    uint256 public IDOENDTIME;

    constructor(uint256 startDate) public {
        symbol = "EDEFI";
        name = "eDefi";
        decimals = 9;
        _totalSupply = 300000000 * 10**9;
        IDOENDTIME = startDate;
        emit Transfer(address(0), msg.sender, _totalSupply);
        addtoWhiteList(msg.sender);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)] - balances[0x000000000000000000000000000000000000dEaD];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
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
    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisted[account];
    }
    function addtoWhiteList(address account) public onlyOwner {
      _whitelisted[account] = true;
    }
    function removefromWhiteList(address account) public onlyOwner {
      _whitelisted[account] = false;
    }

    function isBlocklisted(address account) public view returns (bool) {
        return _blocklisted[account];
    }
    function addtoBlockList(address account) public onlyOwner {
      _blocklisted[account] = true;
    }
    function removefromBlockList(address account) public onlyOwner {
      _blocklisted[account] = false;
    }
    function approve(address spender, uint tokens) public returns (bool success) {

        require( (block.timestamp > IDOENDTIME) || (isWhitelisted(spender)) , "Approve Allowed for whitelisted accounts");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transfer(address to, uint tokens) public returns (bool success)
    {
        require( (block.timestamp > IDOENDTIME) || (isWhitelisted(to)) || (isWhitelisted(msg.sender)), "Transfer is disabled until IDO completes");
        require( (!isBlocklisted(msg.sender) || (to==owner)), "Account was blocked and funds can transfer to admin only");
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;    
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success){
        require( (block.timestamp > IDOENDTIME) || (isWhitelisted(from)) || (isWhitelisted(to)) || (isWhitelisted(msg.sender)), "Transfer is disabled until IDO completes");
        require( (!isBlocklisted(msg.sender) || (to==owner)), "Account was blocked and funds can transfer to admin only");
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function () public payable {
        revert();
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    function setIDOendTime( uint256 time) public onlyOwner {
        IDOENDTIME=time;
    }
}