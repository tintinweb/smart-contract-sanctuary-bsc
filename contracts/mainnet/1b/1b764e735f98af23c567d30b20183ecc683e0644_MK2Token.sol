/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: Mozilla
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

  constructor() {
    _transferOwnership(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(address(0));
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

abstract contract Destory is Context, Ownable {
  function destory() public onlyOwner {
    selfdestruct(payable(owner()));
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

contract ERC20 is IERC20, IERC20Metadata, Context {
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowance;

  uint256 private _totalSupply;
  string private _name;
  string private _symbol;

  constructor(string memory __name, string memory __symbol) {
    _name = __name;
    _symbol = __symbol;
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowance[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }

  function transfer(address to, uint256 amount) public virtual override returns (bool) {
    address owner = _msgSender();
    _transfer(owner, to, amount);
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
    unchecked {
      _approve(owner, spender, currentAllowance - subtractedValue);
    }
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal virtual {
    require(owner != address(0), "ERC20: approve from/owner the zero address");
    require(spender != address(0), "ERC20: approve to/spender the zero address");

    _allowance[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    require(currentAllowance >= amount, "ERC20: insufficient allowance");
    unchecked {
      _approve(owner, spender, currentAllowance - amount);
    }
  }

  function _transfer(address from, address to, uint256 amount) internal virtual {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(from, to, amount);

    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
      _balances[from] = fromBalance - amount;
      _balances[to] += amount;
    }

    emit Transfer(from, to, amount);

    _afterTokenTransfer(from, to, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;

    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount);
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
  function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

abstract contract ERC20Burnable is Context, ERC20 {
  function burn(uint256 amount) public virtual {
    _burn(_msgSender(), amount);
  }

  function burnFrom(address account, uint256 amount) public virtual {
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
  }
}

abstract contract ERC20Capped is ERC20 {
  uint256 private immutable _cap;

  constructor(uint256 __cap) {
    require(__cap > 0, "ERC20Capped: cap is 0");
    _cap = __cap;
  }

  function cap() public view virtual returns (uint256) {
    return _cap;
  }

  function _mint(address account, uint256 amount) internal virtual override {
    require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
    super._mint(account, amount);
  }
}

interface IVesting {
  function setStartTime(uint64 startTime) external returns (bool);
  function addBalance(address beneficiary, uint256 amount) external returns (bool);
  function getBalance(address beneficiary) external view returns (uint256);
  function release() external returns (bool);
  function release(address beneficiary) external returns (bool);
  function getRelease(address beneficiary) external view returns (uint256);
  function addOperationAuthority(address perm) external returns (bool);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require (c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }
}

contract MK2Token is ERC20, ERC20Capped, ERC20Burnable, Ownable, Destory {
  using SafeMath for uint256;

  uint8 private constant DECIMALS = 18;
  uint256 private constant TOTAL_SUPPLY = 2100000000 * 10 ** DECIMALS;

  address private _teamVesting;
  address private _fluidityVesting;
  address private _o2eVesting;
  address private _p2eVesting;
  address private _marketVesting;
  address private _adviserVesting;
  address private _idoVesting;

  bool _isDistributeToken;

  constructor() ERC20("MakeMake Token", "MK2") ERC20Capped(TOTAL_SUPPLY) {
  }

  receive() external payable virtual {}

  function decimals() public pure override returns (uint8) {
    return DECIMALS;
  }

  function distributeToken(
      address __teamVesting,
      address __fluidityVesting, 
      address __o2eVesting, 
      address __p2eVesting, 
      address __marketVesting, 
      address __adviserVesting, 
      address __idoVesting) public onlyOwner {
    require(!_isDistributeToken, "MK2Token: DistributeToken already distribute");
    require(__teamVesting != address(0), "MK2Token: DistributeToken teamVesting is zero");
    require(__fluidityVesting != address(0), "MK2Token: DistributeToken fluidityVesting is zero");
    require(__o2eVesting != address(0), "MK2Token: DistributeToken o2eVesting is zero");
    require(__p2eVesting != address(0), "MK2Token: DistributeToken p2eVesting is zero");
    require(__marketVesting != address(0), "MK2Token: DistributeToken marketVesting is zero");
    require(__adviserVesting != address(0), "MK2Token: DistributeToken adviserVesting is zero");
    require(__idoVesting != address(0), "MK2Token: DistributeToken idoVesting is zero");

    uint256 teamAmount = TOTAL_SUPPLY.mul(175).div(1000);                     // 17.5%
    uint256 fluidityAmount = TOTAL_SUPPLY.mul(25).div(1000);                  // 2.5%
    uint256 o2eAmount = TOTAL_SUPPLY.mul(30).div(100);                        // 30%
    uint256 p2eAmount = TOTAL_SUPPLY.mul(30).div(100);                        // 30%
    uint256 marketAmount = TOTAL_SUPPLY.mul(10).div(100);                     // 10%
    uint256 adviserAmount = TOTAL_SUPPLY.mul(5).div(100);                     // 5%
    uint256 idoAmount = TOTAL_SUPPLY.mul(5).div(100);                         // 5%

    _teamVesting = __teamVesting;
    ERC20._mint(_teamVesting, teamAmount);

    _fluidityVesting = __fluidityVesting;
    ERC20._mint(_fluidityVesting, fluidityAmount);

    _o2eVesting = __o2eVesting;
    ERC20._mint(_o2eVesting, o2eAmount);

    _p2eVesting = __p2eVesting;
    ERC20._mint(_p2eVesting, p2eAmount);

    _marketVesting = __marketVesting;
    ERC20._mint(_marketVesting, marketAmount);

    _adviserVesting = __adviserVesting;
    ERC20._mint(_adviserVesting, adviserAmount);

    _idoVesting = __idoVesting;
    ERC20._mint(_idoVesting, idoAmount);

    _isDistributeToken = true;
  }

  function release() public onlyOwner {
    require(_isDistributeToken, "MK2Token: release is not distribute");
    IVesting(_teamVesting).release();
    IVesting(_fluidityVesting).release();
    IVesting(_o2eVesting).release();
    IVesting(_p2eVesting).release();
    IVesting(_marketVesting).release();
    IVesting(_adviserVesting).release();
    IVesting(_idoVesting).release();
  }

  function teamVesting() public view returns (address) {
    return _teamVesting;
  }

  function fluidityVesting() public view returns (address) {
    return _fluidityVesting;
  }

  function o2eVesting() public view returns (address) {
    return _o2eVesting;
  }

  function p2eVesting() public view returns (address) {
    return _p2eVesting;
  }

  function marketVesting() public view returns (address) {
    return _marketVesting;
  }

  function adviserVesting() public view returns (address) {
    return _adviserVesting;
  }

  function idoVesting() public view returns (address) {
    return _idoVesting;
  }
  
  function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
    super._mint(account, amount);
  }
}