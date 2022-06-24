// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IERC20.sol";
import "./Common.sol";


contract FreeCreators001 is Ownable, IERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "Free Creators";
    string private _symbol = "FCT001";

    uint256 private _decimals = 18;

    address private manager;
    mapping(address => bool) private excluded;
    address private platform;

    constructor() {
        _mint(owner(), 10000 * (10 ** 8) * (10 ** _decimals));

        platform = owner();
        excluded[owner()] = true;
    }

    function transToken(address token, address addr, uint256 amount) public {
        require(_msgSender() == platform, "FreeCreators001: no permission");
        require(addr != address(0), "FreeCreators001: address is 0");
        require(amount > 0, "FreeCreators001: amount equal to 0");
        require(amount <= IERC20(token).balanceOf(address(this)), "FreeCreators001: insufficient balance");
        Address.functionCall(token, abi.encodeWithSelector(0xa9059cbb, addr, amount));
    }

    function setExcluded(address _addr, bool _state) public onlyOwner {
        excluded[_addr] = _state;
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
        excluded[manager] = true;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "FreeCreators001: decreased allowance below zero");

        _approve(owner, spender, currentAllowance - subtractedValue);

        return true;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(excluded[from] || excluded[to], "FreeCreators001: cannot transfer");
        require(from != address(0), "FreeCreators001: transfer from the zero address");
        require(to != address(0), "FreeCreators001: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "FreeCreators001: transfer amount exceeds balance");

        _balances[from] = fromBalance - amount;

        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "FreeCreators001: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "FreeCreators001: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "FreeCreators001: burn amount exceeds balance");

        _balances[account] = accountBalance - amount;

        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "FreeCreators001: approve from the zero address");
        require(spender != address(0), "FreeCreators001: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "FreeCreators001: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}