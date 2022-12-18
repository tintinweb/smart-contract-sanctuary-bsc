pragma solidity ^0.8.7;

interface ERC20Interface {
    function totalSupply() external returns (uint);

    function balanceOf(address tokenOwner) external returns (uint balance);

    function allowance(address tokenOwner, address spender) external returns (uint remaining);

    function transfer(address to, uint tokens) external returns (bool success);

    function approve(address spender, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface ERC21Interface {

    function init(uint totalSupply) external;

    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function approve(address owner, address spender, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    function transfer(address from, address to, uint tokens) external returns (bool success);
}

contract ProxyToken is ERC20Interface {
    string public symbol;
    string public name;
    uint public decimals;
    address public owner;

    ERC21Interface private impl;

    constructor(ERC21Interface _impl, string memory _symbol, string memory _name, uint _totalSupply) {
        impl = _impl;
        symbol = _symbol;
        name = _name;
        decimals = 18;
        owner = msg.sender;

        impl.init(_totalSupply);
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public override view returns (uint) {
        return impl.totalSupply();
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return impl.balanceOf(tokenOwner);
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        bool result = impl.transfer(msg.sender, to, tokens);
        if (result) {
            emit Transfer(msg.sender, to, tokens);
        }
        return result;
    }

    function approve(address spender, uint tokens) public override returns (bool success) {
        bool result = impl.approve(msg.sender, spender, tokens);
        if (result) {
            emit Approval(msg.sender, spender, tokens);
        }
        return result;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        bool result = impl.transferFrom(from, to, tokens);
        if (result) {
            emit Transfer(from, to, tokens);
        }
        return result;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
        return impl.allowance(tokenOwner, spender);
    }

    receive() external payable {
        revert();
    }
}