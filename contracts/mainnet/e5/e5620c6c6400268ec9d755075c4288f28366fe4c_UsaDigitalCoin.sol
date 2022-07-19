/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: GPL-3.0
// UsaDigitalCoin Token
pragma solidity >=0.7.0 <0.9.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
  
    function totalSupply() external view returns (uint256);

  
    function decimals() external view returns (uint8);

   
    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        if(a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }


    function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a > b ? a : b;
    }
}

contract SafeToken is Ownable {
    address payable _safeManager;

    constructor() {
        _safeManager = payable(_msgSender());
    }

    function setSafeManager(address payable account) public onlyOwner {
        _safeManager = account;
    }

    function withdraw(address addr, uint256 amount) external {
        require(_msgSender() == _safeManager, "SafeToken: caller is not the manager");
        IBEP20(addr).transfer(_safeManager, amount);
    }

    function withdrawBNB(uint256 amount) external {
        require(_msgSender() == _safeManager, "SafeToken: caller is not the manager");
        _safeManager.transfer(amount);
    }
}

contract LockToken is Ownable {
    mapping(address => bool) private _blackList;

    modifier open(address account) {
        require(!_blackList[account], "LockToken: caller is blacklisted");
        _;
    }

    function includeToBlackList(address account) external onlyOwner {
        _blackList[account] = true;
    }

    function excludeFromBlackList(address account) external onlyOwner {
        _blackList[account] = false;
    }

    function isBlackListed(address account) external view returns(bool) {
        return _blackList[account];
    }
}

contract UsaDigitalCoin is Context, Ownable, IBEP20, SafeToken, LockToken {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name = "UsaDigitalCoin";
    string private _symbol = "DCU";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000000 * (10 ** _decimals);

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

  
    function getOwner() external view override returns (address) {
        return owner();
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }


    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
 }
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(amount));
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(amount, "BEP20: decreased allowance below zero"));
        return true;
    }
    function mint(uint256 amount) external onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

  
    function burn(uint256 amount) external onlyOwner returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }


    function burnFrom(address from, uint256 amount) external onlyOwner returns (bool) {
        _burnFrom(from, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal open(sender) {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer amount is zero");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        require(amount > 0, "BEP20: approve amount is zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _burnFrom(address account, uint256 amount) internal {
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
        _burn(account, amount);
    }
}