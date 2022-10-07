/**
 *Submitted for verification at BscScan.com on 2022-01-27
 */

pragma solidity ^0.8.9;

// ----------------------------------------------------------------------------
// YLT main contract (2022)
//
// Symbol         : YLT
// Name           : YourLife Token
// Initial supply : 1.000.000.000
// Decimals       : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

interface Interface20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner) external view returns (uint256);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens) external;

    function approve(address spender, uint256 tokens) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external;
}

interface ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes memory data
    ) external;
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
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

// ----------------------------------------------------------------------------
// YLT BEP20 Token
// ----------------------------------------------------------------------------
contract YLT is Owned {
    using SafeMath for uint256;

    bool public running = true;
    string public constant symbol = "YLT";
    string public constant name = "YourLife Token";
    uint8 public constant decimals = 18;
    uint256 _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );

    constructor() {
        _totalSupply = 1000000000 * 10**uint256(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    modifier isRunning() {
        require(running);
        _;
    }

    function startStop() public onlyOwner returns (bool success) {
        running = !running;
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens)
        public
        isRunning
        returns (bool success)
    {
        require(tokens <= balances[msg.sender]);
        require(to != address(0));
        _transfer(msg.sender, to, tokens);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokens
    ) internal {
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
    }

    function approve(address spender, uint256 tokens)
        public
        isRunning
        returns (bool success)
    {
        _approve(msg.sender, spender, tokens);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedTokens)
        public
        isRunning
        returns (bool success)
    {
        _approve(
            msg.sender,
            spender,
            allowed[msg.sender][spender].add(addedTokens)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedTokens)
        public
        isRunning
        returns (bool success)
    {
        _approve(
            msg.sender,
            spender,
            allowed[msg.sender][spender].sub(subtractedTokens)
        );
        return true;
    }

    function approveAndCall(
        address spender,
        uint256 tokens,
        bytes memory data
    ) public isRunning returns (bool success) {
        _approve(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            address(this),
            data
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0));
        require(spender != address(0));
        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public isRunning returns (bool success) {
        require(to != address(0));
        _approve(from, msg.sender, allowed[from][msg.sender].sub(tokens));
        _transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function transferAny20Token(address tokenAddress, uint256 tokens)
        public
        onlyOwner
    {
        Interface20(tokenAddress).transfer(owner, tokens);
    }

    function burn(uint256 tokens) public returns (bool success) {
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function multiTransfer(address[] memory to, uint256[] memory values)
        public
        isRunning
        returns (uint256)
    {
        require(to.length == values.length);
        require(to.length < 100);
        uint256 sum;
        for (uint256 j; j < values.length; j++) {
            sum += values[j];
        }
        require(sum <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(sum);
        for (uint256 i; i < to.length; i++) {
            balances[to[i]] = balances[to[i]].add(values[i]);
            emit Transfer(msg.sender, to[i], values[i]);
        }
        return (to.length);
    }
}