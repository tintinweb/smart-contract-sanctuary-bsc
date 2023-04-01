/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

//SPDX-License-Identifier: UNLICENSED

 pragma solidity ^0.8.7;


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
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint);

  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);

  function transfer(address to, uint value) external returns (bool);

  function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IToken is IERC20 {
  function name() external override view returns (string memory);

  function symbol() external  override view returns (string memory);

  function decimals() external  override view returns (uint256);

  function totalSupply() external  override view returns (uint256);

  function balanceOf(address account) external  override view returns (uint256);

  function allowance(address owner, address spender) external  override view returns (uint256);

  function transfer(address recipient, uint256 amount) external  override returns (bool);

  function approve(address spender, uint256 amount) external override  returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external  override returns (bool);

  function burn(uint256 amount) external returns(bool);

  function setStaking(address staking_) external;

  function mintForStake(address to, uint256 amount) external;

  function withdrawNative(address payable account, uint256 amount) external;

  function withdrawTokens(address account, uint256 amount) external;

  function setNativeRate(uint256 rate) external;

  function setERC20Rate(address token, uint256 rate) external;

  function buyNative() external payable;

  function buyERC20(address token, uint256 amount) external;
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
      require(b <= a, errorMessage);
      uint256 c = a - b;
      return c;
    }
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a / b;
    }
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a % b;
    }
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
}

contract Zephyr is IToken, Ownable {
  using SafeMath for uint256;
  using Address for address;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  string private _name = "Zephyr";
  string private _symbol = "ZPR";

  uint256 private _decimals = 9;
  uint256 private _totalSupply = 12_000_000 * 10 ** _decimals;

  uint256 public nativeRate = 3 * 10 ** 14; 

  mapping(address => uint256) public erc20Rate;

  address public staking;

  constructor() {
    _balances[address(this)] = _totalSupply;
    erc20Rate[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 5 * 10 ** 17; // 0.5 busd per token
  }

  modifier onlyStaking() {
    require(_msgSender() == staking);
    _;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function decimals() external view override returns (uint256) {
    return _decimals;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
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

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: insufficient allowance"));
    return true;
  }

  function burn(uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), address(0), amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _tokenTransfer(address sender, address recipient, uint256 amount) internal {
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
    _tokenTransfer(sender, recipient, amount);
  }

  function setStaking(address staking_) external override onlyOwner {
    require(staking == address(0), "Staking contract already installed");
    staking = staking_;
  }

  function mintForStake(address to, uint256 amount) external override onlyStaking {
    _balances[to] = _balances[to].add(amount);
    _totalSupply = _totalSupply.add(amount);
  }

  function withdrawNative(address payable account, uint256 amount) public override onlyOwner {
    Address.sendValue(account, amount);
  }

  function withdrawTokens(address account, uint256 amount) public override onlyOwner {
    _transfer(address(this), account, amount);
  }

  function setNativeRate(uint256 rate) external override onlyOwner {
    nativeRate = rate;
  }

  function setERC20Rate(address token, uint256 rate) external override onlyOwner {
    erc20Rate[token] = rate;
  }

  function buyNative() external payable override {
    require(msg.value > 0, "Zero buy");
    _tokenTransfer(address(this), _msgSender(), ((msg.value).mul(10000).div(nativeRate) * 10 ** _decimals).div(10000));
  }

  function buyERC20(address token, uint256 amount) external override {
    require(erc20Rate[token] > 0, "Bad token");
    uint256 price = amount.mul(erc20Rate[token]).div(10 ** _decimals);
    require(IERC20(token).balanceOf(_msgSender()) >= price, "Bad balance for buy");
    IERC20(token).transferFrom(_msgSender(), address(this), price);
    _tokenTransfer(address(this), _msgSender(), amount);
  }
}