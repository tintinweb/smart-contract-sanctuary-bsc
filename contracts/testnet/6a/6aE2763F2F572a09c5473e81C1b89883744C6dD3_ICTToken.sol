/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ICTToken {

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);    

    uint private _totalSupply;

    address private _admin;

    constructor() {
        _admin = msg.sender;
    }

    // owner => balance
    mapping(address => uint) private _balances;

    // owner => spender => allowance
    mapping(address => mapping(address => uint)) _allowances;

    function name() public pure returns (string memory) {
        return "ICT Token";
    }

    function symbol() public pure returns (string memory) {
        return "ICT";
    }

    function decimals() public pure returns (uint8) {
        return 2;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "owner zero address");

        return _balances[owner];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        require(owner != address(0), "owner zero address");
        require(spender != address(0), "spender zero address");

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {

        if (from != msg.sender) {
            uint allowanceAmount = _allowances[from][msg.sender];
            require(amount <= allowanceAmount, "transfer amount exceeds allowance");
            _approve(from, msg.sender, allowanceAmount - amount);
        }

        _transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint amount) public {
        require(msg.sender == _admin, "you're not authorized");

        _mint(to, amount);
    }

    function burn(address from, uint amount) public {
        require(msg.sender == _admin, "you're not authorized");

        _burn(from, amount);
    }

    function renounce() public {
        _admin = address(0);
    }

    function admin() public view returns(address) {
        return _admin;
    }

    //Private Function
    function _transfer(address from, address to, uint amount) private {
        require(from != address(0), "transfer from zero address");
        require(to != address(0), "transfer to zero address");
        require(amount <= _balances[from], "transfer amount exceeds balance");
        require(amount > 0, "amount is zero");

        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "owner zero address");
        require(spender != address(0), "spender zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _mint(address to, uint amount) private {
        require(to != address(0), "mint to zero address");
        require(amount > 0, "amount is zero");

        _totalSupply += amount;
        _balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint amount) private {
        require(from != address(0), "burn from zero address");
        require(amount <= _balances[from], "burn amount exceeds balance");

        _totalSupply -= amount;
        _balances[from] -= amount;

        emit Transfer(from, address(0), amount);
    }

}