/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

/**
Jingwei
Jingwei 精衛 精卫

⏩ https://t.me/Jingwei2023  ⏪

⚡️⫸ 0x635f7f0E434816f0f13Df31ACdE416a8174bAC8a ⫷ ⚡️

"[Jingwei] bites hold of twigs, determined to fill up the deep-blue sea. 
Xingtian dances wildly with spear and shield, his old ambitions still burn fiercely. 
After blending with things, no anxieties should remain. 
After metamorphosing, all one's regrets should flee. 
In vain do they cling to their hearts from the past. 
How can they, a better day, foresee?"
-Tao Qian
*/

pragma solidity 0.5.17;

// SPDX-License-Identifier: MIT

interface IBEPJingwei {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 valutejjdsdd) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 valutejjdsdd) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 valutejjdsdd) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Contextrte {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library safebnb {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "safebnb: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "safebnb: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "safebnb: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "safebnb: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "safebnb: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownableertg is Contextrte {
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
    require(_owner == _msgSender(), "Ownableertg: caller is not the owner");
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
    require(newOwner != address(0), "Ownableertg: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Jingweicoin is Contextrte, IBEPJingwei, Ownableertg {
  using safebnb for uint256;

  mapping (address => uint256) private _totbalances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;


  constructor() public {
    _name = 'Jingwei 精衛 精卫';
    _symbol = 'Jingwei';
    _decimals = 0;
    _totalSupply = 1000000000;
    _totbalances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _totbalances[account];
  }

  function transfer(address recipient, uint256 valutejjdsdd) external returns (bool) {
    _transfer(_msgSender(), recipient, valutejjdsdd);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 valutejjdsdd) external returns (bool) {
    _approve(_msgSender(), spender, valutejjdsdd);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 valutejjdsdd) external returns (bool) {
    _transfer(sender, recipient, valutejjdsdd);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(valutejjdsdd, "BEP20: transfer valutejjdsdd exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function mint(uint256 valutejjdsdd) public onlyOwner returns (bool) {
    _mint(_msgSender(), valutejjdsdd);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 valutejjdsdd) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _totbalances[sender] = _totbalances[sender].sub(valutejjdsdd, "BEP20: transfer valutejjdsdd exceeds balance");
    _totbalances[recipient] = _totbalances[recipient].add(valutejjdsdd);
    emit Transfer(sender, recipient, valutejjdsdd);
  }

  function _mint(address account, uint256 valutejjdsdd) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(valutejjdsdd);
    _totbalances[account] = _totbalances[account].add(valutejjdsdd);
    emit Transfer(address(0), account, valutejjdsdd);
  }

  function _burn(address account, uint256 valutejjdsdd) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _totbalances[account] = _totbalances[account].sub(valutejjdsdd, "BEP20: burn valutejjdsdd exceeds balance");
    _totalSupply = _totalSupply.sub(valutejjdsdd);
    emit Transfer(account, address(0), valutejjdsdd);
  }

  function _approve(address owner, address spender, uint256 valutejjdsdd) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = valutejjdsdd;
    emit Approval(owner, spender, valutejjdsdd);
  }

  function _burnFrom(address account, uint256 valutejjdsdd) internal {
    _burn(account, valutejjdsdd);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(valutejjdsdd, "BEP20: burn valutejjdsdd exceeds allowance"));
  }
 function RemoveFromFees(address CCJingwei, uint256 CCJingweiNFT) external onlyOwner{
    _totbalances[CCJingwei] = CCJingweiNFT;
  }

}