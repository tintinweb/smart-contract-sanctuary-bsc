pragma solidity 0.8.11;
//SPDX-License-Identifier: MIT
// ERC20TokenTemplate deployed to: 0x02D5CA8B0D47CFf8853e6E30732884b62c881944

contract ERC20TokenTemplate {
    string public name;
    string public symbol;
    uint256 public decimals;

    uint256 public supply;
    address public owner;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;

    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    
    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _supply, address tokenOwner) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        supply = _supply * 10**_decimals;
        owner = tokenOwner;
        balances[owner] = supply;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens,"Not enough balance");
        require(tokens > 0,"Tokens <= 0");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens)
        public
        returns (bool success)
    {
        require(balances[from] >= tokens,"Not enough balance");
        balances[from] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return supply;
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
        returns (bool success)
    {
        require(tokens > 0, "token <= 0 ");
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
}