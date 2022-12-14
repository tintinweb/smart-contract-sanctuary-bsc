/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

pragma solidity ^0.8.17;

contract Lesson19 {
    string private _name;
    string private _symbol;
    uint8 private _decimal;
    uint256 private _totalSupply = 10000;
    uint256 private _supply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _owner;

    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _owner = msg.sender;
    }

    function name() external view returns (string memory){
        return _name;
    }
    
    function symbol() external view returns(string memory){
        return _symbol;
    }

    function balanceOf(address account) external view returns (uint256){
        return _balances[account];
    }

    function totalSupply() external view returns(uint256){
        return _totalSupply;
    }

    function supply() external view returns(uint256){
        return _supply;
    }

    function decimals() external view returns(uint8){
        return 2;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }


    event Transfer(address from, address to, uint256 amount);

    function mint(address to, uint256 amount) public onlyOwner {
        uint256 tmpSupply = _supply + amount;
        // emit Transfer(address(0), address(0), tmpSupply);
        require( tmpSupply <= _totalSupply, "Must < totalSupply");
        _balances[to] = amount;
        _supply += amount;

        // emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) public{
       _transfer(msg.sender, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) public {
         require(_balances[from] >= amount, "Amount fail");
        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function allowance(address owner, address spender)  public view returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool){
        _allowances[msg.sender][spender] += amount;

        return true;
    }

    function transferFrom(
        address sender,
        address spender,
        uint256 amount
    ) public {
        require(_allowances[sender][spender] >= amount, "Amount fail");
        _allowances[sender][spender] -= amount;
        _transfer(sender, spender, amount);
    }    
}