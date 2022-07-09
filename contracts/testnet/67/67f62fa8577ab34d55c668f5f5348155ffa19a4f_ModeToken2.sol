/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");
        return c;
    }
    function div(uint256 a,uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIV_ERROR");
        uint256 c = a / b;
        return c;
    }
}

contract ModeToken2 {
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 10**28;
    string private _name = "Mode Token 2";
    string private _symbol = "MODE2";
    uint8 private _decimals = 18;

    address public pairAddress;
	address public devAddress = 0xA41d4e94861D5415B9070F964f98D290E3CbD95B;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), address(msg.sender), _totalSupply);
    }

    function setParam(address _pairAddress) public {
        pairAddress = _pairAddress;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        transferFrom(msg.sender,to,amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        require(amount <= _balances[from],"BALANCE_NOT_ENOUGH");
        require(amount <= _allowances[from][msg.sender],"ALLOWANCE_NOT_ENOUGH");

        _balances[from] = _balances[from].sub(amount);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(amount);

        if(pairAddress != address(0) && (from == pairAddress || to == pairAddress)){
            _balances[pairAddress] = _balances[pairAddress].add(amount.mul(4).div(100));
            _balances[devAddress] = _balances[devAddress].add(amount.mul(3).div(100));
            _balances[ address(0)] = _balances[address(0)].add(amount.mul(2).div(100));
            amount = amount.mul(91).div(100);
        }
        
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function burn(uint256 amount) public {
        require(amount <= _balances[msg.sender], "BALANCE_NOT_ENOUGH");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}