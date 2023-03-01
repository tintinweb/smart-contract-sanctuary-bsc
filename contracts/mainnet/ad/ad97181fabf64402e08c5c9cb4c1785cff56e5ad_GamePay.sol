/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

pragma solidity ^0.4.24;

//名稱：Game Pay
//簡稱：GP
//總量：100億
//Game Pay實現自動通縮，每筆交易會扣除千分之一的GP作為手續費並進行銷燬。

// Safe maths
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
// ERC Token Standard #20 Interface
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
// Contract function to receive approval and execute function in one call
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
// Owned contract
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
// ERC20 Token, with the addition of symbol, name and decimals and a
contract GamePay is ERC20Interface, Owned {
    using SafeMath for uint;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    // Constructor
    constructor() public {
        symbol = "GP";
        name = "Game Pay";
        decimals = 18;
        _totalSupply = 10000000000 * 10**uint(decimals);
        balances[address(0xb35fEDb26A64df27fe972056DCC795fAf3fF6Ce3)] = _totalSupply;
        emit Transfer(address(0), address(0xb35fEDb26A64df27fe972056DCC795fAf3fF6Ce3), _totalSupply);
    }
    // Total supply
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        uint toBlackHole = tokens.div(1000);
        address blackHole = 0x0000000000000000000000000000000000000000;
        balances[blackHole] = balances[blackHole].add(toBlackHole);
        balances[to] = balances[to].add(tokens.sub(toBlackHole));
        emit Transfer(msg.sender, blackHole, toBlackHole);
        emit Transfer(msg.sender, to, tokens.sub(toBlackHole));
        return true;
    }
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    // Transfer `tokens` from the `from` account to the `to` account
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        uint toBlackHole = tokens.div(1000);
        address blackHole = 0x0000000000000000000000000000000000000000;
        balances[blackHole] = balances[blackHole].add(toBlackHole);
        balances[to] = balances[to].add(tokens.sub(toBlackHole));
        emit Transfer(from, blackHole, toBlackHole);
        emit Transfer(from, to, tokens.sub(toBlackHole));
        return true;
    }
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    // Don't accept BNB
    function () public payable {
        revert();
    }
    // Owner can transfer out any accidentally sent ERC20 tokens
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}