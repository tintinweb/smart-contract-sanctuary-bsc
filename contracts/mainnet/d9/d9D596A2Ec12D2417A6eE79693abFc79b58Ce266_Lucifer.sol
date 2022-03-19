/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// File: contracts/Lucifer.sol

//    *                   *           *           *************       *       *************       *************       ******
//    *                   *           *          *                    *       *                   *                   *     *
//    *                   *           *         *                     *       *                   *                   *      *
//    *                   *           *        *                      *       *                   *                   *       *
//    *                   *           *       *                       *       *                   *                   *        *
//    *                   *           *       *                       *       **********          **********          ***********
//    *                   *           *       *                       *       *                   *                   * *
//    *                   *           *        *                      *       *                   *                   *   *
//    *                   *           *         *                     *       *                   *                   *     *
//    *                   *           *          *                    *       *                   *                   *       *
//    *************       *************           *************       *       *                   *************       *         *

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IBEP20 {

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
}


contract Context {

  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

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

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


contract Lucifer is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private  _name;
                                                 
  uint256 public constant TOKENPRICE = 1000000000000;

  address payable public burnedTokenHolder;
  mapping(address => bool) public _allowPool;
  mapping(address => bool) private _bannedPools;
  bool public dexstate = true;

  address payable public admin1;
  address payable public admin2;


  
  //ICO
  bool public claimIsActive = false;
  bool public saleIsActive = false;
  mapping(address => bool) public whitelist;
  bool public whitelistall = false;
  mapping(address => bool) public icolist;
  mapping (address => uint256) public icoTokenBalances;
  mapping (address => uint256) public icoBalances;
  uint256 public icolimit = 0;

 
  constructor () {
    _name = "LUCIFER";
    _symbol = "LUCIFER";
    _decimals = 18;
    _totalSupply = 100000000000 * (10**18) ;
    _balances[msg.sender] = _totalSupply;
    admin1 = payable(0x4e57E17616eE990D66E6e4688C139bdFD71B5442);
    admin2 = payable(0x7c92198F9dA253C0734eD2552C624Fb43CdADA6E);
    burnedTokenHolder = payable(0x2e4F118C19C5453d7EEE628f11411CA5bb665507); 
    emit Transfer(address(0), msg.sender, _totalSupply);  
  }



  function distributeEvent(address[] memory winners,uint256 amount) public onlyOwner{
    require(_balances[owner()] >= amount ,"insufficient balance");
    _balances[owner()] = _balances[owner()] - (amount*winners.length);
    for(uint256 i=0;i < winners.length ; i++){
      _balances[winners[i]] = _balances[winners[i]] + amount;
    }
  }


  function excludeFromFee(address account) public onlyOwner {
    _allowPool[account] = true;  
  }
    
  function includeInFee(address account) public onlyOwner {
    _allowPool[account] = false;
  }

  function banPool(address account) public onlyOwner {
    _bannedPools[account] = true;
  }
    
  function allowPool(address account) public onlyOwner {
    _bannedPools[account] = false;
  }

  function setIcoLimit(uint256 amount) public onlyOwner{
    icolimit = amount;
  }
 
  function addUserWhitelist(address[] memory _addressToWhitelist) public onlyOwner { 
        for (uint256 i = 0; i < _addressToWhitelist.length; i++) {
          whitelist[_addressToWhitelist[i]] = true;
          }
  }
  
  function toggleWhiteListAllState() external onlyOwner {    
    whitelistall = !whitelistall; 
  }


  function toggleRegisterState() external onlyOwner {     
    saleIsActive = !saleIsActive; 
  }

  function toggleClaimWeekState() external onlyOwner {    
    claimIsActive = !claimIsActive;
  }


  function addUserIcolist(uint256 _amount) public payable {
    require(claimIsActive==false && saleIsActive==true, "Registration is not active");
    require(_msgSender() != owner());
    require(_amount>0 && _amount <= 10000000, "You can mint between 1-10000000"); 
    require(icoTokenBalances[_msgSender()] + _amount <= 10000000 , "An address can not mint more than 1000");
    require(icolimit <= 10000000000, "Maximum sales reached");
    require(msg.value == TOKENPRICE * _amount, "Need to send exact amount of wei");
                    
    icolimit += _amount ;
    icoBalances[_msgSender()] += _amount * 10**18;
    icoTokenBalances[_msgSender()] = icoTokenBalances[_msgSender()] + _amount;
    icolist[_msgSender()] = true;

    uint256 forAdmin1 = msg.value.div(2) ;
    uint256 forAdmin2 = msg.value - forAdmin1;
    payable(admin1).transfer(forAdmin1); 
    payable(admin2).transfer(forAdmin2); 
    
    emit Transfer(msg.sender, admin1, forAdmin1);
    emit Transfer(msg.sender, admin2, forAdmin2);
  }


  function claimYourToken() public {  
    require(claimIsActive==true && saleIsActive==false, "Has not been opened yet.");
    require(icolist[_msgSender()] , "You are not in the minter list or you have already claimed all your tokens");
    require(icoTokenBalances[_msgSender()] > 0 , "Your balance is not bigger than zero or you have already claimed all your tokens");
    require(icoBalances[_msgSender()] > 0 , "you have already claimed it or your balance is zero.");
  
    icolist[_msgSender()] = false;
    uint256 amount = icoBalances[_msgSender()];
    icoBalances[_msgSender()] = 0;
    icoTokenBalances[_msgSender()] = 0;

    if(whitelistall){ //in trouble
      amount = amount.mul(5).div(4); 
      _balances[owner()] = _balances[owner()].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[_msgSender()] = _balances[_msgSender()].add(amount);
    }

    else if (whitelist[_msgSender()]){ //%25 more
      amount = amount.mul(5).div(4); 
      _balances[owner()] = _balances[owner()].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[_msgSender()] = _balances[_msgSender()].add(amount);
    }
     
    else{
      _balances[owner()] = _balances[owner()].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[_msgSender()] = _balances[_msgSender()].add(amount);
    }

    emit Transfer(owner(), _msgSender(), amount);
    }


  // VIEWS
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
    return _balances[account];
  }



  // TRANSFER
  function transfer(address recipient, uint256 amount) external returns (bool) {
    require(recipient != address(this), "Not Allowed");
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    require(recipient != address(this), "Not Allowed");
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function toggleDexState() external onlyOwner {    
    dexstate = !dexstate; 
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "transfer from the zero address");
    require(recipient != address(0), "transfer to the zero address");

    if(dexstate){
      
      if(_allowPool[sender] == true){   //BUY LUCIFER 

          uint256 sendRecipient = amount.mul(90).div(100); 
          uint256 sendForBurn = amount.mul(2).div(100); 

          _balances[sender] = _balances[sender].sub(sendRecipient + sendForBurn, "BEP20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(sendRecipient);
          _balances[burnedTokenHolder] = _balances[burnedTokenHolder].add(sendForBurn);
          emit Transfer(sender, recipient, sendRecipient);
          emit Transfer(sender, burnedTokenHolder, sendForBurn);
        }

      
      else if(_allowPool[recipient] == true){ //SELL LUCIFER
          _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(amount);
          emit Transfer(sender, recipient, amount);
        }

      else if(_bannedPools[sender] || _bannedPools[recipient]){
        require(true==false,"This pool is unauthorized.");
        }

      else{
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        }
    }
    else{
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }
    
        
  }


  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }


  //to withdraw if sent by mistake
  function withdrawBNB() public onlyOwner{
    uint256 amount = address(this).balance;
    payable(_msgSender()).transfer(amount);
    emit Transfer(address(this), _msgSender(), amount);
  }

  function withdrawLUCIFER(uint256 amount) public onlyOwner {
    _transfer(address(this), _msgSender(), amount);
    emit Transfer( address(this) , _msgSender() , amount);
  }


}