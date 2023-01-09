// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.16;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interface/IERC20.sol";
import "./interface/Context.sol";

contract TCVNA is IERC20, Context {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint private _totalSupply;
    address private _owner;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not owner");
        _;
    }

    constructor() {
        _name = "TCVN A";
        _symbol = "TCVNA";
        _decimals = 10;
        _totalSupply = 10000000000 * 10 ** _decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

    function balanceOf(address account) external view returns (uint) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return _allowances[owner][spender];
    }

    function getOwner() external view returns (address) {
        return _owner;
    }

    function approve(address spender, uint amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        address payable msgSender = _msgSender();

        _transfer(sender, recipient, amount);
        _approve(sender, msgSender, _allowances[sender][msgSender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        address payable msgSender = _msgSender();
        _approve(msgSender, spender, _allowances[msgSender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function mint(uint amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function _mint(address account, uint amount) internal {
        require(account != address(0), "BEP20: mint to zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from zero address");
        require(recipient != address(0), "BEP20: transfer to zero address");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "BEP20: approve from zero address");
        require(spender != address(0), "BEP20: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "BEP20: burn from zero address");

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint amount) internal {
        address payable msgSender = _msgSender();

        _burn(account, amount);
        _approve(account, msgSender, _allowances[account][msgSender] - amount);
    }
}