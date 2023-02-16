// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external pure returns(uint) {
        return 2;
    }

    function totalSupply() external view returns(uint) {
        return totalTokens;
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "not enough tokens!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    constructor(string memory name_, string memory symbol_, uint initialSupply, address shop) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, shop);
    }

    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) external enoughTokens(msg.sender, amount) {
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function mint(uint amount, address shop) public onlyOwner {
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function burn(address _from, uint amount) public onlyOwner {
        _beforeTokenTransfer(_from, address(0), amount);
        require(_from == owner, "invalid adress");
        balances[_from] -= amount;
        totalTokens -= amount;
    }

    function allowance(address _owner, address spender) external view returns(uint) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public  {
        _approve(msg.sender, spender, amount);
    }

    function _approve(address sender, address spender, uint amount) internal virtual  {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }

    function transferFrom(address from, address to, uint amount) external enoughTokens(from, amount) {
        _beforeTokenTransfer(from, to, amount);

        address spender = msg.sender;

        allowances[from][spender] -= amount;    //if <0 --> error
        balances[from] -= amount;
        balances[to] += amount;
    }

    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual {}
}

contract MyToken is ERC20 {
    constructor(address shop) ERC20("USDT Tether", "USDT", 900000000, shop) {

    }
}

contract Regulator {
    IERC20 public token;
    address payable owner;
    

    constructor() {
        token = new MyToken(address(this));
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function airDrop(address _to, uint _amount) public onlyOwner {
        token.transfer(_to, _amount);
    }

    function tokenBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    function tokenBalanceOf(address _adr) public view returns(uint) {
        return token.balanceOf(_adr);
    }
}