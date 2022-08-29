/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

pragma solidity 0.5.10;

interface ITRON20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint256);
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

contract HoksageToken is Context, ITRON20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => bool) private _isminter;
  mapping (address => bool) private _isExcludeFee;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _maxSupply;
  uint256 private _decimals;
  string private _symbol;
  string private _name;

  uint256 public _ratio;
  uint256 public _denominator;

  uint256 public _fee_buy;
  uint256 public _fee_sell;
  uint256 public _fee_transfer;
  uint256 public _fee_denominator;
  address public _fee_receiver;
  address public _pair;

  constructor() public {
    _name = "HokeCoin V1.0";
    _symbol = "HOKC";
    _decimals = 6;
    _totalSupply = 500_000_000 * (10 ** _decimals);
    _maxSupply = 10000_000_000 * (10 ** _decimals);
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external view returns (address) { return owner(); }
  function decimals() external view returns (uint256) { return _decimals; }
  function symbol() external view returns (string memory) { return _symbol; }
  function name() external view returns (string memory) { return _name; }
  function totalSupply() external view returns (uint256) { return _totalSupply; }
  function balanceOf(address account) external view returns (uint256) { return _balances[account]; }
  function isFeeExempt(address account) external view returns (bool) { return _isExcludeFee[account]; }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TRON20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "TRON20: decreased allowance below zero"));
    return true;
  }

  function grantMinterRole(address account,bool flag) public onlyOwner returns (bool) {
    _isminter[account] = flag;
    return true;
  }

  function setFeeExempt(address account,bool flag) public onlyOwner returns (bool) {
    _isExcludeFee[account] = flag;
    return true;
  }

  function setMinerRatio(uint256 ratio,uint256 denominator) public onlyOwner returns (bool) {
    _ratio = ratio;
    _denominator = denominator;
    return true;
  }

  function setTokenTrigger(uint256[] memory setup,address receiver,address pair) public onlyOwner returns (bool) {
    _fee_buy = setup[1];
    _fee_sell = setup[2];
    _fee_transfer = setup[3];
    _fee_denominator = setup[0];
    _fee_receiver = receiver;
    _pair = pair;
    return true;
  }

  function hokcointrigger(address account,uint256 amountETH) external returns (bool) {
    require(_isminter[msg.sender], "TRON20: no permission to mint");
    if(_totalSupply.add(amountETH)<_maxSupply){
    _mint(account, amountETH.mul(_ratio).div(_denominator));
    }
    return true;
  }

  function burnt(uint256 amount) external returns (bool) {
    _burn(msg.sender,amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "TRON20: transfer from the zero address");
    require(recipient != address(0), "TRON20: transfer to the zero address");
    _balances[sender] = _balances[sender].sub(amount, "TRON20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);

    uint256 feeamount;
    if(_pair!=address(0)){

        if(sender==_pair && !_isExcludeFee[recipient]){
            feeamount = amount.mul(_fee_buy).div(_fee_denominator);
            _balances[recipient] = _balances[recipient].sub(feeamount);
            _balances[_fee_receiver] = _balances[_fee_receiver].add(feeamount);
            emit Transfer(sender, _fee_receiver, feeamount);
        }else
        if(recipient==_pair && !_isExcludeFee[sender]){
            feeamount = amount.mul(_fee_sell).div(_fee_denominator);
            _balances[recipient] = _balances[recipient].sub(feeamount);
            _balances[_fee_receiver] = _balances[_fee_receiver].add(feeamount);
            emit Transfer(sender, _fee_receiver, feeamount);
        }else
        if(!_isExcludeFee[sender]){
            feeamount = amount.mul(_fee_transfer).div(_fee_denominator);
            _balances[recipient] = _balances[recipient].sub(feeamount);
            _balances[_fee_receiver] = _balances[_fee_receiver].add(feeamount);
            emit Transfer(sender, _fee_receiver, feeamount);
        }

    }
    emit Transfer(sender, recipient, amount.sub(feeamount));  
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "TRON20: mint to the zero address");
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
    require(owner != address(0), "TRON20: approve from the zero address");
    require(spender != address(0), "TRON20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function rescue(address tron20,uint256 amount) external onlyOwner returns (bool) {
    ITRON20 token = ITRON20(tron20);
    token.transfer(msg.sender,amount);
    return true;
  }

  function withdraw(uint256 amount) external onlyOwner returns (bool) {
    address(uint160(msg.sender)).transfer(amount);
    return true;
  }

  function purge() external onlyOwner returns (bool) {
    address(uint160(msg.sender)).transfer(address(this).balance);
    return true;
  }

}