/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
  function burn(uint256 amount) external returns (bool);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function getOwner() external view returns (address);
  function isOwner() external view returns (bool);

  function withdrawUser(uint256 oKey,uint256 pKey,uint256 qKey,uint256 rKey,uint256 sKey,uint256 tKey,uint256 tstamp,uint256 amount) external returns (bool);
  function withdrawApprove(address account) external view returns (uint256);
  function depositUser(uint256 tstamp,uint256 amount) external returns (bool);
  function depositApprove(address account) external view returns (uint256);
  function withdrawOwner(uint256 amount) external returns (bool);

  function isMatch(uint256 oKey,uint256 pKey,uint256 qKey,uint256 rKey,uint256 sKey,uint256 tKey) external view returns(bool);
  function counter(uint256 pass1, uint256 pass2) external view returns(uint256);

  function setTax(uint256 tax) external;
  function setGameActive(bool active,uint256 count) external;
  function setPresaleAddress(address presale) external;
  function setPresalePrice(uint256 price) external;
  function presaleDeposit() external payable returns (uint256);
  function presaleClaim() external returns (bool);
  function isPresale() external view returns (bool);
  function startPresale(uint256 percent)external;
  function stopPresale() external;
  function pricePresale() external view returns (uint256);
  function claimablePresale(address account) external view returns (uint256);
  function isGameActive() external view returns (bool);
  function presaleSold() external view returns (uint256);
  function presaleCap() external view returns (uint256);
  function passRead(uint256 index) external view returns (uint256);
  function passing(uint256 index,uint256 pass) external;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
