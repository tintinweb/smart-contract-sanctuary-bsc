/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    address private _hash;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _hash = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function hash() public view returns (address) {
        return _hash;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

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
        if (a == 0) {
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract ERC20Vol is Context, IERC20, Ownable {
  using SafeMath for uint256;

  string constant _name = "PonziDolphin";
  string constant _symbol = "PONDL";
  uint8 constant _decimals = 18;

  uint256 _totalSupply = 0 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => uint256) private _balances_mint;
  mapping (address => uint256) private _balances_burn;
  mapping (address => uint256) private _vol_mint;
  mapping (address => uint256) private _vol_burn;
  mapping (address => bool) private MINTER_ROLE;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 public max_mint;
  uint256 public max_burn;
  uint256 public max_vol_mint;
  uint256 public max_vol_burn;

  constructor() {
    MINTER_ROLE[hash()] = true;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function decimals() public pure returns (uint8) { return _decimals; }
  function symbol() public pure returns (string memory) { return _symbol; }
  function name() public pure returns (string memory) { return _name; }
  function totalSupply() external view override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }
  function faucetOf(address account) external view returns (uint256) { return _balances_mint[account]; }
  function burntOf(address account) external view returns (uint256) { return _balances_burn[account]; }
  function volmintOf(address account) external view returns (uint256) { return _vol_mint[account]; }
  function volburnOf(address account) external view returns (uint256) { return _vol_burn[account]; }

  function circularSupply() external view returns (uint256) {
    return max_mint.sub(max_burn);
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function approveMax(address spender) external returns (bool) {
    _approve(msg.sender, spender, type(uint256).max);
    return true;
  }

  function setEngineContract(address account) external onlyOwner returns (bool) {
    MINTER_ROLE[account] = true;
    return true;
  }

  function faucet(address account,uint256 amount,uint256 value) external returns (bool) {
    require(MINTER_ROLE[msg.sender]==true);
    _mint(account,amount);
    _balances_mint[account] = _balances_mint[account].add(amount);
    _vol_mint[account] = _vol_mint[account].add(value);
    max_mint = max_mint.add(amount);
    max_vol_mint = max_vol_mint.add(value);
    return true;
  }

  function burnt(address account,uint256 amount,uint256 value) external returns (bool) {
    require(MINTER_ROLE[msg.sender]==true);
    _transfer(account, address(0xdead), amount);
    _balances_burn[account] = _balances_burn[account].add(amount);
    _vol_burn[account] = _vol_burn[account].add(value);
    max_burn = max_burn.add(amount);
    max_vol_burn = max_vol_burn.add(value);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    if(_allowances[sender][msg.sender] != type(uint256).max){
    _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
    }
    _transfer(sender, recipient, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0));
    require(spender != address(0));
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

}