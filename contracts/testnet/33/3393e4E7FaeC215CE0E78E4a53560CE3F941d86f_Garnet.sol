// SPDX-License-Identifier: GPL-3.0-or-later
/// @author Vũ Đắc Hoàng Ân
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./Ownable.sol";

contract Garnet is IBEP20, Ownable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint private _totalSupply;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    constructor() {
        _name = "Garnet";
        _symbol = "GNTK";
        _decimals = 10;
        _totalSupply = 10000000000 * 10 ** _decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function balanceOf(address account) external view returns (uint) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        address msgSender = _msgSender();
        _transfer(sender, recipient, amount);
        _approve(sender, msgSender, _allowances[sender][msgSender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        address msgSender = _msgSender();
        _approve(msgSender, spender, _allowances[msgSender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        address msgSender = _msgSender();
        _approve(msgSender, spender, _allowances[msgSender][spender] - subtractedValue);
        return true;
    }

    function mint(uint amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function burn(uint amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _mint(address account, uint amount) internal {
        require(account != address(0), "Mint to zero address");
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "Burn from zero address");
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint amount) internal {
        address msgSender = _msgSender();
        _burn(account, amount);
        _approve(account, msgSender, _allowances[account][msgSender] - amount);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
/// @author Vũ Đắc Hoàng Ân
pragma solidity ^0.8.0;

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function transfer(address to, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later
/// @author Vũ Đắc Hoàng Ân
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not owner");
        _;
    }

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}