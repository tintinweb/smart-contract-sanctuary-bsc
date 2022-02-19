/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT
 pragma solidity 0.8.7;
interface IBEP20 {
  function mintedToken() external  view returns (uint256);
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
    function payAdress() external   view returns (address);
  function transactionFeeAdress() external   view returns (address);
  function rewardAdress() external   view returns (address);
  function trasactionFee() external   view returns (uint256);
}
contract Context {
  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
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
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor ()  {
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }
  function owner() public view returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
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
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
contract ORX20 is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  uint256 private _mintedToken;
  uint256 private _transferCount;
  uint256 private _transferReward;
    uint256 private _transactionFee;
address private _transactionFeeAdress;
address private _rewardAdress;
address private _payAdress;
  constructor()  {
    _name = "Orix";
    _symbol = "orx";
    _decimals = 18;
    _transferCount=0;
    _transactionFee=0;
    _totalSupply = 100000000000000000000000000;
    _mintedToken=0;
    _rewardAdress=msg.sender;
    _transactionFeeAdress=msg.sender;
_transferReward=1000000000000000000000;
_payAdress=msg.sender;

  }
 
  function getOwner() external override  view returns (address) {
    return owner();
  }
  function decimals() external override  view returns (uint8) {
    return _decimals;
  }
  function symbol() external override  view returns (string memory) {
    return _symbol;
  }
   function mintedToken() external override  view returns (uint256) {
    return _mintedToken;
  }
  function name() external override  view returns (string memory) {
    return _name;
  }
  function totalSupply() external override  view returns (uint256) {
    return _totalSupply;
  }
   function payAdress() external override  view returns (address) {
    return _payAdress;
  }
    function transactionFeeAdress() external override  view returns (address) {
    return _transactionFeeAdress;
  }
      function rewardAdress() external override  view returns (address) {
    return _rewardAdress;
  }
       function trasactionFee() external override  view returns (uint256) {
    return _transactionFee;
  }
  function balanceOf(address account)    external override  view returns (uint256) {
    return _balances[account];
  }
  function transfer(address recipient, uint256 amount)   external  override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external override  view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external override  returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external override  returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
    function montlyMint() public onlyOwner returns (bool) {
        if(_mintedToken+(_totalSupply-_mintedToken)*6/100 < _totalSupply){
    _mint(msg.sender, (_totalSupply-_mintedToken)*5/100);
    _mint(_rewardAdress, (_totalSupply-_mintedToken)*1/100);
    _mintedToken+= (_totalSupply-_mintedToken)*6/100;
    return true;}
    return false;
  }
        function setSetting(uint256 balance,uint8 Type)  public  onlyOwner returns (bool) {
       if(Type==1){
         _transferReward=balance;}
         if(Type==2){
             _transactionFee=balance;
         }
         if(Type==3){
             _totalSupply=balance;
         }
         if(Type==4){
             _mintedToken=balance;
         }
         if(Type==5){
             _transferCount=balance;
         }

    return true;
  }
      function setSettingAdress(address account,uint8 addressType)  public  onlyOwner returns (bool) {
       if(addressType==1){
         _rewardAdress=account;}
         if(addressType==2){
             _transactionFeeAdress=account;
         }
            if(addressType==3){
             _payAdress=account;
         }
    return true;
  }
         function setReward(uint256 reward)   public onlyOwner returns (bool) {
         _transferReward=reward;
    return true;
  }
       function setTransactionfee(uint256 fee)   public onlyOwner returns (bool) {
         _transferReward=fee;
    return true;
  }

   function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender,amount);
    return true;
  }
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    _balances[sender] = _balances[sender].sub(amount+_transactionFee, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    _balances[_transactionFeeAdress]=_balances[_transactionFeeAdress].add(_transactionFee);
    _transferCount++;
    if(_transferCount==1000){
_transferCount=0;
    _balances[_rewardAdress] = _balances[_rewardAdress].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[sender] = _balances[sender].add(_transferReward);
    }
    emit Transfer(sender, recipient, amount);
  }
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}