/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}


contract CodeWithJD is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // Platform Address
    address public platformWallet;
    // Pancake Router Address
    address public pancakeRouter;
    // Burn Address
    address public burnAddress;

    // Platform Tax
    uint256 public buyTax;
    uint256 public saleTax;

    // Max Buy and Sale
    uint256 public maxBuy;
    uint256 public maxSale;

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "AnzyToken";
        symbol = "ANZY";
        decimals = 2;
        _totalSupply = 1800000000;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        platformWallet = 0xd57833dE0CA26ADe86eB0d817D31dbaF47A45D9D;
        pancakeRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        burnAddress = 0x000000000000000000000000000000000000dEaD;

        buyTax = 10;
        saleTax = 15;

        maxBuy = 1;
        maxSale = 2;
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

    // Buy tokens
    function buyTokens(uint tokens) public payable returns (bool success) {
        // Check if the user has enough tokens to buy
        require(tokens <= balances[msg.sender]);

        // Check if the user is not trying to buy more than the max
        require(tokens <= maxBuy * (totalSupply() / 100));

        // Calculate the total cost of the transaction
        uint256 totalCost = tokens * (tokens + (tokens * buyTax / 100));

        // Make sure the user has enough funds
        require(totalCost <= msg.value);

        // Transfer tokens from the user
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);

        // Calculate the platform tax
        uint256 platformTax = tokens * (tokens * buyTax / 200);

        // Transfer platform tax
        balances[platformWallet] = safeAdd(balances[platformWallet], platformTax);

        // Calculate the liquidity pool tax
        uint256 poolTax = tokens * (tokens * buyTax / 200);

        // Transfer liquidity pool tax
        balances[pancakeRouter] = safeAdd(balances[pancakeRouter], poolTax);

        // Transfer tokens to the user
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);

        // Emit Transfer Event
        emit Transfer(address(0), msg.sender, tokens);

        return true;
    }

    // Sell tokens
    function sellTokens(uint tokens) public returns (bool success) {
        // Check if the user has enough tokens to sell
        require(tokens <= balances[msg.sender]);

        // Check if the user is not trying to sell more than the max
        require(tokens <= maxSale * (totalSupply() / 100));

        // Calculate the total cost of the transaction
        uint256 totalCost = tokens * (tokens - (tokens * saleTax / 100));

        // Transfer tokens from the user
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);

        // Calculate the platform tax
        uint256 platformTax = tokens * (tokens * saleTax / 200);

        // Transfer platform tax
        balances[platformWallet] = safeAdd(balances[platformWallet], platformTax);

        // Calculate the liquidity pool tax
        uint256 poolTax = tokens * (tokens * saleTax / 400);

        // Transfer liquidity pool tax
        balances[pancakeRouter] = safeAdd(balances[pancakeRouter], poolTax);

        // Calculate the burn tax
        uint256 burnTax = tokens * (tokens * saleTax / 400);

        // Transfer burn tax
        balances[burnAddress] = safeAdd(balances[burnAddress], burnTax);

        // Transfer tokens to the user
        msg.sender.transfer(totalCost);

        // Emit Transfer Event
        emit Transfer(msg.sender, address(0), tokens);

        return true;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}