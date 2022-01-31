/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

pragma solidity 0.8.7;

contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'you are not the owner');
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public  {
        require(newOwner != address(0));

        owner = newOwner;
        emit OwnershipTransferred(owner);
    }
}

contract BasicToken is Ownable {
    uint internal _totalSupply; 

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) view public returns (uint balance) {
        return _balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool) {
        require(_balances[msg.sender] >= tokens, 'Balance too low');
        require(to != address(0), 'Address cannot be zero');

        _balances[msg.sender] = _balances[msg.sender] -= tokens;
        _balances[to] = _balances[to] += tokens;

        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function approve(address spender, uint tokens) public returns (bool) {
       _allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) view public returns (uint remaining) {
        return _allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool) {
        require(_allowed[from][msg.sender] >= tokens);
        require(_balances[from] >= tokens, 'balance too low');
        require(to != address(0));

        uint _allowance = _allowed[from][msg.sender];

        _balances[from] = _balances[from] -= tokens;
        _balances[to] = _balances[to] += tokens;
        _allowed[from][msg.sender] = _allowance -= tokens;

        emit Transfer(from, to, tokens);

        return true;
    }
}

contract Koinz_token is BasicToken {
    string public constant name = "Koinz";
    string public constant symbol = "KOINZ";
    uint8 public constant decimals = 8;

    constructor() {
        owner = msg.sender;
        _totalSupply = 10000000000 * 10 ** 8;
        _balances[msg.sender] = _totalSupply;
    }
}