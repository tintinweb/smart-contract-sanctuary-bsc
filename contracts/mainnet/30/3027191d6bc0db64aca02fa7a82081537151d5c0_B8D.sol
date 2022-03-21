/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT
// File: BEP20Standard.sol



pragma solidity 0.8.12;

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

    function mod(uint a, uint b) internal pure returns (uint c) {
        require(b != 0);
        c = a % b;
    }
}

interface BEP20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external;
    function approve(address spender, uint tokens) external;
    function transferFrom(address from, address to, uint tokens) external;
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes memory data) external;
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address transferOwner) public onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract BEP20Standard is Owned {
    using SafeMath for uint;

    uint public _totalSupply;
    string public name;
    uint public decimals;
    string public symbol;
    string public version;
    bool public running;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    //Event which is triggered to log all transfers to this contract's event log
    event Transfer(
        address indexed from,
        address indexed to,
        uint tokens
    );

    //Event which is triggered whenever an owner approves a new allowance for a spender.
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint tokens
    );

    modifier isRunning {
        require(running);
        _;
    }

    function startStop () public onlyOwner returns (bool success) {
        if (running) {
            running = false;
        } else {
            running = true;
        }
        return true;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public isRunning returns (bool success) {
        require(balances[msg.sender] >= tokens && tokens > 0);
        require(to != address(0));
        _transfer(msg.sender, to, tokens);
        return true;
    }

    function _transfer(address from, address to, uint tokens) internal {
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
    }

    function approve(address spender, uint tokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, tokens);
        return true;
    }

    function increaseAllowance(address spender, uint addedTokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].add(addedTokens));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedTokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedTokens));
        return true;
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public isRunning returns (bool success) {
        _approve(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function _approve(address owner, address spender, uint value) internal {
        require(owner != address(0));
        require(spender != address(0));
        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function transferFrom(address from, address to, uint tokens) public isRunning returns (bool success) {
        require(to != address(0));
        _approve(from, msg.sender, allowed[from][msg.sender].sub(tokens));
        _transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function transferAnyBEP20Token(address tokenAddress, uint tokens) public onlyOwner{
        BEP20Interface(tokenAddress).transfer(owner, tokens);
    }

    function burn(uint tokens) public returns (bool success) {
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function mint(uint tokens) public onlyOwner returns (bool success) {
        balances[msg.sender] = balances[msg.sender].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), msg.sender, tokens);
        return true;
    }

    function multiTransfer(address[] memory to, uint[] memory values) public isRunning returns (uint) {
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum.add(values[j]);
        }
        require(sum <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(sum);
        for (uint i; i < to.length; i++) {
            balances[to[i]] = balances[to[i]].add(values[i]);
            emit Transfer(msg.sender, to[i], values[i]);
        }
        return(to.length);
    }
}

// File: B8D.sol

/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

pragma solidity 0.8.12;


// ----------------------------------------------------------------------------
// B8D main contract (2022)
//
// Symbol       : B8D
// Name         : B8DEX
// Total supply : 1.000.000.000
// Decimals     : 18
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------


contract B8D is BEP20Standard {
    constructor() {
        name = "B8DEX";
        decimals = 18;
        symbol = "B8D";
        version = "1.0";
        _totalSupply = 1000000000 * 10**uint(decimals);
        running = true;

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);
    }
}