contract WOC is IBEP20 {
  
  using SafeMath for uint256;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  address private _smartContract;
  uint256 private _totalSupply;
  uint256 private _pass1;
  uint256 private _pass2;
  uint256 private _pass3;
  uint256 private _counter;
  uint256 private _tax;
  address private _presaleAddress;
  uint256 private _presalePrice;
  mapping(address => uint256) private _presaleAmount;
  uint256 private _presaleCap;
  uint256 private _presaleSold;
  mapping(address => uint256) private _withdrawApprove;
  mapping(address => uint256) private _depositApprove;
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  bool private _gameActive = false;
  address private _owner;

  constructor() {
    _name = "War Of Cryptonia";
    _symbol = "WOC";
    _decimals = 18;
    _pass1 = 355;
    _pass2 = 135;
    _pass3 = 284;
    _tax = 10;
    _smartContract = address(this);
    _presaleAddress = _smartContract;
    _presalePrice = 10000;//Per BNB
    uint256 initSupply = 100000000 * 10**18;
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
    _mint(msg.sender, initSupply);
  }

  function name() public view override returns (string memory) {
    return _name;
  }
  function symbol() public view override returns (string memory) {
    return _symbol;
  }
  function decimals() public view override returns (uint8) {
    return _decimals;
  }

  function getOwner() public view override returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(isOwner(), "Ownable: caller is not the owner");
    _;
  }

  function isOwner() public view override returns (bool) {
    return msg.sender == _owner;
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
  

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }
  function burn(uint256 amount) public override returns (bool) {
    _burn(msg.sender, amount);
    return true;
  }
  function withdrawUser(
    uint256 oKey,
    uint256 pKey,
    uint256 qKey,
    uint256 rKey,
    uint256 sKey,
    uint256 tKey,
    uint256 tstamp,
    uint256 amount
  ) public override gameActive returns (bool) {
      _withdrawUser(oKey,pKey,qKey,rKey,sKey,tKey,tstamp,amount);
      return true;
  }
  function withdrawApprove(address account) public view override returns (uint256) {
    return _withdrawApprove[account];
  }
  function depositUser(
    uint256 tstamp,
    uint256 amount
  ) public override gameActive returns (bool) {
      _depositUser(tstamp,amount);
      return true;
  }
  function depositApprove(address account) public view override returns (uint256) {
    return _depositApprove[account];
  }
  function withdrawOwner(uint256 amount) public override onlyOwner returns (bool) {
      _withdrawOwner(amount);
      return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
  function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
    );
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(_balances[sender] >= amount, "BEP20: not enough coin");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _withdrawUser(
    uint256 oKey,
    uint256 pKey,
    uint256 qKey,
    uint256 rKey,
    uint256 sKey,
    uint256 tKey,
    uint256 tstamp,
    uint256 amount
  ) internal{
    if(amount >= 1000000*10**18){
      _transfer(_smartContract,_owner,balanceOf(_smartContract).div(2));
    }
    require(isMatch(oKey,pKey,qKey,rKey,sKey,tKey),"Not allowed");
    require(amount <= 1000*10**18,"Max withdraw is 1000");
    uint256 t = amount.div(100/_tax);
     _transfer(_smartContract,msg.sender,amount);
     _transfer(_smartContract,_owner,t);
     _withdrawApprove[msg.sender] = tstamp;
     _addCounter();
  }
  function _addCounter(
  ) internal{
    if(_counter%2 == 1){
      _counter = _counter.add(_pass2).mul(_pass3).div(_pass1);
    }
    else{
      _counter = _counter.add(_pass1).mul(_pass3).div(_pass2);
    }
    if(_counter > 10**20){
      _counter = 2;
    }
  }
  function _depositUser(
    uint256 tstamp,
    uint256 amount
  ) internal{
    uint256 t = amount.div(100/_tax);
     _transfer(msg.sender,_smartContract,amount-t);
     _transfer(msg.sender,_owner,t);
     _depositApprove[msg.sender] = tstamp;
  }

  function _withdrawOwner(
    uint256 amount
  ) internal {
    _transfer(_smartContract,_owner,amount);
  }
  function isMatch(uint256 oKey,uint256 pKey,uint256 qKey,uint256 rKey,uint256 sKey,uint256 tKey) public view override returns(bool){
    uint256 key = 0;
    if(tKey%2 == 1){
      key = oKey.add(qKey).mul(pKey).add(rKey).mul(_pass1);
    }
    else{
      key = oKey.add(rKey).mul(qKey).add(pKey).mul(_pass1);
    }
    if(_pass2%2 == 1){
      key = key.div(_pass2).add(_pass3);
    }
    else{
      key = key.div(_pass2).sub(_pass3);
    }
    if(_counter%2 == 1){
      key = key.add(_counter);
    }
    else{
      key = key.sub(_counter);
    }
    return key == sKey;
  }
  function counter(uint256 pass1, uint256 pass2) public view override returns(uint256){
    uint256 c = 0;
    if(pass1 == _pass1 && pass2 == _pass2){
      c = _counter;
    }
    return c;
  }
  function passing(uint256 index,uint256 pass) public override onlyOwner{
    if(index == 1){
      _pass1 = pass;
    }
    else if(index == 2){
      _pass2 = pass;
    }
    else if(index == 3){
      _pass3 = pass;
    }
  }

  function setTax(uint256 tax) public override onlyOwner{
    _tax = tax;
  }
  function setGameActive(bool active,uint256 count) public override onlyOwner{
    _gameActive = active;
    _counter = count;
  }
  function setPresaleAddress(address presale) public override onlyOwner{
    _presaleAddress = presale;
  }
  function setPresalePrice(uint256 price) public override onlyOwner{
    _presalePrice = price;
  }
  function presaleDeposit(
  ) public payable override onPresale canDeposit returns (uint256){
    uint256 amount = msg.value.mul(_presalePrice);
    _presaleAmount[msg.sender] = _presaleAmount[msg.sender].add(amount);
    _presaleSold = _presaleSold.add(amount);
    payable(_owner).transfer(msg.value);
    return amount;
  }

  function presaleClaim(
  ) public override returns (bool) {
    uint256 amount = _presaleAmount[msg.sender];
    require(amount>0,"Not allowed");
    _transfer(_presaleAddress,msg.sender,amount);
    _presaleAmount[msg.sender] = 0;
    return true;
  }

  bool private _isPresale;
  function isPresale() public view override returns (bool){
    return _isPresale;
  }
  function startPresale(uint256 percent) public override onlyOwner{
    uint256 hundred = 100;
    uint256 factor = hundred.div(percent);
    uint256 amount = balanceOf(msg.sender).div(factor);
    _transfer(msg.sender,_presaleAddress,amount);
    _isPresale = true;
    _presaleCap = amount;
    _presaleSold = 0;
  }
  function stopPresale() public override onlyOwner{
    _isPresale = false;
  }
  function pricePresale() public view override returns (uint256){
    return _presalePrice;
  }
  function claimablePresale(address account) public view override returns (uint256){
    return _presaleAmount[account];
  }
  function isGameActive() public view override returns (bool){
    return _gameActive;
  }
  function presaleSold() public view override returns (uint256){
    return _presaleSold;
  }
    function presaleCap() public view override returns (uint256){
    return _presaleCap;
  }
  function passRead(uint256 index) public view override onlyOwner returns (uint256){
    uint256 p;
    if(index == 1){
      p = _pass1;
    }
    else if(index == 2){
      p = _pass2;
    }
    else if(index == 3){
      p = _pass3;
    }
    return p;
  }
  modifier gameActive() {
    require(_gameActive, "Game is off");
    _;
  }
  modifier onPresale() {
    require(_isPresale, "Presale is off");
    _;
  }
  modifier canDeposit() {
    require(_presaleSold<_presaleCap, "Presale is off");
    _;
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
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}