/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

/**
 *Submitted for verification at Etherscan.io on 2022-12-03
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


interface IFilm {
    function getId() external view returns (uint256);
    function getPrice() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function setDiscount(string calldata uid, uint256 price) external returns (bool);
    function getDiscount(string calldata uid) external view returns (uint256);
    function setBooking(string calldata cinema, string calldata room, string calldata position, uint256 timestamp) external returns (bool);
    function getBooking(string calldata room, string calldata position, uint256 timestamp) external view returns (address);
    function getOwner() external view returns(address);
}

interface IERC20{
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed owner, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Buy(address indexed film, address indexed buyer, string cinema, string room, string position, uint256 timestamp, uint256 price);
    event Cancel(address indexed film, address indexed buyer, string cinema, string room, string position, uint256 timestamp, uint256 price);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function mint(uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function buy(address film, string calldata cinema, string calldata room, string calldata position, uint256 timestamp, uint256 fee) external returns (bool);
    function cancel(address film, string calldata cinema, string calldata room, string calldata position, uint256 timestamp, uint256 fee) external returns (bool);
}

contract VND is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 _decimals;

    constructor() {
        _name = "VND";
        _symbol = "VND";
        _totalSupply = 1000000000000000;
        _balances[msg.sender] = _totalSupply;
        _decimals = 0;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function mint(uint256 amount) public virtual override returns (bool) {
        _mint(msg.sender, amount);
        emit Mint(msg.sender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function buy(address film, string calldata cinema, string calldata room, string calldata position, uint256 timestamp, uint256 fee) public virtual override returns (bool) {
        address current = IFilm(film).getBooking(room, position, timestamp);
        require(current == address(0), "Position not available");
        uint256 price = IFilm(film).getPrice() + fee;
        require(_balances[msg.sender] > price, "Balance not available");
        address owner = IFilm(film).getOwner();
        _transfer(msg.sender, owner, price);
        IFilm(film).setBooking(cinema, room, position, timestamp);
        emit Buy(film, msg.sender, cinema, room, position, timestamp, price);
        return true;
    }

    function cancel(address film, string calldata cinema, string calldata room, string calldata position, uint256 timestamp, uint256 fee) public virtual override returns (bool) {
        address current = IFilm(film).getBooking(room, position, timestamp);
        require(current != address(0), "Position available, not need cancel");
        uint256 price = IFilm(film).getPrice() + fee;
        require(_balances[msg.sender] > price, "Balance admin not available. You need mint request !!");
        address owner = IFilm(film).getOwner();
        _transfer(owner, msg.sender, price);
        emit Cancel(film, msg.sender, cinema, room, position, timestamp, price);
        return true;
    }

    function _transfer(address from,address to,uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}