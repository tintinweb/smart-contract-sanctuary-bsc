// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//  ██████╗ ██████╗ ███████╗ █████╗ ██╗  ██╗
// ██╔═══██╗██╔══██╗██╔════╝██╔══██╗╚██╗██╔╝
// ██║   ██║██████╔╝█████╗  ███████║ ╚███╔╝
// ██║   ██║██╔══██╗██╔══╝  ██╔══██║ ██╔██╗
// ╚██████╔╝██║  ██║███████╗██║  ██║██╔╝ ██╗
//  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ BEP20.
// Oreax Token (OXR) | February 2023.
// Total Supply: 300,000,000 OXR.

import "./IBEP20.sol";

contract OreaxBEP20 is IBEP20 {
    string  private _name;
    string  private _symbol;
    uint8   private _decimals;
    uint256 private _totalSupply;
    address private _owner;

    mapping(address => uint256) private $balances;
    mapping(address => mapping(address => uint256)) private $allowances;

    constructor() {
        _name = "Oreax";
        _symbol = "OXR";
        _decimals = 10;
        _mint(_msgSender(), 300000000 * 10 ** _decimals);
        _transferOwnership(_msgSender());
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() public view returns (address){
        return _owner;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return $balances[account];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return $allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "Oreax BEP20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "Oreax BEP20: transfer from the zero address");
        require(to != address(0), "Oreax BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = $balances[from];
        require(fromBalance >= amount, "Oreax BEP20: transfer amount exceeds balance");
    unchecked {
        $balances[from] = fromBalance - amount;
        $balances[to] += amount;
    }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Oreax BEP20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
    unchecked {
        $balances[account] += amount;
    }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "Oreax BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = $balances[account];
        require(accountBalance >= amount, "Oreax BEP20: burn amount exceeds balance");
    unchecked {
        $balances[account] = accountBalance - amount;
        _totalSupply -= amount;
    }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Oreax BEP20: approve from the zero address");
        require(spender != address(0), "Oreax BEP20: approve to the zero address");

        $allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Oreax BEP20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _transferOwnership(address newOwner) internal virtual {
        require(newOwner != address(0), "Oreax BEP20: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}