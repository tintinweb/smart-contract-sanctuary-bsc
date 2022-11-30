/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

pragma solidity 0.8.2;

// SPDX-License-Identifier: MIT

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



interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) virtual public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor()  {
        owner = 0xF63CEb5Cc561739ea42550E726a2dEA41a04D4BF;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract TryitAgain is IERC20, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => bool) public isBlacklisted;

    
 constructor() {
        name = "TryitAgain";
        symbol = "TRY";
        decimals = 9;
        _totalSupply = 1000000000000e9;         // 350,000,000 LANC
        address owner = owner;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function addToBlackList(address wallet) external onlyOwner
    {
        isBlacklisted[wallet] = true;
    }

    function removeFromBlackList(address wallet) external onlyOwner
    {
        isBlacklisted[wallet] = false;
    }


    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }


    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public override returns (bool success) {
        require(isBlacklisted[to] == false, "Address is blacklisted");
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) public virtual override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public view virtual override  returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


   receive () external payable {
        revert();
    }
}